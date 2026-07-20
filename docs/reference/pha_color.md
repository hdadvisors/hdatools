# Look up a single PHA color by name

Returns the hex value for the named PHA brand color. Errors with the
list of valid names when the name is not found.

## Usage

``` r
pha_color(name)
```

## Arguments

- name:

  A single color name, e.g. `"Green"` or `"Dark Blue"`.

## Value

A named character scalar (hex color).

## See also

[pha_colors](https://hdadvisors.github.io/hdatools/reference/pha_colors.md)

## Examples

``` r
pha_color("Green")
#>     Green 
#> "#5bab8e" 
pha_color("Dark Blue")
#> Dark Blue 
#> "#2b6b9c" 
```
