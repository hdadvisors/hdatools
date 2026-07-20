# VHA-branded continuous fill scale

A sequential or diverging `colorspace` HCL ramp.

## Usage

``` r
scale_fill_vha_c(
  palette = c("sequential", "diverging"),
  direction = 1,
  na.value = .brands$vha$na_color,
  guide = "colorbar",
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

- ...:

  Other arguments passed on to
  [`ggplot2::continuous_scale()`](https://ggplot2.tidyverse.org/reference/continuous_scale.html)

## Diverging ramp is provisional

**\[experimental\]** VHA's diverging ramp pairs Dark Turq against
Yellow, the palette's only warm hue. Yellow's natural HCL lightness is
too high to survive as a dark, saturated anchor, so that arm renders
golden/olive rather than bright yellow — a sRGB gamut limit, not a
tuning slip. Still monotonic and distinguishable under
protanopia/deuteranopia/tritanopia simulation, but — like HDA's
diverging ramp — a candidate for a follow-up Ramp Lab pass
(`plans/DECISIONS.md`).
