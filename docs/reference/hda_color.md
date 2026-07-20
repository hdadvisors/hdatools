# Look up a single HDA color by name

Returns the hex value for the named HDA brand color. Errors with the
list of valid names when the name is not found.

## Usage

``` r
hda_color(name)
```

## Arguments

- name:

  A single color name, e.g. `"Blue"` or `"Sea Green"`.

## Value

A named character scalar (hex color).

## See also

[hda_colors](https://hdadvisors.github.io/hdatools/reference/hda_colors.md)

## Examples

``` r
hda_color("Blue")
#>      Blue 
#> "#445ca9" 
hda_color("Sea Green")
#> Sea Green 
#> "#8abc8e" 
```
