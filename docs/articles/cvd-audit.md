# CVD accessibility audit — hdatools palettes

This article documents a colorblind-vision (CVD) audit of the four
hdatools brand palettes conducted for the 0.4.0 release. It covers
protanopia, deuteranopia, and tritanopia at full severity. **No palette
color order was changed as a result of this audit** (see
`plans/DECISIONS.md`, Q7, 2026-07-18). The findings here inform chart
authors on which color pairs to avoid in categorical plots and when
supplemental encodings are needed.

## Method

Pairwise perceptual distance (delta-E, CIE76) was computed in Lab color
space via `colorspace`:

1.  Simulate full-severity CVD with
    [`colorspace::protan()`](https://colorspace.R-Forge.R-project.org/reference/simulate_cvd.html)
    / `deutan()` / `tritan()`
2.  Convert simulated hex values to Lab with
    [`colorspace::hex2RGB()`](https://colorspace.R-Forge.R-project.org/reference/hex2RGB.html)
    → `as(., "LAB")`
3.  Compute Euclidean distance (delta-E) for every color pair

Delta-E below **10** is generally considered indistinguishable; values
of **10–20** are borderline; values above **20** are comfortably
distinct. The audit focuses on the first four palette slots — the range
almost always used in a categorical plot — plus two pairs flagged during
the 0.4.0 design review.

------------------------------------------------------------------------

## HDA

Palette: Blue `#445ca9`, Green `#8baeaa`, Yellow `#e9ab3f`, Coral
`#e76f52`, Lavender `#a97a92`, Sea Green `#8abc8e`

| color1 | color2 | Normal | Protan | Deutan | Tritan | Flag |
|:-------|:-------|-------:|-------:|-------:|-------:|:-----|
| Blue   | Green  |   57.7 |   50.9 |   51.9 |   29.5 |      |
| Blue   | Yellow |  111.0 |  109.7 |  113.8 |   73.8 |      |
| Blue   | Coral  |   89.4 |   73.5 |   91.8 |   95.6 |      |
| Green  | Yellow |   68.8 |   63.0 |   65.0 |   57.3 |      |
| Green  | Coral  |   70.0 |   33.1 |   45.2 |   85.1 |      |
| Yellow | Coral  |   41.7 |   37.3 |   22.7 |   30.8 |      |

HDA palette — pairwise delta-E by CVD type {.table}

**First-4 audit — no failures.** The minimum pairwise delta-E across all
CVD types is 22.7 (Yellow vs Coral under deuteranopia). All first-4
pairs are comfortably distinct.

### HDA: Green vs Sea Green (flagged pair)

| color1 | color2    | Normal | Protan | Deutan | Tritan | Flag |
|:-------|:----------|-------:|-------:|-------:|-------:|:-----|
| Green  | Sea Green |     24 |   22.3 |   19.6 |      6 | ⚠️   |

HDA — Green vs Sea Green palette — pairwise delta-E by CVD type {.table}

**Tritanopia failure confirmed.** Green (`#8baeaa`) and Sea Green
(`#8abc8e`) collapse to delta-E = 5.97 under full tritanopia —
effectively indistinguishable. Under protanopia and deuteranopia the
pair is acceptable (delta-E ≈ 20–22).

Tritanopia affects approximately 0.1 % of the population. Green and Sea
Green are positions 2 and 6. They appear together only in a 5–6-category
plot. Recommendations:

- **Avoid pairing Green and Sea Green in a plot that targets tritanopic
  accessibility.**
- In 2–4-category plots the pair will not both appear, so no action is
  needed.
- If a chart must use both and CVD robustness is critical, replace one
  with a manual override (e.g. swap Sea Green for Coral or Lavender).

------------------------------------------------------------------------

## HFV

Palette: Shadow `#334a66`, Sky `#66cccc`, Lilac `#a29dd4`, Grass
`#50aaa7`, Berry `#c0327e`, Desert `#ec7c53`, Leaf `#6fb547`, Cerulean
`#7fc7e0`

| color1 | color2 | Normal | Protan | Deutan | Tritan | Flag |
|:-------|:-------|-------:|-------:|-------:|-------:|:-----|
| Shadow | Sky    |   55.0 |   49.1 |   45.3 |   52.4 |      |
| Shadow | Lilac  |   39.6 |   36.9 |   37.7 |   38.3 |      |
| Shadow | Grass  |   45.0 |   37.9 |   34.3 |   40.0 |      |
| Sky    | Lilac  |   47.7 |   26.5 |   17.2 |   39.7 |      |
| Sky    | Grass  |   12.4 |   12.6 |   12.1 |   12.7 |      |
| Lilac  | Grass  |   46.0 |   25.4 |   18.4 |   34.5 |      |

HFV palette — pairwise delta-E by CVD type {.table}

**Sky vs Grass is the structurally risky pair.** Delta-E is
approximately 12 under all three CVD types (12.1–12.7) — within the
borderline range and the lowest minimum of any first-4 audit. Both
colors are teal-family. They are distinguishable in normal vision by
their lightness contrast, but that contrast diminishes under red-green
CVD.

No pair falls below 10 in the first-4 audit, so no automatic failure.
Recommendations:

- **Avoid using Sky and Grass as the only two series colors** in a
  CVD-sensitive chart. If both are needed, add a shape, pattern, or
  direct-label encoding alongside color.
- 3-category or 4-category plots should order series so Sky and Grass
  are not adjacent in a legend (where label proximity compensates for
  color proximity).

------------------------------------------------------------------------

## PHA

Palette: Green `#5bab8e`, Light Blue `#a6cccc`, Orange `#f39152`, Red
`#be451c`, Purple `#a5add0`, Dark Blue `#2b6b9c`

| color1     | color2     | Normal | Protan | Deutan | Tritan | Flag |
|:-----------|:-----------|-------:|-------:|-------:|-------:|:-----|
| Green      | Light Blue |   26.9 |   19.8 |   18.5 |   21.3 |      |
| Green      | Orange     |   75.6 |   32.0 |   47.6 |   86.3 |      |
| Green      | Red        |   90.1 |   39.5 |   48.2 |  105.9 |      |
| Light Blue | Orange     |   69.5 |   48.7 |   57.0 |   72.8 |      |
| Light Blue | Red        |   85.7 |   59.3 |   63.2 |   96.3 |      |
| Orange     | Red        |   27.8 |   25.6 |   22.5 |   28.9 |      |

PHA palette — pairwise delta-E by CVD type {.table}

**Green vs Light Blue is the tightest pair** (delta-E ≈ 18.5–21.3 across
CVD types). Both are cool desaturated colors that lose further
differentiation under red-green CVD. No pair falls below 10.

### PHA: Orange vs Red (flagged pair)

| color1 | color2 | Normal | Protan | Deutan | Tritan | Flag |
|:-------|:-------|-------:|-------:|-------:|-------:|:-----|
| Orange | Red    |   27.8 |   25.6 |   22.5 |   28.9 |      |

PHA — Orange vs Red palette — pairwise delta-E by CVD type {.table}

**Not confirmed as a failure.** The flagged Orange/Red pair maintains
delta-E ≥ 22 under all CVD types. The lightness difference (Orange is
substantially lighter) provides the primary perceptual cue, and it is
preserved under CVD simulation.

Recommendation: no action needed for the Orange/Red pair. For Green vs
Light Blue in 4-category plots, consider adding a secondary encoding if
tritanopic accessibility is a concern.

------------------------------------------------------------------------

## VHA

Palette: Dark Turq `#0C4D4F`, Light Green `#A0D18E`, Yellow `#ECC51E`,
Light Turq `#19787B`, Grey `#2E3030`, Light Blue `#E3F3F5`

| color1      | color2      | Normal | Protan | Deutan | Tritan | Flag |
|:------------|:------------|-------:|-------:|-------:|-------:|:-----|
| Dark Turq   | Light Green |   61.7 |   61.2 |   61.0 |   49.0 |      |
| Dark Turq   | Yellow      |  100.6 |   95.8 |  100.1 |   72.2 |      |
| Dark Turq   | Light Turq  |   17.9 |   17.1 |   16.5 |   18.3 |      |
| Light Green | Yellow      |   57.0 |   47.0 |   49.8 |   46.2 |      |
| Light Green | Light Turq  |   50.3 |   49.8 |   51.2 |   34.8 |      |
| Yellow      | Light Turq  |   97.0 |   90.1 |   95.6 |   68.5 |      |

VHA palette — pairwise delta-E by CVD type {.table}

**Dark Turq vs Light Turq is the tightest pair** (delta-E ≈ 16.5–18.3
across CVD types). Both are deep teal tones. The primary cue under CVD
is the lightness difference (Dark Turq is considerably darker). No pair
falls below 10 in the first-4 audit.

Recommendations:

- In 2-category plots the pair is acceptable; the lightness contrast is
  sufficient.
- In 4-category plots, prefer not to place Dark Turq and Light Turq as
  the only two categories without supplemental encoding.

------------------------------------------------------------------------

## Diverging ramp caveat

Both arms of a 7-class diverging map converge toward the shared cream
center. As documented in NEWS.md, this causes diverging maps built from
any of the six continuous ramps to lose sign distinction in the
innermost class pair under protanopia. This is structural to any
cream-centered diverging ramp. The mitigation is to always pair a
`palette = "diverging"` map with a legend or direct class labels.

------------------------------------------------------------------------

## Regression tests

`tests/testthat/test-cvd.R` contains
[`colorspace::simulate_cvd()`](https://colorspace.R-Forge.R-project.org/reference/simulate_cvd.html)-based
assertions that the first four colors of each brand palette maintain the
minimum pairwise delta-E thresholds observed above. These tests guard
against future palette edits that silently reduce CVD
distinguishability. They do not validate the absolute CVD safety of the
palettes. They also do not test the HDA Green/Sea Green tritanopia
failure. That failure is a documented limitation, not a threshold a
future edit could improve accidentally.
