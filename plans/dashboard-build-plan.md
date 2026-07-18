# Dashboard build — development dashboard for hdatools

| | |
|---|---|
| **Status** | Session 4 complete (visual refinement) — ready for PR |
| **Branch** | `dashboard-tooling` (off `main` at v0.3.0; this plan is committed on it) |
| **Target version** | none — repo tooling only; no R-package-tree changes, no release, no tag |
| **Entry criteria** | This plan committed on `dashboard-tooling`; design settled in [dashboard-build-prompt.md](dashboard-build-prompt.md) (superseded by this doc — executors need only this file) |
| **Exit criteria** | Generator produces `dashboard.html` from real repo data; all five tabs verified in a browser, including the offline (`--offline`) and no-plan-file paths; `update-dashboard.bat`, machine-trailer hook, `.gitignore` entries, and CLAUDE.md section landed; PR opened `dashboard-tooling` → `main` |

> **How to use this doc.** It follows the same template as the phase plans
> (header table, numbered sessions with goal / steps / verification / stop
> conditions, findings appended as work happens) — deliberately, so the
> dashboard's own phase-plan parser can parse the plan that built it. Each
> session is sized for one Claude session. At the end of a session, append
> what you learned to `## Findings` and update the **Status** row above —
> same convention as phase plans. All exploration is already done; the
> "Verified repo facts" section below is the evidence base. **Do not
> re-explore the repo**, and do not re-open settled design decisions — if
> implementation surfaces a genuine contradiction, stop and raise it with
> Jonathan.

## Ground rules

- **Python only.** One script, `plans/dashboard/generate_dashboard.py`, run
  with the system Python 3.13 (`python` on PATH; fallback
  `C:\Python313\python.exe`). Stdlib only — no pip installs. Never shell out
  to R. Subprocesses: only `git` and (optionally) `gh`.
- **Zero network at view time.** `dashboard.html` is opened from disk
  (`file://`). No CDN references, no external images, no fetches. All CSS/JS
  inline.
- **Output is gitignored; tooling is committed.** `dashboard.html` and
  `gh-cache.json` are generated and gitignored; the generator and `.bat` are
  committed.
- **Never touch the package tree**: `R/`, `man/`, `NAMESPACE`, `DESCRIPTION`,
  `docs/`, `tests/`, `vignettes/`. `^plans$` is already in `.Rbuildignore`,
  so nothing here affects `R CMD check` — keep it that way.
- **Parsers anchor on structure, never line numbers**: `## ` headings and
  pipe-table header rows. Tolerant by default.
- **Fail soft, always.** A section that fails to parse renders as an inline
  warning panel in its tab; the generator itself must never crash on bad
  input. (Mechanism specified below.)
- **The dashboard flags doc-lag; it never edits docs.** Consistency warnings
  tell Jonathan to fix the plan docs by hand.
- **Windows discipline**: pathlib everywhere; write files with
  `encoding="utf-8", newline="\n"`; subprocess with
  `text=True, encoding="utf-8", errors="replace"`.
- Commit messages: imperative mood, **no Claude/Anthropic co-author line**.

## Verified repo facts (reference — do not re-explore)

Gathered 2026-07-17 by direct inspection. Git/gh facts will drift as work
continues; the *conventions* are what the parsers depend on.

### Markdown conventions in `plans/`

All pipe tables repo-wide use the minimal `|---|---|` delimiter row — no
alignment colons, no padding. Headings are strictly `#`/`##`/`###`. Em-dash
`—` separates titles from qualifiers; en-dash `–` appears in ranges
(`§1.1–1.4`).

**ROADMAP.md** — H1, then a `> **Status:**` blockquote. Sections (all `##`):
`How to use this folder`, `Phase table`,
`Package hygiene conventions (standing rules)`,
`Phase-gate interview process`, `Cross-repo follow-ups ledger`.

- Phase table columns: `| Phase | Release | Branch | Scope | Plan file | Status |`.
  Phase cells like `0 — Groundwork`; Branch cells are backtick-quoted; Plan
  file cells are markdown links (possibly into `archive/`), or plain text
  `written at phase gate` / `none — deliberately unplanned`, and may carry a
  `(skeleton)` suffix after the link. Status cells: `**next up**`,
  `**done** — PR open, pending merge/tag`,
  `blocked by Phase 1 merge (gate: Q2, Q4, Q6–Q9)`, `deferred`.
- Gate table (under `## Phase-gate interview process`): `| Gate | Questions |`.
- Ledger (under `## Cross-repo follow-ups ledger`): `| Item | Owning repo | When |`.

**DECISIONS.md** — H1 + blockquote, then two `##` sections:

- `## Settled`: `| Date | Ref | Decision | Rationale | Binds |`. Date is ISO;
  Ref is `process`, `review`, or `Q1`…`Q10`; Decision cells lead with a bold
  phrase (`**Git flow:** …`).
- `## Open — settle at phase gates`:
  `| Ref | Question (short) | Recommended default (review §3) | Gate |`.
  Gate cell values: `Phase 1` / `Phase 2` / `Phase 3` / `n/a (fhfh repo)`.
  Grouping "by gate" = group rows on the Gate cell (rows are gate-ordered,
  not Q-number-ordered).

**Phase plans** (`phase-0-groundwork.md`, `phase-2-features-0.4.0.md`,
archived `phase-1-consolidation-0.3.0.md`):

- Open with `# Phase N — Name`, then a key/value table with an **empty
  header row** `| | |` over `|---|---|`; keys are bold first cells:
  `**Status**`, `**Branch**`, `**Target version**`, `**Entry criteria**`,
  `**Exit criteria**`. Exit criteria live in this table, not a section.
- Session headings are `##`: `## Session 1 (the only session): CI + survey + pkgdown`
  (colon form) or `## Session 1 — Safety net (design review item 1.6)`
  (em-dash form). Regex on `^## Session (\d+)`, then split title on first
  `:` or ` — `.
- Steps are `###` headings within a session (`### Step 1 — …`, `### Wrap-up`).
- Bold inline labels are the reliable intra-session anchors: `**Goal:**`,
  `**Steps:**`, `**Verification:**`, `**Stop here if:**`.
