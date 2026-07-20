# Changelog

## hdatools 0.5.0

- Fixed an unwanted stroke outline on
  [`geom_col()`](https://ggplot2.tidyverse.org/reference/geom_bar.html)/[`geom_bar()`](https://ggplot2.tidyverse.org/reference/geom_bar.html)
  bars: brand themes
  ([`theme_hda()`](https://hdadvisors.github.io/hdatools/reference/theme_hda.md),
  [`theme_hfv()`](https://hdadvisors.github.io/hdatools/reference/theme_hfv.md),
  [`theme_pha()`](https://hdadvisors.github.io/hdatools/reference/theme_pha.md),
  [`theme_vha()`](https://hdadvisors.github.io/hdatools/reference/theme_vha.md))
  now set `colour = NA` in their
  [`ggplot2::element_geom()`](https://ggplot2.tidyverse.org/reference/element.html)
  default instead of the fill color, so column/bar charts no longer
  render a visible border (closes
  [\#21](https://github.com/hdadvisors/hdatools/issues/21)).

- [`get_output_format()`](https://hdadvisors.github.io/hdatools/reference/get_output_format.md)
  now distinguishes `"typst"` and `"docx"` output from `"pdf"` instead
  of folding all three into `"pdf"`.

- The “Using branded themes in hdatools” article no longer requires a
  Census API key or network access to build — it now uses a small
  bundled data table instead of a live
  [`tidycensus::get_acs()`](https://walker-data.com/tidycensus/reference/get_acs.html)
  call.

- Replaced the `showtext`/`sysfonts` font stack with `systemfonts`
  (`ragg` moved to Suggests, as a recommended rendering device —
  hdatools itself never calls it).
  [`register_hda_fonts()`](https://hdadvisors.github.io/hdatools/reference/register_hda_fonts.md)
  now registers the bundled Lato, Roboto Slab, Open Sans, Poppins, Noto
  Sans, and Montserrat faces via
  [`systemfonts::register_font()`](https://systemfonts.r-lib.org/reference/register_font.html);
  the `hdatools.fonts` opt-out still works the same way. Consumers
  rendering with knitr/Quarto must add `dev: "ragg_png"` under
  `knitr: opts_chunk:` in `_quarto.yml` (see `README.md`) — the default
  Cairo device does not consult the systemfonts registry, so without it
  the bundled fonts won’t appear in rendered output. hdatools no longer
  sets `knitr::opts_chunk$set(fig.showtext = TRUE)` as a load-time
  global side effect.

- Removed `hda_pal_discrete()`, `hfv_pal_discrete()`,
  `pha_pal_discrete()`, `scale_color_gradient_hda()`,
  `scale_colour_gradient_hda()`, `scale_color_gradient_pha()`,
  `scale_colour_gradient_pha()`, and `scale_fill_gradient_pha()` — all
  soft-deprecated in 0.3.0. Use the discrete scales
  ([`scale_color_hda()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda.md)
  /
  [`scale_fill_hda()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_hda.md)
  etc.) and continuous ramp scales
  ([`scale_color_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_c.md)
  /
  [`scale_fill_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_hda_c.md)
  etc.) introduced in 0.3.0 and 0.4.0 respectively.

## hdatools 0.4.0

- New
  [`hda_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/hda_focus_pal.md)/[`hfv_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/hfv_focus_pal.md)/[`pha_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/pha_focus_pal.md)/[`vha_focus_pal()`](https://hdadvisors.github.io/hdatools/reference/vha_focus_pal.md)
  return a focus/emphasis palette for “highlight one series, mute the
  rest” charts: element 1 is the named brand color hex, elements 2–`n`
  are the brand’s neutral gray. Pass directly to
  `scale_fill_manual(values = …)` or `scale_colour_manual(values = …)`.

- New
  [`hda_span()`](https://hdadvisors.github.io/hdatools/reference/hda_span.md)/[`hfv_span()`](https://hdadvisors.github.io/hdatools/reference/hfv_span.md)/[`pha_span()`](https://hdadvisors.github.io/hdatools/reference/pha_span.md)/[`vha_span()`](https://hdadvisors.github.io/hdatools/reference/vha_span.md)
  wrap a text string in `<span style='color:#…'>…</span>` using a named
  brand color, for use with
  [`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html)
  and
  [`ggtext::element_textbox()`](https://wilkelab.org/ggtext/reference/element_textbox.html).
  Color is resolved through the per-brand `.*_color()` accessor, so
  invalid names error with the valid list.

- New pkgdown article “CVD accessibility audit”
  (`vignettes/articles/cvd-audit.Rmd`) documents pairwise
  perceptual-distance (delta-E, CIE76) results for all four brand
  palettes under full-severity protanopia, deuteranopia, and tritanopia.
  Key findings: HDA Green vs Sea Green collapses to delta-E ≈ 6 under
  tritanopia (positions 2 and 6; use a secondary encoding if both must
  appear in a tritanopia-sensitive chart); HFV Sky vs Grass is
  borderline (~12 delta-E) under all CVD types; PHA Orange vs Red —
  flagged during design review — passes all CVD types (≥ 22). No palette
  order was changed (Q7, `plans/DECISIONS.md`, 2026-07-18). New
  `tests/testthat/test-cvd.R` adds
  [`colorspace::simulate_cvd()`](https://colorspace.R-Forge.R-project.org/reference/simulate_cvd.html)-based
  regression assertions that guard minimum pairwise delta-E for the
  first four slots of each brand palette.

- Added VHA as a fourth first-class brand:
  [`theme_vha()`](https://hdadvisors.github.io/hdatools/reference/theme_vha.md),
  [`scale_color_vha()`](https://hdadvisors.github.io/hdatools/reference/scale_color_vha.md)/
  [`scale_fill_vha()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_vha.md)
  (+
  [`scale_colour_vha()`](https://hdadvisors.github.io/hdatools/reference/scale_color_vha.md)
  alias), the full `scale_*_vha_c()`/`scale_*_vha_b()` continuous/binned
  matrix, and
  `vha_colors`/[`vha_color()`](https://hdadvisors.github.io/hdatools/reference/vha_color.md)
  — all generated from a single `.brands$vha` registry entry
  (`R/brands.R`), with no VHA-specific code in `R/scales.R`/
  `R/themes.R`. Montserrat (OFL) is bundled alongside the existing
  fonts. See the new pkgdown article “Adding a new client brand to
  hdatools” (`vignettes/articles/adding-a-brand.Rmd`) for the general
  pattern this proves out. **VHA’s diverging ramp is provisional** — it
  pairs Dark Turq against Yellow, the palette’s only warm hue, but
  Yellow’s natural HCL lightness is too high to survive as a dark,
  saturated anchor, so that arm renders golden/olive rather than bright
  yellow (an sRGB gamut limit, not a tuning slip); candidate for a
  follow-up Ramp Lab pass, same as HDA’s diverging ramp.

- [`theme_hda()`](https://hdadvisors.github.io/hdatools/reference/theme_hda.md)/[`theme_hfv()`](https://hdadvisors.github.io/hdatools/reference/theme_hfv.md)/[`theme_pha()`](https://hdadvisors.github.io/hdatools/reference/theme_pha.md)
  alone now brand a plot with no `scale_*()` call required, via ggplot2
  4.0’s theme-carried palettes: each theme sets
  `palette.colour.discrete`/`palette.fill.discrete` to the brand’s full
  discrete palette and `palette.colour.continuous`/
  `palette.fill.continuous` to the brand’s sequential ramp (the same
  ramps behind
  [`scale_color_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_c.md)
  and friends). An explicit `scale_*()` call (or a manual
  [`aes()`](https://ggplot2.tidyverse.org/reference/aes.html) value)
  always overrides these theme-carried defaults, so every existing plot
  that already sets its own scale is unaffected.

- The same three themes now set a default `geom` fill/colour (via
  [`ggplot2::element_geom()`](https://ggplot2.tidyverse.org/reference/element.html)),
  so a bare
  [`geom_bar()`](https://ggplot2.tidyverse.org/reference/geom_bar.html)/[`geom_col()`](https://ggplot2.tidyverse.org/reference/geom_bar.html)/
  [`geom_point()`](https://ggplot2.tidyverse.org/reference/geom_point.html)/[`geom_line()`](https://ggplot2.tidyverse.org/reference/geom_path.html)
  with no `fill`/`colour` mapping at all renders in the brand’s first
  palette color instead of ggplot2’s stock grey/black.

- Raised the `ggplot2` dependency floor to `>= 4.0.0` (from `>= 3.5.0`),
  the version required for the theme-carried
  palette/[`element_geom()`](https://ggplot2.tidyverse.org/reference/element.html)
  features above.

- New
  [`scale_color_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_c.md)/[`scale_colour_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_c.md)/[`scale_fill_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_hda_c.md)
  (and the matching `hfv`/`pha` versions) — a full continuous color/fill
  scale matrix (9 exports) built from six `colorspace` HCL
  sequential/diverging ramps tuned and CVD-checked
  (protanopia/deuteranopia/tritanopia) in the Ramp Lab review
  (`plans/ramp-lab/REVIEW.md`). Each takes
  `palette = c("sequential", "diverging")` to choose the ramp, plus
  `direction`, `na.value`, and `guide`. Sequential ramps default to
  higher value = darker color; diverging ramps default to the ramp’s own
  low-to-high arm order as reviewed. **HDA’s diverging ramp (Blue vs
  Coral) is provisional** — it’s a near-twin of PHA’s and is pending a
  follow-up Ramp Lab pass to differentiate it before final adoption
  (`plans/DECISIONS.md`, 2026-07-18).

- New
  [`scale_color_hda_b()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_b.md)/[`scale_colour_hda_b()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_b.md)/[`scale_fill_hda_b()`](https://hdadvisors.github.io/hdatools/reference/scale_fill_hda_b.md)
  (and the matching `hfv`/`pha` versions) — the binned counterpart of
  the above (9 exports), defaulting to `n.breaks = 7`, the class count
  every ramp was tuned and CVD-checked against.

- 7-class diverging maps built from any of the six ramps lose sign
  distinction in their innermost class pair under protanopia (structural
  to the shared cream center) — always pair a `palette = "diverging"`
  map with a legend or direct labels (documented on every new scale’s
  help page).

- `scale_color_gradient_hda()`, `scale_color_gradient_pha()`, and
  `scale_fill_gradient_pha()`’s existing soft-deprecation notices now
  name their replacement
  (e.g. [`scale_color_hda_c()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda_c.md))
  via `lifecycle`’s `use_instead`, now that one exists.

- `"Leaf"` (`#6fb547`) and `"Cerulean"` (`#7fc7e0`) join `hfv_colors`
  and `.brands$hfv$palette` as official HFV secondary colors — both HFV
  ramps are built on Leaf, and Cerulean was approved alongside it at
  Ramp Lab sign-off.

- HFV gets its first `na.value` default (`#d6dadd`), needed now that it
  has continuous scales for the first time; HDA/PHA already had their
  own (`#cfcfd0`/`#e2e4e3`).

- `colorspace` joins Imports (used only internally by the new ramp
  scales).

- New `hda_colors`, `hfv_colors`, `pha_colors` — exported named
  character vectors of each brand’s palette hex values, sourced directly
  from the internal `.brands` registry. Downstream consumers can now
  reference brand hexes by name (e.g. `hda_colors["Blue"]`) or pass the
  full vector to `scale_fill_manual(values = hda_colors)` without
  hardcoding hex strings.

- New
  [`hda_color()`](https://hdadvisors.github.io/hdatools/reference/hda_color.md),
  [`hfv_color()`](https://hdadvisors.github.io/hdatools/reference/hfv_color.md),
  [`pha_color()`](https://hdadvisors.github.io/hdatools/reference/pha_color.md)
  — per-brand accessors that return the hex for a named color and error
  with the list of valid names on an unknown input.

## hdatools 0.3.0

- New
  [`scale_colour_hda()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hda.md),
  [`scale_colour_hfv()`](https://hdadvisors.github.io/hdatools/reference/scale_color_hfv.md),
  [`scale_colour_pha()`](https://hdadvisors.github.io/hdatools/reference/scale_color_pha.md),
  `scale_colour_gradient_hda()`, and `scale_colour_gradient_pha()` —
  British- spelling aliases of the existing `scale_color_*()` exports,
  for parity with ggplot2’s own `colour`/`color` aliasing. No change to
  any existing export.

- `hda_pal_discrete()`, `hfv_pal_discrete()`, `pha_pal_discrete()`,
  `scale_color_gradient_hda()`, `scale_color_gradient_pha()`, and
  `scale_fill_gradient_pha()` are now soft-deprecated
  ([`lifecycle:: deprecate_soft()`](https://lifecycle.r-lib.org/reference/deprecate_soft.html));
  they keep working exactly as before, but calling them directly will
  surface a one-time deprecation notice. `lifecycle` moves to Imports.

- Internal-only: the three brands’ discrete palettes, gradient stops, NA
  colours, and select theme parameters (`base_size`, `html_adjust`,
  `pdf_adjust`, `lineheight`) now live in one internal registry
  (`R/brands.R`), and the 9 exported discrete/gradient scales are now
  thin wrappers over two shared internal constructors. No behavior
  change; every pre-refactor identity test asserting exact hex/parameter
  values passes unmodified.

- Internal-only:
  [`theme_hda()`](https://hdadvisors.github.io/hdatools/reference/theme_hda.md),
  [`theme_hfv()`](https://hdadvisors.github.io/hdatools/reference/theme_hfv.md),
  and
  [`theme_pha()`](https://hdadvisors.github.io/hdatools/reference/theme_pha.md)
  are now thin wrappers over one shared internal builder
  (`.brand_theme()` in `R/themes.R`), reading the font/margin/size
  parameters that differ per brand from the `R/brands.R` registry. No
  behavior change; signatures and `...` passthrough are unchanged, and
  every pre-refactor theme-identity test passes unmodified.

- pkgdown site rebuilt on Bootstrap 5 (`template: bootstrap: 5`);
  reference index now groups exports into **Themes**, **Palettes &
  scales**, **Helpers**, and **Analysis utils**. Fixed “depreciated” →
  “deprecated” wording in the `space` parameter docs for
  `scale_color_gradient_hda()`, `scale_color_gradient_pha()`, and
  `scale_fill_gradient_pha()`. No behavior change.

- Internal cleanup only, no behavior changes: enabled Roxygen markdown
  so help pages and the pkgdown site render `code`/**bold** correctly,
  corrected the
  [`get_logo()`](https://hdadvisors.github.io/hdatools/reference/get_logo.md)
  `@return` description, dropped unused namespace imports, added
  [`flip_gridlines()`](https://hdadvisors.github.io/hdatools/reference/flip_gridlines.md)/[`get_logo()`](https://hdadvisors.github.io/hdatools/reference/get_logo.md)/[`get_output_format()`](https://hdadvisors.github.io/hdatools/reference/get_output_format.md)/[`adjust_base_size()`](https://hdadvisors.github.io/hdatools/reference/adjust_base_size.md)
  to the README, removed the dead internal `add_google_fonts()` alias,
  and made the package startup message fire only when font registration
  actually succeeds.

## hdatools 0.2.0

### Breaking changes

- [`add_reliability()`](https://hdadvisors.github.io/hdatools/reference/add_reliability.md)
  gains a `cv_col` argument. Supplying it switches to a new
  classification path: tidy-eval column selection, a `scale` argument
  (`"percent"`, the default, or `"proportion"`), and `<=` boundaries (a
  CV of exactly 15 percent is now “High”). Omitting `cv_col` keeps the
  original behavior byte-for-byte: auto-detect a single column ending in
  `_cv`, treat it as a 0-1 proportion, and use strict `<` boundaries.
- [`flip_gridlines()`](https://hdadvisors.github.io/hdatools/reference/flip_gridlines.md)’s
  `size` argument is deprecated in favor of `linewidth`, matching
  ggplot2’s own `size` → `linewidth` rename.
- `ggiraph` moves from Imports to Suggests.
  [`publish_plot()`](https://hdadvisors.github.io/hdatools/reference/publish_plot.md)
  now errors with an install hint if ggiraph isn’t installed, instead of
  failing to load the package at all.

### New features

- Fonts are bundled and registered offline. `inst/fonts/` ships the
  exact static TTF faces
  [`theme_hda()`](https://hdadvisors.github.io/hdatools/reference/theme_hda.md),
  [`theme_hfv()`](https://hdadvisors.github.io/hdatools/reference/theme_hfv.md),
  and
  [`theme_pha()`](https://hdadvisors.github.io/hdatools/reference/theme_pha.md)
  use (Lato, Roboto Slab, Open Sans, Poppins, Noto Sans), registered by
  the new exported
  [`register_hda_fonts()`](https://hdadvisors.github.io/hdatools/reference/register_hda_fonts.md)
  — no more per-session network download from Google Fonts, and no more
  silent failure when a render happens offline. Opt out with
  `options(hdatools.fonts = FALSE)` or the `HDATOOLS_NO_FONTS`
  environment variable. See `inst/fonts/LICENSES.md` for the OFL and
  Apache 2.0 texts covering each face.
- [`theme_pha()`](https://hdadvisors.github.io/hdatools/reference/theme_pha.md)
  reaches parity with
  [`theme_hda()`](https://hdadvisors.github.io/hdatools/reference/theme_hda.md)/[`theme_hfv()`](https://hdadvisors.github.io/hdatools/reference/theme_hfv.md):
  new `output_format`, `html_adjust`/`pdf_adjust`, and `...` passthrough
  arguments, and a `strip.text` element so
  [`markdown_wrap_gen()`](https://hdadvisors.github.io/hdatools/reference/markdown_wrap_gen.md)
  facet labels render correctly. `html_adjust`/`pdf_adjust` default to
  0/0, so existing
  [`theme_pha()`](https://hdadvisors.github.io/hdatools/reference/theme_pha.md)
  output is unchanged.
  [`theme_hda()`](https://hdadvisors.github.io/hdatools/reference/theme_hda.md)/[`theme_hfv()`](https://hdadvisors.github.io/hdatools/reference/theme_hfv.md)
  also gain explicit `html_adjust`/`pdf_adjust` parameters (defaults
  match prior hardcoded behavior).
- [`get_logo()`](https://hdadvisors.github.io/hdatools/reference/get_logo.md)
  now resolves its image path from the installed package
  ([`system.file()`](https://rdrr.io/r/base/system.file.html)) instead
  of a hardcoded relative path, so it works correctly once the package
  is installed rather than only from source.

### Modernization for ggplot2 4.0

- Dropped the deprecated positional `scale_name` argument from all
  discrete and gradient scales.
- Renamed every deprecated `size=` to `linewidth=` in the themes and in
  [`add_zero_line()`](https://hdadvisors.github.io/hdatools/reference/add_zero_line.md).
- Raised the `ggplot2` floor to \>= 3.5.0 (required for the `scale_name`
  deprecation shape) and added floors to all other Imports, chosen below
  every known consumer’s lockfile.

### Documentation & housekeeping

- Fixed a broken
  [`add_reliability()`](https://hdadvisors.github.io/hdatools/reference/add_reliability.md)
  README example (it passed 10 values into an 8-row data frame and
  relied on `_cv` auto-detection against a column literally named `cv`).
- Documented that `strip.text` overrides on any theme must use
  [`ggtext::element_markdown()`](https://wilkelab.org/ggtext/reference/element_markdown.html),
  not a raw
  [`ggplot2::element_text()`](https://ggplot2.tidyverse.org/reference/element.html)
  — ggplot2 4.0 only merges theme elements of the same class.
- Slimmed the namespace: replaced blanket `@import` package imports with
  qualified `pkg::` calls throughout, keeping only `%+replace%` and
  rlang’s tidy-eval helpers as bare imports.
- Fixed the `Authors@R` given/family name order for all three authors.
  Jonathan Knopf is now the maintainer; Kyle Walker moves to `aut`.
- Added `URL`/`BugReports`, dropped `Date`/`LazyData`, and removed the
  legacy `Author:` field.
- Removed the dead `data-raw/DATASET.R` stub and moved
  `vignettes/branded-themes.Rmd` to `vignettes/articles/` (pkgdown
  builds it as a long-form article; it was never wired up as a real
  package vignette).

## hdatools 0.1.7

- See git history.

## hdatools 0.1.6

- See git history.

## hdatools 0.1.5

- See git history.

## hdatools 0.1.4

- See git history.

## hdatools 0.1.3

- See git history.

## hdatools 0.1.2

- See git history.

## hdatools 0.1.1

- See git history.

## hdatools 0.1.0

- Merges updates in `jtk` branch to original build-out in `main`.
- Adds new color scale functions, including `scale_color_gradient_*`.
- Adds new color palette (`pha_pal_discrete()`) for the Partnership for
  Housing Affordability (PHA).
- Theme helper functions now load more Google Font options and include
  [`flip_gridlines()`](https://hdadvisors.github.io/hdatools/reference/flip_gridlines.md)
  shortcut.
- `hda_pal_discrete()` now includes `repeat_pal` option to loop colors
  for data with more than six variables.
