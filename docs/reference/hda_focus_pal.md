# Focus/emphasis palette for HDA

Returns a character vector of `n` hex colors for "highlight one series,
mute the rest" charts. The first element is the brand hex for `color`;
the remaining `n - 1` elements are HDA's neutral gray (`#cfcfd0`). Pass
the result to
[`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
or
[`ggplot2::scale_colour_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Usage

``` r
hda_focus_pal(color, n = 5)
```

## Arguments

- color:

  A valid HDA color name (e.g. `"Blue"`, `"Green"`).

- n:

  Total number of series (focus + muted). Must be a positive integer.

## Value

An unnamed character vector of length `n`.

## See also

[`hda_color()`](https://hdadvisors.github.io/hdatools/reference/hda_color.md),
[`hfv_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/hfv_focus_pal.md),
[`pha_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/pha_focus_pal.md),
[`vha_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/vha_focus_pal.md)

## Examples

``` r
hda_focus_pal("Blue", n = 4)
#> [1] "#445ca9" "#cfcfd0" "#cfcfd0" "#cfcfd0"
```
