> **ARCHIVED — completed 2026-07-19.** All seven Tier 2 items landed; 405 tests passing; PR #19 squash-merged to main; tagged v0.4.0.

# Phase 2 — Features (release 0.4.0)

| | |
|---|---|
| **Status** | not started |
| **Branch** | `release-0.4.0` (off `main`) |
| **Target version** | `0.4.0` |
| **Entry criteria** | Phase 1 merged and tagged `v0.3.0`; floating consumers (vhtf, fed-workforce) pinned per the cross-repo ledger in ROADMAP.md |
| **Exit criteria** | All Tier 2 items landed (or explicitly deferred with reason); release checklist done; PR merged; tag `v0.4.0` pushed |

## Phase gate — settled 2026-07-18

The six questions gating this phase are answered; full rationale lives in
[DECISIONS.md](DECISIONS.md)'s Settled table (rows dated 2026-07-18). Summary:

| Q | Decision | Affects |
|---|---|---|
| Q2 | Adopt `_brand.yml` as an **output only** (generated from `.brands`, never a runtime input) | Posture only — implementation stays Phase 4 backlog (3.2), not this phase |
| Q4 | Raise the **ggplot2 floor to ≥ 4.0** at this release | Session 3 |
| Q6 | Continuous ramps built **programmatically** (colorspace HCL from brand anchors), then eyeballed + CVD-checked | Session 2 |
| Q7 | CVD audit is **document-only** this phase — no palette reordering | Session 5 |
| Q8 | Add **VHA as a fourth first-class brand**; confirm hex ownership before coding | Session 4 |
| Q9 | **Keep house theme defaults** (no legend, blank axis titles) — no change | Session 3 (guardrail; no dedicated work) |

No Tier 2 item was dropped or deferred by these answers — all seven land this
phase, with Q7 constraining item 2.5's scope to document-only.

## Session 1 — Exported color vectors + accessor (item 2.1)

**Goal:** give downstream consumers named hex access without hardcoding, so
faar/fhfh/fed-workforce can delete their local hex vectors (ROADMAP.md
ledger).

**Steps:**

1. Export `hda_colors`, `hfv_colors`, `pha_colors` — named character vectors
   assigned directly from `.brands$<brand>$palette` (plain vectors per the Q1
   registry decision; not `data/` objects).
2. Add a per-brand accessor — `hda_color(name)`, `hfv_color(name)`,
   `pha_color(name)` — returning the hex for a named color and erroring with
   the valid names listed on an unknown one. Mirrors the existing per-brand
   export convention (`scale_color_hda()` etc.).
3. roxygen docs with usage examples (`hda_colors["Blue"]`,
   `hda_color("Blue")`); `devtools::document()`.
4. Tests: assert each exported vector equals `.brands$<brand>$palette`
   exactly (guards drift); assert the accessor returns the right hex and
   errors on an unknown name.
5. NEWS.md bullet; bump dev version (`.9001`).

**Verification:** `devtools::test()` green; dev loop 0 errors / 0 warnings /
license-NOTE-only; a plot using
`theme_hda() + scale_fill_manual(values = hda_colors)` renders without
warnings.

**Stop here if:** the color label names (`"Blue"`, `"Sky"`, etc.) aren't
names you're ready to commit to as public API — once exported, renaming a
label is a breaking change. Confirm with Jonathan before exporting.

## Session 2 — Designed continuous ramps (item 2.2, Q6)

**Goal:** replace the current "categorical palette strung end-to-end"
gradient with real sequential/diverging ramps, and complete the
`scale_*_{brand}_c()` matrix (today HDA has color-only, HFV has none, PHA has
both).

**Steps:**

1. Add sequential and diverging ramp anchors per brand to `.brands` (e.g.
   `.brands$hda$ramps$sequential` / `$diverging`), built with
   `colorspace::sequential_hcl()` / `diverging_hcl()` calibrated off 2–3 brand
   anchor colors (Q6). Eyeball the rendered ramps and run
   `colorspace::simulate_cvd()` over them before committing stops.
