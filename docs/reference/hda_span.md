# Wrap text in a brand-colored HTML span (HDA)

Produces a `<span style='color:#…'>text</span>` tag for use with
[`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html)
or
[`ggtext::element_textbox()`](https://wilkelab.org/ggtext/reference/element_textbox.html).
Color is resolved through
[`hda_color()`](https://hdadvisors.github.io/hdatools/reference/hda_color.md).
Invalid names error with the valid list.

## Usage

``` r
hda_span(text, color)
```

## Arguments

- text:

  Character string to wrap.

- color:

  A valid HDA color name (e.g. `"Blue"`, `"Sea Green"`).

## Value

A character string containing the HTML span tag.

## See also

[`hda_color()`](https://hdadvisors.github.io/hdatools/reference/hda_color.md),
[`hfv_span()`](https://hdadvisors.github.io/hdatools/reference/hfv_span.md),
[`pha_span()`](https://hdadvisors.github.io/hdatools/reference/pha_span.md),
[`vha_span()`](https://hdadvisors.github.io/hdatools/reference/vha_span.md)

## Examples

``` r
hda_span("Housing Data Advisors", "Blue")
#> [1] "<span style='color:#445ca9'>Housing Data Advisors</span>"
hda_span("note", "Green")
#> [1] "<span style='color:#8baeaa'>note</span>"
```
