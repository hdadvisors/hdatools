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
        codes.append(f"<code>{html.escape(m.group(1))}</code>")
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
# Stub renderer (Session 1 — replaced in Session 3)
# ---------------------------------------------------------------------------

def render_stub(sections: dict[str, Section]) -> str:
    lines = [
        "<!doctype html>",
        "<html lang='en'><head><meta charset='utf-8'>",
        "<title>hdatools dashboard (stub)</title></head><body>",
        "<h1>hdatools dashboard — stub</h1>",
        "<p>Parse layer complete. Full render in Session 3.</p>",
        "<ul>",
    ]
    for name, sec in sections.items():
        status = "ok" if sec.data is not None else "FAILED"
        warn_count = len(sec.warnings)
        lines.append(
            f"<li><strong>{html.escape(name)}</strong>: {status}"
            + (f" — {warn_count} warning(s)" if warn_count else "")
            + "</li>"
        )
    lines += ["</ul>", "</body></html>"]
    return "\n".join(lines)

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

    # Write stub HTML
    html_out = render_stub(sections)
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(html_out, encoding="utf-8", newline="\n")
    print(f"Dashboard written to {OUT}")


if __name__ == "__main__":
    main()
