# Focus/emphasis palette for VHA

Returns a character vector of `n` hex colors for "highlight one series,
mute the rest" charts. The first element is the brand hex for `color`;
the remaining `n - 1` elements are VHA's neutral gray (`#d6dbdb`). Pass
the result to
[`ggplot2::scale_fill_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html)
or
[`ggplot2::scale_colour_manual()`](https://ggplot2.tidyverse.org/reference/scale_manual.html).

## Usage

``` r
vha_focus_pal(color, n = 5)
```

## Arguments

- color:

  A valid VHA color name (e.g. `"Dark Turq"`, `"Yellow"`).

- n:

  Total number of series (focus + muted). Must be a positive integer.

## Value

An unnamed character vector of length `n`.

## See also

[`vha_color()`](https://hdadvisors.github.io/hdatools/reference/vha_color.md),
[`hda_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/hda_focus_pal.md),
[`hfv_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/hfv_focus_pal.md),
[`pha_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/pha_focus_pal.md)

## Examples

``` r
vha_focus_pal("Dark Turq", n = 4)
#> [1] "#0C4D4F" "#d6dbdb" "#d6dbdb" "#d6dbdb"
```
