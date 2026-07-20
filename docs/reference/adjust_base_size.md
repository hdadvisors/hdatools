# Adjust base size for different output formats

This function adjusts the base font size depending on the output format
(studio, HTML, or PDF).

## Usage

``` r
adjust_base_size(base_size, html_adjust, pdf_adjust, format)
```

## Arguments

- base_size:

  The base font size for studio/interactive output.

- html_adjust:

  The amount to subtract from base_size for HTML output.

- pdf_adjust:

  The amount to subtract from base_size for PDF output.

- format:

  The output format, as returned by get_output_format().

## Value

An adjusted base size appropriate for the specified output format.

## Examples

``` r
adjust_base_size(12, 2, 5, "html")  # Returns 10
#> [1] 10
adjust_base_size(12, 2, 5, "pdf")   # Returns 7
#> [1] 7
adjust_base_size(12, 2, 5, "studio")  # Returns 12
#> [1] 12
```
