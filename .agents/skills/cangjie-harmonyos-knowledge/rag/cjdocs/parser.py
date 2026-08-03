from __future__ import annotations

import re
from dataclasses import dataclass, field
from pathlib import Path

from .util import make_anchor, norm_text, read_text_lossless, relative_posix, sha256_bytes


HEADING_RE = re.compile(r"^(#{1,6})\s+(.+?)\s*$")
FENCE_RE = re.compile(r"^```(.*)$")
LINK_RE = re.compile(r"\[([^\]]+)\]\(([^)]+)\)")
SYMBOL_HEADING_RE = re.compile(
    r"^(?:static\s+)?(?P<kind>func|class|interface|enum|struct|var|let|prop|init|operator|macro|extend)\b\s*(?P<rest>.*)$",
    re.IGNORECASE,
)
# ArkUI 组件文档的 H1 是裸 PascalCase（# Text / # Refresh / # Column）— 不带 kind 前缀，
# 旧正则漏抽导致 symbol 命令对 83 个组件全部落空/误导（2026-07-05 审计）
COMPONENT_H1_RE = re.compile(r"^[A-Z][A-Za-z0-9]{1,40}$")
IMPORT_RE = re.compile(r"^\s*import\s+([A-Za-z0-9_.*{}.,\s]+)")


@dataclass(slots=True)
class CodeBlock:
    language: str
    code: str
    start_line: int
    end_line: int
    imports: list[str] = field(default_factory=list)


@dataclass(slots=True)
class Link:
    text: str
    target: str
    line: int


@dataclass(slots=True)
class Section:
    title: str
    level: int
    breadcrumb: str
    anchor: str
    start_line: int
    end_line: int
    body: str
    kind: str
    parent_symbol: str | None = None
    code_blocks: list[CodeBlock] = field(default_factory=list)
    links: list[Link] = field(default_factory=list)

    @property
    def ref_suffix(self) -> str:
        return f"#{self.anchor}" if self.anchor else ""


@dataclass(slots=True)
class ParsedDocument:
    path: Path
    rel_path: str
    doc_type: str
    kit: str
    title: str
    encoding: str
    digest: str
    size: int
    sections: list[Section]


def detect_doc_type(rel_path: str) -> str:
    parts = Path(rel_path).parts
    if len(parts) >= 2 and parts[0].lower() == "docs":
        return parts[1].lower()
    return "unknown"


def detect_kit(rel_path: str) -> str:
    parts = Path(rel_path).parts
    if len(parts) >= 3 and parts[0].lower() == "docs":
        return parts[2]
    if len(parts) >= 2:
        return parts[1]
    return ""


def classify_section(doc_type: str, level: int, title: str) -> tuple[str, str | None]:
    match = SYMBOL_HEADING_RE.match(norm_text(title))
    if doc_type == "api" and match:
        kind = match.group("kind").lower()
        return kind, None
    if title.lower().startswith("示例") or title.lower().startswith("example"):
        return "example-section", None
    if doc_type == "guide":
        return "guide", None
    return "section", None


def clip_to_balanced_paren(rest: str) -> str:
    """截到与首个 '(' 配对的右括号，保留完整重载签名。

    init/operator 标题形如 `init(?ResourceStr, ?ResourceStr)`，旧逻辑用
    `rest.split()[0]` 会把成员名截断成 `init (?ResourceStr,`（2026-07 审计）。
    """
    open_idx = rest.find("(")
    if open_idx < 0:
        return rest.split()[0]
    depth = 0
    for i in range(open_idx, len(rest)):
        ch = rest[i]
        if ch == "(":
            depth += 1
        elif ch == ")":
            depth -= 1
            if depth == 0:
                return rest[: i + 1].strip()
    return rest.strip()


def extract_symbol_name(title: str) -> tuple[str | None, str | None]:
    title = norm_text(title).strip("`")
    match = SYMBOL_HEADING_RE.match(title)
    if not match:
        return None, None
    kind = match.group("kind").lower()
    # markdown 标题里的转义反斜杠（如 `class ForEach\<T>`）不属于符号名，
    # 旧逻辑在 `<` 处切分后会留下尾反斜杠（`ForEach\`），先整体去掉。
    rest = match.group("rest").strip().replace("\\", "")
    if kind in {"init", "operator"}:
        name = kind
        if rest:
            name = f"{kind} {clip_to_balanced_paren(rest)}"
        return kind, name
    token = re.split(r"[\s(<:{]", rest, maxsplit=1)[0].strip()
    token = token.strip("`")
    return kind, token or None


