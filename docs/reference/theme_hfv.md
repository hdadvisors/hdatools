# Use a HousingForward Virginia-branded ggplot2 theme

Use a HousingForward Virginia-branded ggplot2 theme

## Usage

``` r
theme_hfv(
  base_size = 14,
  base_family = "Open Sans",
  flip_gridlines = FALSE,
  output_format = NULL,
  html_adjust = 4,
  pdf_adjust = 7,
  ...
)
```

## Arguments

- base_size:

  The base size of text elements; defaults to 14

- base_family:

  The base font family; defaults to "Open Sans"

- flip_gridlines:

  Orientation of major gridlines; defaults to FALSE for y-axis

- output_format:

  Optional manual specification of output format

- html_adjust:

  Amount subtracted from base_size for HTML output; defaults to 4

- pdf_adjust:

  Amount subtracted from base_size for PDF output; defaults to 7

- ...:

  Additional arguments passed to ggplot2::theme()

## Details

When overriding strip text under ggplot2 \>= 4.0, use
[`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html),
never a raw
[`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html):
the branded strip element is a ggtext markdown element, and ggplot2 4.0
only merges theme elements of the same class.

The theme alone carries HFV's brand identity into an otherwise unbranded
plot: bar/column fills, point colors, and line colors default to
`hfv_colors["Shadow"]` (via
[`ggplot2::element_geom()`](https://ggplot2.tidyverse.org/reference/element.html)),
a discrete `aes(colour =)`/`aes(fill =)` mapping cycles through the full
HFV palette, and a continuous mapping uses the HFV sequential ramp (see
[`scale_color_hfv_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hfv_c.md))
— all with no `scale_*()` call required. An explicit `scale_*()` (or a
manual [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html)
value) always overrides these theme-carried defaults.
