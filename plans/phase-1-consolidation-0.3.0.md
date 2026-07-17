# Phase 1 — Consolidation (release 0.3.0)

| | |
|---|---|
| **Status** | not started — blocked by Phase 0 |
| **Branch** | `release-0.3.0` (off `main`, after Phase 0 merges) |
| **Target version** | `0.3.0` (dev sits at `0.2.0.9000` → bump per session per ROADMAP conventions → release drops suffix) |
| **Entry criteria** | Phase 0 complete: CI green on `main`, pha-update-2026 survey recorded |
| **Exit criteria** | All Tier 1 items landed; **every pre-refactor test passes unmodified**; release checklist done; PR merged; tag `v0.3.0` pushed |

**The one rule of this phase:** output is provably identical. Tier 1 is pure
consolidation (design review §1.1–1.4, item table §2 Tier 1) — if any test
written in Session 1 changes result after Sessions 2–3, the refactor has a
bug. Tests are never adjusted to make the refactor pass (CLAUDE.md rule).

## Interview — settle before coding (first 10 minutes of Session 1)

| Q | Question | Recommended default | What the answer changes |
|---|---|---|---|
| **Q1** | Where does the palette single-source-of-truth live? | Plain named character vectors in an internal registry (`R/brands.R`) + exported vectors later in Phase 2. Not `data/` objects, not brand.yml-driven. | The shape of `R/brands.R` written in Session 2; whether Phase 2's `_brand.yml` work (Q2) reads or generates. |
| **Q3** | Deprecation policy — confirm the inviolable surface. | fhfh's surface untouchable (`theme_hda()` + `...` passthrough + `flip_gridlines`, `add_zero_line`, `scale_fill_hda` named args). Everything else may soft-deprecate via `lifecycle`; removals at 0.5+. Keep positional `direction` (cheap). | Whether `lifecycle` enters Imports this phase (only if a deprecation actually ships in 0.3.0 — default: **no deprecations in 0.3.0**, it stays a zero-change release; deprecations start in 0.4.0). |

Record answers in [DECISIONS.md](DECISIONS.md) before writing code.

## Session 1 — Safety net (design review item 1.6)

**Goal:** lock in the current behavior of every theme and scale as tests,
committed *before* any refactor commit exists.

**Steps:**

1. **Theme element-identity tests.** For each of `theme_hda()`, `theme_hfv()`,
   `theme_pha()` — across the argument grid that matters downstream
   (defaults; `base_size` variants; `flip_gridlines = TRUE/FALSE`; each
   `output_format`) — capture every computed element via
   `ggplot2::calc_element()` and snapshot/assert it. Font-free per the
   CLAUDE.md structural-testing convention.