def parse_markdown(path: Path, root: Path) -> ParsedDocument:
    data = path.read_bytes()
    text, encoding = read_text_lossless(path)
    rel_path = relative_posix(path, root)
    doc_type = detect_doc_type(rel_path)
    kit = detect_kit(rel_path)
    lines = text.splitlines()
    anchors: dict[str, int] = {}
    headings: list[tuple[int, int, str, str]] = []
    for idx, line in enumerate(lines, 1):
        match = HEADING_RE.match(line)
        if match:
            level = len(match.group(1))
            title = norm_text(match.group(2))
            headings.append((idx, level, title, make_anchor(title, anchors)))
    if not headings:
        headings.append((1, 1, path.stem, make_anchor(path.stem, anchors)))

    doc_title = headings[0][2]
    sections: list[Section] = []
    stack: list[tuple[int, str]] = []
    for pos, (start, level, title, anchor) in enumerate(headings):
        end = headings[pos + 1][0] - 1 if pos + 1 < len(headings) else len(lines)
        while stack and stack[-1][0] >= level:
            stack.pop()
        stack.append((level, title))
        breadcrumb = " > ".join(item[1] for item in stack)
        body = "\n".join(lines[start:end])
        kind, parent_symbol = classify_section(doc_type, level, title)
        sections.append(
            Section(
                title=title,
                level=level,
                breadcrumb=breadcrumb,
                anchor=anchor,
                start_line=start,
                end_line=end,
                body=body,
                kind=kind,
                parent_symbol=parent_symbol,
                code_blocks=[],
                links=[],
            )
        )

    attach_blocks_and_links(lines, sections)
    attach_parent_symbols(sections)
    return ParsedDocument(
        path=path,
        rel_path=rel_path,
        doc_type=doc_type,
        kit=kit,
        title=doc_title,
        encoding=encoding,
        digest=sha256_bytes(data),
        size=len(data),
        sections=sections,
    )


def attach_parent_symbols(sections: list[Section]) -> None:
    symbol_stack: list[tuple[int, str]] = []
    for section in sections:
        kind, name = extract_symbol_name(section.title)
        if not kind and section.level == 1 and section.kind == "section":
            bare = section.title.strip().strip("`")
            if COMPONENT_H1_RE.match(bare):
                kind, name = "component", bare
        if kind and name and section.level <= 2:
            symbol_stack = [(section.level, name)]
            continue
        while symbol_stack and symbol_stack[-1][0] >= section.level:
            symbol_stack.pop()
        if section.kind in {"func", "class", "interface", "enum", "struct", "var", "prop", "init", "operator", "extend"}:
            if symbol_stack:
                section.parent_symbol = symbol_stack[-1][1]
        if kind and name:
            symbol_stack.append((section.level, name))


def attach_blocks_and_links(lines: list[str], sections: list[Section]) -> None:
    section_iter = iter(sections)
    current = next(section_iter, None)
    next_section = next(section_iter, None)
    in_fence = False
    fence_lang = ""
    fence_start = 0
    fence_lines: list[str] = []

    def advance(line_no: int) -> Section | None:
        nonlocal current, next_section
        while next_section and line_no >= next_section.start_line:
            current = next_section
            next_section = next(section_iter, None)
        return current

    for idx, line in enumerate(lines, 1):
        sec = advance(idx)
        fence = FENCE_RE.match(line)
        # 链接抽取带 in_fence 守卫：code fence 内的 `[x](y)` 是示例代码而非文档链接，
        # 旧逻辑无此守卫，把 fence 内文本当链接入库造成虚断链（2026-07 审计）。
        if sec and not in_fence and not fence:
            for match in LINK_RE.finditer(line):
                sec.links.append(Link(text=match.group(1), target=match.group(2), line=idx))
        if fence:
            if in_fence:
                code = "\n".join(fence_lines)
                imports = [m.group(1).strip() for m in map(IMPORT_RE.match, fence_lines) if m]
                target = sec or current
                if target:
                    target.code_blocks.append(
                        CodeBlock(
                            language=fence_lang.strip().lower(),
                            code=code,
                            start_line=fence_start,
                            end_line=idx,
                            imports=imports,
                        )
                    )
                in_fence = False
                fence_lines = []
            else:
                in_fence = True
                fence_lang = fence.group(1).strip()
                fence_start = idx
                fence_lines = []
            continue
        if in_fence:
            fence_lines.append(line)