- Trailing `## Findings` section — heading may carry a parenthetical
  (`## Findings (filled in during the session)`), so anchor on the prefix.
  Empty findings = italic placeholder `*(none yet — phase not started)*`.
- Skeleton marker: `phase-2-features-0.4.0.md` has a leading blockquote
  containing "Skeleton only" and a header Status of
  `blocked — Phase 1 (…) not yet merged to main`.

**Archive** (`plans/archive/*.md`) — completion header is a blockquote
*before* the H1, first line `> **ARCHIVED — <short status>.**`, usually
ending "Kept for historical reference; content below is unedited." Files:
`phase-1-consolidation-0.3.0.md`, `hdatools-design-review.md`,
`hdatools-modernization.md`, `strip-text-diagnostic.md` all follow it.
**Exception: `hdatools-audit.md` has no header at all and its markdown is
backslash-escaped** (`\#`, `\*\*`, double-blank-line spacing). The archive
parser must swallow it: emit `{status: None, title: <best effort>}` plus a
soft warning, never an exception.

**NEWS.md** — one H1 per release: `# hdatools 0.3.0`. During dev the top
heading is `# hdatools (development version)`; right now (released 0.3.0)
there is **no** dev heading — handle both states. Bullets are `*` with
2-space hanging indent; `Internal-only:` prefix convention.

**DESCRIPTION** — standard DCF; parse with regex `^Version:\s*(\S+)` (line 4
today: `Version: 0.3.0`).

**Other parse targets**: `CLAUDE.md` `## Release checklist` section (numbered
list) feeds the Release & CI tab; `README.md` contains fenced code blocks and
exactly one local image `![](man/figures/hda_plot.png)` — no external badges.

### Git & GitHub state (snapshot 2026-07-17)

- **Local branches**: `dashboard-tooling` (current; 1 commit ahead of main),
  `docs/pathless-claude-md`, `main`, `phase-0-groundwork`,
  `post-0.2.0-cleanup`, `release-0.3.0`.
- **Remote-only legacy branches** (pre-modernization, footnote material):
  `jtk`, `jtk-repeat-pal`, `category-colors`, `showtext-knitr-fix`,
  `release-0.2.0`.
- **Tags**: `v0.1.7`, `v0.2.0`, `v0.3.0`. `main` tip = `7ae0e8f` = v0.3.0 =
  merge of PR #15.
- **Modernization-era boundary**: commit `5963754`
  ("Add hdatools design review plan (2026 modernization)", 2026-07-16), on
  the mainline. The Branches tab covers `5963754..main` plus era branches
  only.
- **Squash-merge gotcha (load-bearing):** PRs #13 and #14 were
  squash-merged — their head commits are *not* ancestors of `main`, so git
  ancestry cannot detect "merged". **gh PR state is the source of truth for
  merges**; `mergeCommit.oid` + `mergedAt` pin each merged branch to a
  mainline commit. PR #15 was a true merge commit.
- **gh CLI**: v2.96.0, authenticated to `hdadvisors/hdatools` (account
  knopfjt). Verified working, with field names confirmed live:
  - `gh pr list --state all --limit 50 --json number,title,state,headRefName,mergedAt,mergeCommit,url`
  - `gh run list --limit 30 --json workflowName,status,conclusion,headBranch,createdAt,url`
  - `state` values seen: `MERGED` (all 9 existing PRs). Workflows:
    `R-CMD-check` (the real CI; jobs R-CMD-check + ggplot2-devel) and
    `pages-build-deployment` (GitHub Pages noise — label or filter it).
- **CI triggers** (`.github/workflows/R-CMD-check.yaml`): push to
  `[main, phase-0-groundwork, 'release-*']` and PRs to `main`. So
  `dashboard-tooling` gets CI only via its PR.
- **CLAUDE.md sections in order**: Running R / The dev loop / Generated
  files / Testing conventions / Release checklist / Skills / Planning docs.

### Known doc-lag — the checker's acceptance test (do NOT "fix" these while building)

The plan docs currently lag git/gh reality in four ways. They are the live
proof the consistency checker works; leave them for Jonathan to fix after
the dashboard flags them:

1. ROADMAP Phase 0 status `**next up**` — but PR #14 (phase-0-groundwork) is
   MERGED.
2. ROADMAP Phase 1 status `**done** — PR open, pending merge/tag` — but PR
   #15 is MERGED and tag `v0.3.0` exists.
3. `phase-0-groundwork.md` still sits in `plans/`, not `plans/archive/`,
   despite its phase being merged.
4. `phase-2-features-0.4.0.md` header Status says Phase 1
   (`release-0.3.0`) "not yet merged to main".

Consequence: active-phase detection (spec below) will initially report
Phase 0 as active. That is **correct behavior** — the docs are the source of
intent; the banner is what tells Jonathan they've lagged.

## Architecture (settled — implement, don't redesign)

### File layout

```
plans/dashboard/
├── generate_dashboard.py    # committed — single file, stdlib only
├── update-dashboard.bat     # committed
├── githooks/
│   └── prepare-commit-msg   # committed — machine-trailer hook (see Machine tags)
├── dashboard.html           # generated — gitignored
└── gh-cache.json            # generated — gitignored
```

Keeping the hook under `plans/dashboard/` (rather than a top-level
`.githooks/`) means `^plans$` in `.Rbuildignore` already covers it — no new
ignore entry, no `R CMD check` exposure.

### Script skeleton

Single file; CSS and JS as module-level triple-quoted constants; HTML
assembled with small f-string helpers. Top-level constants:

```python
ROOT  = Path(__file__).resolve().parents[2]   # repo root
PLANS = ROOT / "plans"
CACHE = Path(__file__).parent / "gh-cache.json"
OUT   = Path(__file__).parent / "dashboard.html"
MODERNIZATION_SHA = "5963754"
LEGACY_BRANCHES = {"jtk", "jtk-repeat-pal", "category-colors",
                   "showtext-knitr-fix", "release-0.2.0"}
```

