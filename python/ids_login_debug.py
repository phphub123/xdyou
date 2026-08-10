#!/usr/bin/env python3
"""Reproduce the Traintime PDA IDS password-login flow for diagnostics.

Install dependencies:
    python3 -m pip install -r python/requirements.txt

Run interactively, or inject credentials without putting the password in argv:
    IDS_USERNAME=... IDS_PASSWORD=... python3 python/ids_login_debug.py

The response body is printed with authentication tokens redacted. Cookies,
passwords, CAPTCHA keys, and reusable service tickets are never printed.
"""

from __future__ import annotations

import argparse
import base64
import getpass
import io
import json
import math
import os
import random
import re
import secrets
import sys
import time
from dataclasses import dataclass
from typing import Any, Sequence
from urllib.parse import parse_qsl, urlencode, urljoin, urlsplit, urlunsplit

import requests
from bs4 import BeautifulSoup
from cryptography.hazmat.primitives import padding
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from PIL import Image


IDS_ORIGIN = "https://ids.xidian.edu.cn"
LOGIN_ENDPOINT = f"{IDS_ORIGIN}/authserver/login"
FINGERPRINT_ENDPOINT = f"{IDS_ORIGIN}/authserver/bfp/info"
CAPTCHA_OPEN_ENDPOINT = (
    f"{IDS_ORIGIN}/authserver/common/openSliderCaptcha.htl"
)
CAPTCHA_VERIFY_ENDPOINT = (
    f"{IDS_ORIGIN}/authserver/common/verifySliderCaptcha.htl"
)
REAUTH_TYPE_ENDPOINT = (
    f"{IDS_ORIGIN}/authserver/reAuthCheck/changeReAuthType.do"
)
REAUTH_SMS_ENDPOINT = (
    f"{IDS_ORIGIN}/authserver/dynamicCode/getDynamicCodeByReauth.do"
)
REAUTH_SUBMIT_ENDPOINT = (
    f"{IDS_ORIGIN}/authserver/reAuthCheck/reAuthSubmit.do"
)
USER_AGENT = (
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) "
    "AppleWebKit/537.36 (KHTML, like Gecko) "
    "Chrome/130.0.0.0 Safari/537.36"
)
PASSWORD_PREFIX = b"xidianscriptsxdu" * 4
PASSWORD_IV = b"xidianscriptsxdu"
CAPTCHA_CHARS = "ABCDEFGHJKMNPQRSTWXYZabcdefhijkmnprstwxyz2345678"
SENSITIVE_FIELD_NAMES = {
    "password",
    "pwdencryptsalt",
    "lt",
    "execution",
    "ticket",
    "dynamiccode",
    "authorization",
    "bfp",
    "sign",
    "uuid",
}


class LoginDiagnosticError(RuntimeError):
    """Raised when the IDS protocol cannot be reproduced safely."""


@dataclass(frozen=True)
class TrackPoint:
    a: int
    b: int
    c: int

    def as_dict(self) -> dict[str, int]:
        return {"a": self.a, "b": self.b, "c": self.c}


def _aes_cbc_base64(plaintext: bytes, key: bytes, iv: bytes) -> str:
    if len(key) not in (16, 24, 32):
        raise LoginDiagnosticError(
            f"IDS 返回了不支持的 AES 密钥长度：{len(key)} 字节"
        )
    padder = padding.PKCS7(algorithms.AES.block_size).padder()
    padded = padder.update(plaintext) + padder.finalize()
    encryptor = Cipher(algorithms.AES(key), modes.CBC(iv)).encryptor()
    encrypted = encryptor.update(padded) + encryptor.finalize()
    return base64.b64encode(encrypted).decode("ascii")


def encrypt_password(password: str, salt: str) -> str:
    """Match IDSSession.aesEncrypt in ids_session.dart."""
    return _aes_cbc_base64(
        PASSWORD_PREFIX + password.encode("utf-8"),
        salt.encode("utf-8"),
        PASSWORD_IV,
    )