2. Generalize `.scale_brand_gradient()` into one internal continuous
   constructor taking `palette = c("sequential", "diverging")` and
   `aesthetics`.
3. Export the complete matrix — `scale_colour_hda_c()` / `scale_color_hda_c()`
   / `scale_fill_hda_c()` × 3 brands (9 exports) — replacing the leaky
   `colors`/`values`/`space` args with `palette`, `direction`, `na.value`,
   `...` (afcharts' `scale_*_continuous_af()` shape).
4. Soft-deprecate `scale_color_gradient_hda()`, `scale_color_gradient_pha()`,
   `scale_fill_gradient_pha()` via `lifecycle::deprecate_soft()`, this time
   with a `use_instead` pointing at the matching new `_c()` function (Q3's
   Phase 2 note: replacements carry the target now that one exists).
5. Tests: structural hex-output assertions (`ggplot_build()`-based) for
   representative `n` on each new scale; `lifecycle::expect_deprecated()` on
   the three retired functions, asserting it names the right replacement.
6. NEWS.md; `devtools::document()`; bump dev version.

**Verification:** dev loop 0/0/license-NOTE-only; render a swatch plot per
ramp and eyeball it — attach the observation to this file's Findings section,
not a committed snapshot (vdiffr is Tier 3.3, not yet in place).

**Stop here if:** a brand's anchors produce a muddy or non-monotonic HCL
ramp — adjust anchor points or the luminance sweep and record the deviation
in Findings rather than shipping a ramp that looks wrong.

## Session 3 — ggplot2 4.x theme-carried palettes (item 2.3, Q4)

**Goal:** raise the ggplot2 floor to ≥ 4.0 and have `theme_*()` alone brand a
plot with no scale call required.

**Steps:**

1. Bump `DESCRIPTION` `Imports: ggplot2 (>= 4.0.0)`; `devtools::check()`
   surfaces any 4.x S7-element-validation breakage immediately.
2. In `.brand_theme()` ([R/themes.R](../R/themes.R)), set
   `theme(palette.colour.discrete = ..., palette.fill.discrete = ...,
   palette.colour.continuous = ..., palette.fill.continuous = ...)` reading
   the discrete palette from `.brands[[brand]]$palette` and the continuous
   ramps from Session 2.
3. Adopt the 4.x `ink`/`paper` theme args and `theme(geom =
   element_geom(...))` for brand-default geom fills (e.g. default column
   fill = the brand's first color), replacing any `update_geom_defaults()`
   pattern in use today.
4. Add a test confirming an explicit `scale_*()` call still overrides the
   theme-carried palette (design review: ~65 existing call sites must stay
   unaffected).
5. **Guardrail (Q9):** no change to `legend.position` or blank-axis-title
   defaults in this session — the theme-carried palette is additive only.
6. Extend the Phase 1 `calc_element()`/`ggplot_build()` structural tests to
   cover the new theme-carried palette fields; confirm a bare
   `ggplot(...) + theme_hfv()` (no scale call) renders branded colors.
7. NEWS.md; `devtools::document()`; bump dev version.

**Verification:** dev loop 0/0/license-NOTE-only; CI green; manual smoke
test — a no-scale-call plot renders branded under each theme.

**Stop here if:** raising the floor breaks `complete = TRUE` construction or
an existing structural test in a way that isn't a one-line fix — flag before
exceeding the review's M-effort estimate for this item.

## Session 4 — VHA as a fourth brand (item 2.4, Q8)

**Goal:** prove the "brands are data" architecture by adding VHA as a fourth
`.brands` entry, retiring vhtf's ~200-line local clone.

**Steps:**

1. Confirm VHA hex palette values and brand-asset ownership before writing
   any code (Q8's explicit caveat).
2. Add `.brands$vha`, mirroring hda/hfv/pha's shape exactly: `palette`,
   sequential/diverging `ramps` (Session 2's builder), `na_color`, `fonts`,
   `base_size`, `html_adjust`/`pdf_adjust`, `lineheight`, `theme_fonts`,
   `theme_margins`.
3. Bundle Montserrat (OFL) alongside the existing TTFs, via the same
   mechanism the other three brands use today (the systemfonts/ragg
   migration is Tier 3.1, not this phase).
4. Generate the full per-brand surface from the shared builders:
   `theme_vha()`, `scale_color_vha()` / `scale_fill_vha()` (+ `colour`
   aliases), `scale_*_vha_c()`, `vha_colors` / `vha_color()`. Every one of
   these should be a one-line wrapper over the Session 1–3 internals — if any
   needs brand-specific special-casing, that's a signal the builder isn't
   general enough yet; flag it rather than hand-rolling a VHA exception.
5. Write the "adding a new client brand" howto (vignette or README section)
   documenting the one-registry-entry pattern end to end, using VHA as the
   worked example.
6. Tests mirroring hda/hfv/pha's existing coverage (palette, theme element
   identity, scale output) for vha.
7. NEWS.md; `devtools::document()`; bump dev version.

**Verification:** dev loop 0/0/license-NOTE-only; a
`theme_vha() + scale_fill_vha()` plot renders correctly; the howto builds in
the pkgdown reference/article.

**Stop here if:** VHA hex ownership isn't confirmed, or adding the brand
requires a real code branch (not just a registry entry) anywhere in
`R/scales.R`/`R/themes.R` — either blocks the "one entry" story and needs
Jonathan's sign-off on the workaround.

## Session 5 — CVD audit, document-only (item 2.5, Q7)

**Goal:** audit all four brands' discrete palettes for colorblind safety and
document the findings — no default color order changes.

**Steps:**

1. Run cols4all (`c4a_data()` / CVD scoring, WCAG contrast) against
   hda/hfv/pha/vha's discrete palettes.
2. Document results (pkgdown article or README/reference section),
   confirming or clearing the pairs the design review flagged as
   visually risky (HDA sage `#8baeaa` vs sea-green `#8abc8e`; PHA orange
   `#f39152` vs red `#be451c`).
3. Add a `colorspace::simulate_cvd()`-based regression test asserting a
   minimum pairwise perceptual distance for the first 3–4 colors of each
   palette (the common ≤4-series case). This guards future edits — it does
   not change today's palettes.
4. **Per Q7:** do not reorder any palette's default color order. If a
   palette fails badly, add an opt-in `cvd_safe = TRUE` argument or a
   separately-named safe palette instead — and raise that with Jonathan for
   explicit sign-off before shipping even the opt-in.
5. NEWS.md (documentation-only bullet); `devtools::document()`; bump dev
   version.

**Verification:** dev loop 0/0/license-NOTE-only; audit doc renders in
pkgdown; regression test passes against the current, unreordered palettes.

**Stop here if:** the audit finds a palette failing badly enough that
document-only feels irresponsible — stop and raise it with Jonathan for an
explicit reorder decision (Q7's carve-out) rather than deciding unilaterally.

## Session 6 — Span helper + focus palette, then release (items 2.6, 2.7)

**Goal:** land the two remaining small additive features, then ship 0.4.0.

**Steps:**

1. **Item 2.6** — ggtext span helper (e.g. `hda_span(text, color, brand =
   ...)`) emitting `<span style='color:#…'>text</span>` from a brand + named
   color, replacing the hand-pasted pattern in fhfh/fed-workforce subtitles.
   Builds on Session 1's named-color accessors.
2. **Item 2.7** — focus/emphasis palette (one brand color + grays), afcharts'
   "highlight one series" pattern. Additive only; no default change (Q9).
3. Structural tests for both (palette/span-string output).
4. NEWS.md; `devtools::document()`; bump dev version.
5. **Release 0.4.0:** run the CLAUDE.md release checklist end to end —
   version + NEWS heading, claim-by-claim NEWS verification, dev loop,
   `urlchecker::url_check()`, `spelling::spell_check_package()`, pkgdown
   partial rebuild + commit `docs/`.
6. PR `release-0.4.0` → `main`; merge on green; tag annotated `v0.4.0`; push
   tags.
7. Move this file to `plans/archive/` with a completion header; update the
   ROADMAP phase table; confirm the ledger rows (vhtf retiring its local VHA
   clone; faar/fhfh/fed-workforce deleting hardcoded hex vectors) are
   actionable. **Draft `phase-3-fonts-0.5.0.md` at the start of the next
   phase's session**, not now.

**Verification (release):** installed-package smoke test across all four
brands (theme + discrete scale + continuous scale + span helper + focus
palette); `R CMD check` 0/0/license-NOTE-only; CI green on the merge commit.

## Cross-repo follow-ups relevant to this phase

See ROADMAP.md's ledger — in particular "retire the ~200-line local VHA
clone" (vhtf, after this phase) and "delete local hardcoded hex vectors"
(faar/fhfh/fed-workforce, after this phase).

## Findings (filled in during sessions)

### Session 5 (item 2.5)

**CVD audit method:** `colorspace::simulate_cvd()` (protan/deutan/tritan, sev = 1),
pairwise delta-E (CIE76) in Lab space. Audit covers first four palette slots per brand
plus the two design-review-flagged pairs.

**Key findings (delta-E < 10 = indistinguishable; 10–20 = borderline):**

| Brand | CVD type | Worst pair | delta-E | Status |
|---|---|---|---|---|
| HDA | tritanopia | Green vs Sea Green (pos 2/6) | **5.97** | **Failure** — severe under tritanopia only |
| HFV | all three | Sky vs Grass (pos 2/4) | 12.1–12.7 | Borderline — no failure, documented |
| PHA | deuteranopia | Green vs Light Blue (pos 1/2) | 18.5 | Acceptable |
| VHA | deuteranopia | Dark Turq vs Light Turq (pos 1/4) | 16.5 | Acceptable |
| PHA | protan/deutan/tritan | Orange vs Red (pos 3/4) | 22.5–28.9 | **Cleared** (design-review flag not confirmed) |

HDA Green/Sea Green tritanopia failure accepted as documented-only per Q7. Tritanopia
affects ~0.1 % of the population; the pair only co-occurs in a ≥5-category plot.
Vignette recommends a secondary encoding if CVD robustness is required there.

HFV Sky/Grass borderline (~12 across all CVD types): teal-family structural issue;
documented with "use secondary encoding" guidance, same document-only posture.

**Deliverables landed:** `tests/testthat/test-cvd.R` (regression guards, first-4 per
brand + both flagged pairs); `vignettes/articles/cvd-audit.Rmd`; NEWS.md bullet.

### Session 2 (item 2.2)

- **Scope expanded to continuous + binned.** This session's task brief asked
  for a continuous *and* binned scale matrix (`_c()`/`_b()`, 18 exports
  total), one step beyond this doc's original Session 2 spec (`_c()` only,
  9 exports). Treated as authoritative; `n.breaks = 7` defaults on the binned
  side since every ramp was tuned/CVD-checked specifically at 7 classes.
- **HFV `na_color` gap filled.** HFV had no `na_color` (`NULL`) since it never
  had a continuous scale before. Added `#d6dadd` (a light cool-leaning gray,
  echoing HFV's Shadow/Sky/Cerulean blues) alongside HDA's `#cfcfd0`/PHA's
  `#e2e4e3`, confirmed with Jonathan rather than invented silently.
- **All six R snippets in `plans/ramp-lab/REVIEW.md` re-verified via Rscript**
  before transcription into the registry — all six reproduced their stated
  hex exactly.
- Deprecation `with =` targets added to the three existing
  `scale_*_gradient_*()` soft-deprecations (this doc's step 4), one session
  early relative to a strict reading of the numbered steps above, since the
  replacement functions now exist.
- **Swatch eyeball check (continuous + binned, all six ramps):** all render as
  described in `REVIEW.md` — sequential ramps run cream (low) to the brand's
  dark anchor (high); HDA/PHA diverging run navy-family (low) through cream to
  brick/coral (high); HFV diverging runs green (low) through cream to
  berry-magenta (high), with the periwinkle/seafoam transitional band near
  center that REVIEW.md's HFV-diverging residual-concerns note called out.
  Binned (n=7) bands match the continuous ramp's color story at each stop. No
  surprises; nothing to flag beyond what REVIEW.md already documented.