`main()` uses argparse with `--offline` (skip gh, use cache — this is also
the committed test hook) and `--check-only` (print warnings, exit 0, no HTML
write).

### Fail-soft mechanism (two layers)

1. **Hard failures.** A `Section` dataclass —
   `Section(name: str, data: Any | None, warnings: list[str])` — is the
   universal carrier. Every parser and the git/gh layers are invoked only
   through `run_section(name, fn, *args)`, which catches `Exception` and
   returns `Section(name, None, ["<name> failed: ExcType: msg"])`. Only
   `render_page` (pure string assembly) sits outside the net.
2. **Soft degradation.** Parsers return partial data plus warnings for
   recoverable oddities: ragged table row padded/truncated, unrecognized
   status cell passed through raw, archive file with no ARCHIVED header,
   session heading that didn't match the regex rendered as raw text.

Rendering: `panel(section, body_html)` prepends a `.warn-panel` box (⚠ +
bullet list of warnings) inside the affected tab; if `data is None` the box
is the whole panel. The page header shows a count of tabs carrying parse
warnings. No stack trace ever reaches the HTML.

### Markdown layer (pure Python, ~200 lines)

A minimal renderer — not a JS renderer in the page — because the parsing
layer already needs Python table/heading parsing, and rendering at
generation time keeps the Docs tab inside the fail-soft net.

- **Block**: ATX headings `#`–`####`; fenced code (contents escaped
  verbatim); pipe tables (minimal delimiter form); `-`/`*` unordered and
  `1.` ordered lists with hanging-indent continuation lines and one nesting
  level; blockquotes (including bold-led status blockquotes); paragraphs;
  `---` rules.
- **Inline** (applied after `html.escape`, in order): `` `code` ``
  (protected from further substitution), `**bold**`, `*italic*`,
  `[text](url)`, autolink bare `https://` URLs.
- **Images**: `![alt](path)` — relative path that exists under ROOT →
  `<img src="../../<path>">` (loads over `file://`, offline); anything else
  → `<em>[image: alt]</em>`. Never emit an external `<img>`.
- Raw HTML in source is escaped and shown literally.
- **Entry points**: `md_to_html(text)` (Docs tab) and `md_inline(text)`
  (table cells / status strings, inline rules only).
- **Shared helpers**: `parse_pipe_table(lines) -> (headers, rows, warnings)`
  (tolerant: pad/truncate ragged rows with a warning) and
  `split_h2_sections(text) -> dict[heading, body_lines]`.

### Parsers (each: `path -> (dict, warnings)`)

| Parser | Anchors | Returns |
|---|---|---|
| `parse_description` | regex `^Version:` | `{version}` |
| `parse_roadmap` | `## Phase table`, `## Phase-gate interview process`, `## Cross-repo follow-ups ledger`; fallback: first table whose header starts `\| Phase \|` | `{status_note, phases: [{phase, release, branch, scope, plan_file, plan_is_link, status}], gates, ledger}` |
| `parse_decisions` | `## Settled`, `## Open — settle at phase gates` | `{settled: [...], open: [...]}` (open rows keep raw Gate cell) |
| `parse_phase_plan` | first table with empty `\| \| \|` header (keys from bold first cells); `^## Session (\d+)`; `###` steps; leading blockquote "Skeleton only"; `## Findings` prefix | `{title, header: {status, branch, target_version, entry_criteria, exit_criteria}, is_skeleton, sessions: [{num, title, steps, done_state}], findings_html}` |
| `parse_archive` | per file: leading `> **ARCHIVED — <status>.**` blockquote + first H1 | `[{file, status, title}]`; header-less file → `status: None` + warning |
| `parse_news` | `^# hdatools ` headings | `{dev: {html} \| None, releases: [{version, html}]}` |

### Git layer (read-only, `cwd=ROOT`, timeout 15 s)

| Purpose | Command |
|---|---|
| branches + tips | `git for-each-ref refs/heads refs/remotes/origin --format=%(refname:short)\|%(objectname:short)\|%(committerdate:iso-strict)\|%(subject)` |
| ahead/behind vs main | `git rev-list --left-right --count main...<branch>` (left = behind, right = ahead) |
| branch point | `git merge-base main <branch>` |
| era membership | `git merge-base --is-ancestor 5963754 <merge-base-sha>` (rc 0 = in era) |
| mainline rows | `git log --first-parent --format=%h\|%H\|%cs\|%s 5963754^..main` |
| tags (deref annotated) | `git tag --list v* --format=%(refname:short)\|%(objectname:short)\|%(*objectname:short)\|%(creatordate:short)` |
| current branch | `git rev-parse --abbrev-ref HEAD` |
| dirty flag | `git status --porcelain` (non-empty → "uncommitted changes" chip in header) |

### gh layer with offline fallback

- Fetch commands: the two verified `gh pr list` / `gh run list` invocations
  above.
- Cache `gh-cache.json`:
  `{"fetched_at": <datetime.now().astimezone().isoformat()>, "prs": [...], "runs": [...]}`
  — raw gh JSON stored untransformed so live and cached paths share one
  downstream code path. Written atomically (`tempfile` in same dir +
  `os.replace`).