def encrypt_captcha_payload(payload: str, key: bytes) -> str:
    """Match NetworkClient.aesEncrypt used by the Dart CAPTCHA client."""
    random_text = "".join(secrets.choice(CAPTCHA_CHARS) for _ in range(80))
    return _aes_cbc_base64(
        random_text[:64].encode("ascii") + payload.encode("utf-8"),
        key,
        random_text[64:].encode("ascii"),
    )


def generate_fingerprint() -> str:
    return secrets.token_hex(16).upper()


def hidden_fields(html: str) -> dict[str, str]:
    soup = BeautifulSoup(html, "html.parser")
    fields: dict[str, str] = {}
    for element in soup.find_all("input", attrs={"type": "hidden"}):
        name = element.get("name") or element.get("id")
        value = element.get("value")
        if name and value is not None:
            fields[str(name)] = str(value)
    return fields


def _image_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    rgba = image.convert("RGBA")
    opaque_points = [
        (x, y)
        for y in range(rgba.height)
        for x in range(rgba.width)
        if rgba.getpixel((x, y))[3] == 255
    ]
    if not opaque_points:
        raise LoginDiagnosticError("滑块小图中没有可识别的不透明区域")
    xs, ys = zip(*opaque_points)
    return min(xs), min(ys), max(xs), max(ys)


def solve_offset(
    puzzle_data: bytes,
    piece_data: bytes,
    *,
    border: int = 24,
) -> float:
    """Port the normalized cross-correlation solver from Dart."""
    try:
        puzzle = Image.open(io.BytesIO(puzzle_data)).convert("L")
        piece = Image.open(io.BytesIO(piece_data)).convert("RGBA")
    except Exception as error:
        raise LoginDiagnosticError("滑块图片无法解码") from error

    x_left, y_top, x_right, y_bottom = _image_bbox(piece)
    x_left += border
    y_top += border
    x_right -= border
    y_bottom -= border
    window_width = x_right - x_left + 1
    window_height = y_bottom - y_top + 1
    if window_width <= 0 or window_height <= 0:
        raise LoginDiagnosticError("滑块模板在裁边后为空")

    piece_luma = piece.convert("L")
    template_values = [
        piece_luma.getpixel((x, y))
        for y in range(y_top, y_top + window_height)
        for x in range(x_left, x_left + window_width)
    ]
    template_mean = sum(template_values) / len(template_values)
    template = [value - template_mean for value in template_values]

    big_width = puzzle.width - piece.width + window_width
    candidate_count = big_width - window_width
    if candidate_count <= 0:
        raise LoginDiagnosticError("滑块图片尺寸不符合预期")

    best_x = 0
    best_score = -math.inf
    for candidate_x in range(candidate_count):
        values = [
            puzzle.getpixel((candidate_x + x_left + x, y_top + y))
            for y in range(window_height)
            for x in range(window_width)
        ]
        mean = sum(values) / len(values)
        centered = [value - mean for value in values]
        numerator = sum(a * b for a, b in zip(centered, template))
        denominator = sum(value * value for value in centered) + 0.000001
        score = numerator / denominator
        if score > best_score:
            best_score = score
            best_x = candidate_x
    return best_x / puzzle.width


def generate_tracks(offset: int) -> list[TrackPoint]:
    tracks = [TrackPoint(0, 0, 0)]
    count = random.randint(10, 14)
    vertical = 0
    normalization = 1.0 / (1.0 + math.exp(-7.0 * (1.0 - 0.42)))
    for index in range(count):
        curve = (
            1.0 / (1.0 + math.exp(-7.0 * ((index / count) - 0.42)))
        ) / normalization
        horizontal = min(offset - 1, max(tracks[-1].a + 1, round(offset * curve)))
        choice = random.random()
        if choice < 0.65:
            vertical -= 1
        elif choice < 0.80:
            vertical += 1
        vertical = max(-10, min(10, vertical))
        tracks.append(TrackPoint(horizontal, vertical, random.randint(300, 500)))
    tracks.append(TrackPoint(offset, vertical, random.randint(300, 500)))
    return tracks


def _mask_phone(value: str) -> str:
    digits = re.sub(r"\D", "", value)
    if len(digits) < 7:
        return "****"
    return f"{digits[:3]}****{digits[-4:]}"


