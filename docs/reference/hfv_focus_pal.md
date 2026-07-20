# Focus/emphasis palette for HFV

Returns a character vector of `n` hex colors for "highlight one series,
mute the rest" charts. The first element is the brand hex for `color`;
the remaining `n - 1` elements are HFV's neutral gray (`#d6dadd`). Pass
the result to
[`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
or
[`ggplot2::scale_colour_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Usage

``` r
hfv_focus_pal(color, n = 5)
```

## Arguments

- color:

  A valid HFV color name (e.g. `"Shadow"`, `"Sky"`).

- n:

  Total number of series (focus + muted). Must be a positive integer.

## Value

An unnamed character vector of length `n`.

## See also

[`hfv_color()`](https://hdadvisors.github.io/hdatools/reference/hfv_color.md),
[`hda_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/hda_focus_pal.md),
[`pha_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/pha_focus_pal.md),
[`vha_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/vha_focus_pal.md)

## Examples

``` r
hfv_focus_pal("Shadow", n = 4)
#> [1] "#334a66" "#d6dadd" "#d6dadd" "#d6dadd"
```
