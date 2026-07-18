> **ARCHIVED — complete.** All Phase 0 items landed; merged to `main` via
> PR #14 (squash) on 2026-07-16. Kept for historical reference; content
> below is unedited.

# Phase 0 — Groundwork

| | |
|---|---|
| **Status** | not started |
| **Branch** | `phase-0-groundwork` (off `main`) |
| **Target version** | none — `DESCRIPTION` stays at `0.2.0.9000`; no release, no tag |
| **Entry criteria** | ROADMAP.md and DECISIONS.md exist (done 2026-07-16) |
| **Exit criteria** | CI green on `main`; pha-update-2026 survey recorded below; pkgdown site rebuilt on Bootstrap 5; pinning notes in ROADMAP ledger confirmed |

> This file is also the **template** for later phase plans: header table,
> interview section, numbered sessions each with goal / steps / verification /
> stop conditions, and a findings section appended as work happens.

## Interview — settle before coding

None for this phase. The process questions were settled 2026-07-16
(see [DECISIONS.md](DECISIONS.md)).

## Session 1 (the only session): CI + survey + pkgdown

**Goal:** the Tier 1 refactor starts with a CI safety net, full knowledge of
PHA's real blast radius, and a modernized pkgdown config — with zero change to
package behavior.

### Step 1 — GitHub Actions R-CMD-check

