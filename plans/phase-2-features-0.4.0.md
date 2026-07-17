# Phase 2 — Features (release 0.4.0)

> **Skeleton only.** Drafted at the start of Phase 1's release session per
> ROADMAP.md convention (plans are written just-in-time so phase-gate
> interview answers shape them). Sessions have not started; do not begin
> Phase 2 work from this file alone — hold the phase-gate interview first.

| | |
|---|---|
| **Status** | blocked — Phase 1 (`release-0.3.0`) not yet merged to `main` |
| **Branch** | `release-0.4.0` (off `main`, after Phase 1 merges) |
| **Target version** | `0.4.0` |
| **Entry criteria** | Phase 1 merged and tagged `v0.3.0`; floating consumers (vhtf, fed-workforce) pinned per the cross-repo ledger in ROADMAP.md |
| **Exit criteria** | All Tier 2 items landed (or explicitly deferred with reason); release checklist done; PR merged; tag `v0.4.0` pushed |

## Interview — settle before coding (first ~10 minutes of Session 1)

Per ROADMAP.md's gate mapping, Phase 2 opens these questions from
[archive/hdatools-design-review.md §3](archive/hdatools-design-review.md):
**Q2** (brand.yml posture), **Q4** (ggplot2 ≥ 4.0 floor), **Q6** (ramp design
method), **Q7** (CVD reorder), **Q8** (VHA hexes + Montserrat), **Q9** (house
theme defaults). Record answers in [DECISIONS.md](DECISIONS.md) before
writing code.

## Tier 2 items (design review §2, item table)

Each becomes its own session (or is folded into an adjacent one) once the
gate answers are in; effort/blast-radius/API-break notes are the review's,
not re-verified here:

1. **2.1** — Export `hda_colors`/`hfv_colors`/`pha_colors` named vectors +
   `hda_color()` accessor, generated from the `.brands` registry
   ([R/brands.R](../R/brands.R)) Phase 1 already built.
2. **2.2** — Designed sequential + diverging ramps per brand; complete the
   `scale_*_{brand}_c()` matrix; soft-deprecate `scale_*_gradient_*` (gated
   on Q6).
3. **2.3** — ggplot2 4.x theme-carried palettes (`palette.colour.discrete`
   etc.) + `ink`/`paper` + `element_geom()` defaults in
   [R/themes.R](../R/themes.R)'s `.brand_theme()` builder (gated on Q4 —
   raises the ggplot2 floor to >= 4.0).
4. **2.4** — Brand extensibility proof: add VHA as a fourth brand
   (`theme_vha()`, palettes, scales — all from one `.brands` entry per the
   Phase 1 builder), bundle Montserrat, write an "adding a new client brand"
   howto (gated on Q8).
5. **2.5** — CVD audit (cols4all) + documented safe-subset ordering +
   `simulate_cvd` regression test. Document-only unless Q7 explicitly
   approves reordering (that recolors existing consumer charts).
6. **2.6** — ggtext span helper (e.g. `hda_span("text", "sky")`) replacing
   the hand-pasted `<span style='color:#…'>` pattern in fhfh/fed-workforce.
7. **2.7** — Focus/emphasis palette (one brand color + grays), afcharts
   "highlight one series" pattern.

## Cross-repo follow-ups relevant to this phase

See ROADMAP.md's ledger — in particular "retire the ~200-line local VHA
clone" (vhtf, after this phase) and "delete local hardcoded hex vectors"
(faar/fhfh/fed-workforce, after this phase).

## Findings (filled in during sessions)

*(none yet — phase not started)*
