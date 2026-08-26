# PHA-branded discrete color scale

PHA-branded discrete color scale

## Usage

``` r
scale_color_pha(direction = 1, repeat_pal = FALSE, ...)

scale_colour_pha(direction = 1, repeat_pal = FALSE, ...)
```

## Arguments

- direction:

  If -1, reverse the scale (defaults to 1)

- repeat_pal:

  If TRUE, repeat the palette enough times to account for all discrete
  values

- ...:

  Additional arguments passed to ggplot2::discrete_scale()

## Value

A
[`ggplot2::discrete_scale()`](https://ggplot2.tidyverse.org/reference/discrete_scale.html)
object.

## Examples

``` r
library(ggplot2)
ggplot(mtcars, aes(wt, mpg, color = factor(cyl))) +
  geom_point() +
  scale_color_pha()

```
