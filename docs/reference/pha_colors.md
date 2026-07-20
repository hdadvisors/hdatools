# Named PHA color vector

A named character vector of the six PHA brand colors, taken directly
from the internal `.brands` registry. Names are the canonical color
labels (e.g. `"Green"`, `"Orange"`).

## Usage

``` r
pha_colors
```

## See also

[`pha_color()`](https://hdadvisors.github.io/hdatools/reference/pha_color.md),
[hda_colors](https://hdadvisors.github.io/hdatools/reference/hda_colors.md),
[hfv_colors](https://hdadvisors.github.io/hdatools/reference/hfv_colors.md),
[vha_colors](https://hdadvisors.github.io/hdatools/reference/vha_colors.md)

## Examples

``` r
pha_colors
#>      Green Light Blue     Orange        Red     Purple  Dark Blue 
#>  "#5bab8e"  "#a6cccc"  "#f39152"  "#be451c"  "#a5add0"  "#2b6b9c" 
pha_colors["Green"]
#>     Green 
#> "#5bab8e" 
```
