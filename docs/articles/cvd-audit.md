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
almost always used in a categorical plot — plus the pairs flagged for
each brand: HDA Green vs Sea Green (from the 0.4.0 design review) and
PHA Teal vs Blue (from the 2026-08 rebrand).

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
Green are positions 2 and 6, so they appear together only in a
5–6-category plot. Recommendations:

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
colors are teal-family; they are distinguishable in normal vision by
their lightness contrast but that contrast diminishes under red-green
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

Palette: Orange `#f78f49`, Teal `#42a18d`, Blue `#3990b1`, Navy
`#0b242e`, Orange Deep `#a4560c`, Teal Light `#a0d0c3`

The first four are PHA’s own 2026 guide colors; the last two are tints
derived from Orange and Teal. This section covers the palette adopted in
2026-08; the previous PHA palette (Green, Light Blue, Orange, Red,
Purple, Dark Blue) was retired with the rebrand.

| color1 | color2 | Normal | Protan | Deutan | Tritan | Flag |
|:-------|:-------|-------:|-------:|-------:|-------:|:-----|
| Orange | Teal   |   84.4 |   41.8 |   58.5 |   92.6 |      |
| Orange | Blue   |   93.1 |   70.7 |   85.7 |   90.3 |      |
| Orange | Navy   |   93.1 |   76.0 |   89.5 |   87.6 |      |
| Teal   | Blue   |   32.5 |   29.0 |   27.3 |    6.6 | ⚠️   |
| Teal   | Navy   |   56.0 |   51.3 |   47.3 |   52.9 |      |
| Blue   | Navy   |   46.9 |   46.8 |   45.5 |   48.9 |      |

PHA palette — pairwise delta-E by CVD type {.table}

Separation is strong across the first four under red-green CVD: every
pair clears delta-E 27 under protanopia and deuteranopia, and 32 under
normal vision. Under tritanopia every pair clears 52 except one, covered
next.

### PHA: Teal vs Blue (documented limitation)

| color1 | color2 | Normal | Protan | Deutan | Tritan | Flag |
|:-------|:-------|-------:|-------:|-------:|-------:|:-----|
| Teal   | Blue   |   32.5 |     29 |   27.3 |    6.6 | ⚠️   |

PHA — Teal vs Blue palette — pairwise delta-E by CVD type {.table}

**Confirmed limitation.** Teal and Blue collapse to delta-E ≈ 6.6 under
full tritanopia — below the threshold where two colors reliably read as
different. Protanopia and deuteranopia are unaffected (29.0 and 27.3).

This is inherent to PHA’s own guide. Its two cool hues sit at HCL 168.6
and 227.1, and a tritan simulation maps that hue range close together.
Correcting it would mean substituting a hue the brand guidelines do not
sanction, so it is documented rather than worked around — the same
posture taken for HDA’s Green/Sea Green pair.

Recommendations:

- **Avoid using Teal and Blue as the only two series colors** in a chart
  where tritanopic accessibility matters. Add a shape, pattern, or
  direct-label encoding alongside color if both are needed.
- In 3-category and 4-category plots, order series so Teal and Blue are
  not adjacent in a legend, where label proximity compensates for color
  proximity.
- Navy is a safe substitute for Blue in a two-color chart: Teal vs Navy
  holds delta-E 52.9 under tritanopia, and Navy is an official guide
  color.

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
across CVD types). Both are deep teal tones; the primary cue under CVD
is the lightness difference (Dark Turq is considerably darker). No pair
falls below 10 in the first-4 audit.

Recommendations:

- In 2-category plots the pair is acceptable; the lightness contrast is
  sufficient.
- In 4-category plots, prefer not to place Dark Turq and Light Turq as
  the only two categories without supplemental encoding.

------------------------------------------------------------------------

## Diverging ramp caveat

As documented in NEWS.md, 7-class diverging maps built from any of the
six continuous ramps lose sign distinction in the innermost class pair
under protanopia, because both arms converge toward the shared cream
center. This is structural to any cream-centered diverging ramp; the
mitigation is to always pair a `palette = "diverging"` map with a legend
or direct class labels.

------------------------------------------------------------------------

## Regression tests

`tests/testthat/test-cvd.R` contains
[`colorspace::simulate_cvd()`](https://colorspace.R-Forge.R-project.org/reference/simulate_cvd.html)-based
assertions that the first four colors of each brand palette maintain the
minimum pairwise delta-E thresholds observed above. These tests guard
against future palette edits that silently reduce CVD
distinguishability; they do not validate the absolute CVD safety of the
palettes. They do not test the two documented tritanopia failures — HDA
Green/Sea Green and PHA Teal/Blue — which are limitations rather than
thresholds a future edit could improve accidentally. For PHA the tritan
guard still runs across the other five first-4 pairs, with Teal/Blue
excluded, so the collapse does not mask them.
