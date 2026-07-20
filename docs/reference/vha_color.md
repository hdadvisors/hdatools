# Look up a single VHA color by name

Returns the hex value for the named VHA brand color. Errors with the
list of valid names when the name is not found.

## Usage

``` r
vha_color(name)
```

## Arguments

- name:

  A single color name, e.g. `"Dark Turq"` or `"Yellow"`.

## Value

A named character scalar (hex color).

## See also

[vha_colors](https://hdadvisors.github.io/hdatools/reference/vha_colors.md)

## Examples

``` r
vha_color("Dark Turq")
#> Dark Turq 
#> "#0C4D4F" 
vha_color("Yellow")
#>    Yellow 
#> "#ECC51E" 
```
