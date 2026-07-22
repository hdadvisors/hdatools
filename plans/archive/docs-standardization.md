> **ARCHIVED — completed 2026-07-22.** All six sessions landed; see Findings
> below. Not yet committed/pushed — commit breakdown pending Jonathan's review.

# Docs & conventions standardization

| | |
|---|---|
| **Status** | In progress |
| **Branch** | `docs-standardization` (off `main`) |
| **Target version** | none — doc/process only, no version bump |
| **Entry criteria** | 0.5.0 shipped; phase-gate/ROADMAP model retired (2026-07-20) |
| **Exit criteria** | All six sessions below land; `devtools::check()` clean; pkgdown site rebuilt; PR merged to `main`; this file archived |

## Interview — settled 2026-07-22

Full rationale for every decision below is in [DECISIONS.md](DECISIONS.md)'s Settled table (rows dated 2026-07-22). Summary:

| Area | Decision |
|---|---|
| Conventional Commits | Convention-only (`type(scope): subject`); no tooling; NEWS.md and version bumps stay manual |
| NEWS.md format | Conventional-Changelog-style grouped sections; filename stays `NEWS.md` |
| Prose style | Custom blend — IBM clause discipline default, STE100 one-instruction-per-sentence for procedural steps; applies to internal docs and pkgdown prose alike |
| Audience split | Explicit "using hdatools" vs. "contributing to hdatools" tracks; using-track written zero-assumption-friendly |
| SemVer | Document the semver.org 0.x deviation; explicit `1.0.0` bar (see DECISIONS.md) |
| Templates | Add PR template + chore/docs/design-decision issue templates |
| Skill scope | hdatools-only; no new cross-repo skill |
| pkgdown scope | Full style pass on all 4 articles + roxygen reference prose |

This is a doc/process-only initiative: no R source logic changes, no behavior changes, no NEWS.md bullet needed per-session (one summary bullet lands in Session 6).

## Session 1 — Record decisions + set up

**Goal:** capture the interview outcome durably before touching any doc content.

**Steps:**

1. Append the settled-decision rows to `plans/DECISIONS.md` (done as part of opening this file).
2. Create this file.

**Verification:** DECISIONS.md rows present; this file exists.

## Session 2 — New conventions content

**Goal:** add the new commit/PR/issue/versioning conventions as net-new content, before any existing prose is rewritten.

**Steps:**

1. `CONTRIBUTING.md`: add a **Commit message convention** section — `type(scope): subject`, type taxonomy (`feat`/`fix`/`docs`/`chore`/`test`/`refactor`/`perf`), scope = functional area, issue references where relevant. State explicitly that this is convention-only, not tool-enforced.
2. `CONTRIBUTING.md`: update **Versioning & releases** — add the semver.org-deviation note and the `1.0.0` bar from DECISIONS.md.
3. Add `.github/PULL_REQUEST_TEMPLATE.md` — checklist: NEWS.md bullet added, `devtools::document()`/`test()`/`check()` clean, DECISIONS.md row added if a design decision was made, docs rebuilt if roxygen/README/articles touched.
4. Add `.github/ISSUE_TEMPLATE/chore.md`, `docs.md`, `design_decision.md`, matching the existing `bug_report.md`/`feature_request.md` frontmatter and section shape.

**Verification:** all four new/updated files read cleanly; nothing contradicts an existing DECISIONS.md row.

**Stop here if:** the commit-type taxonomy doesn't cleanly cover a real recent commit from git history — adjust the taxonomy before finalizing, don't force-fit.

## Session 3 — NEWS.md retrofit

**Goal:** regroup existing entries without changing their factual content.

**Steps:**

1. Restructure the `0.2.0`–`0.5.0` NEWS.md entries into grouped headings (Features / Bug Fixes / Breaking Changes / Documentation / Internal), verifying every claim against current code as it's moved (the existing release-checklist rule, applied here too).
2. Leave `0.1.0`–`0.1.7` stub entries ("See git history") untouched.
3. Document the going-forward grouped-entry template in CLAUDE.md's "NEWS, tests, and docs rules" section.

**Verification:** every pre-existing NEWS.md claim still traceable to real behavior after regrouping; diff shows regrouping only, no content changes beyond the heading structure.

**Stop here if:** a NEWS.md claim can't be verified against current code while retrofitting — that's a documentation bug independent of this project; flag it rather than silently preserving or dropping it.

## Session 4 — Internal docs tightening

**Goal:** apply the custom-blend style to README.md, CLAUDE.md, and CONTRIBUTING.md prose.

**Steps:**

1. `README.md`: restructure per the audience split — plain-language purpose/summary first, then a zero-assumption-friendly Quick start, then the existing Features reference, then a pointer to CONTRIBUTING.md.
2. `CLAUDE.md`: tighten remaining narrative prose (R-first preamble, dev-loop intro, release-checklist intro). Leave tables, checklists, and "Known gotchas" untouched (carve-outs). Cross-reference new CONTRIBUTING.md sections instead of duplicating.
3. `CONTRIBUTING.md`: tighten the getting-started narrative and the Session 2 prose for consistency. Leave the SemVer table and label table untouched.

**Verification:** every prose paragraph in these three files reads in custom-blend style; no table/checklist/decision-log content altered; `devtools::document()` + `test()` still pass if any example code was touched.

## Session 5 — pkgdown external rewrite

**Goal:** full style pass across the pkgdown-facing surface, then rebuild the site.

