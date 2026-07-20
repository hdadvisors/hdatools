# Focus/emphasis palette for PHA

Returns a character vector of `n` hex colors for "highlight one series,
mute the rest" charts. The first element is the brand hex for `color`;
the remaining `n - 1` elements are PHA's neutral gray (`#e2e4e3`). Pass
the result to
[`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
or
[`ggplot2::scale_colour_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Usage

``` r
pha_focus_pal(color, n = 5)
```

## Arguments

- color:

  A valid PHA color name (e.g. `"Green"`, `"Orange"`).

- n:

  Total number of series (focus + muted). Must be a positive integer.

## Value

An unnamed character vector of length `n`.

## See also

[`pha_color()`](https://hdadvisors.github.io/hdatools/reference/pha_color.md),
[`hda_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/hda_focus_pal.md),
[`hfv_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/hfv_focus_pal.md),
[`vha_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/vha_focus_pal.md)

## Examples

``` r
pha_focus_pal("Green", n = 4)
#> [1] "#5bab8e" "#e2e4e3" "#e2e4e3" "#e2e4e3"
```
