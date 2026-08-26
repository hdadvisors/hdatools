# Named PHA color vector

A named character vector of the six PHA brand colors, taken directly
from the internal `.brands` registry. Names are the canonical color
labels (e.g. `"Orange"`, `"Teal"`).

## Usage

``` r
pha_colors
```

## Details

The first four — `"Orange"`, `"Teal"`, `"Blue"`, `"Navy"` — are PHA's
own guide colors, so a chart with four or fewer categories uses only
sanctioned brand colors. `"Orange Deep"` and `"Teal Light"` are tints
derived from the first two and appear only at five and six categories.

## See also

[`pha_color()`](https://hdadvisors.github.io/hdatools/reference/pha_color.md),
[hda_colors](https://hdadvisors.github.io/hdatools/reference/hda_colors.md),
[hfv_colors](https://hdadvisors.github.io/hdatools/reference/hfv_colors.md),
[vha_colors](https://hdadvisors.github.io/hdatools/reference/vha_colors.md)

## Examples

``` r
pha_colors
#>      Orange        Teal        Blue        Navy Orange Deep  Teal Light 
#>   "#f78f49"   "#42a18d"   "#3990b1"   "#0b242e"   "#a4560c"   "#a0d0c3" 
pha_colors["Orange"]
#>    Orange 
#> "#f78f49" 
```
