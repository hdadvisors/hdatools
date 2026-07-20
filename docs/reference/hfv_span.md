# Wrap text in a brand-colored HTML span (HFV)

Produces a `<span style='color:#…'>text</span>` tag for use with
[`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html)
or
[`ggtext::element_textbox()`](https://wilkelab.org/ggtext/reference/element_textbox.html).
Color is resolved through
[`hfv_color()`](https://hdadvisors.github.io/hdatools/reference/hfv_color.md),
so invalid names error with the valid list.

## Usage

``` r
hfv_span(text, color)
```

## Arguments

- text:

  Character string to wrap.

- color:

  A valid HFV color name (e.g. `"Shadow"`, `"Sky"`).

## Value

A character string containing the HTML span tag.

## See also

[`hfv_color()`](https://hdadvisors.github.io/hdatools/reference/hfv_color.md),
[`hda_span()`](https://hdadvisors.github.io/hdatools/reference/hda_span.md),
[`pha_span()`](https://hdadvisors.github.io/hdatools/reference/pha_span.md),
[`vha_span()`](https://hdadvisors.github.io/hdatools/reference/vha_span.md)

## Examples

``` r
hfv_span("HousingForward Virginia", "Shadow")
#> [1] "<span style='color:#334a66'>HousingForward Virginia</span>"
hfv_span("note", "Sky")
#> [1] "<span style='color:#66cccc'>note</span>"
```
