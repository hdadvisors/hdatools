# Named HDA color vector

A named character vector of the six HDA brand colors, taken directly
from the internal `.brands` registry. Names are the canonical color
labels (e.g. `"Blue"`, `"Green"`).

## Usage

``` r
hda_colors
```

## Details

Use `hda_colors["Blue"]` to pull a single hex by name, or pass the whole
vector to `scale_fill_manual(values = hda_colors)` for manual scales.

## See also

[`hda_color()`](https://hdadvisors.github.io/hdatools/reference/hda_color.md),
[hfv_colors](https://hdadvisors.github.io/hdatools/reference/hfv_colors.md),
[pha_colors](https://hdadvisors.github.io/hdatools/reference/pha_colors.md),
[vha_colors](https://hdadvisors.github.io/hdatools/reference/vha_colors.md)

## Examples

``` r
hda_colors
#>      Blue     Green    Yellow     Coral  Lavender Sea Green 
#> "#445ca9" "#8baeaa" "#e9ab3f" "#e76f52" "#a97a92" "#8abc8e" 
hda_colors["Blue"]
#>      Blue 
#> "#445ca9" 
hda_colors[c("Blue", "Yellow")]
#>      Blue    Yellow 
#> "#445ca9" "#e9ab3f" 
```