def _safe_message(value: Any, fallback: str) -> str:
    message = str(value or fallback)
    return re.sub(
        r"\b1\d{10}\b",
        lambda match: _mask_phone(match.group(0)),
        message,
    )


def _json_object(response: requests.Response, context: str) -> dict[str, Any]:
    try:
        value = response.json()
    except requests.JSONDecodeError as error:
        raise LoginDiagnosticError(f"{context}没有返回有效 JSON") from error
    if not isinstance(value, dict):
        raise LoginDiagnosticError(f"{context}返回的 JSON 不是对象")
    return value


def solve_slider_captcha(
    session: requests.Session,
    timeout: float,
    *,
    attempts: int = 6,
) -> None:
    for attempt in range(1, attempts + 1):
        opened = session.get(
            CAPTCHA_OPEN_ENDPOINT,
            params={"_": str(int(time.time() * 1000))},
            timeout=timeout,
            allow_redirects=False,
        )
        opened.raise_for_status()
        captcha = _json_object(opened, "滑块接口")
        try:
            puzzle_data = base64.b64decode(captcha["bigImage"], validate=True)
            piece_data = base64.b64decode(captcha["smallImage"], validate=True)
        except (KeyError, TypeError, ValueError) as error:
            raise LoginDiagnosticError("滑块接口缺少有效的图片数据") from error
        if len(piece_data) < 16:
            raise LoginDiagnosticError("滑块小图中缺少验证密钥")

        estimated = round(solve_offset(puzzle_data, piece_data) * 280)
        for delta in (1, -1, 2, -2, 3, -3, 4):
            move = estimated + delta
            if not 0 <= move <= 280:
                continue
            tracks = generate_tracks(move)
            time.sleep(max(tracks[-1].c - 100, 0) / 1000)
            payload = json.dumps(
                {
                    "canvasLength": 280,
                    "moveLength": move,
                    "tracks": [point.as_dict() for point in tracks],
                },
                ensure_ascii=False,
                separators=(",", ":"),
            )
            sign = encrypt_captcha_payload(payload, piece_data[-16:])
            verified = session.post(
                CAPTCHA_VERIFY_ENDPOINT,
                data={"sign": sign},
                headers={
                    "Accept": "application/json, text/javascript, */*; q=0.01",
                    "Origin": IDS_ORIGIN,
                    "X-Requested-With": "XMLHttpRequest",
                },
                timeout=timeout,
                allow_redirects=False,
            )
            verified.raise_for_status()
            result = _json_object(verified, "滑块验证接口")
            if result.get("errorCode") == 1:
                print(f"滑块验证成功（第 {attempt} 轮）")
                return
    raise LoginDiagnosticError("滑块验证码自动验证失败")


def redact_url(value: str) -> str:
    parsed = urlsplit(urljoin(IDS_ORIGIN, value))
    query = []
    for key, item in parse_qsl(parsed.query, keep_blank_values=True):
        if key.lower() in SENSITIVE_FIELD_NAMES or item.startswith("ST-"):
            item = "<redacted>"
        query.append((key, item))
    return urlunsplit(
        (parsed.scheme, parsed.netloc, parsed.path, urlencode(query), parsed.fragment)
    )


def sanitize_body(body: str) -> str:
    """Redact common CAS/IDS credentials while preserving diagnostic HTML."""
    sanitized = re.sub(
        r"(?i)(ticket=)(ST-[^&\s\"'<>]+)",
        r"\1<redacted>",
        body,
    )
    sanitized = re.sub(
        r"(?i)(\b(?:1\d{2})\d{4}(\d{4})\b)",
        r"***MASKED***\2",
        sanitized,
    )
    soup = BeautifulSoup(sanitized, "html.parser")
    for element in soup.find_all("input"):
        name = str(element.get("name") or element.get("id") or "").lower()
        if name in SENSITIVE_FIELD_NAMES and element.has_attr("value"):
            element["value"] = "<redacted>"
    for element in soup.find_all("script"):
        text = element.string
        if text:
            for field in SENSITIVE_FIELD_NAMES:
                text = re.sub(
                    rf"(?i)([\"']?{re.escape(field)}[\"']?\s*[:=]\s*[\"'])[^\"']*",
                    r"\1<redacted>",
                    text,
                )
            element.string = text
    return str(soup)


