# Migrating from showtext to ragg

hdatools 0.5.0 replaces the `showtext`/`sysfonts` font stack with
`systemfonts`. This article explains why the switch was made, what
consumers need to add to their projects, and what changes (and what
doesn’t) in rendered output.

## Why the switch

### Tidyverse guidance

The tidyverse now recommends the `systemfonts` + `ragg` stack for custom
font rendering in R. The previous approach —
[`sysfonts::font_add()`](https://rdrr.io/pkg/sysfonts/man/font_add.html)
followed by
[`showtext::showtext_auto()`](https://rdrr.io/pkg/showtext/man/showtext_auto.html)
— works, but it carries a significant drawback.
[`showtext::showtext_auto()`](https://rdrr.io/pkg/showtext/man/showtext_auto.html)
replaces R’s graphics device hooks globally. This means loading hdatools
was silently changing rendering behavior for every plot in a session,
even plots unrelated to hdatools themes.

### PDF text quality

The older showtext approach rasterizes text at figure resolution and
bakes it into the PDF as pixels, not as selectable text. Fonts
registered with `systemfonts` and rendered via `ragg` or a compatible
device are output as real vector text in PDFs. This means the text is
selectable, searchable, and crisp at any zoom level. Word and Typst
output also benefits from this approach.

### Cleaner package boundaries

`systemfonts` separates two concerns: font *registration* (hdatools’
job) and device *selection* (the consumer’s job, via their Quarto or
knitr configuration). hdatools now does only the registration step —
calling
[`systemfonts::register_font()`](https://systemfonts.r-lib.org/reference/register_font.html)
for each bundled typeface — and never touches knitr globals or the
active graphics device.

## What you need to add

To render plots with hdatools’ bundled fonts, your Quarto project must
use a `systemfonts`-aware graphics device. The default Cairo device does
not consult the `systemfonts` registry. Without this change, the bundled
fonts will not appear in rendered output.

Add the following to your project’s `_quarto.yml`:

``` yaml
knitr:
  opts_chunk:
    dev: "ragg_png"
```

This sets `ragg_png` as the default knitr graphics device for every
chunk in your document. `ragg_png` is the PNG device from the
[ragg](https://ragg.r-lib.org/) package and is fully
`systemfonts`-aware. The `ragg` package is listed in hdatools’
`Suggests`. Install it with `install.packages("ragg")` if it is not
already present.

For R Markdown documents (not Quarto), set the device per-chunk or
globally:

``` r

knitr::opts_chunk$set(dev = "ragg_png")
```

## Opting out of font registration

If you supply your own font setup and do not want hdatools to register
its bundled faces, set the option before loading the package:

``` r

options(hdatools.fonts = FALSE)
library(hdatools)
```

Or use the environment variable (useful in `.Renviron` or a CI
environment):

    HDATOOLS_NO_FONTS=1

Either opt-out leaves hdatools’ theme functions fully functional. They
will just resolve font names through whatever faces are already
registered on the system.

## What changes visually

### Minor metric and hinting shifts

`ragg` uses HarfBuzz and FreeType for text shaping and hinting, while
`showtext` uses its own rendering pipeline. In practice this produces:

- Slightly different character advance widths (affects line breaks and
  text wrapping in plot titles and labels).
- Richer sub-pixel hinting on screen; crisper vector text in PDFs.

In side-by-side comparisons the differences are subtle. Character
spacing may shift by a pixel or two in rasterized output, and wrapped
labels may reflow slightly. These are expected and acceptable rendering
improvements, not bugs.

### What does not change

- **Colors** — palette definitions, brand hex values, and scale
  functions are unchanged.
- **Theme layout** — margins, axis lines, gridline weights, base sizes,
  and all other
  [`ggplot2::theme()`](https://ggplot2.tidyverse.org/reference/theme.html)
  elements are identical to previous releases.
- **The `hdatools.fonts = FALSE` opt-out** — the mechanism and behavior
  are unchanged; hdatools simply uses
  [`systemfonts::register_font()`](https://systemfonts.r-lib.org/reference/register_font.html)
  internally instead of
  [`sysfonts::font_add()`](https://rdrr.io/pkg/sysfonts/man/font_add.html).
- **Font families available** — Lato, Roboto Slab, Open Sans, Poppins,
  Noto Sans, and Montserrat are all still bundled and registered.

## What hdatools no longer does

hdatools 0.4.x called `knitr::opts_chunk$set(fig.showtext = TRUE)` at
load time as a global side effect. **This is gone in 0.5.0.** Code that
relied on `fig.showtext = TRUE` being set automatically should add the
`dev: "ragg_png"` block above instead. The `ragg` device does not need
`fig.showtext`.
