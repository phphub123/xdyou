package ohos_app_cangjie_entry.components

import kit.ArkUI.*
import kit.ArkWeb.*
import ohos.arkui.state_macro_manage.*
import ohos.business_exception.*
import std.sync.*
import std.time.*

// Reuses the authenticated ArkWeb cookie jar to finish service-specific SSO.
// Short-lived authorization values and cookies remain memory-only.
@Component
public class ServiceAuthWeb {
    let url: String
    let cookieUrl: String
    let stableId: String
    let onReady: (String, String, String) -> Unit
    let onFailure: (String) -> Unit
    let controller: WebviewController = WebviewController()
    let cookiesEnabled: Unit = WebCookieManager.setAcceptCookiesEnabled(true)
    var completed: Bool = false
    var inspectAttempts: Int64 = 0

    var inspectTimer: ?Timer = None

    protected override func aboutToAppear(): Unit {
        this.inspectTimer = Some(Timer.repeat(Duration.second * 3, Duration.second * 3, { => launch { this.inspect(true) }}))
    }
    protected override func aboutToDisappear(): Unit {
        match (this.inspectTimer) { case Some(timer) => timer.cancel(); case None => () }
        this.inspectTimer = None
    }

    func inspect(allowCookieFallback: Bool): Unit {
        if (this.completed) { return }
        if (allowCookieFallback) { this.inspectAttempts += 1 }
        try {
            let currentUrl = this.controller.getUrl()
            let script = """
(() => {
  const safe = (fn) => { try { return String(fn() || ''); } catch (_) { return ''; } };
  const href = safe(() => location.href);
  const input = safe(() => {
    const node = document.querySelector('#openid, input[name=openid]');
    return node ? node.value : '';
  });
  const jwt = safe(() => {
    const url = new URL(location.href);
    const hit = (location.hash || '').match(/[?&]jwt=([^&]+)/);
    return url.searchParams.get('jwt') || (hit ? hit[1] : '') ||
      localStorage.getItem('jwt') || sessionStorage.getItem('jwt') || '';
  });
  const group = safe(() => localStorage.getItem('groupCode') || sessionStorage.getItem('groupCode') || '');
  const code = safe(() => new URL(location.href).searchParams.get('code') || '');
  return ['XDYOU_AUTH', href, 'code=' + code, 'openid=' + input, 'jwt=' + jwt, 'groupCode=' + group].join('|');
})()
"""
            let callback: AsyncCallback<String> = {
                error: ?BusinessException, data: ?String => launch {
                    match (error) {
                        case Some(value) => this.onFailure("业务认证页面检查失败：${value.code} ${value.message}")
                        case None => match (data) {
                            case Some(raw) =>
                                let value = raw.trimAscii().replace("\"", "")
                                if (value.startsWith("XDYOU_AUTH|")) {
                                    let tokenReady = !value.contains("|code=|") || !value.contains("|openid=|") || !value.contains("|jwt=|")
                                    let cookieFallbackReady = allowCookieFallback && this.inspectAttempts >= 4
                                    if (!tokenReady && !cookieFallbackReady) { return }
                                    let idsCookies = WebCookieManager.fetchCookie("https://ids.xidian.edu.cn/authserver/login")
                                    let serviceCookies = WebCookieManager.fetchCookie(this.cookieUrl)
                                    let cookies = if (idsCookies == "") { serviceCookies }
                                        else if (serviceCookies == "") { idsCookies }
                                        else { idsCookies + "; " + serviceCookies }
                                    this.completed = true
                                    match (this.inspectTimer) { case Some(timer) => timer.cancel(); case None => () }
                                    this.onReady(currentUrl, value, cookies)
                                }
                            case None => ()
                        }
                    }
                }
            }
            this.controller.runJavaScript(script, callback)
        } catch (error: BusinessException) {
            this.onFailure("业务认证页面不可用：${error.code} ${error.message}")
        }
    }

    func build() {
        Web(src: this.url, controller: this.controller)
            .domStorageAccess(true)
            .onlineImageAccess(true)
            .onPageEnd({_ => launch { this.inspect(false) }})
            .width(1.vp)
            .height(1.vp)
            .opacity(0.01)
            .id(this.stableId)
    }
}
