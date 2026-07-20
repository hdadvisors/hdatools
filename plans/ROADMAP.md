# hdatools modernization roadmap

> **Status:** live. Created 2026-07-16 from the approved design review
> (now at [archive/hdatools-design-review.md](archive/hdatools-design-review.md) —
> the evidence base; phase plans cite it by section, e.g. "§1.4").
> Start every work session here.

## How to use this folder

1. **Read this file** — the phase table below tells you where the work stands.
2. **Check [DECISIONS.md](DECISIONS.md)** — every settled decision lives there.
   Never re-litigate one; if implementation contradicts a decision, stop and
   raise it.
3. **Open the current phase's plan file** and pick up at the first unfinished
   session. Each session in a phase plan has its own goal, steps, verification,
   and stop conditions.
4. When a phase ships, move its plan file to `archive/` with a short
   `> **ARCHIVED — completed.**` header (see existing archive files for the
   convention), and update the phase table below.

**Terms used throughout** (defined once, here):

- **Dev version** — between releases, `DESCRIPTION` carries a 4-component
  version like `0.2.0.9000`. The `.9000` marks "development state after 0.2.0."
  A release drops the suffix and bumps normally (`0.3.0`).
- **Phase gate** — the short structured interview at the start of a phase's
  first session that settles that phase's open questions before any code is
  written.
- **PR** — pull request on GitHub. Here, one per phase: the phase branch is
  merged to `main` only when the whole phase passes the release checklist.
- **Floating consumers** — repos (vhtf, fed-workforce) that install hdatools
  from `main` with no version pin, so whatever is on `main` must always work.

## Phase table

| Phase | Release | Branch | Scope | Plan file | Status |
|---|---|---|---|---|---|
| 0 — Groundwork | none (stays 0.2.0.9000) | `phase-0-groundwork` | CI (R-CMD-check), pha-update-2026 usage survey, pkgdown Bootstrap 5 + reference grouping + typo fixes (§1.9), consumer-pinning notes | [archive/phase-0-groundwork.md](archive/phase-0-groundwork.md) | **done** — merged (PR #14, squash) |
| 1 — Consolidation | **0.3.0** | `release-0.3.0` | Tier 1 (§1.1–1.4, 1.6): safety-net tests, brand registry, one scale factory, one theme builder, colour aliases. Output provably identical. | [archive/phase-1-consolidation-0.3.0.md](archive/phase-1-consolidation-0.3.0.md) | **done** |
| 2 — Features | **0.4.0** | `release-0.4.0` | Tier 2 (§2.1–2.7): exported color vectors + accessor, designed continuous ramps + deprecations, ggplot2 4.x theme-carried palettes (floor → ≥ 4.0), VHA brand + "adding a brand" howto, CVD audit (document-only), span helper, focus palette | [archive/phase-2-features-0.4.0.md](archive/phase-2-features-0.4.0.md) | **done** |
| 3 — Fonts | **0.5.0** | `release-0.5.0` | Tier 3.1: systemfonts/ragg migration, drop showtext/sysfonts, consumer `dev: ragg_png` guidance (§4), side-by-side render comparison in one consumer before tagging | [plans/phase-3-fonts-0.5.0.md](phase-3-fonts-0.5.0.md) | **in progress** |
| 4 — Backlog | 0.6.0+ | per item | brand.yml emission (§3.2), vdiffr snapshots (§3.3), `use_hdatools()` (§3.4), rewrite `branded-themes` article (drop tidycensus/tidyverse dep, use synthetic data, add PHA/VHA). Revisit after 0.5.0. Package split (§3.5) rejected per review. | none — deliberately unplanned | deferred |

Phases run strictly in order. Phase 2/3 plans are drafted **just-in-time** at
their gates so interview answers and earlier-phase learnings shape them —
don't write them early.

## Package hygiene conventions (standing rules)

These follow tidyverse practice and apply to every phase.

**Versioning**

- Dev work sits at `x.y.z.9000`. When a session lands a meaningful
  user-facing chunk mid-phase, bump the 4th component (`.9001`, `.9002`, …) —
  it makes `sessionInfo()` unambiguous when debugging a consumer.
- A release drops the dev suffix to the phase table's target (`0.3.0`), per
  the CLAUDE.md release checklist — never skip that checklist.

**Branches and PRs**

- Branch off `main` at phase start, named per the phase table. All of the
  phase's sessions commit to that branch.
- Commit messages: imperative mood, no Claude/Anthropic co-author (CLAUDE.md).
- One PR per phase, merged only when **all** hold: CI green,
  `devtools::check()` at 0 errors / 0 warnings / license-NOTE-only, release
  checklist complete. `main` therefore stays always-installable for the
  floating consumers.

**NEWS.md**

- Every user-facing change gets a bullet under
  `# hdatools (development version)` **in the same session it lands** — never
  reconstructed at release time. Verified claim-by-claim at release
  (checklist step 3).

**Docs**

- roxygen, README, and pkgdown updates land in the same session as the code
  they document. `devtools::document()` runs before every commit that touches
  roxygen comments.

**Tests**

- CLAUDE.md's testing rules apply verbatim: a red test is a finding about the
  code; snapshots are reviewed, never blanket-accepted; structural
  `ggplot_build()`/`calc_element()` assertions keep the suite font-free.

## Phase-gate interview process

Each phase plan opens with an **"Interview — settle before coding"** section:
that phase's open questions from the design review (§3), each with the
review's recommended default and a note on what the answer changes. The
interview is the first ~10 minutes of the phase's first session; answers are
written to [DECISIONS.md](DECISIONS.md) immediately, then coding starts.

Question → phase mapping:

| Gate | Questions |
|---|---|
| Phase 0 | none — process questions were settled 2026-07-16 (see DECISIONS.md) |
| Phase 1 | **Q1** (registry form), **Q3** (deprecation policy / fhfh surface) |
| Phase 2 | **Q2** (brand.yml posture), **Q4** (ggplot2 ≥ 4.0 floor), **Q6** (ramp design), **Q7** (CVD reorder), **Q8** (VHA hexes + Montserrat), **Q9** (house theme defaults) |
| Phase 3 | **Q5** (fonts go/no-go + which consumer for the render comparison) |
| n/a | **Q10** (`add_reliability()` ban) — belongs to fhfh's own session; tracked in the ledger below |

## Cross-repo follow-ups ledger

Out-of-package work the review parked. Each item is owned by the named repo's
own session — **never done as a drive-by from hdatools work**.

| Item | Owning repo | When |
|---|---|---|
| Pin hdatools (renv or tagged ref) — currently floats on `main` | vhtf | before Phase 1 merges, ideally during Phase 0 |
| Pin hdatools — currently floats on `main` | fed-workforce | before Phase 1 merges, ideally during Phase 0 |
| Verify `add_reliability()` cv_col/percent path against real data; retire the CLAUDE.md/README ban (Q10) | fhfh | fhfh's next data session |
| Re-snapshot to 0.3.0 / 0.4.0 / 0.5.0 and compare renders after each release | fhfh (binding) | after each release, per existing rollout convention |
| Retire the ~200-line local VHA clone once `theme_vha()` ships in 0.4.0 | vhtf | after Phase 2 release |
| Delete local hardcoded hex vectors once `*_colors` export in 0.4.0 | fhfh | after Phase 2 release |
