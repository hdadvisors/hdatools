# Wrap text in a brand-colored HTML span (PHA)

Produces a `<span style='color:#…'>text</span>` tag for use with
[`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html)
or
[`ggtext::element_textbox()`](https://wilkelab.org/ggtext/reference/element_textbox.html).
Color is resolved through
[`pha_color()`](https://hdadvisors.github.io/hdatools/reference/pha_color.md),
so invalid names error with the valid list.

## Usage

``` r
pha_span(text, color)
```

## Arguments

- text:

  Character string to wrap.

- color:

  A valid PHA color name (e.g. `"Green"`, `"Dark Blue"`).

## Value

A character string containing the HTML span tag.

## See also

[`pha_color()`](https://hdadvisors.github.io/hdatools/reference/pha_color.md),
[`hda_span()`](https://hdadvisors.github.io/hdatools/reference/hda_span.md),
[`hfv_span()`](https://hdadvisors.github.io/hdatools/reference/hfv_span.md),
[`vha_span()`](https://hdadvisors.github.io/hdatools/reference/vha_span.md)

## Examples

``` r
pha_span("Partnership for Housing Affordability", "Green")
#> [1] "<span style='color:#5bab8e'>Partnership for Housing Affordability</span>"
pha_span("note", "Dark Blue")
#> [1] "<span style='color:#2b6b9c'>note</span>"
```