def response_kind(response: requests.Response, service_requested: bool) -> str:
    location = response.headers.get("Location")
    if response.status_code in (301, 302) and location:
        uri = urlsplit(urljoin(IDS_ORIGIN, location))
        if uri.path == "/authserver/reAuthCheck/reAuthLoginView.do":
            return "需要短信二次认证（账号密码阶段已通过）"
        ticket = dict(parse_qsl(uri.query)).get("ticket")
        if service_requested and ticket and ticket.startswith("ST-"):
            return "登录成功，收到业务系统 service ticket"
        if not service_requested and uri.path == "/authserver/index.do":
            return "登录成功，跳转到 IDS 首页"
        return "收到未识别的登录重定向"
    if response.status_code == 401:
        return "认证失败（HTTP 401，通常为账号或密码错误）"
    soup = BeautifulSoup(response.text, "html.parser")
    if soup.find("form", id="continue") is not None:
        return "需要提交 continue 表单"
    error = soup.find(id="showErrorTip")
    if error and error.get_text(strip=True):
        return f"登录失败：{error.get_text(' ', strip=True)}"
    return "登录接口返回非重定向响应"


def print_response(response: requests.Response, service_requested: bool) -> None:
    print("\n===== IDS 登录 POST 响应（敏感信息已脱敏）=====")
    print(f"状态码: {response.status_code}")
    print(f"Content-Type: {response.headers.get('Content-Type', '<none>')}")
    print(f"响应体字节数: {len(response.content)}")
    print(f"结果判断: {response_kind(response, service_requested)}")
    location = response.headers.get("Location")
    if location:
        print(f"Location: {redact_url(location)}")
    print("----- 响应正文 -----")
    if response.content:
        print(sanitize_body(response.text))
    else:
        print("<empty body>")
    print("===== 响应结束 =====")


def continue_response(
    session: requests.Session,
    response: requests.Response,
    timeout: float,
) -> requests.Response | None:
    soup = BeautifulSoup(response.text, "html.parser")
    form = soup.find("form", id="continue")
    if form is None:
        return None
    fields = {
        str(element.get("name")): str(element.get("value"))
        for element in form.find_all("input")
        if element.get("name") is not None and element.get("value") is not None
    }
    action = urljoin(response.url, str(form.get("action") or LOGIN_ENDPOINT))
    return session.post(
        action,
        data=fields,
        timeout=timeout,
        allow_redirects=False,
    )


def _reauthentication_location(response: requests.Response) -> str | None:
    location = response.headers.get("Location")
    if response.status_code not in (301, 302) or not location:
        return None
    absolute = urljoin(IDS_ORIGIN, location)
    if urlsplit(absolute).path != "/authserver/reAuthCheck/reAuthLoginView.do":
        return None
    return absolute


def register_fingerprint(
    session: requests.Session,
    fingerprint: str,
    timeout: float,
) -> None:
    response = session.get(
        FINGERPRINT_ENDPOINT,
        params={"bfp": fingerprint, "_": str(int(time.time() * 1000))},
        timeout=timeout,
        allow_redirects=False,
    )
    response.raise_for_status()


