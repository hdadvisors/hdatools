# Use an HDAdvisors-branded ggplot2 theme

Use an HDAdvisors-branded ggplot2 theme

## Usage

``` r
theme_hda(
  base_size = 14,
  base_family = "Lato",
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

  The base font family; defaults to "Lato"

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
[`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html).
The branded strip element is a ggtext markdown element. ggplot2 4.0 only
merges theme elements of the same class.

The theme alone carries HDA's brand identity into an otherwise unbranded
plot, with no `scale_*()` call required:

- Bar/column fills, point colors, and line colors default to
  `hda_colors["Blue"]` (via
  [`ggplot2::element_geom()`](https://ggplot2.tidyverse.org/reference/element.html)).

- A discrete `aes(colour =)`/`aes(fill =)` mapping cycles through the
  full HDA palette.

- A continuous mapping uses the HDA sequential ramp (see
  [`scale_color_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_c.md)).

An explicit `scale_*()` (or a manual
[`aes()`](https://ggplot2.tidyverse.org/reference/aes.html) value)
always overrides these theme-carried defaults.
