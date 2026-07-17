"""
Development dashboard generator for hdatools.
Produces plans/dashboard/dashboard.html from real repo data.
Stdlib only. Python 3.10+.
"""

from __future__ import annotations

import argparse
import dataclasses
import html
import json
import os
import re
import subprocess
import sys
import tempfile
from datetime import datetime
from pathlib import Path
from typing import Any

# ---------------------------------------------------------------------------
# Top-level constants
# ---------------------------------------------------------------------------

ROOT = Path(__file__).resolve().parents[2]   # repo root
PLANS = ROOT / "plans"
CACHE = Path(__file__).parent / "gh-cache.json"
OUT = Path(__file__).parent / "dashboard.html"

MODERNIZATION_SHA = "5963754"
LEGACY_BRANCHES = {"jtk", "jtk-repeat-pal", "category-colors",
                   "showtext-knitr-fix", "release-0.2.0"}

# ---------------------------------------------------------------------------
# Subprocess helper
# ---------------------------------------------------------------------------

def run(args: list[str], cwd: Path = ROOT, timeout: int = 15) -> str:
    """Run a subprocess; return stdout. Raises on nonzero exit."""
    result = subprocess.run(
        args,
        cwd=str(cwd),
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=timeout,
    )
    if result.returncode != 0:
        raise RuntimeError(
            f"{args[0]} exited {result.returncode}: {result.stderr.strip()}"
        )
    return result.stdout

# ---------------------------------------------------------------------------
# Fail-soft section carrier
# ---------------------------------------------------------------------------

@dataclasses.dataclass
class Section:
    name: str
    data: Any | None
    warnings: list[str]


def run_section(name: str, fn, *args) -> Section:
    """Call fn(*args); wrap any exception as a Section with data=None."""
    try:
        data, warnings = fn(*args)
        return Section(name, data, warnings)
    except Exception as exc:
        return Section(name, None, [f"{name} failed: {type(exc).__name__}: {exc}"])

# ---------------------------------------------------------------------------
# Markdown helpers
# ---------------------------------------------------------------------------

def parse_pipe_table(lines: list[str]) -> tuple[list[str], list[list[str]], list[str]]:
    """
    Parse a minimal pipe table. Returns (headers, rows, warnings).
    Tolerant: pads/truncates ragged rows with a warning per occurrence.
    """
    warnings: list[str] = []
    table_lines = [l for l in lines if l.strip().startswith("|")]
    if not table_lines:
        return [], [], ["no pipe table found"]

    def split_row(line: str) -> list[str]:
        parts = line.strip().strip("|").split("|")
        return [p.strip() for p in parts]

    # First row = headers
    headers = split_row(table_lines[0])
    ncols = len(headers)

    rows: list[list[str]] = []
    for raw in table_lines[1:]:
        cells = split_row(raw)
        # Skip delimiter rows (all dashes/colons)
        if all(re.fullmatch(r"[-: ]+", c) for c in cells if c):
            continue
        if len(cells) < ncols:
            warnings.append(
                f"row has {len(cells)} cells, expected {ncols}; padded with empty"
            )
            cells += [""] * (ncols - len(cells))
        elif len(cells) > ncols:
            warnings.append(
                f"row has {len(cells)} cells, expected {ncols}; truncated"
            )
            cells = cells[:ncols]
        rows.append(cells)

    return headers, rows, warnings


def split_h2_sections(text: str) -> dict[str, list[str]]:
    """
    Split text on '## ' headings. Returns {heading_text: [body_lines]}.
    Text before the first '## ' is stored under key ''.
    """
    sections: dict[str, list[str]] = {}
    current_key = ""
    current_lines: list[str] = []

    for line in text.splitlines():
        if line.startswith("## "):
            sections[current_key] = current_lines
            current_key = line[3:].strip()
            current_lines = []
        else:
            current_lines.append(line)

    sections[current_key] = current_lines
    return sections


# Sentinel for code-span protection
_CODE_SENTINEL = "\x00CODE\x00"


def md_inline(text: str) -> str:
    """
    Apply inline markdown rules to already-html-escaped text.
    Order: code spans (protected), **bold**, *italic*, [text](url), autolink.
    """
    # Protect code spans
    codes: list[str] = []

    def protect_code(m: re.Match) -> str:
        # m.group(1) is already html-escaped (md_inline's input contract) — do not re-escape.
        codes.append(f"<code>{m.group(1)}</code>")
        return f"{_CODE_SENTINEL}{len(codes) - 1}{_CODE_SENTINEL}"

    text = re.sub(r"`([^`]+)`", protect_code, text)

    # Bold
    text = re.sub(r"\*\*(.+?)\*\*", r"<strong>\1</strong>", text)
    # Italic (single star, not double)
    text = re.sub(r"(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)", r"<em>\1</em>", text)
    # Links [text](url)
    text = re.sub(r"\[([^\]]+)\]\(([^)]+)\)", r'<a href="\2">\1</a>', text)
    # Autolink bare https://
    text = re.sub(
        r"(?<![\"'=])(https://[^\s<>\"']+)",
        r'<a href="\1">\1</a>',
        text,
    )

    # Restore code spans
    for i, code_html in enumerate(codes):
        text = text.replace(f"{_CODE_SENTINEL}{i}{_CODE_SENTINEL}", code_html)

    return text


def md_to_html(text: str) -> str:
    """
    Convert a markdown string to HTML (block + inline).
    Supports: fenced code, ATX headings, ---, blockquotes, ordered/unordered
    lists (1 nesting level, hanging-indent continuation), pipe tables,
    paragraphs, images. Raw HTML is escaped literally.
    """
    lines = text.splitlines()
    out: list[str] = []
    i = 0
    n = len(lines)

    def flush_para(para: list[str]) -> str:
        if not para:
            return ""
        return "<p>" + md_inline(html.escape(" ".join(para))) + "</p>\n"

    para: list[str] = []

    def emit_para():
        nonlocal para
        if para:
            out.append(flush_para(para))
            para = []

    while i < n:
        line = lines[i]
        stripped = line.strip()

        # Fenced code block
        if stripped.startswith("```"):
            emit_para()
            fence = stripped[:3]
            lang = stripped[3:].strip()
            code_lines: list[str] = []
            i += 1
            while i < n and not lines[i].strip().startswith(fence):
                code_lines.append(lines[i])
                i += 1
            lang_attr = f' class="language-{html.escape(lang)}"' if lang else ""
            out.append(
                f"<pre><code{lang_attr}>"
                + html.escape("\n".join(code_lines))
                + "</code></pre>\n"
            )
            i += 1  # skip closing fence
            continue

        # ATX headings
        m = re.match(r"^(#{1,4})\s+(.*)", line)
        if m:
            emit_para()
            level = len(m.group(1))
            content = md_inline(html.escape(m.group(2).strip()))
            out.append(f"<h{level}>{content}</h{level}>\n")
            i += 1
            continue

        # Horizontal rule
        if re.match(r"^---+$", stripped):
            emit_para()
            out.append("<hr>\n")
            i += 1
            continue

        # Blockquote
        if stripped.startswith(">"):
            emit_para()
            bq_lines: list[str] = []
            while i < n and lines[i].strip().startswith(">"):
                bq_lines.append(lines[i].strip().lstrip(">").lstrip(" "))
                i += 1
            inner = md_to_html("\n".join(bq_lines))
            out.append(f"<blockquote>{inner}</blockquote>\n")
            continue

        # Pipe table
        if "|" in stripped and stripped.startswith("|"):
            emit_para()
            tbl_lines: list[str] = []
            while i < n and "|" in lines[i] and lines[i].strip().startswith("|"):
                tbl_lines.append(lines[i])
                i += 1
            headers, rows, tbl_warns = parse_pipe_table(tbl_lines)
            if headers:
                th_cells = "".join(
                    f"<th>{md_inline(html.escape(h))}</th>" for h in headers
                )
                tbody_rows = []
                for row in rows:
                    td_cells = "".join(
                        f"<td>{md_inline(html.escape(c))}</td>" for c in row
                    )
                    tbody_rows.append(f"<tr>{td_cells}</tr>")
                out.append(
                    f"<table><thead><tr>{th_cells}</tr></thead>"
                    f"<tbody>{''.join(tbody_rows)}</tbody></table>\n"
                )
            continue

        # Ordered list
        if re.match(r"^\d+\.\s", stripped):
            emit_para()
            items: list[str] = []
            current_item_lines: list[str] = []

            def flush_item():
                if current_item_lines:
                    items.append(" ".join(current_item_lines))
                current_item_lines.clear()

            while i < n:
                ln = lines[i]
                if re.match(r"^\d+\.\s", ln.strip()):
                    flush_item()
                    current_item_lines.append(re.sub(r"^\d+\.\s+", "", ln.strip()))
                    i += 1
                elif ln.startswith("  ") and current_item_lines:
                    current_item_lines.append(ln.strip())
                    i += 1
                else:
                    break
            flush_item()
            lis = "".join(
                f"<li>{md_inline(html.escape(it))}</li>" for it in items
            )
            out.append(f"<ol>{lis}</ol>\n")
            continue

        # Unordered list
        if re.match(r"^[-*]\s", stripped):
            emit_para()
            items = []
            current_item_lines = []

            def flush_item2():
                if current_item_lines:
                    items.append(" ".join(current_item_lines))
                current_item_lines.clear()

            while i < n:
                ln = lines[i]
                if re.match(r"^[-*]\s", ln.strip()):
                    flush_item2()
                    current_item_lines.append(re.sub(r"^[-*]\s+", "", ln.strip()))
                    i += 1
                elif ln.startswith("  ") and current_item_lines:
                    current_item_lines.append(ln.strip())
                    i += 1
                else:
                    break
            flush_item2()
            lis = "".join(
                f"<li>{md_inline(html.escape(it))}</li>" for it in items
            )
            out.append(f"<ul>{lis}</ul>\n")
            continue

        # Image: ![alt](path)
        img_m = re.match(r"^!\[([^\]]*)\]\(([^)]+)\)\s*$", stripped)
        if img_m:
            emit_para()
            alt = html.escape(img_m.group(1))
            path_str = img_m.group(2)
            img_path = ROOT / path_str
            if img_path.exists():
                src = "../../" + path_str.replace("\\", "/")
                out.append(f'<img src="{src}" alt="{alt}" style="max-width:100%">\n')
            else:
                out.append(f"<em>[image: {alt}]</em>\n")
            i += 1
            continue

        # Blank line → flush paragraph
        if not stripped:
            emit_para()
            i += 1
            continue

        # Paragraph accumulation
        para.append(stripped)
        i += 1

    emit_para()
    return "".join(out)

