# hdatools

The `hdatools` package provides a set of functions and tools for data
analysis and visualization.

## Installation

``` r

# install.packages("devtools")
devtools::install_github("hdadvisors/hdatools")
```

hdatools bundles the Lato, Roboto Slab, Open Sans, Poppins, and Noto
Sans faces used by its themes and registers them with systemfonts
offline the first time the package loads — no network request, no
per-session Google Fonts download. To skip registration (for example, to
supply your own font setup), set `options(hdatools.fonts = FALSE)` or
the environment variable `HDATOOLS_NO_FONTS` before loading the package.

Rendering plots with these fonts requires a systemfonts-aware graphics
device. In a Quarto document, add the following to `_quarto.yml` (the
default Cairo device does not consult the systemfonts registry, so
without this the bundled fonts won’t appear in rendered output):

``` yaml
knitr:
  opts_chunk:
    dev: "ragg_png"
```

## Features

### Themes

- [`theme_hda()`](https://hdadvisors.github.io/hdatools/reference/theme_hda.md):
  HDAdvisors-branded ggplot2 theme
- [`theme_hfv()`](https://hdadvisors.github.io/hdatools/reference/theme_hfv.md):
  HousingForward Virginia-branded ggplot2 theme
- [`theme_pha()`](https://hdadvisors.github.io/hdatools/reference/theme_pha.md):
  PHA-branded ggplot2 theme

Under ggplot2 \>= 4.0, override a theme’s `strip.text` (e.g. for faceted
plots) with
[`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html),
never a raw
[`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html)
— the themes’ own strip element is a ggtext markdown element, and
ggplot2 4.0 only merges theme elements of the same class.

### Color Scales

- [`scale_color_hda()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda.md)/[`scale_colour_hda()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda.md),
  [`scale_fill_hda()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_hda.md):
  HDA-branded discrete color scales
- [`scale_color_hfv()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hfv.md)/[`scale_colour_hfv()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hfv.md),
  [`scale_fill_hfv()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_hfv.md):
  HFV-branded discrete color scales
- [`scale_color_pha()`](https://hdadvisors.github.io/hdatools/reference/scale_color_pha.md)/[`scale_colour_pha()`](https://hdadvisors.github.io/hdatools/reference/scale_color_pha.md),
  [`scale_fill_pha()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_pha.md):
  PHA-branded discrete color scales
- `scale_color_gradient_hda()`/`scale_colour_gradient_hda()`:
  HDA-branded continuous color scale (deprecated, use
  [`scale_color_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_c.md))
- `scale_color_gradient_pha()`/`scale_colour_gradient_pha()`,
  `scale_fill_gradient_pha()`: PHA-branded continuous color scales
  (deprecated, use
  [`scale_color_pha_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_pha_c.md)/[`scale_fill_pha_c()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_pha_c.md))

### Continuous ramp scales

Six `colorspace` HCL sequential/diverging ramps (one pair per brand),
tuned and CVD-checked in the Ramp Lab review. HDA’s diverging ramp is
provisional (see `NEWS.md`).

- [`scale_color_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_c.md)/[`scale_colour_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_c.md),
  [`scale_fill_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_hda_c.md):
  HDA-branded continuous color/fill scales
- [`scale_color_hfv_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hfv_c.md)/[`scale_colour_hfv_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hfv_c.md),
  [`scale_fill_hfv_c()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_hfv_c.md):
  HFV-branded continuous color/fill scales
- [`scale_color_pha_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_pha_c.md)/[`scale_colour_pha_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_pha_c.md),
  [`scale_fill_pha_c()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_pha_c.md):
  PHA-branded continuous color/fill scales
- [`scale_color_hda_b()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_b.md)/[`scale_colour_hda_b()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_b.md),
  [`scale_fill_hda_b()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_hda_b.md):
  HDA-branded binned color/fill scales (7 classes by default)
- [`scale_color_hfv_b()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hfv_b.md)/[`scale_colour_hfv_b()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hfv_b.md),
  [`scale_fill_hfv_b()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_hfv_b.md):
  HFV-branded binned color/fill scales (7 classes by default)
- [`scale_color_pha_b()`](https://hdadvisors.github.io/hdatools/reference/scale_color_pha_b.md)/[`scale_colour_pha_b()`](https://hdadvisors.github.io/hdatools/reference/scale_color_pha_b.md),
  [`scale_fill_pha_b()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_pha_b.md):
  PHA-branded binned color/fill scales (7 classes by default)

Each takes `palette = c("sequential", "diverging")` to choose the ramp.

### Utility Functions

- [`add_reliability()`](https://hdadvisors.github.io/hdatools/reference/add_reliability.md):
  Add reliability labels based on coefficient of variation
- [`fct_case_when()`](https://hdadvisors.github.io/hdatools/reference/fct_case_when.md):
  Create a factor with case_when logic and automatic level ordering
- [`markdown_wrap_gen()`](https://hdadvisors.github.io/hdatools/reference/markdown_wrap_gen.md):
  Generate a function to wrap and format facet labels with markdown
- [`add_zero_line()`](https://hdadvisors.github.io/hdatools/reference/add_zero_line.md):
  Add darker line to zero intercept
- [`flip_gridlines()`](https://hdadvisors.github.io/hdatools/reference/flip_gridlines.md):
  Flip major gridlines from horizontal to vertical
- [`publish_plot()`](https://hdadvisors.github.io/hdatools/reference/publish_plot.md):
  Create dynamic graphic from plot object when document rendered as HTML
- [`get_logo()`](https://hdadvisors.github.io/hdatools/reference/get_logo.md):
  Get an HDA/HFV logo `<img>` tag for use in a plot
- [`get_output_format()`](https://hdadvisors.github.io/hdatools/reference/get_output_format.md):
  Detect the current output format (studio, HTML, or PDF)
- [`adjust_base_size()`](https://hdadvisors.github.io/hdatools/reference/adjust_base_size.md):
  Adjust a base font size for the detected output format
- [`register_hda_fonts()`](https://hdadvisors.github.io/hdatools/reference/register_hda_fonts.md):
  Register hdatools’ bundled fonts (called automatically on load)

## Usage

Basic example:

``` r

library(hdatools)
library(tidyverse)

# Create a sample dataset
data <- data.frame(
  x = as.character(c(1:8)),
  y = runif(8, 0, 100),
  group = rep(c("A", "B"), each = 4)
)

# Create a plot with HDA theme and colors
ggplot(data, aes(x, y, fill = group)) +
  geom_col(position = "dodge") +
  scale_fill_hda() +
  add_zero_line() +
  theme_hda() +
  labs(title = "Sample Plot with HDA Theme",
       subtitle = "Using *hdatools* package",
       caption = "**Source:** Data source.")

# Add reliability labels to a dataset, naming the CV column (percent scale)
data_with_reliability <- data |> 
  mutate(cv = runif(8, 0, 50)) |> 
  add_reliability(cv_col = cv)

# Legacy path: auto-detects a single column ending in "_cv" (0-1 proportion)
data_with_legacy_cv <- data |> 
  mutate(value_cv = runif(8, 0, 0.5)) |> 
  add_reliability()

# Create a factor with custom ordering
data_with_factor <- data |> 
  mutate(factor_col = fct_case_when(
    x < 3 ~ "Low",
    x < 7 ~ "Medium",
    TRUE ~ "High"
  ))
```

![](reference/figures/hda_plot.png)