- Add `.github/workflows/R-CMD-check.yaml` following the standard
  `usethis::use_github_action("check-standard")` shape, with two adaptations:
  - **Matrix:** `windows-latest` + `ubuntu-latest`; R release; one extra
    ubuntu job installing ggplot2 devel (`r-lib/ggplot2`) to catch upstream
    breakage early.
  - **License NOTE:** the check must pass with the known
    `Non-standard license specification: file LICENSE` NOTE. Use
    `error-on: '"warning"'` in the `rcmdcheck` step so NOTEs don't fail the
    run (any *new* NOTE still gets caught at release time by the manual
    checklist — CI's job here is errors/warnings).
- First verify the YAML locally does nothing weird (`R CMD check` still clean
  via the normal dev loop), then push the branch and confirm the workflow runs
  green on GitHub before proceeding.

**Verification:** Actions tab shows green check on all matrix cells for the
phase branch.

**Stop here if:** the ggplot2-devel job fails for a reason inside hdatools —
that's a real finding; record it in "Findings" below and raise it before the
Tier 1 refactor, don't paper over it.

### Step 2 — Survey pha-update-2026

The design review inferred PHA blast radius from faar's archive and flagged it
**unverified** (review header + §2 note). Before any PHA-touching change:

- Locate the local clone of `pha-update-2026` (ask Jonathan for the path if
  not under `C:\repos\hda\`).
- Grep it for every hdatools symbol: `theme_pha`, `scale_fill_pha`,
  `scale_color_pha`, `scale_color_gradient_pha`, `scale_fill_gradient_pha`,
  `pha_pal_discrete`, plus the shared helpers (`add_zero_line`,
  `add_reliability`, `publish_plot`, `get_logo`, `fct_case_when`,
  `flip_gridlines`, `hda_pal` local copies).
- Record counts and any positional/unusual call patterns in "Findings" below,
  mirroring the consumer table in the design review.

**Verification:** the Findings section below has a filled-in table; if usage
contradicts a design-review assumption (e.g. heavy gradient use), flag it in
the session summary — it may change Phase 1/2 scope.

### Step 3 — pkgdown modernization (§1.9 rows 6 and 8, + typo)

- `_pkgdown.yml`: replace the BS3-era `template: params: bootswatch:` block
  with `template: bootstrap: 5`; add a grouped `reference:` index — groups:
  **Themes** / **Palettes & scales** / **Helpers** / **Analysis utils**
  (every export must land in exactly one group or pkgdown errors — that error
  is the completeness check).
- Fix the "depreciated" → "deprecated" typos in the roxygen comments of the
  gradient scales (`R/scales.R`) — docs-only wording change, no code change;
  re-run `devtools::document()`.
- Rebuild the site **offline-safe** per CLAUDE.md: `init_site()` +
  `build_home()` + `build_reference()` + `build_news()` (do not
  `build_site()` — the tidycensus article needs network).

**Verification:** site loads locally from `docs/index.html` with BS5 styling;
reference index shows the four groups; `devtools::check()` still
0 errors / 0 warnings / license-NOTE-only.

### Step 4 — Consumer pinning notes

- Confirm the ROADMAP "Cross-repo follow-ups ledger" rows for vhtf and
  fed-workforce are accurate (repo names, current floating state). Nothing is
  changed in those repos from here — the ledger is the reminder that their own
  sessions do the pinning before Phase 1 merges.

### Wrap-up

- NEWS.md: pkgdown/typo changes are developer-facing; one bullet under
  `# hdatools (development version)` covering the pkgdown modernization is
  enough. CI needs no NEWS bullet.
- PR `phase-0-groundwork` → `main`; merge on green. No tag, no version bump.
- Move this file to `plans/archive/` with a completion header; update the
  ROADMAP phase table (Phase 0 → done, Phase 1 → next up).

## Findings (filled in during the session)

### pha-update-2026 usage survey

Survey run 2026-07-16 against `C:\repos\hda\pha-update-2026`. All chapter `.qmd`
files are stubs (sourcing `_common.R` only; chart code not yet written). Active
call sites are limited to `_common.R` and archived SOH-2026 scripts.

| Symbol | Call sites (active) | Call sites (archive) | Notes |
|---|---|---|---|
| `theme_pha` | 0 | 7 | Archive: `soh-2026/scripts/demographics.R` (×2), `market-rental.R` (×2), `market-sale.R` (×5). Chapters are stubs; all future `theme_pha()` calls are in-scope. |
| `scale_fill_pha` | 0 | 2 | Archive: `demographics.R`. `_common.R` comments list it as an expected import. |
| `scale_color_pha` | 0 | 0 | `_common.R` comments list it as expected; no calls yet. |
| `scale_color_gradient_pha` | 0 | 0 | No usage anywhere. |
| `scale_fill_gradient_pha` | 0 | 0 | No usage anywhere. |
| `pha_pal_discrete` | 0 | 0 | Not used; repo defines a local `pha_pal` hardcoded vector instead (matches the hdatools palette). |
| `add_zero_line` | 0 | 4 | Archive: `demographics.R` (×2), `market-rental.R` (×1), `market-sale.R` (×1). `_common.R` comment lists it as expected import. |
| `add_reliability` | 0 | 0 | Explicitly bypassed: `_common.R` defines a local `flag_reliability()` wrapper because repo stores CV on 0-100 scale while `add_reliability()` legacy path expects 0-1. |
| `flip_gridlines` | 0 | 0 | No usage. |
| `fct_case_when` | 0 | 0 | No usage. |
| `publish_plot` | 0 | 0 | No usage. |
| `get_logo` | 0 | 0 | No usage. |

**renv pin status:** renv.lock locks hdatools at v0.1.7 / SHA
`7ac3e5f04bac009c5da7d06684d43d374a5e9de3` from `RemoteRef: "main"` — effectively
pinned at that SHA, but on the `main` ref. Needs explicit SHA or tag pin before
Phase 1 merges (see ROADMAP ledger).

**Design-review consistency:** no surprises. No gradient scale usage in any active
or planned code. The local `pha_pal` vector duplicates `hdatools::pha_pal_discrete`'s
colors — the Phase 2 `*_colors` export will let this be cleaned up after 0.4.0.
The `add_reliability()` bypass is expected per the design review (Q10 in DECISIONS.md).

### Other findings

- `.github/` must be in `.Rbuildignore` to suppress the hidden-files NOTE from
  `R CMD check`. Added in this session.
- pkgdown `fa-home fa-lg` icon lacks `aria-label` (accessibility advisory from
  pkgdown 1.x → 2.x); not a build error. Address if pkgdown ever enforces it.