**Steps:**

1. `vignettes/articles/*.Rmd` (4 files): apply custom-blend style to narrative prose; preserve code blocks, R snippets, and tables as-is. `adding-a-brand.Rmd`'s numbered steps get the STE100 one-instruction-per-sentence treatment.
2. Roxygen documentation (`R/*.R`): tighten the canonical prose once per function family (`theme_*()`, `scale_*_c()`/`_b()`, `scale_color()`/`scale_fill_*()`, `*_color()`/`*_colors`, `*_span()`, `*_focus_pal()`, `add_reliability()`, `fct_case_when()`, etc.), then verify the tightened shape repeats correctly across the HDA/HFV/PHA/VHA copies rather than hand-editing each brand's copy independently.
3. Verify `_pkgdown.yml`'s reference-index grouping still matches current exports; adjust only if drifted.
4. `devtools::document()` → `devtools::test()` → `devtools::check()` (0 errors/warnings, license-NOTE-only) → `pkgdown::build_site()`.

**Verification:** all 4 articles + roxygen prose pass the style lens; `R CMD check` stays at 0 errors/0 warnings/license-NOTE-only; site rebuilds cleanly; spot-check rendered articles and a sample of reference pages.

**Stop here if:** `devtools::check()` surfaces a new error, warning, or NOTE beyond the documented cloud-session exceptions — investigate before continuing.

## Session 6 — Wrap-up

**Goal:** close out the initiative.

**Steps:**

1. Add one NEWS.md bullet (under a Documentation/Internal heading in the next dev entry) summarizing the doc/convention overhaul.
2. Move this file to `plans/archive/` with a completion header.
3. Propose a commit breakdown using the new commit convention (dogfooding it immediately) for Jonathan's review — never auto-commit.
4. Open a PR to `main` once Jonathan confirms the commits.

**Verification:** working tree clean; PR opened; this file archived.

## Findings

- **Session 1 complete (2026-07-22):** DECISIONS.md rows added; this file
  created.

- **Session 2 complete (2026-07-22):** Added the commit message convention
  (`type(scope): subject`, including a `release` type discovered by checking
  the taxonomy against real commit history — release/version-bump commits
  didn't fit any of the standard Conventional Commits types) and the
  semver.org-deviation + `1.0.0` bar to CONTRIBUTING.md. Added
  `.github/PULL_REQUEST_TEMPLATE.md` and three new issue templates
  (`chore.md`, `docs.md`, `design_decision.md`).

- **Session 3 complete (2026-07-22):** Retrofitted NEWS.md's `0.2.0`–`0.5.0`
  entries into grouped headings (bullet count verified identical
  before/after: 54 = 54, confirming no content was lost, only regrouped).
  `0.1.0`–`0.1.7` left untouched. Documented the grouped-entry template in
  CONTRIBUTING.md's "NEWS, tests, and docs rules" section — the plan
  originally said "CLAUDE.md," but that section actually lives in
  CONTRIBUTING.md; corrected in place.

- **Session 4 complete (2026-07-22):** README.md restructured around the
  audience split (purpose paragraph → Quick start → Features → Usage →
  Contributing pointer). CLAUDE.md and CONTRIBUTING.md prose tightened to
  custom-blend style; tables, checklists, and the decisions log left
  untouched per the carve-out rules.

- **Session 5 complete (2026-07-22):** Vignette-rewrite subagent hit a
  transient API overload (529) before making any edits (confirmed via clean
  `git diff`); took the work over directly instead of retrying. Tightened all
  4 articles (`branded-themes.Rmd`, `adding-a-brand.Rmd`, `cvd-audit.Rmd`,
  `ragg-migration.Rmd`) and roxygen prose across `R/*.R`. `scales.R`'s ~456
  roxygen lines turned out to be almost entirely repeated one-line `@param`
  fragments per brand — already appropriately terse, needed near-zero
  changes; the real prose lived in `theme_helpers.R` (`register_hda_fonts()`),
  `themes.R` (the four `theme_*()` `@details` blocks, converted to bullet
  lists), and `span.R`. Repeated per-brand blocks were fixed once and applied
  via `replace_all` rather than hand-edited per copy.
  `devtools::check()` surfaced a NOTE beyond the documented set:
  `CONTRIBUTING.md` flagged as a non-standard top-level file — a pre-existing
  gap (never added to `.Rbuildignore` alongside `CLAUDE.md`), not something
  this session's edits caused. Fixed by adding `^CONTRIBUTING\.md$` to
  `.Rbuildignore`; re-check confirmed 0 errors / 0 warnings / 0 notes.
  `pkgdown::build_site()` rebuilt cleanly; spot-checked the home page, a
  reference page with a converted bullet list, the regrouped NEWS/Changelog
  page, and an article in the browser — all rendered correctly. Pre-existing
  pkgdown sitrep notices (DESCRIPTION missing the pkgdown site URL, a navbar
  icon missing `aria-label`, missing alt-text on the README's example image)
  are unrelated to this session's scope and were left alone.

- **Session 6 (this session):** DESCRIPTION bumped to `0.5.0.9000` and a
  summary NEWS.md bullet added, per the standing "bump the dev suffix when a
  meaningful chunk lands" rule — this is not a release, just marking that a
  dev cycle has meaningful work in it. This file archived. Commit breakdown
  proposed to Jonathan for review before anything is committed or pushed.
