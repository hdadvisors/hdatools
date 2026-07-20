# VHA-branded binned fill scale

The same sequential/diverging `colorspace` HCL ramps as
[`scale_fill_vha_c()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_vha_c.md),
discretized into classes. Defaults to 7 classes.

## Usage

``` r
scale_fill_vha_b(
  palette = c("sequential", "diverging"),
  direction = 1,
  na.value = .brands$vha$na_color,
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
  first arm and high values toward the second; `-1` swaps which arm
  represents low vs. high.

- na.value:

  Default color for NA values (#d6dbdb, VHA Light Gray)

- guide:

  Legend representation for scale

- n.breaks:

  Number of classes; defaults to 7

- ...:

  Other arguments passed on to
  [`ggplot2::binned_scale()`](https://ggplot2.tidyverse.org/reference/binned_scale.html)

## Diverging ramp is provisional

**\[experimental\]** See
[`scale_color_vha_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_vha_c.md)
for the Yellow-arm gamut caveat.
