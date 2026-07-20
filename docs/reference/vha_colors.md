# Named VHA color vector

A named character vector of the six VHA brand colors, taken directly
from the internal `.brands` registry. Names are the canonical color
labels (e.g. `"Dark Turq"`, `"Yellow"`).

## Usage

``` r
vha_colors
```

## See also

[`vha_color()`](https://hdadvisors.github.io/hdatools/reference/vha_color.md),
[hda_colors](https://hdadvisors.github.io/hdatools/reference/hda_colors.md),
[hfv_colors](https://hdadvisors.github.io/hdatools/reference/hfv_colors.md),
[pha_colors](https://hdadvisors.github.io/hdatools/reference/pha_colors.md)

## Examples

``` r
vha_colors
#>   Dark Turq Light Green      Yellow  Light Turq        Grey  Light Blue 
#>   "#0C4D4F"   "#A0D18E"   "#ECC51E"   "#19787B"   "#2E3030"   "#E3F3F5" 
vha_colors["Dark Turq"]
#> Dark Turq 
#> "#0C4D4F" 
```
