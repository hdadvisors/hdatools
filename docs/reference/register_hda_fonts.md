# Register hdatools' bundled fonts for use in plots and knitr output

Registers the font faces bundled in `inst/fonts/` (Lato and Roboto Slab
for
[`theme_hda()`](https://hdadvisors.github.io/hdatools/reference/theme_hda.md),
Open Sans and Poppins for
[`theme_hfv()`](https://hdadvisors.github.io/hdatools/reference/theme_hfv.md),
Noto Sans for
[`theme_pha()`](https://hdadvisors.github.io/hdatools/reference/theme_pha.md),
Montserrat for
[`theme_vha()`](https://hdadvisors.github.io/hdatools/reference/theme_vha.md))
with systemfonts, making them available by name to ragg graphics devices
(and any other systemfonts-aware device). Everything is read from files
installed with the package. This never makes a network request.

## Usage

``` r
register_hda_fonts(quiet = FALSE)
```

## Arguments

- quiet:

  If `TRUE`, suppresses the message emitted when registering a family
  unexpectedly fails. A name collision with an installed system font is
  not a failure, so it is never reported. Registration issues are
  non-fatal: hdatools falls back to whatever fonts are already available
  on the system.

## Value

Invisibly, `TRUE` if every bundled family is available (registered by
hdatools or already present as a system font), `FALSE` if skipped via
the opt-out or if a family failed to register for an unexpected reason.

## Details

Rendering with these fonts requires a systemfonts-aware device. For
knitr/Quarto output, set `dev: "ragg_png"` (see `README.md`). The
default Cairo device does not consult the systemfonts registry.

Registration can be skipped by setting `options(hdatools.fonts = FALSE)`
or the environment variable `HDATOOLS_NO_FONTS` to any non-empty value.
This is useful if a consumer wants to supply its own font setup.

Each bundled family is registered independently.
[`systemfonts::register_font()`](https://systemfonts.r-lib.org/reference/register_font.html)
refuses to register a name that already matches an installed system font
(e.g. Open Sans ships with several common apps). When that happens, this
function leaves that one family alone and still registers the rest. The
system copy resolves under the same name anyway.