def complete_sms_reauthentication(
    session: requests.Session,
    challenge_location: str,
    *,
    username: str,
    service: str | None,
    fingerprint: str,
    timeout: float,
    trust_device: bool,
    code_attempts: int,
) -> requests.Response:
    """Complete the same SMS reauthentication flow as IDSReAuthClient."""
    challenge_uri = urlsplit(challenge_location)
    multifactor = dict(parse_qsl(challenge_uri.query)).get(
        "isMultifactor", "true"
    )

    print("\n正在准备短信二次认证……")
    challenge = session.get(
        challenge_location,
        timeout=timeout,
        allow_redirects=False,
    )
    if challenge.status_code != 200:
        raise LoginDiagnosticError(
            f"二次认证页面已失效（HTTP {challenge.status_code}）"
        )
    register_fingerprint(session, fingerprint, timeout)

    selected = session.post(
        REAUTH_TYPE_ENDPOINT,
        data={
            "isMultifactor": multifactor,
            "reAuthType": "3",
            "service": service or "",
        },
        timeout=timeout,
        allow_redirects=False,
    )
    selected.raise_for_status()
    selected_json = _json_object(selected, "切换短信二次认证接口")
    if str(selected_json.get("code")) != "1":
        raise LoginDiagnosticError(
            _safe_message(selected_json.get("message"), "无法切换到短信二次认证")
        )

    recipient: str | None = None
    selected_data = selected_json.get("data")
    if isinstance(selected_data, dict):
        value = selected_data.get("reAuthUserNameInput")
        if value:
            recipient = _mask_phone(str(value))
    if recipient:
        print(f"短信接收号码: {recipient}")

    print("正在发送短信验证码……")
    sent = session.post(
        REAUTH_SMS_ENDPOINT,
        data={
            "userName": username,
            "authCodeTypeName": "reAuthDynamicCodeType",
        },
        timeout=timeout,
        allow_redirects=False,
    )
    sent.raise_for_status()
    sent_json = _json_object(sent, "短信验证码接口")
    send_result = str(sent_json.get("res") or "")
    if send_result not in {"success", "code_time_fail"}:
        raise LoginDiagnosticError(
            _safe_message(sent_json.get("returnMessage"), "短信验证码发送失败")
        )

    message = _safe_message(sent_json.get("returnMessage"), "验证码已发送")
    raw_seconds = sent_json.get("codeTime")
    try:
        retry_after = max(0, int(str(raw_seconds)))
    except (TypeError, ValueError):
        retry_after = 0
    mobile = sent_json.get("mobile")
    mobile_hint = _mask_phone(str(mobile)) if mobile else recipient
    suffix = f"（{mobile_hint}）" if mobile_hint else ""
    print(f"{message}{suffix}")
    if retry_after:
        print(f"{retry_after} 秒后可重新发送；本脚本不会自动重复发送。")

    for attempt in range(1, code_attempts + 1):
        code = getpass.getpass("短信验证码: ").strip()
        if not code:
            print("验证码不能为空。", file=sys.stderr)
            continue
        submitted = session.post(
            REAUTH_SUBMIT_ENDPOINT,
            data={
                "service": service or "",
                "reAuthType": "3",
                "isMultifactor": multifactor,
                "password": "",
                "dynamicCode": code,
                "uuid": "",
                "answer1": "",
                "answer2": "",
                "otpCode": "",
                "skipTmpReAuth": str(trust_device).lower(),
            },
            timeout=timeout,
            allow_redirects=False,
        )
        submitted.raise_for_status()
        submit_json = _json_object(submitted, "二次认证提交接口")
        status = str(submit_json.get("code") or "")
        submit_message = _safe_message(submit_json.get("msg"), "二次认证失败")
        print(
            f"二次认证提交响应: HTTP {submitted.status_code}, "
            f"状态={status or '<missing>'}, 消息={submit_message}"
        )
        if status == "reAuth_success":
            break
        if status == "reAuth_unauthorized":
            raise LoginDiagnosticError(submit_message)
        if status != "reAuth_failed":
            raise LoginDiagnosticError("统一认证返回了未知的二次认证状态")
        if attempt == code_attempts:
            raise LoginDiagnosticError(
                f"短信验证码连续 {code_attempts} 次未通过"
            )
        print(f"验证码未通过，还可尝试 {code_attempts - attempt} 次。")
    else:
        raise LoginDiagnosticError("未提交有效的短信验证码")

    print("短信二次认证成功，正在获取最终登录跳转……")
    final = session.get(
        LOGIN_ENDPOINT,
        params={"service": service} if service else None,
        timeout=timeout,
        allow_redirects=False,
    )
    return final


