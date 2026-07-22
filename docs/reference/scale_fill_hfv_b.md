# HFV-branded binned fill scale

The same sequential/diverging `colorspace` HCL ramps as
[`scale_fill_hfv_c()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_hfv_c.md),
discretized into classes. Defaults to 7 classes, the count every ramp
was tuned and CVD-checked against in the Ramp Lab review
(`plans/ramp-lab/REVIEW.md`).

## Usage

``` r
scale_fill_hfv_b(
  palette = c("sequential", "diverging"),
  direction = 1,
  na.value = .brands$hfv$na_color,
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

  Default color for NA values (#d6dadd, HFV Light Gray)

- guide:

  Legend representation for scale

- n.breaks:

  Number of classes; defaults to 7 (see above)

- ...:

  Other arguments passed on to
  [`ggplot2::binned_scale()`](https://ggplot2.tidyverse.org/reference/binned_scale.html)

## Diverging palette usage

7-class diverging maps built from these ramps lose sign distinction in
their innermost class pair under protanopia. This is structural to the
shared cream center. Always pair a `palette = "diverging"` map with a
legend or direct labels. See `plans/DECISIONS.md` (2026-07-18).
