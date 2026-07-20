# Look up a single HFV color by name

Returns the hex value for the named HFV brand color. Errors with the
list of valid names when the name is not found.

## Usage

``` r
hfv_color(name)
```

## Arguments

- name:

  A single color name, e.g. `"Sky"` or `"Shadow"`.

## Value

A named character scalar (hex color).

## See also

[hfv_colors](https://hdadvisors.github.io/hdatools/reference/hfv_colors.md)

## Examples

``` r
hfv_color("Sky")
#>       Sky 
#> "#66cccc" 
hfv_color("Shadow")
#>    Shadow 
#> "#334a66" 
```