# ---------------------------------------------------------------------------
# Parsers
# ---------------------------------------------------------------------------

def parse_description(path: Path) -> tuple[dict, list[str]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    m = re.search(r"^Version:\s*(\S+)", text, re.MULTILINE)
    if not m:
        return {"version": None}, ["Version: line not found in DESCRIPTION"]
    return {"version": m.group(1)}, []


def _extract_md_link(cell: str) -> tuple[str | None, bool]:
    """Return (url_or_path, is_link). url_or_path is None if no link."""
    m = re.search(r"\[([^\]]+)\]\(([^)]+)\)", cell)
    if m:
        return m.group(2), True
    return None, False


def parse_roadmap(path: Path) -> tuple[dict, list[str]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    warnings: list[str] = []
    sections = split_h2_sections(text)

    # Status note from leading blockquote
    preamble = "\n".join(sections.get("", []))
    status_note_m = re.search(r"^>\s*\*\*Status:\*\*\s*(.+)", preamble, re.MULTILINE)
    status_note = status_note_m.group(1).strip() if status_note_m else ""

    # Phase table
    phase_section_key = next(
        (k for k in sections if k.startswith("Phase table")), None
    )
    if phase_section_key is None:
        # fallback: find first section whose table header starts with | Phase |
        for k, body in sections.items():
            joined = "\n".join(body)
            if re.search(r"^\| Phase \|", joined, re.MULTILINE):
                phase_section_key = k
                warnings.append(
                    "Phase table section not found by name; using first table with '| Phase |' header"
                )
                break

    phases: list[dict] = []
    if phase_section_key is not None:
        body_lines = sections[phase_section_key]
        headers, rows, tbl_warns = parse_pipe_table(body_lines)
        warnings.extend(tbl_warns)
        col = {h.strip().lower(): i for i, h in enumerate(headers)}
        for row in rows:
            def cell(key: str) -> str:
                idx = col.get(key)
                return row[idx].strip() if idx is not None and idx < len(row) else ""

            plan_cell = cell("plan file")
            plan_url, plan_is_link = _extract_md_link(plan_cell)
            phases.append({
                "phase": cell("phase"),
                "release": cell("release"),
                "branch": re.sub(r"`", "", cell("branch")),
                "scope": cell("scope"),
                "plan_file": plan_url,
                "plan_is_link": plan_is_link,
                "plan_cell_raw": plan_cell,
                "status": cell("status"),
            })

    # Gate table
    gate_key = next(
        (k for k in sections if k.startswith("Phase-gate interview process")), None
    )
    gates: list[dict] = []
    if gate_key:
        _, rows, w = parse_pipe_table(sections[gate_key])
        warnings.extend(w)
        gates = [{"gate": r[0] if r else "", "questions": r[1] if len(r) > 1 else ""} for r in rows]

    # Cross-repo ledger
    ledger_key = next(
        (k for k in sections if k.startswith("Cross-repo follow-ups ledger")), None
    )
    ledger: list[dict] = []
    if ledger_key:
        headers_l, rows_l, w = parse_pipe_table(sections[ledger_key])
        warnings.extend(w)
        ledger = [dict(zip(headers_l, r)) for r in rows_l]

    return {
        "status_note": status_note,
        "phases": phases,
        "gates": gates,
        "ledger": ledger,
    }, warnings


def parse_decisions(path: Path) -> tuple[dict, list[str]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    warnings: list[str] = []
    sections = split_h2_sections(text)

    settled_key = next((k for k in sections if k.startswith("Settled")), None)
    open_key = next(
        (k for k in sections if k.startswith("Open")), None
    )

    settled: list[dict] = []
    if settled_key:
        headers, rows, w = parse_pipe_table(sections[settled_key])
        warnings.extend(w)
        settled = [dict(zip([h.lower() for h in headers], r)) for r in rows]
    else:
        warnings.append("## Settled section not found")

    open_q: list[dict] = []
    if open_key:
        headers, rows, w = parse_pipe_table(sections[open_key])
        warnings.extend(w)
        open_q = [dict(zip([h.lower() for h in headers], r)) for r in rows]
    else:
        warnings.append("## Open section not found")

    return {"settled": settled, "open": open_q}, warnings


def _parse_header_table(lines: list[str]) -> tuple[dict, list[str]]:
    """
    Parse a phase-plan key/value table with empty '| | |' header row.
    Returns (dict of lowercased-key → value, warnings).
    """
    warnings: list[str] = []
    table_lines = [l for l in lines if l.strip().startswith("|")]
    result: dict[str, str] = {}

    skipping_header = True
    for raw in table_lines:
        cells = [c.strip() for c in raw.strip().strip("|").split("|")]
        # Skip the empty-header row and delimiter row
        if skipping_header:
            if all(c == "" for c in cells):
                skipping_header = False
            continue
        if all(re.fullmatch(r"[-: ]*", c) for c in cells):
            continue
        if len(cells) >= 2:
            key_raw = cells[0]
            value = cells[1]
            # Strip bold markers from key
            key = re.sub(r"\*\*", "", key_raw).strip().lower().replace(" ", "_")
            result[key] = value

    return result, warnings


def parse_phase_plan(path: Path) -> tuple[dict, list[str]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    warnings: list[str] = []
    lines = text.splitlines()

    # Check for skeleton marker in leading blockquotes
    is_skeleton = False
    for line in lines[:20]:
        if line.strip().startswith(">") and "skeleton only" in line.lower():
            is_skeleton = True
            break

    # First H1 → title
    title = path.stem
    for line in lines:
        m = re.match(r"^#\s+(.+)", line)
        if m:
            title = m.group(1).strip()
            break

    # Header table (first | | | table)
    header_table_lines: list[str] = []
    in_header_table = False
    found_empty_header = False
    for line in lines:
        stripped = line.strip()
        if not in_header_table:
            if stripped == "| | |":
                in_header_table = True
                found_empty_header = True
                header_table_lines.append(line)
            continue
        if stripped.startswith("|"):
            header_table_lines.append(line)
        else:
            break

    header: dict[str, str] = {}
    if found_empty_header:
        header, hw = _parse_header_table(header_table_lines)
        warnings.extend(hw)
    else:
        warnings.append("No | | | header table found")

    # Sessions: split on ## Session N
    sessions: list[dict] = []
    session_blocks: list[tuple[int, str, list[str]]] = []
    current_session_num: int | None = None
    current_session_title = ""
    current_session_lines: list[str] = []

    for line in lines:
        m = re.match(r"^## Session (\d+)", line)
        if m:
            if current_session_num is not None:
                session_blocks.append(
                    (current_session_num, current_session_title, current_session_lines)
                )
            current_session_num = int(m.group(1))
            rest = line[m.end():].strip()
            # Split on first ': ' or ' — '
            if ": " in rest:
                current_session_title = rest.split(": ", 1)[1].strip()
            elif " — " in rest:
                current_session_title = rest.split(" — ", 1)[1].strip()
            elif rest.startswith(":"):
                current_session_title = rest[1:].strip()
            elif rest.startswith("—"):
                current_session_title = rest[1:].strip()
            else:
                current_session_title = rest
            current_session_lines = []
        elif current_session_num is not None:
            current_session_lines.append(line)

    if current_session_num is not None:
        session_blocks.append(
            (current_session_num, current_session_title, current_session_lines)
        )

    # Findings section
    findings_lines: list[str] = []
    in_findings = False
    for line in lines:
        if re.match(r"^## Findings", line):
            in_findings = True
            findings_lines = []
            continue
        if in_findings:
            if line.startswith("## ") and not line.startswith("## Findings"):
                break
            findings_lines.append(line)

    findings_text = "\n".join(findings_lines)
    findings_html = md_to_html(findings_text)

    # Session done-state from findings
    done_sessions: set[int] = set()
    for num, _, _ in session_blocks:
        if re.search(rf"\bSession {num}\b", findings_text):
            done_sessions.add(num)

    for num, s_title, s_lines in session_blocks:
        steps: list[str] = []
        for line in s_lines:
            m = re.match(r"^### (.+)", line)
            if m:
                steps.append(m.group(1).strip())
        sessions.append({
            "num": num,
            "title": s_title,
            "steps": steps,
            "done_state": "done" if num in done_sessions else "not started",
        })

    return {
        "title": title,
        "header": header,
        "is_skeleton": is_skeleton,
        "sessions": sessions,
        "findings_html": findings_html,
    }, warnings


def parse_archive(plans_dir: Path) -> tuple[list, list[str]]:
    """Parse all .md files in plans_dir/archive/."""
    warnings: list[str] = []
    archive_dir = plans_dir / "archive"
    if not archive_dir.exists():
        return [], ["archive/ directory not found"]

    results: list[dict] = []
    for md_file in sorted(archive_dir.glob("*.md")):
        file_warnings: list[str] = []
        text = md_file.read_text(encoding="utf-8", errors="replace")
        lines = text.splitlines()

        # Look for ARCHIVED header in first 15 lines
        status: str | None = None
        for line in lines[:15]:
            m = re.match(r"^>\s*\*\*ARCHIVED\s*[—-]\s*(.+?)\*\*", line)
            if m:
                status = m.group(1).strip().rstrip(".")
                break

        if status is None:
            file_warnings.append(f"{md_file.name}: no ARCHIVED header")

        # First H1 (not backslash-escaped)
        title = md_file.stem
        for line in lines:
            m = re.match(r"^# (.+)", line)
            if m:
                title = m.group(1).strip()
                break
            # Backslash-escaped heading: \# title
            m2 = re.match(r"^\\#\s+(.+)", line)
            if m2:
                title = m2.group(1).strip()
                break

        warnings.extend(file_warnings)
        results.append({
            "file": md_file.name,
            "status": status,
            "title": title,
            "warnings": file_warnings,
        })

    return results, warnings


def parse_news(path: Path) -> tuple[dict, list[str]]:
    text = path.read_text(encoding="utf-8", errors="replace")
    warnings: list[str] = []

    # Split on "# hdatools " headings
    segments: list[tuple[str, str]] = []  # (heading_text, body)
    current_heading = ""
    current_body_lines: list[str] = []

    for line in text.splitlines():
        m = re.match(r"^# hdatools\s*(.*)", line)
        if m:
            if current_heading or current_body_lines:
                segments.append((current_heading, "\n".join(current_body_lines)))
            current_heading = m.group(1).strip()
            current_body_lines = []
        else:
            current_body_lines.append(line)

    if current_heading or current_body_lines:
        segments.append((current_heading, "\n".join(current_body_lines)))

    if not segments:
        return {"dev": None, "releases": []}, ["no '# hdatools' headings found in NEWS.md"]

    dev: dict | None = None
    releases: list[dict] = []

    for heading, body in segments:
        if heading == "(development version)":
            dev = {"html": md_to_html(body)}
        else:
            # Heading is the version string (e.g. "0.3.0")
            releases.append({"version": heading, "html": md_to_html(body)})

    return {"dev": dev, "releases": releases}, warnings


def parse_release_checklist(path: Path) -> tuple[dict, list[str]]:
    """CLAUDE.md '## Release checklist' numbered list, rendered to HTML."""
    text = path.read_text(encoding="utf-8", errors="replace")
    sections = split_h2_sections(text)
    key = next((k for k in sections if k.startswith("Release checklist")), None)
    if key is None:
        return {"html": ""}, ["## Release checklist section not found in CLAUDE.md"]
    body = "\n".join(sections[key])
    return {"html": md_to_html(body)}, []


def parse_doc_raw(path: Path) -> tuple[dict, list[str]]:
    """Whole-file markdown render, for the Docs tab (regenerated fresh each run)."""
    text = path.read_text(encoding="utf-8", errors="replace")
    return {"html": md_to_html(text)}, []

# ---------------------------------------------------------------------------
# Git layer
# ---------------------------------------------------------------------------

def _is_ancestor(ancestor: str, descendant: str) -> bool:
    """git merge-base --is-ancestor: rc 0 = True, rc 1 = False, anything else raises."""
    result = subprocess.run(
        ["git", "merge-base", "--is-ancestor", ancestor, descendant],
        cwd=str(ROOT),
        capture_output=True,
        text=True,
        encoding="utf-8",
        errors="replace",
        timeout=15,
    )
    if result.returncode not in (0, 1):
        raise RuntimeError(
            f"git merge-base --is-ancestor exited {result.returncode}: {result.stderr.strip()}"
        )
    return result.returncode == 0


def parse_git(root: Path) -> tuple[dict, list[str]]:
    warnings: list[str] = []

    current_branch = run(["git", "rev-parse", "--abbrev-ref", "HEAD"]).strip()
    dirty = bool(run(["git", "status", "--porcelain"]).strip())

    raw_refs = run([
        "git", "for-each-ref", "refs/heads", "refs/remotes/origin",
        "--format=%(refname)|%(refname:short)|%(objectname:short)|%(committerdate:iso-strict)|%(subject)",
    ])
    ref_rows: list[tuple[str, str, str, str, str]] = []
    for line in raw_refs.splitlines():
        if not line.strip():
            continue
        parts = line.split("|", 4)
        if len(parts) != 5:
            warnings.append(f"for-each-ref: unexpected line, skipped: {line!r}")
            continue
        ref_rows.append((parts[0], parts[1], parts[2], parts[3], parts[4]))

    # Dedup local vs origin/<name>; local wins. Skip origin/HEAD (symref) and main (trunk).
    branch_data: dict[str, dict] = {}
    for full_refname, refname, sha, date, subject in ref_rows:
        if full_refname == "refs/remotes/origin/HEAD":
            continue
        is_remote = refname.startswith("origin/")
        name = refname[len("origin/"):] if is_remote else refname
        if name == "main":
            continue
        entry = branch_data.setdefault(name, {"local": False, "remote": False})
        entry["remote" if is_remote else "local"] = True
        if "sha" not in entry:
            entry["sha"] = sha
            entry["date"] = date
            entry["subject"] = subject

    branches: list[dict] = []
    legacy: list[dict] = []
    for name, entry in sorted(branch_data.items()):
        ref_arg = name if entry["local"] else f"origin/{name}"
        try:
            merge_base = run(["git", "merge-base", "main", ref_arg]).strip()
            counts = run(["git", "rev-list", "--left-right", "--count", f"main...{ref_arg}"]).strip()
            behind_s, ahead_s = counts.split()
            in_era = _is_ancestor(MODERNIZATION_SHA, merge_base)
            machine = run([
                "git", "log", "-1", "--format=%(trailers:key=Machine,valueonly)", ref_arg,
            ]).strip()
        except Exception as exc:
            warnings.append(f"branch {name}: {type(exc).__name__}: {exc}")
            continue

        rec = {
            "name": name,
            "sha": entry["sha"],
            "date": entry["date"],
            "subject": entry["subject"],
            "local": entry["local"],
            "remote": entry["remote"],
            "current": name == current_branch,
            "ahead": int(ahead_s),
            "behind": int(behind_s),
            "merge_base": merge_base,
            "machine": machine,
        }

        if name in LEGACY_BRANCHES or not in_era:
            legacy.append(rec)
        else:
            branches.append(rec)

    # Mainline: first-parent commits from the modernization boundary to main
    raw_mainline = run([
        "git", "log", "--first-parent",
        "--format=%h|%H|%cs|%s|%(trailers:key=Machine,valueonly)",
        f"{MODERNIZATION_SHA}^..main",
    ])
    mainline: list[dict] = []
    for line in raw_mainline.splitlines():
        if not line.strip():
            continue
        parts = line.split("|", 4)
        if len(parts) < 4:
            warnings.append(f"mainline log: unexpected line, skipped: {line!r}")
            continue
        short, full, date, subject = parts[0], parts[1], parts[2], parts[3]
        machine = parts[4] if len(parts) > 4 else ""
        mainline.append({
            "short": short, "full": full, "date": date, "subject": subject, "machine": machine,
        })

    # Tags (dereferenced to the commit they point at)
    raw_tags = run([
        "git", "tag", "--list", "v*",
        "--format=%(refname:short)|%(objectname:short)|%(*objectname:short)|%(creatordate:short)",
    ])
    tags: list[dict] = []
    for line in raw_tags.splitlines():
        if not line.strip():
            continue
        parts = line.split("|")
        if len(parts) != 4:
            warnings.append(f"tag line unexpected, skipped: {line!r}")
            continue
        tag_name, obj_sha, deref_sha, date = parts
        tags.append({
            "name": tag_name,
            "commit_sha": deref_sha or obj_sha,
            "date": date,
        })

    return {
        "current_branch": current_branch,
        "dirty": dirty,
        "mainline": mainline,
        "branches": branches,
        "legacy_branches": legacy,
        "tags": tags,
    }, warnings


def attach_pr_and_ci_to_branches(branches: list[dict], prs: list[dict], runs: list[dict]) -> None:
    """Mutate each branch dict in place: 'pr' (or None), 'ci_latest' (or None)."""
    pr_by_branch: dict[str, dict] = {}
    for pr in prs:
        head = pr.get("headRefName")
        if head and head not in pr_by_branch:
            pr_by_branch[head] = pr

    ci_by_branch: dict[str, list[dict]] = {}
    for r in runs:
        if r.get("workflowName") != "R-CMD-check":
            continue
        head = r.get("headBranch")
        if head:
            ci_by_branch.setdefault(head, []).append(r)

    for b in branches:
        b["pr"] = pr_by_branch.get(b["name"])
        ci_list = ci_by_branch.get(b["name"], [])
        b["ci_latest"] = ci_list[0] if ci_list else None


def attach_pr_and_tags_to_mainline(mainline: list[dict], prs: list[dict], tags: list[dict]) -> None:
    """Mutate each mainline row in place: 'pr' (merge that landed it, or None), 'tags' (list of names)."""
    pr_by_merge_sha = {
        pr["mergeCommit"]["oid"]: pr
        for pr in prs
        if pr.get("mergeCommit") and pr["mergeCommit"].get("oid")
    }
    tags_by_short_sha: dict[str, list[str]] = {}
    for t in tags:
        tags_by_short_sha.setdefault(t["commit_sha"], []).append(t["name"])

    for row in mainline:
        row["pr"] = pr_by_merge_sha.get(row["full"])
        row["tags"] = tags_by_short_sha.get(row["short"], [])

# ---------------------------------------------------------------------------
# gh layer (with cache + offline fallback)
# ---------------------------------------------------------------------------

GH_PR_FIELDS = "number,title,state,headRefName,mergedAt,mergeCommit,url"
GH_RUN_FIELDS = "workflowName,status,conclusion,headBranch,createdAt,url"

GH_FAILURE_MODES = (subprocess.TimeoutExpired, FileNotFoundError, RuntimeError, json.JSONDecodeError)


def _write_cache_atomic(payload: dict) -> None:
    CACHE.parent.mkdir(parents=True, exist_ok=True)
    fd, tmp_path = tempfile.mkstemp(dir=str(CACHE.parent), prefix="gh-cache-", suffix=".tmp")
    try:
        with os.fdopen(fd, "w", encoding="utf-8", newline="\n") as f:
            json.dump(payload, f, indent=2)
        os.replace(tmp_path, CACHE)
    except Exception:
        try:
            os.unlink(tmp_path)
        except OSError:
            pass
        raise


def _cache_age_days(fetched_at: str | None) -> float | None:
    if not fetched_at:
        return None
    try:
        fetched_dt = datetime.fromisoformat(fetched_at)
    except ValueError:
        return None
    return (datetime.now().astimezone() - fetched_dt).total_seconds() / 86400


def parse_gh(offline: bool) -> tuple[dict, list[str]]:
    warnings: list[str] = []
    live: tuple[list, list] | None = None

    if not offline:
        try:
            prs_raw = run(
                ["gh", "pr", "list", "--state", "all", "--limit", "50", "--json", GH_PR_FIELDS],
                timeout=20,
            )
            runs_raw = run(
                ["gh", "run", "list", "--limit", "30", "--json", GH_RUN_FIELDS],
                timeout=20,
            )
            prs = json.loads(prs_raw)
            runs = json.loads(runs_raw)
        except GH_FAILURE_MODES as exc:
            warnings.append(f"gh fetch failed ({type(exc).__name__}: {exc}); falling back to cache")
        else:
            live = (prs, runs)

    if live is not None:
        prs, runs = live
        fetched_at = datetime.now().astimezone().isoformat()
        _write_cache_atomic({"fetched_at": fetched_at, "prs": prs, "runs": runs})
        return {
            "source": "live",
            "fetched_at": fetched_at,
            "cache_age_days": 0.0,
            "prs": prs,
            "runs": runs,
        }, warnings

    if offline:
        warnings.append("--offline: using cached gh data")

    if CACHE.exists():
        try:
            cached = json.loads(CACHE.read_text(encoding="utf-8"))
        except json.JSONDecodeError as exc:
            warnings.append(f"gh-cache.json unreadable: {type(exc).__name__}: {exc}")
            return {
                "source": "unavailable", "fetched_at": None, "cache_age_days": None,
                "prs": [], "runs": [],
            }, warnings
        fetched_at = cached.get("fetched_at")
        return {
            "source": "cached",
            "fetched_at": fetched_at,
            "cache_age_days": _cache_age_days(fetched_at),
            "prs": cached.get("prs", []),
            "runs": cached.get("runs", []),
        }, warnings

    warnings.append("no gh data and no cache — run once online")
    return {
        "source": "unavailable", "fetched_at": None, "cache_age_days": None,
        "prs": [], "runs": [],
    }, warnings

# ---------------------------------------------------------------------------
# Active-phase detection
# ---------------------------------------------------------------------------

def _strip_md_bold(text: str) -> str:
    return re.sub(r"\*\*", "", text)


def _status_prefix(status_raw: str) -> str:
    """Lowercased, markdown-stripped status text before any em/en-dash separator."""
    text = _strip_md_bold(status_raw).strip().lower()
    for sep in (" — ", " – "):
        if sep in text:
            return text.split(sep, 1)[0].strip()
    return text


def _status_is_cleanly_done(status_raw: str) -> bool:
    """Strict: the *entire* normalized status is 'done'/'merged' with no trailing
    qualifier. Used where a lingering qualifier (e.g. '— PR open, pending tag')
    is itself the signal that the badge is stale, even though the leading word
    says done."""
    text = _strip_md_bold(status_raw).strip().lower()
    return text in ("done", "merged")


def detect_active_phase(phases: list[dict]) -> tuple[dict | None, str]:
    """Returns (phase_dict_or_None, label) where label is 'active', 'blocked', or 'none'."""
    for phase in phases:
        if _status_prefix(phase["status"]).startswith(("next up", "in progress", "active")):
            return phase, "active"
    for phase in phases:
        prefix = _status_prefix(phase["status"])
        if prefix not in ("done", "merged", "deferred"):
            return phase, "blocked"
    return None, "none"


def resolve_plan_file(phase: dict, phase_plans: dict[str, dict | None]) -> dict:
    """Classify a phase row's Plan file cell: absent / archived / skeleton / normal."""
    cell_raw = phase["plan_cell_raw"].strip()
    low = cell_raw.lower()
    if not phase["plan_is_link"] or low == "written at phase gate" or low.startswith("none"):
        return {"state": "absent", "path": None}

    target = phase["plan_file"] or ""
    normalized = target.replace("\\", "/")
    if not (PLANS / normalized).exists():
        return {"state": "absent", "path": target}

    if normalized.startswith("archive/"):
        return {"state": "archived", "path": target}

    stem = Path(normalized).stem
    plan_data = phase_plans.get(stem)
    is_skeleton = "(skeleton)" in low or bool(plan_data and plan_data.get("is_skeleton"))
    return {
        "state": "skeleton" if is_skeleton else "normal",
        "path": target,
        "data": plan_data,
    }

# ---------------------------------------------------------------------------
# Consistency checks (exactly 7)
# ---------------------------------------------------------------------------

def run_consistency_checks(model: dict) -> list[dict]:
    findings: list[dict] = []

    roadmap = model.get("roadmap") or {}
    phases = roadmap.get("phases", [])
    gh_data = model.get("gh") or {}
    prs = gh_data.get("prs", [])
    git_data = model.get("git") or {}
    tags = git_data.get("tags", [])
    branches = git_data.get("branches", [])
    phase_plans = model.get("phase_plans") or {}
    description = model.get("description") or {}
    news = model.get("news") or {}

    pr_by_branch: dict[str, dict] = {}
    for pr in prs:
        head = pr.get("headRefName")
        if head and head not in pr_by_branch:
            pr_by_branch[head] = pr

    def merged_pr(branch_name: str) -> dict | None:
        pr = pr_by_branch.get(branch_name)
        return pr if pr and pr.get("state") == "MERGED" else None

    tag_names = {t["name"] for t in tags}

    # 1. Status vs PR
    for phase in phases:
        branch = phase.get("branch")
        if not branch:
            continue
        pr = merged_pr(branch)
        if pr and _status_prefix(phase["status"]) not in ("done", "merged"):
            findings.append({
                "check": "status-vs-pr",
                "level": "warning",
                "message": (
                    f"Phase {phase['phase']}: status is \"{phase['status']}\" but branch "
                    f"`{branch}` PR #{pr['number']} is MERGED"
                ),
            })

    # 2. Status vs tag
    for phase in phases:
        release = _strip_md_bold(phase.get("release", "")).strip()
        tag_guess = f"v{release}"
        if tag_guess in tag_names and not _status_is_cleanly_done(phase["status"]):
            findings.append({
                "check": "status-vs-tag",
                "level": "warning",
                "message": (
                    f"Phase {phase['phase']}: status is \"{phase['status']}\" but tag "
                    f"{tag_guess} exists"
                ),
            })

    # 3. Plan not archived
    for phase in phases:
        branch = phase.get("branch")
        if not branch:
            continue
        pr = merged_pr(branch)
        if pr and phase.get("plan_is_link") and phase.get("plan_file"):
            target = phase["plan_file"].replace("\\", "/")
            if not target.startswith("archive/"):
                findings.append({
                    "check": "plan-not-archived",
                    "level": "warning",
                    "message": (
                        f"Phase {phase['phase']}: PR #{pr['number']} is MERGED but plan file "
                        f"\"{phase['plan_file']}\" is still under plans/, not plans/archive/"
                    ),
                })

    # 5. Stale phase-plan header
    for stem, plan_data in phase_plans.items():
        if not plan_data:
            continue
        status_text = (plan_data.get("header") or {}).get("status", "")
        low = status_text.lower()
        if "not yet merged" in low or "pending" in low:
            for candidate in re.findall(r"`([^`]+)`", status_text):
                if candidate == "main":
                    continue
                pr = merged_pr(candidate)
                if pr:
                    findings.append({
                        "check": "stale-header",
                        "level": "warning",
                        "message": (
                            f"{stem}.md: header Status says \"{status_text}\" but branch "
                            f"`{candidate}` PR #{pr['number']} is MERGED"
                        ),
                    })

    # 4. Version vs NEWS
    version = description.get("version")
    if version:
        dev = news.get("dev")
        releases = news.get("releases") or []
        if ".9000" in version:
            if not dev:
                findings.append({
                    "check": "version-vs-news",
                    "level": "warning",
                    "message": (
                        f"DESCRIPTION version {version} is a dev version but NEWS.md has no "
                        f"'(development version)' heading"
                    ),
                })
        else:
            if dev:
                findings.append({
                    "check": "version-vs-news",
                    "level": "warning",
                    "message": (
                        f"DESCRIPTION version {version} has no dev suffix but NEWS.md still "
                        f"has a '(development version)' heading"
                    ),
                })
            else:
                top_version = releases[0]["version"] if releases else None
                if top_version != version:
                    findings.append({
                        "check": "version-vs-news",
                        "level": "warning",
                        "message": (
                            f"DESCRIPTION version {version} does not match NEWS.md's top "
                            f"heading \"{top_version}\""
                        ),
                    })

    # 6. Merged branch still local (info-level; Branches tab, not the banner)
    for b in branches:
        if not b.get("local"):
            continue
        pr = merged_pr(b["name"])
        if pr:
            findings.append({
                "check": "merged-branch-still-local",
                "level": "info",
                "message": f"Branch `{b['name']}` PR #{pr['number']} is MERGED; safe to delete locally",
            })

    # 7. CI red (unmerged/live branches only)
    for b in branches:
        if merged_pr(b["name"]):
            continue
        ci = b.get("ci_latest")
        if ci and ci.get("conclusion") not in (None, "success"):
            findings.append({
                "check": "ci-red",
                "level": "warning",
                "message": (
                    f"Branch `{b['name']}`: latest R-CMD-check concluded "
                    f"\"{ci.get('conclusion')}\""
                ),
            })

    return findings


def build_model(sections: dict[str, "Section"]) -> dict:
    model: dict[str, Any] = {}
    for key in ("description", "roadmap", "decisions", "archive", "news"):
        model[key] = sections[key].data

    model["phase_plans"] = {
        "phase-0-groundwork": sections["phase_plan_0"].data,
        "phase-2-features-0.4.0": sections["phase_plan_2"].data,
    }

    model["git"] = sections["git"].data
    model["gh"] = sections["gh"].data

    if model["git"] and model["gh"]:
        attach_pr_and_ci_to_branches(model["git"]["branches"], model["gh"]["prs"], model["gh"]["runs"])
        attach_pr_and_tags_to_mainline(model["git"]["mainline"], model["gh"]["prs"], model["git"]["tags"])

    phases = (model["roadmap"] or {}).get("phases", [])
    active_phase, active_label = detect_active_phase(phases)
    active_plan = None
    if active_phase:
        active_plan = resolve_plan_file(active_phase, model["phase_plans"])
    model["active_phase"] = {"phase": active_phase, "label": active_label, "plan": active_plan}

    model["consistency"] = run_consistency_checks(model)

    return model

# ---------------------------------------------------------------------------
# CSS / JS constants
# ---------------------------------------------------------------------------

CSS_CONSTANT = """
:root {
  --paper: #FFFCF0;
  --black: #100F0F;
  --base-50: #F2F0E5;
  --base-100: #E6E4D9;
  --base-600: #6F6E69;
  --green-600: #66800B;
  --orange-600: #BC5215;
  --red-600: #AF3029;
  --blue-600: #205EA6;
  --cyan-600: #24837B;
}
* { box-sizing: border-box; }
html, body {
  margin: 0; padding: 0;
  background: var(--paper);
  color: var(--black);
  font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif;
  font-size: 15px;
  line-height: 1.5;
}
.container { max-width: 1100px; margin: 0 auto; padding: 0 20px 60px; }
a { color: var(--blue-600); }
code, pre, .commit-sha { font-family: ui-monospace, SFMono-Regular, Consolas, monospace; }
h1, h2, h3 { line-height: 1.25; }
h1 { font-size: 1.5rem; margin: 0; }
h2 { font-size: 1.15rem; margin: 28px 0 10px; border-bottom: 1px solid var(--base-100); padding-bottom: 6px; }
h3 { font-size: 1rem; margin: 16px 0 6px; }

.page-header { padding: 20px 0 12px; }
.title-row { display: flex; align-items: baseline; justify-content: space-between; flex-wrap: wrap; gap: 8px; }
.version-chip { font-size: 0.9rem; font-weight: normal; color: var(--base-600); margin-left: 8px; }
.header-meta { display: flex; align-items: center; gap: 8px; flex-wrap: wrap; }
.generated-at { color: var(--base-600); font-size: 0.85rem; }

.chip {
  display: inline-block;
  padding: 2px 8px;
  border-radius: 999px;
  font-size: 0.8rem;
  background: var(--base-50);
  color: var(--black);
  border: 1px solid var(--base-100);
  white-space: nowrap;
}
a.chip { text-decoration: none; }
.chip-green { background: color-mix(in srgb, var(--green-600) 14%, var(--paper)); border-color: var(--green-600); color: color-mix(in srgb, var(--green-600) 80%, var(--black)); }
.chip-orange { background: color-mix(in srgb, var(--orange-600) 14%, var(--paper)); border-color: var(--orange-600); color: color-mix(in srgb, var(--orange-600) 80%, var(--black)); }
.chip-red { background: color-mix(in srgb, var(--red-600) 14%, var(--paper)); border-color: var(--red-600); color: color-mix(in srgb, var(--red-600) 80%, var(--black)); }
.chip-blue { background: color-mix(in srgb, var(--blue-600) 14%, var(--paper)); border-color: var(--blue-600); color: color-mix(in srgb, var(--blue-600) 80%, var(--black)); }
.chip-cyan { background: color-mix(in srgb, var(--cyan-600) 14%, var(--paper)); border-color: var(--cyan-600); color: color-mix(in srgb, var(--cyan-600) 80%, var(--black)); }
.chip-neutral { color: var(--base-600); }

.cache-banner, .doc-lag-banner {
  margin: 12px 0;
  padding: 10px 14px;
  border-radius: 6px;
  background: color-mix(in srgb, var(--orange-600) 10%, var(--paper));
  border-left: 4px solid var(--orange-600);
}
.doc-lag-banner ul { margin: 6px 0; padding-left: 20px; }
.banner-footer { margin: 6px 0 0; font-style: italic; color: var(--base-600); }

.tabbar {
  position: sticky; top: 0; z-index: 10;
  display: flex; gap: 4px; flex-wrap: wrap;
  background: var(--paper);
  padding: 10px 0; margin-bottom: 16px;
  border-bottom: 1px solid var(--base-100);
}
.tabbar button, .docs-subtabs button {
  font: inherit; cursor: pointer;
  padding: 6px 12px;
  border: 1px solid var(--base-100);
  background: var(--base-50);
  color: var(--black);
  border-radius: 6px 6px 0 0;
}
.tabbar button.active, .docs-subtabs button.active {
  background: var(--paper);
  border-color: var(--blue-600);
  border-bottom: 2px solid var(--blue-600);
  color: var(--blue-600);
  font-weight: 600;
}
.docs-subtabs { display: flex; gap: 4px; margin-bottom: 14px; }

table { width: 100%; border-collapse: collapse; margin: 10px 0 20px; font-size: 0.92rem; }
th, td { text-align: left; padding: 6px 10px; border-bottom: 1px solid var(--base-100); vertical-align: top; }
th { background: var(--base-50); font-weight: 600; }

.panel { background: var(--base-50); border: 1px solid var(--base-100); border-radius: 8px; padding: 14px 16px; margin: 10px 0; }
.warn-panel { background: color-mix(in srgb, var(--orange-600) 10%, var(--paper)); border-left: 4px solid var(--orange-600); border-radius: 6px; padding: 8px 12px; margin: 8px 0; font-size: 0.88rem; }
.warn-panel.hard { background: color-mix(in srgb, var(--red-600) 10%, var(--paper)); border-left-color: var(--red-600); }
.warn-panel ul { margin: 4px 0 0; padding-left: 20px; }

details { margin: 12px 0; }
summary { cursor: pointer; padding: 6px 0; font-weight: 600; }
.archive-details ul, .legacy-details ul { padding-left: 20px; }

.status-note { color: var(--base-600); font-style: italic; }

.active-phase-card .session-list, .active-phase-card .step-list { padding-left: 20px; }
.active-phase-card .step-list { font-size: 0.88rem; color: var(--base-600); }

.lane-grid { display: grid; grid-template-columns: minmax(200px, 340px) 1fr; gap: 0 20px; }
.lane-row { display: contents; }
.lane-main {
  position: relative;
  padding: 10px 0 24px 22px;
  border-left: 2px solid var(--base-100);
  margin-left: 6px;
}
.commit-dot {
  position: absolute; left: -7px; top: 12px;
  width: 12px; height: 12px; border-radius: 50%;
  background: var(--black); border: 2px solid var(--paper);
}
.commit-info { display: flex; flex-direction: column; gap: 2px; }
.commit-sha { font-size: 0.85rem; color: var(--base-600); }
.commit-date { font-size: 0.78rem; color: var(--base-600); }
.commit-subject { font-size: 0.92rem; }
.commit-badges { display: flex; gap: 4px; flex-wrap: wrap; margin-top: 4px; }
.machine-chip { font-size: 0.72rem; }

.lane-branches { display: flex; flex-direction: column; gap: 8px; padding: 10px 0 24px; }
.branch-card { background: var(--base-50); border: 1px solid var(--base-100); border-radius: 8px; padding: 10px 12px; }
.branch-name { display: flex; align-items: center; gap: 6px; margin-bottom: 4px; }
.branch-detail { font-size: 0.85rem; margin: 3px 0; }
.branch-annotation { font-size: 0.82rem; color: var(--base-600); margin-top: 6px; font-style: italic; }

.lane-row-unmatched .lane-main { border-left-color: transparent; color: var(--base-600); font-size: 0.85rem; }

.gh-stamp { color: var(--base-600); font-size: 0.85rem; }

.prose img { max-width: 100%; }
.prose pre { background: var(--base-50); border: 1px solid var(--base-100); padding: 10px; border-radius: 6px; overflow-x: auto; }
.prose blockquote { border-left: 3px solid var(--base-100); margin: 10px 0; padding: 2px 14px; color: var(--base-600); }

@media (max-width: 720px) {
  .lane-grid { grid-template-columns: 1fr; }
  .lane-main { border-left: none; padding-left: 0; }
  .commit-dot { display: none; }
}
"""

JS_CONSTANT = """
(function () {
  function activateTab(tabId) {
    document.querySelectorAll('.tab').forEach(function (el) {
      el.hidden = el.id !== 'tab-' + tabId;
    });
    document.querySelectorAll('.tabbar button').forEach(function (btn) {
      btn.classList.toggle('active', btn.dataset.tab === tabId);
    });
  }
  function activateDocsSub(sub) {
    document.querySelectorAll('.docs-tab').forEach(function (el) {
      el.hidden = el.id !== 'docs-' + sub;
    });
    document.querySelectorAll('.docs-subtabs button').forEach(function (btn) {
      btn.classList.toggle('active', btn.dataset.docsub === sub);
    });
  }
  function restoreFromHash() {
    var parts = location.hash.replace('#', '').split('/');
    var tab = parts[0] || 'roadmap';
    activateTab(tab);
    if (tab === 'docs') {
      activateDocsSub(parts[1] || 'readme');
    }
  }
  var tabbar = document.querySelector('.tabbar');
  if (tabbar) {
    tabbar.addEventListener('click', function (e) {
      var btn = e.target.closest('button[data-tab]');
      if (!btn) return;
      var tab = btn.dataset.tab;
      location.hash = tab === 'docs' ? 'docs/readme' : tab;
    });
  }
  var docsSubtabs = document.querySelector('.docs-subtabs');
  if (docsSubtabs) {
    docsSubtabs.addEventListener('click', function (e) {
      var btn = e.target.closest('button[data-docsub]');
      if (!btn) return;
      location.hash = 'docs/' + btn.dataset.docsub;
    });
  }
  window.addEventListener('hashchange', restoreFromHash);
  restoreFromHash();
})();
"""

# ---------------------------------------------------------------------------
# Render helpers
# ---------------------------------------------------------------------------

def _cls(condition: bool, cls_name: str) -> str:
    return cls_name if condition else ""


def _status_chip(status_raw: str) -> str:
    prefix = _status_prefix(status_raw)
    if prefix in ("done", "merged"):
        cls = "chip-green"
    elif prefix in ("next up", "in progress", "active"):
        cls = "chip-blue"
    elif prefix == "deferred":
        cls = "chip-neutral"
    elif prefix.startswith("blocked"):
        cls = "chip-orange"
    else:
        cls = "chip-neutral"
    return f'<span class="chip {cls}">{md_inline(html.escape(status_raw))}</span>'


def render_section_warnings(*secs: Section | None) -> str:
    """Warn-panel(s) for any section that failed outright or carries soft warnings."""
    parts: list[str] = []
    for sec in secs:
        if sec is None:
            continue
        if sec.data is None or sec.warnings:
            hard = sec.data is None
            header = f"{sec.name}" + (" failed to parse" if hard else f" — {len(sec.warnings)} warning(s)")
            items = "".join(f"<li>{html.escape(w)}</li>" for w in sec.warnings)
            parts.append(
                f'<div class="warn-panel {_cls(hard, "hard")}">'
                f'<p>⚠ {html.escape(header)}</p>'
                f'<ul>{items}</ul></div>'
            )
    return "".join(parts)


# ---------------------------------------------------------------------------
# Page chrome
# ---------------------------------------------------------------------------

_TAB_SECTION_MAP = {
    "roadmap": ["roadmap", "phase_plan_0", "phase_plan_2", "archive"],
    "branches": ["git", "gh"],
    "decisions": ["decisions"],
    "release": ["gh", "description", "news", "release_checklist"],
    "docs": ["doc_readme", "doc_claude", "doc_news"],
}


def compute_warn_tab_count(sections: dict[str, Section]) -> int:
    count = 0
    for keys in _TAB_SECTION_MAP.values():
        if any(sections.get(k) and (sections[k].data is None or sections[k].warnings) for k in keys):
            count += 1
    return count


def render_header(model: dict, sections: dict[str, Section]) -> str:
    version = (model.get("description") or {}).get("version") or "unknown"
    git = model.get("git") or {}
    branch = git.get("current_branch") or "?"
    dirty_chip = '<span class="chip chip-orange">uncommitted changes</span>' if git.get("dirty") else ""
    warn_count = compute_warn_tab_count(sections)
    warn_chip = (
        f'<span class="chip chip-orange">{warn_count} tab(s) with parse warnings</span>'
        if warn_count else ""
    )
    generated = datetime.now().astimezone().strftime("%Y-%m-%d %H:%M %z")
    return (
        '<header class="page-header">'
        '<div class="title-row">'
        f'<h1>hdatools <span class="version-chip">v{html.escape(version)}</span></h1>'
        '<div class="header-meta">'
        f'<span class="chip chip-neutral"><code>{html.escape(branch)}</code></span>'
        f'{dirty_chip}{warn_chip}'
        f'<span class="generated-at">generated {html.escape(generated)}</span>'
        '</div></div></header>'
    )


def render_tabbar() -> str:
    tabs = [
        ("roadmap", "Roadmap"),
        ("branches", "Branches &amp; PRs"),
        ("decisions", "Decisions"),
        ("release", "Release &amp; CI"),
        ("docs", "Docs"),
    ]
    buttons = "".join(
        f'<button data-tab="{tid}" class="{_cls(i == 0, "active")}">{label}</button>'
        for i, (tid, label) in enumerate(tabs)
    )
    return f'<nav class="tabbar">{buttons}</nav>'


def render_consistency_banner(model: dict) -> str:
    warnings_ = [f for f in model.get("consistency", []) if f["level"] == "warning"]
    if not warnings_:
        return ""
    items = "".join(f"<li>{html.escape(f['message'])}</li>" for f in warnings_)
    return (
        '<div class="doc-lag-banner">'
        f'<p><strong>{len(warnings_)} doc-lag warning(s)</strong></p>'
        f'<ul>{items}</ul>'
        '<p class="banner-footer">Fix the docs by hand — the dashboard never edits them.</p>'
        '</div>'
    )


def render_gh_cache_banner(gh: dict) -> str:
    if gh.get("source") != "cached":
        return ""
    age = gh.get("cache_age_days")
    age_note = f" (cache is {age:.0f} days old)" if age is not None and age > 7 else ""
    fetched = gh.get("fetched_at") or "unknown time"
    return (
        '<div class="cache-banner">'
        f'⚠ gh unavailable — showing cached data last fetched {html.escape(str(fetched))}{age_note}'
        '</div>'
    )


# ---------------------------------------------------------------------------
# Roadmap tab
# ---------------------------------------------------------------------------

def render_active_phase_card(active: dict) -> str:
    phase = active.get("phase")
    label = active.get("label", "none")
    plan = active.get("plan") or {}

    if phase is None:
        return '<div class="panel">No active phase found.</div>'

    label_chip = {
        "active": '<span class="chip chip-blue">active</span>',
        "blocked": '<span class="chip chip-orange">blocked</span>',
    }.get(label, "")

    header_html = (
        f'<h3>Phase {html.escape(phase["phase"])} {label_chip}</h3>'
        f'<p>{md_inline(html.escape(phase["scope"]))}</p>'
        f'<p>Release: {md_inline(html.escape(phase["release"]))}'
        f' &middot; Branch: <code>{html.escape(phase["branch"])}</code>'
        f' &middot; Status: {_status_chip(phase["status"])}</p>'
    )

    plan_state = plan.get("state", "absent")
    if plan_state == "absent":
        plan_html = (
            '<p class="plan-note"><em>No plan file yet — drafted just-in-time at the '
            'phase gate (per ROADMAP convention).</em></p>'
        )
    elif plan_state == "archived":
        plan_html = f'<p class="plan-note">Plan file archived: <code>{html.escape(plan.get("path") or "")}</code></p>'
    elif plan_state == "skeleton":
        plan_data = plan.get("data") or {}
        header = plan_data.get("header", {})
        entry = header.get("entry_criteria", "")
        plan_html = (
            '<p><span class="chip chip-orange">skeleton — gate interview not held</span></p>'
            + (f'<p>{md_inline(html.escape(entry))}</p>' if entry else "")
        )
    else:  # normal
        plan_data = plan.get("data") or {}
        header = plan_data.get("header", {})
        entry = header.get("entry_criteria", "")
        exit_ = header.get("exit_criteria", "")
        sessions = plan_data.get("sessions", [])
        session_items = []
        for s in sessions:
            state_cls = "chip-green" if s["done_state"] == "done" else "chip-neutral"
            steps = "".join(f"<li>{html.escape(st)}</li>" for st in s["steps"])
            session_items.append(
                f'<li><span class="chip {state_cls}">{html.escape(s["done_state"])}</span> '
                f'Session {s["num"]} — {html.escape(s["title"])}'
                + (f'<ul class="step-list">{steps}</ul>' if steps else "")
                + "</li>"
            )
        plan_html = (
            (f'<p><strong>Entry:</strong> {md_inline(html.escape(entry))}</p>' if entry else "")
            + (f'<p><strong>Exit:</strong> {md_inline(html.escape(exit_))}</p>' if exit_ else "")
            + (f'<ul class="session-list">{"".join(session_items)}</ul>' if session_items else "")
            + '<p class="plan-note"><em>Session done/not-started is inferred from the '
              'plan\'s Findings section.</em></p>'
        )

    return f'<div class="panel active-phase-card">{header_html}{plan_html}</div>'


def render_roadmap_tab(model: dict, sections: dict[str, Section]) -> str:
    roadmap_sec = sections["roadmap"]
    roadmap = roadmap_sec.data or {}
    phases = roadmap.get("phases", [])
    status_note = roadmap.get("status_note", "")

    phase_rows = "".join(
        "<tr>"
        f"<td>{md_inline(html.escape(p['phase']))}</td>"
        f"<td>{md_inline(html.escape(p['release']))}</td>"
        f"<td>{'<code>' + html.escape(p['branch']) + '</code>' if p['branch'] else ''}</td>"
        f"<td>{md_inline(html.escape(p['scope']))}</td>"
        f"<td>{md_inline(html.escape(p['plan_cell_raw']))}</td>"
        f"<td>{_status_chip(p['status'])}</td>"
        "</tr>"
        for p in phases
    )
    phase_table = (
        "<table><thead><tr><th>Phase</th><th>Release</th><th>Branch</th><th>Scope</th>"
        "<th>Plan file</th><th>Status</th></tr></thead>"
        f"<tbody>{phase_rows}</tbody></table>"
    )

    active_card = render_active_phase_card(model.get("active_phase") or {})

    gates = roadmap.get("gates", [])
    gate_rows = "".join(
        f"<tr><td>{md_inline(html.escape(g['gate']))}</td><td>{md_inline(html.escape(g['questions']))}</td></tr>"
        for g in gates
    )
    gate_table = (
        "<h2>Phase-gate questions</h2>"
        "<table><thead><tr><th>Gate</th><th>Questions</th></tr></thead>"
        f"<tbody>{gate_rows}</tbody></table>"
    )

    archive_sec = sections["archive"]
    archive_list = archive_sec.data or []
    archive_items = "".join(
        f"<li><code>{html.escape(a['file'])}</code>"
        + (f" — {html.escape(a['status'])}" if a["status"] else " — <em>no ARCHIVED header</em>")
        + "</li>"
        for a in archive_list
    )
    archive_html = (
        f'<details class="archive-details"><summary>Archived plans ({len(archive_list)})</summary>'
        f'<ul>{archive_items}</ul></details>'
    )

    body = (
        (f'<p class="status-note">{md_inline(html.escape(status_note))}</p>' if status_note else "")
        + "<h2>Phase table</h2>" + phase_table
        + "<h2>Active phase</h2>" + active_card
        + gate_table
        + archive_html
    )
    return render_section_warnings(roadmap_sec, sections["phase_plan_0"], sections["phase_plan_2"], archive_sec) + body


# ---------------------------------------------------------------------------
# Branches & PRs tab
# ---------------------------------------------------------------------------

def render_mainline_row(row: dict) -> str:
    badges = [f'<span class="chip chip-blue">{html.escape(t)}</span>' for t in row.get("tags", [])]
    pr = row.get("pr")
    if pr:
        badges.append(
            f'<span class="chip chip-green">merges PR #{pr["number"]} ← '
            f'{html.escape(pr.get("headRefName") or "")}</span>'
        )
    machine = row.get("machine")
    machine_chip = f'<span class="chip chip-neutral machine-chip">{html.escape(machine)}</span>' if machine else ""
    return (
        '<div class="commit-dot"></div>'
        '<div class="commit-info">'
        f'<code class="commit-sha">{html.escape(row["short"])}</code> '
        f'<span class="commit-date">{html.escape(row["date"])}</span> {machine_chip}'
        f'<div class="commit-subject">{html.escape(row["subject"])}</div>'
        f'<div class="commit-badges">{"".join(badges)}</div>'
        '</div>'
    )


def _branch_annotation(name: str, is_merged: bool, is_local: bool) -> str:
    if name.startswith("release-"):
        return "phase branch — one PR per phase, merged only when the release checklist passes"
    if name == "dashboard-tooling":
        return "repo tooling branch — small standalone PR"
    if is_merged and is_local:
        return "PR merged; this local branch is safe to delete"
    return ""


def render_branch_card(b: dict) -> str:
    pr = b.get("pr")
    is_merged = bool(pr and pr.get("state") == "MERGED")
    if pr:
        state = pr.get("state", "")
        state_cls = {"MERGED": "chip-green", "OPEN": "chip-blue", "CLOSED": "chip-red"}.get(state, "chip-neutral")
        pr_badge = f'<a class="chip {state_cls}" href="{html.escape(pr.get("url") or "")}">{html.escape(state)} #{pr["number"]}</a>'
        merge_info = ""
        if is_merged:
            merged_at = (pr.get("mergedAt") or "")[:10]
            merge_sha = ((pr.get("mergeCommit") or {}).get("oid") or "")[:7]
            merge_info = (
                f'<div class="branch-detail">merged {html.escape(merged_at)}'
                + (f" ({html.escape(merge_sha)})" if merge_sha else "")
                + "</div>"
            )
    else:
        pr_badge = '<span class="chip chip-neutral">no PR yet</span>'
        merge_info = ""

    ci = b.get("ci_latest")
    ci_html = ""
    if ci:
        concl = ci.get("conclusion") or ci.get("status") or "unknown"
        ci_cls = "chip-green" if concl == "success" else "chip-red" if ci.get("conclusion") else "chip-neutral"
        ci_html = (
            '<div class="branch-detail">R-CMD-check: '
            f'<a class="chip {ci_cls}" href="{html.escape(ci.get("url") or "")}">{html.escape(concl)}</a></div>'
        )

    machine = b.get("machine")
    machine_chip = f'<span class="chip chip-neutral machine-chip">{html.escape(machine)}</span>' if machine else ""
    current_chip = '<span class="chip chip-cyan">current branch</span>' if b.get("current") else ""
    annotation = _branch_annotation(b["name"], is_merged, b.get("local", False))
    annotation_html = f'<div class="branch-annotation">{html.escape(annotation)}</div>' if annotation else ""

    return (
        '<div class="branch-card">'
        f'<div class="branch-name"><code>{html.escape(b["name"])}</code>{current_chip}{machine_chip}</div>'
        f'<div class="branch-detail">{b["behind"]} behind, {b["ahead"]} ahead of main</div>'
        f'<div class="branch-detail">{pr_badge}</div>'
        f'{merge_info}{ci_html}{annotation_html}'
        '</div>'
    )


def render_branches_tab(model: dict, sections: dict[str, Section]) -> str:
    git_sec = sections["git"]
    gh_sec = sections["gh"]
    git = git_sec.data or {}
    mainline = git.get("mainline", [])
    branches = git.get("branches", [])
    legacy = git.get("legacy_branches", [])

    mainline_full_shas = {row["full"] for row in mainline}
    branches_by_base: dict[str, list[dict]] = {}
    unmatched: list[dict] = []
    for b in branches:
        base = b.get("merge_base")
        if base in mainline_full_shas:
            branches_by_base.setdefault(base, []).append(b)
        else:
            unmatched.append(b)

    grid_rows = []
    for row in mainline:
        cards = "".join(render_branch_card(b) for b in branches_by_base.get(row["full"], []))
        grid_rows.append(
            '<div class="lane-row">'
            f'<div class="lane-main">{render_mainline_row(row)}</div>'
            f'<div class="lane-branches">{cards}</div>'
            '</div>'
        )

    if unmatched:
        cards = "".join(render_branch_card(b) for b in unmatched)
        grid_rows.append(
            '<div class="lane-row lane-row-unmatched">'
            '<div class="lane-main"><em>merge-base not on main’s first-parent chain '
            '— typically a squash-merged branch whose real ancestry diverged from '
            'the mainline commits shown at left</em></div>'
            f'<div class="lane-branches">{cards}</div>'
            '</div>'
        )

    legacy_items = "".join(
        f'<li><code>{html.escape(b["name"])}</code> — last commit {html.escape(b["date"][:10])}</li>'
        for b in legacy
    )
    legacy_html = (
        f'<details class="legacy-details"><summary>Pre-modernization history ({len(legacy)})</summary>'
        f'<ul>{legacy_items}</ul></details>'
        if legacy else ""
    )

    info_findings = [f for f in model.get("consistency", []) if f.get("level") == "info"]
    info_html = ""
    if info_findings:
        items = "".join(f"<li>{html.escape(f['message'])}</li>" for f in info_findings)
        info_html = f'<div class="panel"><p><strong>Housekeeping</strong></p><ul>{items}</ul></div>'

    body = f'<div class="lane-grid">{"".join(grid_rows)}</div>{legacy_html}{info_html}'
    return render_section_warnings(git_sec, gh_sec) + body


# ---------------------------------------------------------------------------
# Decisions tab
# ---------------------------------------------------------------------------

def render_decisions_tab(sections: dict[str, Section]) -> str:
    dec_sec = sections["decisions"]
    dec = dec_sec.data or {}
    settled = dec.get("settled", [])
    open_q = dec.get("open", [])

    settled_headers = ["date", "ref", "decision", "rationale", "binds"]
    settled_rows = "".join(
        "<tr>" + "".join(f"<td>{md_inline(html.escape(row.get(h, '')))}</td>" for h in settled_headers) + "</tr>"
        for row in settled
    )
    settled_table = (
        "<table><thead><tr><th>Date</th><th>Ref</th><th>Decision</th><th>Rationale</th><th>Binds</th></tr></thead>"
        f"<tbody>{settled_rows}</tbody></table>"
    )

    groups: dict[str, list[dict]] = {}
    order: list[str] = []
    for row in open_q:
        gate = row.get("gate", "") or "(no gate)"
        if gate not in groups:
            groups[gate] = []
            order.append(gate)
        groups[gate].append(row)

    group_blocks = []
    for gate in order:
        rows_html = "".join(
            "<tr>"
            f"<td>{md_inline(html.escape(r.get('ref', '')))}</td>"
            f"<td>{md_inline(html.escape(r.get('question (short)', '')))}</td>"
            f"<td>{md_inline(html.escape(r.get('recommended default (review §3)', '')))}</td>"
            "</tr>"
            for r in groups[gate]
        )
        group_blocks.append(
            f'<h3>{html.escape(gate)}</h3>'
            "<table><thead><tr><th>Ref</th><th>Question</th><th>Recommended default</th></tr></thead>"
            f"<tbody>{rows_html}</tbody></table>"
        )

    body = f"<h2>Settled</h2>{settled_table}<h2>Open — settle at phase gates</h2>{''.join(group_blocks)}"
    return render_section_warnings(dec_sec) + body


# ---------------------------------------------------------------------------
# Release & CI tab
# ---------------------------------------------------------------------------

def render_release_tab(model: dict, sections: dict[str, Section]) -> str:
    description = model.get("description") or {}
    news_sec = sections["news"]
    news = news_sec.data or {}
    version = description.get("version") or "unknown"

    dev = news.get("dev")
    releases = news.get("releases") or []
    if dev:
        news_block = f'<h3>Unreleased changes (development version)</h3>{dev["html"]}'
    elif releases:
        latest = releases[0]
        news_block = f'<h3>Latest release — {html.escape(latest["version"])}</h3>{latest["html"]}'
    else:
        news_block = "<p>No NEWS entries found.</p>"

    gh = model.get("gh") or {}
    git = model.get("git") or {}
    branches = git.get("branches", [])
    if gh.get("source") == "live":
        stamp = f'live, fetched {html.escape(gh.get("fetched_at") or "")}'
    elif gh.get("source") == "cached":
        stamp = f'cached, fetched {html.escape(gh.get("fetched_at") or "")}'
    else:
        stamp = "no gh data available"

    ci_rows = "".join(
        "<tr>"
        f"<td><code>{html.escape(b['name'])}</code></td>"
        f"<td>{html.escape(((b.get('ci_latest') or {}).get('conclusion') or (b.get('ci_latest') or {}).get('status') or 'no runs'))}</td>"
        "</tr>"
        for b in branches
    )
    ci_table = (
        f'<p class="gh-stamp">{stamp}</p>'
        "<table><thead><tr><th>Branch</th><th>Latest R-CMD-check</th></tr></thead>"
        f"<tbody>{ci_rows}</tbody></table>"
    )

    checklist_sec = sections.get("release_checklist")
    checklist_html = (checklist_sec.data or {}).get("html", "") if checklist_sec else ""

    ledger = (sections["roadmap"].data or {}).get("ledger", []) if sections["roadmap"].data else []
    if ledger:
        ledger_rows = "".join(
            "<tr>" + "".join(f"<td>{md_inline(html.escape(v))}</td>" for v in row.values()) + "</tr>"
            for row in ledger
        )
        ledger_table = (
            "<table><thead><tr><th>Item</th><th>Owning repo</th><th>When</th></tr></thead>"
            f"<tbody>{ledger_rows}</tbody></table>"
        )
    else:
        ledger_table = "<p>No cross-repo follow-ups.</p>"

    body = (
        f'<h2>Version {html.escape(version)}</h2>{news_block}'
        f'<h2>CI status</h2>{ci_table}'
        f'<h2>Release checklist</h2>{checklist_html}'
        f'<h2>Cross-repo follow-ups</h2>{ledger_table}'
    )
    return render_section_warnings(sections["description"], news_sec, checklist_sec) + body


# ---------------------------------------------------------------------------
# Docs tab
# ---------------------------------------------------------------------------

def render_docs_tab(sections: dict[str, Section]) -> str:
    docs = [("readme", "README", "doc_readme"), ("claude", "CLAUDE.md", "doc_claude"), ("news", "NEWS.md", "doc_news")]
    subbuttons = "".join(
        f'<button data-docsub="{sid}" class="{_cls(i == 0, "active")}">{label}</button>'
        for i, (sid, label, _) in enumerate(docs)
    )
    panels = []
    for i, (sid, _label, key) in enumerate(docs):
        sec = sections.get(key)
        content_html = (sec.data or {}).get("html", "") if sec else ""
        warn_html = render_section_warnings(sec) if sec else ""
        hidden_attr = "" if i == 0 else " hidden"
        panels.append(f'<div class="docs-tab prose" id="docs-{sid}"{hidden_attr}>{warn_html}{content_html}</div>')
    return f'<div class="docs-subtabs">{subbuttons}</div>' + "".join(panels)


# ---------------------------------------------------------------------------
# Full page assembly
# ---------------------------------------------------------------------------

def render_page(model: dict, sections: dict[str, Section]) -> str:
    header_html = render_header(model, sections)
    cache_banner_html = render_gh_cache_banner(model.get("gh") or {})
    banner_html = render_consistency_banner(model)
    tabbar_html = render_tabbar()

    roadmap_body = render_roadmap_tab(model, sections)
    branches_body = render_branches_tab(model, sections)
    decisions_body = render_decisions_tab(sections)
    release_body = render_release_tab(model, sections)
    docs_body = render_docs_tab(sections)

    return (
        "<!doctype html>\n"
        '<html lang="en">\n<head>\n<meta charset="utf-8">\n'
        "<title>hdatools dashboard</title>\n"
        f"<style>{CSS_CONSTANT}</style>\n</head>\n<body>\n"
        '<div class="container">\n'
        f"{header_html}\n{cache_banner_html}\n{banner_html}\n{tabbar_html}\n"
        "<main>\n"
        f'<section id="tab-roadmap" class="tab">{roadmap_body}</section>\n'
        f'<section id="tab-branches" class="tab" hidden>{branches_body}</section>\n'
        f'<section id="tab-decisions" class="tab" hidden>{decisions_body}</section>\n'
        f'<section id="tab-release" class="tab" hidden>{release_body}</section>\n'
        f'<section id="tab-docs" class="tab" hidden>{docs_body}</section>\n'
        "</main>\n</div>\n"
        f"<script>{JS_CONSTANT}</script>\n"
        "</body>\n</html>\n"
    )

# ---------------------------------------------------------------------------
# main
# ---------------------------------------------------------------------------

def main() -> None:
    parser = argparse.ArgumentParser(description="hdatools development dashboard")
    parser.add_argument(
        "--offline",
        action="store_true",
        help="Skip gh CLI; use cached gh data if available",
    )
    parser.add_argument(
        "--check-only",
        action="store_true",
        help="Print consistency warnings and exit 0 (no HTML written)",
    )
    args = parser.parse_args()

    # Run all parsers through the fail-soft wrapper
    sections: dict[str, Section] = {}

    sections["description"] = run_section(
        "description", parse_description, ROOT / "DESCRIPTION"
    )
    sections["roadmap"] = run_section(
        "roadmap", parse_roadmap, PLANS / "ROADMAP.md"
    )
    sections["decisions"] = run_section(
        "decisions", parse_decisions, PLANS / "DECISIONS.md"
    )
    sections["phase_plan_0"] = run_section(
        "phase_plan_0",
        parse_phase_plan,
        PLANS / "phase-0-groundwork.md",
    )
    sections["phase_plan_2"] = run_section(
        "phase_plan_2",
        parse_phase_plan,
        PLANS / "phase-2-features-0.4.0.md",
    )
    sections["archive"] = run_section(
        "archive", parse_archive, PLANS
    )
    sections["news"] = run_section(
        "news", parse_news, ROOT / "NEWS.md"
    )
    sections["release_checklist"] = run_section(
        "release_checklist", parse_release_checklist, ROOT / "CLAUDE.md"
    )
    sections["doc_readme"] = run_section(
        "doc_readme", parse_doc_raw, ROOT / "README.md"
    )
    sections["doc_claude"] = run_section(
        "doc_claude", parse_doc_raw, ROOT / "CLAUDE.md"
    )
    sections["doc_news"] = run_section(
        "doc_news", parse_doc_raw, ROOT / "NEWS.md"
    )
    sections["git"] = run_section(
        "git", parse_git, ROOT
    )
    sections["gh"] = run_section(
        "gh", parse_gh, args.offline
    )

    model = build_model(sections)

    if args.check_only:
        any_warn = False
        for name, sec in sections.items():
            for w in sec.warnings:
                print(f"[{name}] {w}")
                any_warn = True
        if not any_warn:
            print("No parse warnings.")

        print()
        if model["consistency"]:
            for finding in model["consistency"]:
                print(f"[{finding['check']}] ({finding['level']}) {finding['message']}")
        else:
            print("No consistency warnings.")
        sys.exit(0)

    html_out = render_page(model, sections)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(html_out, encoding="utf-8", newline="\n")
    print(f"Dashboard written to {OUT}")


if __name__ == "__main__":
    main()