- **Failure detection** = any of: `subprocess.TimeoutExpired`,
  `FileNotFoundError` (gh not installed), nonzero return code (covers auth
  and gh's own network errors), `json.JSONDecodeError`. No network probing —
  gh failing *is* the offline signal.
- Behavior: success → refresh cache, PR/CI panels stamped
  "live, fetched <now>". Failure → load cache; if present, identical panels
  plus an orange banner "gh unavailable — showing cached data last fetched
  <fetched_at>" (add "cache is N days old" if > 7 days); if absent, PR/CI
  panels render as warning panels ("no gh data and no cache — run once
  online"); everything else unaffected.

### Active-phase detection

Normalize ROADMAP status cells (strip markdown, lowercase, take text before
any ` — `):

1. **Active** = first row whose status starts `next up`, `in progress`, or
   `active`.
2. Else first row that is not done-like (`done`, `merged`) and not
   `deferred` — label it "next phase (blocked)".
3. Else render a "no active phase" card.

Plan-file resolution for that row: extract the markdown link target from the
Plan file cell. Treat as **absent** if the cell has no link, says
`written at phase gate` / `none…`, or the path (relative to `plans/`)
doesn't exist → the Roadmap tab still renders the active-phase card from the
ROADMAP row alone (release, branch, scope, status) with the note *"No plan
file yet — drafted just-in-time at the phase gate (per ROADMAP
convention)."* An archive-pointing link → "archived" treatment. Skeleton
(cell suffix or file blockquote) → "skeleton — gate interview not held"
chip; suppress per-session done/undone claims.

Session done-state heuristic (cheap, honest): a session is "done" if the
plan's Findings section mentions `Session N`; otherwise "not started". The
card labels this as *inferred from findings*.

### Consistency checks (exactly these 7)

1. **Status vs PR** — phase row's Branch has a gh PR with state MERGED but
   row status isn't done-like. *(Fires today: Phase 0.)*
2. **Status vs tag** — phase row's Release has an existing `v<X>` tag but
   status isn't done-like. *(Fires today: Phase 1.)*
3. **Plan not archived** — phase whose PR is MERGED but whose plan file
   resolves under `plans/`, not `plans/archive/`. *(Fires today: phase-0.)*
4. **Version vs NEWS** — DESCRIPTION version without `.9000` must equal
   NEWS's top `# hdatools <ver>`; with a dev suffix, NEWS's top heading must
   be `(development version)`. *(Silent today: 0.3.0 matches.)*
5. **Stale phase-plan header** — active/blocked plan header Status says
   "not yet merged"/"pending" naming a branch whose PR is MERGED.
   *(Fires today: phase-2 skeleton.)*
6. **Merged branch still local** — local branch whose PR is MERGED →
   info-level "safe to delete" note in the Branches tab (not the banner).
7. **CI red** — latest `R-CMD-check` conclusion ≠ success for a live
   (unmerged) branch → banner warning.

Banner copy always ends: *"Fix the docs by hand — the dashboard never edits
them."*

### Machine tags (laptop/desktop chips on commits)

Git records no hostname, and every existing commit has identical
author/committer identity — so **past commits are permanently untaggable**;
the feature covers commits made after a one-time setup. The signal is a
`Machine: <name>` commit-message trailer added by a hook.

**Hook** — `plans/dashboard/githooks/prepare-commit-msg` (verbatim; LF line
endings, no BOM):

```sh
#!/bin/sh
# Adds a "Machine: <name>" trailer from `git config hda.machine`.
# No-op if hda.machine is unset, on merge/squash commits, or if a
# Machine: trailer is already present.
machine=$(git config hda.machine)
[ -n "$machine" ] || exit 0
case "$2" in merge|squash) exit 0 ;; esac
if ! grep -qi "^Machine:" "$1"; then
    git interpret-trailers --in-place --trailer "Machine: $machine" "$1"
fi
```

**One-time setup, run by Jonathan on each machine** (not by an executor
session — it changes per-machine git config):

```bash
git config --global hda.machine laptop      # or: desktop
git config core.hooksPath plans/dashboard/githooks   # per repo clone
```

`hda.machine` is global (names the machine once, reusable by other repos);
`core.hooksPath` is per-clone. Until both are set on a machine, its commits
simply carry no trailer — the dashboard renders no chip, which is also the
correct display for all pre-existing commits and for GitHub-created
merge/squash commits (authored server-side, never tagged).

**Dashboard side:** append `%(trailers:key=Machine,valueonly)` as a final
field to the mainline `git log --first-parent` format; for branch cards, get
the tip commit's trailer with `git log -1 --format=%(trailers:key=Machine,valueonly) <branch>`.
Render a small neutral (base-tone) chip with the machine name next to the
commit/card when the value is non-empty; render nothing when empty. Treat
the trailer value as untrusted text (escape it).

### The five tabs

1. **Roadmap** — current version prominent in the page header (shared by all
   tabs) plus here; phase table as rows/cards with status badges; the active
   phase expanded: sessions with done / in-progress / not-started, entry and
   exit criteria from the header table; the gate-questions table.
2. **Branches & PRs** — **HTML/CSS two-column lane layout, not SVG** (the
   era has ~3 mainline commits and ≤ 4 branches; squash merges mean true
   topology isn't in git anyway — the semantic model is more truthful and
   trivially annotatable). Left column, the **main lane**: first-parent
   commits `5963754..main` newest-first, each a dot on a continuous vertical
   line with short SHA, date, subject, and badges for tags and PR merges
   ("merges PR #15 ← release-0.3.0"). Right column: **branch cards** aligned
   beside their merge-base row, each with: branch name (+ "current branch"
   marker), ahead/behind counts, PR badge (MERGED/OPEN/CLOSED #N, link) or
   "no PR yet", merge commit + date if merged, latest `R-CMD-check`
   conclusion for that branch, and a **plain-language learning-aid
   annotation** chosen by branch-name convention: `release-*` → "phase
   branch — one PR per phase, merged only when the release checklist
   passes"; `dashboard-tooling` → "repo tooling branch — small standalone
   PR"; merged-but-still-local → "PR merged; this local branch is safe to
   delete". Era filter: branch's merge-base with main is a descendant of
   `5963754` AND branch not in `LEGACY_BRANCHES`. Legacy remote branches go
   in a `<details>` "Pre-modernization history" footnote as a plain list
   with last-commit dates.
3. **Decisions** — settled table rendered as-is; open questions grouped by
   Gate cell value with the phase gate as group heading.
4. **Release & CI** — version + NEWS dev bullets (when no dev heading
   exists, show the latest release's notes labeled as such); latest CI run
   per branch with the live/cached stamp; the release-checklist steps parsed
   from CLAUDE.md `## Release checklist`; the cross-repo ledger table.
5. **Docs** — rendered CLAUDE.md / README.md / NEWS.md behind a nested
   sub-switcher, regenerated fresh each run.

### Tabs, JS, and colors

- **JS (~35 lines, vanilla)**: one delegated click handler on the tab bar
  toggling `hidden` + `.active` and writing `location.hash`
  (`#roadmap`, …); Docs sub-switcher same pattern nested
  (`#docs/readme`); restore from hash on load. Deep-linkable, refresh-safe,
  no storage APIs — fully `file://`-safe. `<details>/<summary>` for all
  collapsibles (zero JS).
- **CSS (~120–150 lines)**: utilitarian — system font stack, max-width
  container, sticky tab bar, badge/chip classes, `.warn-panel`, the lane
  grid. No animation, no framework.
- **Colors: Flexoki ([kepano/flexoki](https://github.com/kepano/flexoki)),
  minimal subset only** — ~12 CSS variables inlined in the CSS constant,
  light theme only. Verify exact hexes against the Flexoki README when
  implementing. Neutrals: `paper` #FFFCF0 (page bg), `black` #100F0F (text),
  base-50 #F2F0E5 / base-100 #E6E4D9 (panel bg / borders), base-600 #6F6E69
  (muted text). Semantic accents, 600-weight, each with one job:
  **green** = done/merged/CI-pass badges; **orange** = warnings, stale-cache
  banner, blocked status; **red** = errors/CI-fail/failed-parse panels;
  **blue** = links, active tab, info chips; **cyan** = current-branch
  marker. Everything else stays neutral. Do not pull in the full palette.

### update-dashboard.bat (verbatim)

```bat
@echo off
setlocal
cd /d "%~dp0"
set "PY=python"
where python >nul 2>nul || set "PY=C:\Python313\python.exe"
"%PY%" generate_dashboard.py %*
if errorlevel 1 (
    echo.
    echo Dashboard generation FAILED. See message above.
    pause
    exit /b 1
)
start "" "%~dp0dashboard.html"
endlocal
```

(`start "" "<path>"` — the empty title argument is mandatory with a quoted
path; `%*` passes `--offline` through; `pause` only on failure.)

### .gitignore additions (verbatim)

```
# development dashboard (generated)
plans/dashboard/dashboard.html
plans/dashboard/gh-cache.json
```

### CLAUDE.md section

New `## Development dashboard` between `## Skills` and `## Planning docs`,
~6 lines: local HTML dashboard at `plans/dashboard/` tracking phases,
branches/PRs, decisions, and release state; **re-run the generator after any
commit that changes project state** (phase status, NEWS, DESCRIPTION,
branch/PR changes) via `python plans/dashboard/generate_dashboard.py`, or
double-click `plans\dashboard\update-dashboard.bat` to regenerate and open;
`dashboard.html` and `gh-cache.json` are gitignored; the plan docs are the
source of truth — when the dashboard shows consistency warnings, fix the
docs by hand, never treat the dashboard as authoritative.

## Session 1 — Parse layer

**Goal:** `generate_dashboard.py` exists with the skeleton, markdown layer,
and all six parsers working against the real repo files. No git/gh/rendering
yet (stub HTML output is fine).

**Steps:**

1. Create `plans/dashboard/` and the script skeleton: constants, `run()`
   subprocess helper, `Section` dataclass, `run_section()`, argparse
   (`--offline`, `--check-only`), and a `main()` that writes a stub page
   (UTF-8, `newline="\n"`). Confirm the stub opens via `file://`. Also
   create `githooks/prepare-commit-msg` verbatim from the Machine tags
   section (LF endings — it runs under Git's sh).
2. Markdown layer: `md_inline`, `md_to_html`, `parse_pipe_table`,
   `split_h2_sections`, per the spec above. Smoke-render NEWS.md.
3. Parsers, in order: `parse_description` → `parse_roadmap` →
   `parse_decisions` → `parse_phase_plan` → `parse_archive` → `parse_news`.
   Test `parse_phase_plan` against **both** `phase-2-features-0.4.0.md`
   (skeleton, blocked) and `archive/phase-1-consolidation-0.3.0.md`
   (em-dash session titles, filled findings).

**Verification:** drive each parser from a temp test script run with
`python` against the real files (write the script to the session scratchpad,
not the repo): NEWS renders to sane HTML; ROADMAP yields 5 phases with the
statuses quoted in "Known doc-lag"; DECISIONS yields settled + gate-grouped
open rows; both phase plans parse; `hdatools-audit.md` returns
`status: None` + warning, no exception; a deliberately ragged table row is
padded with a warning.

**Stop here if:** any parser needs more than one special case per file
beyond those documented above — that means a convention drifted since
2026-07-17; re-read the actual file and update this doc's facts section,
don't guess.

## Session 2 — Data layer

**Goal:** git layer, gh layer with cache/offline, active-phase detection,
and all 7 consistency checks produce a complete, sane model dict.

**Steps:**

1. Git layer: the 8 commands in the table above, each via `run()` through
   `run_section()`. Build the era branch model: for each local/remote
   branch, merge-base vs main, ahead/behind, era membership
   (`--is-ancestor 5963754`), LEGACY_BRANCHES exclusion; mainline rows
   `5963754^..main`; tags with dereference. Include the `Machine:` trailer
   field on mainline rows and branch tips (Machine tags section); empty for
   every commit until Jonathan runs the per-machine setup — that must not
   warn.
2. gh layer: fetch, atomic cache write, cache read, `--offline`
   short-circuit, the four failure modes. Join PR data onto branches by
   `headRefName` (this is what marks squash-merged branches as merged) and
   CI runs by `headBranch`, keeping only `R-CMD-check` (label
   `pages-build-deployment` separately or drop it).
3. Active-phase detection per spec, including the absent-plan-file and
   skeleton paths.
4. The 7 consistency checks; `--check-only` prints them and exits 0.

**Verification:** `--check-only` fires **exactly the four expected doc-lag
warnings** (Phase 0 status-vs-PR, Phase 1 status-vs-tag, phase-0 plan not
archived, phase-2 stale header) and **not** version-vs-NEWS; `--offline`
with cache present uses it and stamps the fetched-at time; `--offline` with
the cache deleted degrades to warnings without crashing; the branch model
shows `release-0.3.0` and `phase-0-groundwork` as MERGED (via gh, despite
squash merges) and `dashboard-tooling` as current, 1 ahead. If the git/gh
state has drifted from the snapshot (more commits on `dashboard-tooling`, a
new PR), verify against live reality — the snapshot documents conventions,
not eternal facts.

**Stop here if:** gh output shapes differ from the verified field lists
(gh version drift) — adapt the field list and note it in Findings rather
than working around it silently.

## Session 3 — Render + ship

**Goal:** full HTML rendering, the `.bat`, ignore rules, CLAUDE.md section,
end-to-end verification, commit + PR.

**Steps:**

1. CSS constant (Flexoki subset per spec) and JS constant (hash tabs).
2. Renderers: page chrome (header with version, generated-at timestamp,
   dirty chip, warnings banner; tab bar), then Roadmap, Branches & PRs
   (lane layout), Decisions, Release & CI, Docs.
3. `update-dashboard.bat` (verbatim above), `.gitignore` additions,
   CLAUDE.md `## Development dashboard` section.
4. End-to-end verification (below), then update this doc's Status row and
   Findings, and propose the commit.

**Verification (the full checklist):**

1. `python plans/dashboard/generate_dashboard.py` exits 0; `gh-cache.json`
   stamped today.
2. Open `dashboard.html` in the browser pane (`file://`). Walk all five
   tabs, the Docs sub-switcher, the legacy `<details>` footnote; reload with
   a `#decisions` hash and confirm tab restore.
3. The banner shows the four expected doc-lag warnings (unless Jonathan has
   fixed the docs by then) and no version-vs-NEWS warning; banner ends with
   the "fix the docs by hand" line.
4. Offline path: `--offline` → orange cached-data banner with stamp, all
   other tabs identical. Delete `gh-cache.json` + `--offline` → PR/CI
   warning panels only, no crash. Run once with gh genuinely unreachable
   (e.g. a shell whose PATH lacks gh) to prove failure *detection*.
5. No-plan-file path: copy ROADMAP.md to the scratchpad, edit the active
   row's Plan file cell to `written at phase gate`, point the parser at the
   copy from a scratch test script → "No plan file yet" card renders.
   Confirm the skeleton chip on Phase 2's row against the real file.
6. Fail-soft: confirm the archive panel shows the `hdatools-audit.md`
   warning inline; feed one parser a garbage file from the scratchpad and
   confirm a warning panel, not a crash.
6b. Machine tags: with the hook configured (`core.hooksPath` +
   `hda.machine` set — if Jonathan hasn't run the setup yet, set both
   temporarily, then unset `core.hooksPath` after), make a scratch commit on
   `dashboard-tooling`, confirm the trailer lands and the chip renders, then
   keep or amend that commit as part of the session's real work. Confirm
   untagged commits render with no chip.
7. Repo hygiene: `git status --porcelain` shows only
   `plans/dashboard/generate_dashboard.py`, `plans/dashboard/update-dashboard.bat`,
   `plans/dashboard/githooks/prepare-commit-msg`,
   `.gitignore`, `CLAUDE.md`, and this plan's edits; `dashboard.html` and
   `gh-cache.json` are invisible to git. No package-tree file touched, so
   `devtools::check()` is unaffected by construction — no need to run it.
8. Run `update-dashboard.bat` from a terminal: regenerates and opens the
   default browser. Break the script deliberately once (e.g. bad flag) to
   confirm the pause-on-failure path, then restore.

**Stop here if:** anything requires touching the package tree, a pip
install, or a network resource in the HTML — those violate settled
constraints; raise it instead.

**Wrap-up:** suggest a commit on `dashboard-tooling` (imperative mood, no
co-author line), then a small PR `dashboard-tooling` → `main` titled
"Add development dashboard tooling".

## Findings (filled in during sessions)

### Session 1 — 2026-07-17

**Outcome:** all 27 parser assertions pass; `--check-only` emits exactly the one expected warning (`hdatools-audit.md: no ARCHIVED header`); stub HTML generated successfully.

**Implementation notes:**

- `hdatools-audit.md` backslash-escaped headings (`\#`, `\##`) handled in `parse_archive` via a fallback `^\\#\s+` regex for title extraction; status correctly returns `None` with warning.
- `parse_phase_plan` header-table parser anchors on the `| | |` empty-header sentinel row then reads bold-first-cell rows; correctly parses both phase-1 (archive, em-dash session titles) and phase-2 (skeleton, colon form) without special-casing.
- `md_to_html` uses line-by-line state machine; code spans are protected with a sentinel before bold/italic substitution to prevent double-processing.
- `NEWS.md` currently has no dev-version heading (released state); `parse_news` returns `dev=None`, first release `0.3.0` — both correct.
- ROADMAP parser correctly identifies all 5 phases; gate and ledger tables parse cleanly.
- DECISIONS: 8 settled rows, 10 open rows confirmed.
- Git hook written with LF-only line endings (0 CRLF); confirmed via byte scan.

**No convention mismatches found** relative to the verified repo facts documented above.

### Session 2 — 2026-07-17

**Pre-check on Session 1's commit:** found one genuine oopsie —
`plans/dashboard/__pycache__/generate_dashboard.cpython-314.pyc` (compiled
bytecode) had been committed alongside the source. Removed it from tracking
(`git rm --cached`) and added `__pycache__/` to `.gitignore` so it can't
recur. Everything else in the commit (the stub `dashboard.html`, the LF-only
hook) checked out fine; all 27 Session 1 assertions still pass.

**Outcome:** `--check-only` fires exactly the four expected doc-lag
warnings and no version-vs-NEWS warning; `--offline` with cache present
loads it and stamps the original `fetched_at`; deleting the cache and
running `--offline` degrades cleanly (empty `prs`/`runs`, a warning, no
crash — and correctly makes the PR-dependent checks 1/3/5 go silent, since
without PR data the script can't claim a branch *isn't* merged). Live `gh`
fetch round-trips through the atomic cache write correctly.

**Live-state drift from the plan's 2026-07-17 snapshot (expected per the
plan's own caveat — verified against reality, not treated as a bug):**

- Local branches `phase-0-groundwork` and `release-0.3.0` no longer exist
  (deleted after their PRs merged) — only `dashboard-tooling`, `main`, and
  `release-0.2.0` remain local. The era branch model still surfaces both via
  their `origin/*` refs, joined to MERGED PRs #14 and #15 by `headRefName`,
  so check 6 ("merged branch still local") correctly finds nothing to flag.
- `dashboard-tooling` is **3 ahead** of `main`, not 1 — two more commits
  (the build plan and build prompt) landed after the snapshot was taken.
- `post-0.2.0-cleanup` and `docs/pathless-claude-md` land in the *legacy*
  bucket, not the era bucket, despite not being in `LEGACY_BRANCHES` by
  name: their merge-bases with `main` predate the `5963754` modernization
  commit chronologically (both PRs were opened and merged against an older
  `main`, before the modernization plan landed), so the era filter
  (descendant of `5963754`) correctly excludes them. This is real git
  topology, not a bug — the plan's era-filter rule already covers it ("branch
  not in LEGACY_BRANCHES" is an *or*-exclusion, not the only one).

**Implementation notes:**

- `git for-each-ref refs/heads refs/remotes/origin` includes the
  `refs/remotes/origin/HEAD` symref, whose `%(refname:short)` collapses to
  the bare string `origin` (not `origin/HEAD`) — a real gotcha that would
  silently manufacture a fake "origin" branch card. Fixed by also fetching
  `%(refname)` (the full ref) and filtering on the unambiguous full name
  `refs/remotes/origin/HEAD`, rather than guessing the short form.
- **"Done-like" needed two different definitions to reproduce the four
  expected warnings, not one shared helper.** Check 1 (status vs PR) uses
  the same prefix-before-em-dash normalization as active-phase detection
  (`_status_prefix`) — Phase 1's status "**done** — PR open, pending
  merge/tag" normalizes to prefix `done`, so check 1 correctly stays quiet
  on it. Check 2 (status vs tag) needs a *stricter* test
  (`_status_is_cleanly_done`) — the full normalized string must equal
  exactly `done`/`merged` with no trailing qualifier — because the
  qualifier itself ("pending merge/tag") is precisely what makes that row
  stale against the now-existing `v0.3.0` tag. Using either definition for
  both checks either double-fires check 1 on Phase 1 or silences check 2 on
  Phase 1 — both wrong. Checks 3, 5, 6, 7 don't use a done-like test at all
  (their own wording doesn't call for one).
- Tags are dereferenced via `%(*objectname:short)` (falls back to
  `%(objectname:short)` for lightweight tags) and matched to mainline rows
  by short SHA — safe here since this repo's short-hash length is
  consistently 7 across both `git tag` and `git log`.
- Mainline rows and branches both get PR/tag data joined in via
  `attach_pr_and_ci_to_branches` / `attach_pr_and_tags_to_mainline`, kept as
  separate mutating helpers so Session 3's renderer can use the same
  `model["git"]` dict without re-deriving joins.
- `core.autocrlf=true` is set globally on this machine, so git prints an "LF
  will be replaced by CRLF" warning when `dashboard.html`/`generate_dashboard.py`
  are staged — harmless (it only affects the working-tree checkout view, not
  the committed blob or the script's own `newline="\n"` writes), and not
  something to fix here (pre-existing machine config, out of scope).

**No convention mismatches found beyond the two noted above** (the
`origin/HEAD` short-ref quirk and the two-tier done-like definition), both
resolved as documented.

### Session 3 — 2026-07-17

**Outcome:** full HTML rendering shipped (CSS/JS constants, page chrome, all
five tabs), `update-dashboard.bat`, `.gitignore` entries, and the CLAUDE.md
`## Development dashboard` section all landed. Flexoki hexes verified
byte-for-byte against `kepano/flexoki`'s README (via `gh api
repos/kepano/flexoki/contents/README.md`) — all 10 constants in the spec
matched exactly, no adjustment needed. Full verification checklist (8 items)
passed; two genuine, non-obvious things surfaced along the way, both fixed
in this session (not deferred):

1. **Real bug, Session 1 layer, first visible now:** `md_inline`'s code-span
   protection re-escaped its already-html-escaped input
   (`html.escape(m.group(1))` on text that was, by the function's own
   contract, already escaped by the caller). Invisible in Session 1/2
   because nothing was ever rendered in a browser; visible the moment
   DECISIONS.md's `` `add_zero_line("x"/"y")` `` cell rendered as literal
   `&quot;` text instead of a quote mark. Fixed by dropping the second
   `html.escape()` call — `m.group(1)` is wrapped in `<code>` as-is now.
   Worth a grep for other double-escape sites if the markdown layer is
   touched again.
2. **Not a bug — a real git-topology consequence of the squash-merge
   gotcha the plan already flagged.** The lane layout aligns branch cards
   to their `git merge-base` row. For `phase-0-groundwork` and
   `release-0.3.0` (both squash-merged, both deleted locally, both joined
   via `gh` PR data instead of ancestry), the actual `git merge-base main
   <ref>` result is **not** one of the 3 first-parent mainline commits —
   it's a real, in-era commit (verified: descendant of `5963754`) that
   simply isn't on `main`'s first-parent chain, because squash-merging
   severed the branch's real ancestry from main's linear history. Only
   `dashboard-tooling` (never squash-merged, still live) aligns cleanly.
   Rather than force a misleading alignment, added an honest fallback row
   ("merge-base not on main's first-parent chain — typically a
   squash-merged branch...") for branches whose merge-base doesn't match a
   shown mainline row. This will recur for every future squash-merged,
   subsequently-deleted branch — expected, not a regression.

**Verification checklist — all 8 items passed:**

1. Generator exits 0; `gh-cache.json` stamped same-day.
2. All five tabs, the Docs sub-switcher, and the legacy `<details>`
   footnote walked in a browser; `#decisions` hash-reload correctly
   restored the Decisions tab on load.
3. Banner fired exactly the 4 documented doc-lag warnings, no
   version-vs-NEWS warning, ended with the "fix the docs by hand" line.
4. `--offline` with cache present → orange cached-data banner with the
   correct stamp. Cache deleted + `--offline` → clean degrade (no crash,
   exit 0), and correctly silenced checks 1/3/5 (PR-dependent) while check
   2 (tag-only) still fired — matching Session 2's documented two-tier
   behavior. Ran once with a **genuinely gh-less PATH** (`env -i PATH=...`
   excluding GitHub CLI's directory, no `--offline` flag) — confirmed real
   failure *detection*: `FileNotFoundError` caught, fell back to cache,
   correct banner. Not a simulation of the offline flag; gh was actually
   unreachable.
5. No-plan-file path: copied ROADMAP.md to the scratchpad, changed Phase
   0's Plan file cell to `written at phase gate`, drove `parse_roadmap` +
   `resolve_plan_file` + `render_active_phase_card` against the copy from a
   scratch script → resolved state `absent`, "No plan file yet" note
   rendered. Also drove the skeleton path directly (Phase 2 isn't the
   currently-active phase, so the active-card skeleton branch needed its
   own scratch exercise): resolved state `skeleton`, chip rendered.
6. Fed a garbage file to `parse_decisions` and `parse_phase_plan` via
   `run_section` — both returned warnings, no exception; confirmed the
   resulting `warn-panel` HTML renders correctly. Archive panel's
   `hdatools-audit.md: no ARCHIVED header` line confirmed inline in the
   browser.
6b. `hda.machine` was already set globally (`jtk-desktop`) from a prior
   session; `core.hooksPath` was not set for this clone. Set it
   temporarily, confirmed the hook script directly (invoked against scratch
   commit-message files, not a real commit — see note below): adds the
   trailer, no-ops on `merge`/`squash` sources, no-ops when a trailer is
   already present. Confirmed `render_mainline_row` shows the machine chip
   only when the trailer is non-empty. **Did not make a scratch commit** —
   my standing instructions require your go-ahead before any commit, and
   the plan's own phrasing ("keep or amend that commit as part of the
   session's real work") means the scratch commit was always meant to
   become the real one. Unset `core.hooksPath` again afterward per the same
   instructions (default: don't leave git config changed without being
   asked to keep it). **Once you approve the Session 3 commit below, if
   `core.hooksPath` is set at commit time it'll carry the trailer
   naturally** — recommend re-running
   `git config core.hooksPath plans/dashboard/githooks` before committing,
   since `hda.machine` is already in place and this is the last piece of
   the one-time setup.
7. `git status --porcelain` hygiene: found `plans/dashboard/dashboard.html`
   was still git-tracked (committed as the Session 1 stub, before
   `.gitignore` covered it) — `.gitignore` alone doesn't untrack an
   already-tracked file. Ran `git rm --cached` to untrack it (working-tree
   file untouched, now shows `!!`/ignored). `gh-cache.json` was already
   untracked, now correctly ignored. Final `--porcelain` output: only
   `.gitignore`, `CLAUDE.md`, `plans/dashboard/generate_dashboard.py`
   (modified), `plans/dashboard/dashboard.html` (staged deletion from
   index), and `plans/dashboard/update-dashboard.bat` (new, untracked) —
   matches the plan's expected file list exactly (`githooks/prepare-commit-msg`
   needed no changes, already committed in Session 1). No package-tree file
   touched.
8. `update-dashboard.bat` run from a real terminal (PowerShell, `cmd /c`):
   success path regenerated and exited 0. Failure path (`--bogus-flag-xyz`,
   stdin piped so `pause` didn't hang the session) printed "Dashboard
   generation FAILED. See message above." and `Press any key to continue`,
   confirming the errorlevel branch and `pause` both fire correctly, then
   exited 1.

**Tooling note (not a product bug):** the browser-preview tool used for
verification cannot actually load `file://` paths outside its own mounted
root — `navigate` reports success but the tab silently shows a frozen
snapshot from first load, never picking up regenerated content. Worked
around by serving `plans/dashboard/` via a throwaway local
`python -m http.server` on `127.0.0.1` for verification purposes only; the
shipped product is unaffected and still opens via plain `file://` per spec
(`update-dashboard.bat` uses `start "" "dashboard.html"`, no server
involved).

**No package-tree files touched; no pip installs; no network reference in
the generated HTML** (the only external URLs in the rendered output are gh's
own PR/CI links, which is expected — not a resource the page loads).

### Session 4 — visual refinement (2026-07-17)

Interview-driven polish pass over the rendered dashboard; generator
architecture unchanged (still one stdlib-only script, no network at view
time). What changed:

- **GitHub links throughout.** `repo_url` parsed from DESCRIPTION `URL:`;
  mainline SHAs → `/commit/<full>`, remote branches → `/tree/<name>`, tags →
  `/releases/tag/<name>`, ledger repos → org URL; PR/CI links now
  `target="_blank" rel="noopener"`. Quiet-link style (`a.qlink`) keeps tables
  from turning blue.
- **Status column** renders a discrete badge (Done / Next / Active / Blocked /
  Deferred) via `normalize_status()`, with the free-text qualifier as muted
  text under the badge. Consistency checks still read the raw status strings
  (`--check-only` output verified byte-identical before/after).
- **Branches & PRs** replaced the lane grid with an SVG git graph: gray main
  rail + fixed-height HTML commit rows + branch rails colored by PR state
  (GitHub convention: green open, purple merged, red closed, gray no-PR).
  Fork points come from a new `fork_point` field in `parse_git` — the newest
  first-parent mainline commit that is an ancestor of the branch tip —
  because `merge-base main <ref>` lands on second-parent history once a
  branch is merged. Merge points come from `pr.mergeCommit.oid`, which also
  fixed the old "unmatched squash-merge" bucket. `baseRefName` added to
  `GH_PR_FIELDS` (old caches: treated as `main`).
- **Decisions tab**: categorical Ref chips (Qn / process / review), colored
  gate chips on group headers, Binds scope chips, and settled-elsewhere
  flags — open rows whose Q-ref already appears in Settled render muted with
  a green "settled <date>" chip.
- **Icons**: ~10 GitHub Octicons vendored as inline SVG constants (MIT) —
  used on PR/tag/CI/branch chips and warning banners; replaced the bare `⚠`.
- **Flexoki purple** (`--purple-600: #5E409D`) added for merged-PR state.
