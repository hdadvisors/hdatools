# Look up a single PHA color by name

Returns the hex value for the named PHA brand color. Errors with the
list of valid names when the name is not found.

## Usage

``` r
pha_color(name)
```

## Arguments

- name:

  A single color name, e.g. `"Orange"` or `"Teal Light"`.

## Value

A named character scalar (hex color).

## See also

[pha_colors](https://hdadvisors.github.io/hdatools/reference/pha_colors.md)

## Examples

``` r
pha_color("Orange")
#>    Orange 
#> "#f39152" 
pha_color("Teal Light")
#> Error: "Teal Light" is not a valid PHA color name. Valid names: Green, Light Blue, Orange, Red, Purple, Dark Blue.
```