2. **Palette/scale output tests.** For all 9 exported scales: assert the exact
   hex sequence returned for n = 1..6 series, `direction = 1` and `-1`
   (including **positional** `scale_fill_hda(-1)` — faar's idiom), and
   `repeat_pal = TRUE` where applicable. For the 3 gradient scales, assert the
   default `colors`/`values` passed through to the built scale.
3. Run `devtools::test()`; all green against the *current* code. Commit as its
   own commit ("Add pre-refactor identity tests for themes and scales").

**Verification:** suite green; a deliberate one-character sabotage of a hex in
`R/scales.R` makes it red (proves the net catches palette drift) — revert the
sabotage.

**Stop here if:** writing the tests reveals current behavior that looks like a
bug (e.g. inconsistent `output_format` handling). Record it, ask Jonathan —
don't "fix" it silently into the snapshot.

## Session 2 — Brand registry + scale factory (items 1.1, 1.2, 1.4)

**Goal:** one source of truth for palettes; nine scale exports become thin
wrappers. Zero API or output change.

**Steps:**

1. Create `R/brands.R` (per Q1 decision): internal `.brands` registry — a
   named list with one entry per brand (`hda`, `hfv`, `pha`) holding the
   discrete palette (named hexes), gradient anchors, font families, and theme
   parameters (base_size, adjust defaults, lineheight, margin quirks — pulled
   from the deltas cataloged in review §1.4). *Internal only this phase;
   exported color vectors are Phase 2 (item 2.1).*
2. Replace the three byte-identical `*_pal_discrete()` factory bodies with one
   internal factory reading the registry; build on `scales::pal_manual()` /
   `scales::new_discrete_palette()` per review §1.2 so palettes carry
   metadata. The exported `*_pal_discrete()` names keep working as one-liners
   (their deprecation is a Phase 2 question, per Q3 default).
3. Replace the 6 discrete + 3 gradient scale bodies with one internal
   constructor (`scale_brand_d()` / gradient equivalent); the 9 exports become
   one-line wrappers. `direction` stays the first parameter (positional use
   in faar).
4. Item 1.4: standardize on `aesthetics = "colour"` internally; add
   `scale_colour_hda()` / `scale_colour_hfv()` / `scale_colour_pha()` (and
   gradient spellings) as aliases of the existing `scale_color_*` exports,
   with shared roxygen docs. Additive only.
5. `devtools::document()`; `devtools::test()` — **Session 1 tests pass
   unmodified** (the alias tests from step 4 are the only new tests).
   NEWS.md bullets: internal registry (dev-facing), `scale_colour_*` aliases
   (user-facing). Bump dev version to `.9001`.

**Verification:** full dev loop (`document` → `test` → `check`) at
0 / 0 / license-NOTE-only; CI green on the branch; `git diff --stat` shows
`R/scales.R` shrinking, no `man/` page for an existing export changing its
usage section except the new aliases.

## Session 3 — Theme builder (item 1.3) + release

**Goal:** three ~150-line themes become one builder + per-brand specs; then
ship 0.3.0.

**Steps:**

1. Write internal `.brand_theme(spec, base_size, flip_gridlines,
   output_format, ...)` in `R/themes.R`: element list built in plain code
   (gridline elements chosen by an ordinary `if`, not `%+replace%` + glued
   `+ if (...)`), constructed with `complete = TRUE` per review §1.4.
   Implement the `flip_gridlines` arg via the exported `flip_gridlines()`
   helper's element logic so the grid color has a single definition
   (§1.9 row 1).
2. `theme_hda()` / `theme_hfv()` / `theme_pha()` become wrappers over
   `.brand_theme(.brands$hda, ...)` etc. **Signatures, defaults, and the
   `...` → `theme()` passthrough are preserved exactly** (fhfh contract, Q3).
3. `devtools::test()` — the Session 1 element-identity tests are the
   acceptance gate and must pass **unmodified**. Any diff = refactor bug; fix
   the builder, not the test.
4. While in there (§1.9 row 3, cheap and behavior-safe): make
   `get_output_format()` recognize `"typst"` and `"docx"` explicitly and add
   `"interactive"` as the preferred name for `"studio"` **with the old value
   still returned/accepted** — only if the Session 1 snapshots confirm no
   downstream-visible change; otherwise defer to Phase 2.
5. **Release 0.3.0:** run the CLAUDE.md release checklist end-to-end
   (version + NEWS heading, claim-by-claim NEWS verification, dev loop,
   `urlchecker`, `spelling`, pkgdown partial rebuild + commit `docs/`).
   PR `release-0.3.0` → `main`; merge on green; tag annotated `v0.3.0`; push
   tags.
6. Move this file to `plans/archive/` with a completion header; update the
   ROADMAP phase table; add the "consumers may bump to 0.3.0" reminder rows
   to the ledger if not already there. **Draft
   `phase-2-features-0.4.0.md` at the start of the next phase's session**,
   not now.

**Verification (release):** installed-package smoke test — in a fresh R
session, `library(hdatools)`, build one plot per brand with
`theme_*() + scale_fill_*()` and confirm no warnings; `R CMD check` 0 / 0 /
license-NOTE-only; CI green on the merge commit.

## Findings (filled in during sessions)

- **Session 2:** `lifecycle::deprecate_soft()` on the 6 newly-deprecated
  functions (item 3 of Q3) collided with the *existing* test suite, not with
  the refactor itself:
  - `test-deprecation.R`'s ggplot2-idiom regression guard forces
    `lifecycle_verbosity = "error"`, which turns our own soft-deprecation into
    the same `lifecycle_error_deprecated` class it was built to catch on
    ggplot2's idioms. Fixed by pointing that test's gradient-scale assertions
    at the internal `.scale_brand_gradient()` constructor instead of the now-
    deprecated exported wrappers — that test's actual intent (no
    ggplot2-internal deprecated idiom fires) is unrelated to our own notice.
  - `lifecycle::deprecate_soft()` treats a call made directly inside a
    `testthat::test_that()` block as a "direct user call" by design, so every
    pre-existing/Session-1 identity test invoking the 6 functions started
    emitting a deprecation warning (32 new WARNs) even though returned values
    were unchanged. Fixed by adding `withr::local_options(lifecycle_verbosity
    = "quiet")` to the affected `test_that()` blocks in `test-scales.R` —
    values asserted are identical to before; only the deprecation-notice noise
    is silenced, since those tests exist to check output identity, not
    deprecation behavior.
  - Both changes were confirmed with the user before applying (test-file
    edits fall outside a "Session 1 tests must pass unmodified" default).
    Final state: 189/189 tests pass (183 pre-existing + 6 new
    `scale_colour_*` alias tests), 0 warnings, `devtools::check()` 0/0/0.
  - All `.brands` hex values, gradient stops, `na_color`, and theme params
    (`base_size`/`html_adjust`/`pdf_adjust`/`lineheight`) were verified
    programmatically against the pre-refactor source (git `HEAD`), not
    transcribed from memory — see commit `f5fcae4`.
