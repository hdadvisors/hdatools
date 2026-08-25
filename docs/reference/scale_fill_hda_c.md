# HDA-branded continuous fill scale

A sequential or diverging `colorspace` HCL ramp, tuned and CVD-checked
against protanopia, deuteranopia, and tritanopia in the Ramp Lab review
(`plans/ramp-lab/REVIEW.md`).

## Usage

``` r
scale_fill_hda_c(
  palette = c("sequential", "diverging"),
  direction = 1,
  na.value = .brands$hda$na_color,
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
  first arm and high values toward the second, as constructed in the
  Ramp Lab review; `-1` swaps which arm represents low vs. high.

- na.value:

  Default color for NA values (#cfcfd0, HDA Light Gray)

- guide:

  Legend representation for scale

- ...:

  Other arguments passed on to
  [`ggplot2::continuous_scale()`](https://ggplot2.tidyverse.org/reference/continuous_scale.html)

## Value

A
[`ggplot2::continuous_scale()`](https://ggplot2.tidyverse.org/reference/continuous_scale.html)
object.

## Diverging palette usage

7-class diverging maps built from these ramps lose sign distinction in
their innermost class pair under protanopia (structural to the shared
cream center) — always pair a `palette = "diverging"` map with a legend
or direct labels. See `plans/DECISIONS.md` (2026-07-18).

## HDA diverging is provisional

**\[experimental\]** HDA's diverging ramp (Blue vs Coral) is pending a
follow-up Ramp Lab pass before final adoption (see `plans/DECISIONS.md`,
2026-07-18). PHA's 2026 rebrand moved its diverging arms to Blue vs
Orange, which widened the cool-arm gap between the two brands from 16 to
32 degrees, but the HDA pass is still open on its own terms. It ships
now so the scale matrix is complete; treat it as subject to change.

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg, fill = disp)) +
  geom_point(shape = 21) +
  scale_fill_hda_c()

```
