# Wrap text in a brand-colored HTML span (VHA)

Produces a `<span style='color:#…'>text</span>` tag for use with
[`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html)
or
[`ggtext::element_textbox()`](https://wilkelab.org/ggtext/reference/element_textbox.html).
Color is resolved through
[`vha_color()`](https://hdadvisors.github.io/hdatools/reference/vha_color.md).
Invalid names error with the valid list.

## Usage

``` r
vha_span(text, color)
```

## Arguments

- text:

  Character string to wrap.

- color:

  A valid VHA color name (e.g. `"Dark Turq"`, `"Yellow"`).

## Value

A character string containing the HTML span tag.

## See also

[`vha_color()`](https://hdadvisors.github.io/hdatools/reference/vha_color.md),
[`hda_span()`](https://hdadvisors.github.io/hdatools/reference/hda_span.md),
[`hfv_span()`](https://hdadvisors.github.io/hdatools/reference/hfv_span.md),
[`pha_span()`](https://hdadvisors.github.io/hdatools/reference/pha_span.md)

## Examples

``` r
vha_span("Virginia Housing Alliance", "Dark Turq")
#> [1] "<span style='color:#0C4D4F'>Virginia Housing Alliance</span>"
vha_span("note", "Yellow")
#> [1] "<span style='color:#ECC51E'>note</span>"
```
