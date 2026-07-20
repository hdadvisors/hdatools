# Named HFV color vector

A named character vector of the six HFV brand colors, taken directly
from the internal `.brands` registry. Names are the canonical color
labels (e.g. `"Shadow"`, `"Sky"`).

## Usage

``` r
hfv_colors
```

## See also

[`hfv_color()`](https://hdadvisors.github.io/hdatools/reference/hfv_color.md),
[hda_colors](https://hdadvisors.github.io/hdatools/reference/hda_colors.md),
[pha_colors](https://hdadvisors.github.io/hdatools/reference/pha_colors.md),
[vha_colors](https://hdadvisors.github.io/hdatools/reference/vha_colors.md)

## Examples

``` r
hfv_colors
#>    Shadow       Sky     Lilac     Grass     Berry    Desert      Leaf  Cerulean 
#> "#334a66" "#66cccc" "#a29dd4" "#50aaa7" "#c0327e" "#ec7c53" "#6fb547" "#7fc7e0" 
hfv_colors["Sky"]
#>       Sky 
#> "#66cccc" 
```
