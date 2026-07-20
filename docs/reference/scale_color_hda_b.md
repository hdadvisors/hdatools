# HDA-branded binned color scale

The same sequential/diverging `colorspace` HCL ramps as
[`scale_color_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_c.md),
discretized into classes. Defaults to 7 classes, the count every ramp
was tuned and CVD-checked against in the Ramp Lab review
(`plans/ramp-lab/REVIEW.md`).

## Usage

``` r
scale_color_hda_b(
  palette = c("sequential", "diverging"),
  direction = 1,
  na.value = .brands$hda$na_color,
  guide = "coloursteps",
  n.breaks = 7,
  ...
)

scale_colour_hda_b(
  palette = c("sequential", "diverging"),
  direction = 1,
  na.value = .brands$hda$na_color,
  guide = "coloursteps",
  n.breaks = 7,
  ...
)
```

## Arguments

- palette:

  One of `"sequential"` (default) or `"diverging"`

- direction:

  For `palette = "sequential"`, `1` (default) maps higher values to
  darker colors; `-1` reverses so higher values are lighter. For
  `palette = "diverging"`, `1` (default) maps low values toward the
  first arm and high values toward the second, as constructed in the
  Ramp Lab review; `-1` swaps which arm represents low vs. high.

- na.value:

  Default color for NA values (#cfcfd0, HDA Light Gray)

- guide:

  Legend representation for scale

- n.breaks:

  Number of classes; defaults to 7 (see above)

- ...:

  Other arguments passed on to
  [`ggplot2::binned_scale()`](https://ggplot2.tidyverse.org/reference/binned_scale.html)

## Diverging palette usage

7-class diverging maps built from these ramps lose sign distinction in
their innermost class pair under protanopia (structural to the shared
cream center) — always pair a `palette = "diverging"` map with a legend
or direct labels. See `plans/DECISIONS.md` (2026-07-18).

## HDA diverging is provisional

**\[experimental\]** HDA's diverging ramp (Blue vs Coral) is a near-twin
of PHA's (Dark Blue vs Red) and is pending a follow-up Ramp Lab pass to
differentiate it before final adoption (see `plans/DECISIONS.md`,
2026-07-18). It ships now so the scale matrix is complete; treat it as
subject to change.
