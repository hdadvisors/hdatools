# Determine the current output format

This function checks the current environment to determine whether the
code is being run in an interactive session (like RStudio), or as part
of rendering an HTML, PDF, Typst, or Word document.

## Usage

``` r
get_output_format(manual_format = NULL)
```

## Arguments

- manual_format:

  An optional string specifying the format. If provided, this overrides
  the automatic detection.

## Value

A string indicating the detected format: `"studio"` for interactive
sessions, `"html"` for HTML output, `"typst"` for Typst output, `"docx"`
for Word output, or `"pdf"` for PDF/LaTeX and any other non-HTML knitr
output.

## Examples

``` r
# Automatic detection
get_output_format()
#> [1] "studio"

# Manual override
get_output_format("pdf")
#> [1] "pdf"
```