def login(
    username: str,
    password: str,
    *,
    service: str | None,
    timeout: float,
    captcha_attempts: int,
    trust_device: bool,
    code_attempts: int,
) -> int:
    session = requests.Session()
    session.headers.update({"User-Agent": USER_AGENT})
    params = {"service": service} if service else None

    print("正在请求 IDS 登录页……")
    initial = session.get(
        LOGIN_ENDPOINT,
        params=params,
        timeout=timeout,
        allow_redirects=False,
    )
    initial.raise_for_status()
    if initial.status_code in (301, 302):
        print_response(initial, service is not None)
        return 0

    fields = hidden_fields(initial.text)
    required = ("pwdEncryptSalt", "lt", "execution")
    missing = [name for name in required if name not in fields]
    if missing:
        raise LoginDiagnosticError(
            "登录页缺少隐藏字段：" + ", ".join(missing)
        )

    fingerprint = generate_fingerprint()
    register_fingerprint(session, fingerprint, timeout)

    print("正在验证滑块验证码……")
    solve_slider_captcha(session, timeout, attempts=captcha_attempts)

    form = {
        "username": username,
        "password": encrypt_password(password, fields["pwdEncryptSalt"]),
        "rememberMe": "true",
        "cllt": "userNameLogin",
        "dllt": "generalLogin",
        "_eventId": "submit",
        "lt": fields["lt"],
        "execution": fields["execution"],
    }
    print("正在提交账号密码……")
    response = session.post(
        LOGIN_ENDPOINT,
        params=params,
        data=form,
        timeout=timeout,
        allow_redirects=False,
    )
    print_response(response, service is not None)

    continued = continue_response(session, response, timeout)
    if continued is not None:
        print("\n已按应用逻辑提交 continue 表单。")
        print_response(continued, service is not None)
        response = continued

    challenge_location = _reauthentication_location(response)
    if challenge_location is not None:
        response = complete_sms_reauthentication(
            session,
            challenge_location,
            username=username,
            service=service,
            fingerprint=fingerprint,
            timeout=timeout,
            trust_device=trust_device,
            code_attempts=code_attempts,
        )
        print_response(response, service is not None)
        if _reauthentication_location(response) is not None:
            raise LoginDiagnosticError("二次认证完成后仍被要求重新认证")

    kind = response_kind(response, service is not None)
    return 0 if "登录成功" in kind else 1


def positive_float(value: str) -> float:
    parsed = float(value)
    if not math.isfinite(parsed) or parsed <= 0:
        raise argparse.ArgumentTypeError("必须是大于 0 的有限数值")
    return parsed


def positive_int(value: str) -> int:
    parsed = int(value)
    if parsed <= 0:
        raise argparse.ArgumentTypeError("必须是大于 0 的整数")
    return parsed


def build_parser() -> argparse.ArgumentParser:
    parser = argparse.ArgumentParser(
        description="复现 Traintime PDA 的西电 IDS 账密登录并打印脱敏响应。"
    )
    parser.add_argument(
        "--service",
        default=os.environ.get("IDS_SERVICE"),
        help="可选业务系统 service URL；也可通过 IDS_SERVICE 设置",
    )
    parser.add_argument(
        "--timeout",
        type=positive_float,
        default=30.0,
        help="单次网络请求超时秒数（默认 30）",
    )
    parser.add_argument(
        "--captcha-attempts",
        type=positive_int,
        default=6,
        help="滑块图片刷新轮数（默认 6）",
    )
    parser.add_argument(
        "--code-attempts",
        type=positive_int,
        default=3,
        help="短信验证码最多提交次数（默认 3）",
    )
    parser.add_argument(
        "--trust-device",
        action="store_true",
        help="二次认证成功后信任当前设备；默认不信任",
    )
    return parser


def main(argv: Sequence[str] | None = None) -> int:
    args = build_parser().parse_args(argv)
    username = os.environ.get("IDS_USERNAME") or input("IDS 账号: ").strip()
    password = os.environ.get("IDS_PASSWORD") or getpass.getpass("IDS 密码: ")
    if not username or not password:
        print("账号和密码不能为空。", file=sys.stderr)
        return 2
    try:
        return login(
            username,
            password,
            service=args.service,
            timeout=args.timeout,
            captcha_attempts=args.captcha_attempts,
            trust_device=args.trust_device,
            code_attempts=args.code_attempts,
        )
    except (LoginDiagnosticError, requests.RequestException) as error:
        print(f"诊断失败: {error}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
