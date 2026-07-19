# Internal palette factory shared by the three *_pal_discrete() exports.
# Reproduces the exact direction/repeat_pal closure each hand-written
# version used, reading its raw hex vector from .brands.
.brand_pal_discrete <- function(pal) {
  function(direction = 1, repeat_pal = FALSE) {

    function(n) {

      if (repeat_pal) {
        if (n > length(pal)) {
          times <- ceiling(n / length(pal))
          pal <- rep(pal, times)
        }
      }

      pal_n <- pal[1:n]

      if (direction == -1) {
        return(rev(pal_n))
      } else {
        return(pal_n)
      }

    }

  }
}

# Internal discrete scale constructor shared by the 6 scale_color_*()/
# scale_fill_*() exports.
.scale_brand_discrete <- function(aesthetics, brand, direction = 1, repeat_pal = FALSE, ...) {
  ggplot2::discrete_scale(
    aesthetics = aesthetics,
    palette = .brand_pal_discrete(unname(.brands[[brand]]$palette))(
      direction = direction, repeat_pal = repeat_pal
    ),
    ...
  )
}

# Internal gradient scale constructor shared by the 3 scale_*_gradient_*()
# exports.
.scale_brand_gradient <- function(aesthetics, colors, values, space, na.value, guide, ...) {
  ggplot2::continuous_scale(
    aesthetics = aesthetics,
    palette = scales::gradient_n_pal(colors, values, space),
    na.value = na.value,
    guide = guide,
    ...
  )
}

# Reverses a ramp's raw colorspace order (dark -> light for sequential;
# arm1 -> cream -> arm2 for diverging) into the order scales::gradient_n_pal()
# should map low -> high value onto, then applies direction on top. Sequential
# ramps get rev()'d by default so higher value = darker color (colorspace's
# own order would otherwise map higher value = lighter); diverging ramps are
# already in the right low -> high order as constructed (arm1 = one extreme,
# cream = center, arm2 = other extreme), so direction is the only flip.
.ramp_hex_for_scale <- function(brand, palette, direction, n) {
  hex <- .ramp_hex(brand, palette, n)
  if (palette == "sequential") hex <- rev(hex)
  if (direction == -1) hex <- rev(hex)
  hex
}

# Internal continuous scale constructor shared by the 9 scale_*_<brand>_c()
# exports.
.scale_brand_continuous <- function(aesthetics, brand, palette, direction, na.value, guide, ...) {
  ggplot2::continuous_scale(
    aesthetics = aesthetics,
    palette = scales::gradient_n_pal(.ramp_hex_for_scale(brand, palette, direction, .RAMP_N_DENSE)),
    na.value = na.value,
    guide = guide,
    ...
  )
}

# Internal binned scale constructor shared by the 9 scale_*_<brand>_b()
# exports.
.scale_brand_binned <- function(aesthetics, brand, palette, direction, na.value, guide, n.breaks, ...) {
  ggplot2::binned_scale(
    aesthetics = aesthetics,
    palette = scales::gradient_n_pal(.ramp_hex_for_scale(brand, palette, direction, .RAMP_N_DENSE)),
    na.value = na.value,
    guide = guide,
    n.breaks = n.breaks,
    ...
  )
}

#' Generate a discrete HDA color palette
#'
#' `r lifecycle::badge("deprecated")` Use `scale_color_hda()`/`scale_fill_hda()`
#' directly instead of calling this palette generator.
#'
#' @param direction If -1, reverse the palette; defaults to 1
#' @param repeat_pal If TRUE, repeat the palette enough times to account for all discrete values
#'
#' @return n colors (generally passed to ggplot2)
#' @export
hda_pal_discrete <- function(direction = 1, repeat_pal = FALSE) {
  lifecycle::deprecate_soft("0.3.0", "hda_pal_discrete()")
  .brand_pal_discrete(unname(.brands$hda$palette))(direction = direction, repeat_pal = repeat_pal)
}

#' Generate a discrete HFV color palette
#'
#' `r lifecycle::badge("deprecated")` Use `scale_color_hfv()`/`scale_fill_hfv()`
#' directly instead of calling this palette generator.
#'
#' @param direction If -1, reverse the palette; defaults to 1
#' @param repeat_pal If TRUE, repeat the palette enough times to account for all discrete values
#'
#' @return n colors (generally passed to ggplot2)
#' @export
hfv_pal_discrete <- function(direction = 1, repeat_pal = FALSE) {
  lifecycle::deprecate_soft("0.3.0", "hfv_pal_discrete()")
  .brand_pal_discrete(unname(.brands$hfv$palette))(direction = direction, repeat_pal = repeat_pal)
}

#' Generate a discrete PHA color palette
#'
#' `r lifecycle::badge("deprecated")` Use `scale_color_pha()`/`scale_fill_pha()`
#' directly instead of calling this palette generator.
#'
#' @param direction If -1, reverse the palette; defaults to 1
#' @param repeat_pal If TRUE, repeat the palette enough times to account for all discrete values
#'
#' @return n colors (generally passed to ggplot2)
#' @export
pha_pal_discrete <- function(direction = 1, repeat_pal = FALSE) {
  lifecycle::deprecate_soft("0.3.0", "pha_pal_discrete()")
  .brand_pal_discrete(unname(.brands$pha$palette))(direction = direction, repeat_pal = repeat_pal)
}

#' HDA-branded discrete color scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @param repeat_pal If TRUE, repeat the palette enough times to account for all discrete values
#' @param ... Additional arguments passed to ggplot2::discrete_scale()
#' @export
scale_color_hda <- function(direction = 1, repeat_pal = FALSE, ...) {
  .scale_brand_discrete("colour", "hda", direction, repeat_pal, ...)
}

#' @rdname scale_color_hda
#' @export
scale_colour_hda <- scale_color_hda

#' HFV-branded discrete color scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @param repeat_pal If TRUE, repeat the palette enough times to account for all discrete values
#' @param ... Additional arguments passed to ggplot2::discrete_scale()
#' @export
scale_color_hfv <- function(direction = 1, repeat_pal = FALSE, ...) {
  .scale_brand_discrete("colour", "hfv", direction, repeat_pal, ...)
}

#' @rdname scale_color_hfv
#' @export
scale_colour_hfv <- scale_color_hfv

#' PHA-branded discrete color scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @param repeat_pal If TRUE, repeat the palette enough times to account for all discrete values
#' @param ... Additional arguments passed to ggplot2::discrete_scale()
#' @export
scale_color_pha <- function(direction = 1, repeat_pal = FALSE, ...) {
  .scale_brand_discrete("colour", "pha", direction, repeat_pal, ...)
}

#' @rdname scale_color_pha
#' @export
scale_colour_pha <- scale_color_pha

#' HDA-branded discrete fill scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @param repeat_pal If TRUE, repeat the palette enough times to account for all discrete values
#' @param ... Additional arguments passed to ggplot2::discrete_scale()
#' @export
scale_fill_hda <- function(direction = 1, repeat_pal = FALSE, ...) {
  .scale_brand_discrete("fill", "hda", direction, repeat_pal, ...)
}

#' HFV-branded discrete fill scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @param repeat_pal If TRUE, repeat the palette enough times to account for all discrete values
#' @param ... Additional arguments passed to ggplot2::discrete_scale()
#' @export
scale_fill_hfv <- function(direction = 1, repeat_pal = FALSE, ...) {
  .scale_brand_discrete("fill", "hfv", direction, repeat_pal, ...)
}

#' PHA-branded discrete fill scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @param repeat_pal If TRUE, repeat the palette enough times to account for all discrete values
#' @param ... Additional arguments passed to ggplot2::discrete_scale()
#' @export
scale_fill_pha <- function(direction = 1, repeat_pal = FALSE, ...) {
  .scale_brand_discrete("fill", "pha", direction, repeat_pal, ...)
}

#' HDA-branded 4-color continuous color scale
#'
#' `r lifecycle::badge("deprecated")`
#'
#' @param colors Vector of colors
#' @param values If colors should not be evenly positioned along the gradient, this vector gives the position (between 0 and 1) for each color in the vector
#' @param space Color space in which to calculate gradient. Must be "Lab" - other values deprecated
#' @param na.value Default color for NA values (#cfcfd0, HDA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to continuous_scale()
#' @export
scale_color_gradient_hda <- function(...,
                                     colors = .brands$hda$gradient,
                                     values = NULL,
                                     space = "Lab",
                                     na.value = .brands$hda$na_color,
                                     guide = "colorbar") {
  lifecycle::deprecate_soft("0.3.0", "scale_color_gradient_hda()", "scale_color_hda_c()")
  .scale_brand_gradient("color", colors, values, space, na.value, guide, ...)
}

#' @rdname scale_color_gradient_hda
#' @export
scale_colour_gradient_hda <- scale_color_gradient_hda

#' PHA-branded 4-color continuous color scale
#'
#' `r lifecycle::badge("deprecated")`
#'
#' @param colors Vector of colors
#' @param values If colors should not be evenly positioned along the gradient, this vector gives the position (between 0 and 1) for each color in the vector
#' @param space Color space in which to calculate gradient. Must be "Lab" - other values deprecated
#' @param na.value Default color for NA values (#e2e4e3, PHA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to continuous_scale()
#' @export
scale_color_gradient_pha <- function(...,
                                     colors = .brands$pha$gradient,
                                     values = NULL,
                                     space = "Lab",
                                     na.value = .brands$pha$na_color,
                                     guide = "colorbar") {
  lifecycle::deprecate_soft("0.3.0", "scale_color_gradient_pha()", "scale_color_pha_c()")
  .scale_brand_gradient("color", colors, values, space, na.value, guide, ...)
}

#' @rdname scale_color_gradient_pha
#' @export
scale_colour_gradient_pha <- scale_color_gradient_pha

#' PHA-branded 4-color continuous fill scale
#'
#' `r lifecycle::badge("deprecated")`
#'
#' @param colors Vector of colors
#' @param values If colors should not be evenly positioned along the gradient, this vector gives the position (between 0 and 1) for each color in the vector
#' @param space Color space in which to calculate gradient. Must be "Lab" - other values deprecated
#' @param na.value Default color for NA values (#e2e4e3, PHA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to continuous_scale()
#' @export
scale_fill_gradient_pha <- function(...,
                                     colors = .brands$pha$gradient,
                                     values = NULL,
                                     space = "Lab",
                                     na.value = .brands$pha$na_color,
                                     guide = "colorbar") {
  lifecycle::deprecate_soft("0.3.0", "scale_fill_gradient_pha()", "scale_fill_pha_c()")
  .scale_brand_gradient("fill", colors, values, space, na.value, guide, ...)
}

# ---- Continuous/binned ramp scales (item 2.2) -----------------------------
#
# Six colorspace HCL ramps (one sequential + one diverging per brand), tuned
# and CVD-checked in plans/ramp-lab/REVIEW.md, exposed as a full
# continuous (_c)/binned (_b) x color/fill matrix. Every export below is a
# thin wrapper over .scale_brand_continuous()/.scale_brand_binned() — brand
# differences live entirely in the .brands registry (R/brands.R), not in
# per-brand code.

#' HDA-branded continuous color scale
#'
#' A sequential or diverging `colorspace` HCL ramp, tuned and CVD-checked
#' against protanopia, deuteranopia, and tritanopia in the Ramp Lab review
#' (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @section HDA diverging is provisional: `r lifecycle::badge("experimental")`
#'   HDA's diverging ramp (Blue vs Coral) is a near-twin of PHA's (Dark Blue
#'   vs Red) and is pending a follow-up Ramp Lab pass to differentiate it
#'   before final adoption (see `plans/DECISIONS.md`, 2026-07-18). It ships
#'   now so the scale matrix is complete; treat it as subject to change.
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#cfcfd0, HDA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to `ggplot2::continuous_scale()`
#' @export
scale_color_hda_c <- function(palette = c("sequential", "diverging"),
                               direction = 1,
                               na.value = .brands$hda$na_color,
                               guide = "colorbar",
                               ...) {
  palette <- match.arg(palette)
  .scale_brand_continuous("colour", "hda", palette, direction, na.value, guide, ...)
}

#' @rdname scale_color_hda_c
#' @export
scale_colour_hda_c <- scale_color_hda_c

#' HDA-branded continuous fill scale
#'
#' A sequential or diverging `colorspace` HCL ramp, tuned and CVD-checked
#' against protanopia, deuteranopia, and tritanopia in the Ramp Lab review
#' (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @section HDA diverging is provisional: `r lifecycle::badge("experimental")`
#'   HDA's diverging ramp (Blue vs Coral) is a near-twin of PHA's (Dark Blue
#'   vs Red) and is pending a follow-up Ramp Lab pass to differentiate it
#'   before final adoption (see `plans/DECISIONS.md`, 2026-07-18). It ships
#'   now so the scale matrix is complete; treat it as subject to change.
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#cfcfd0, HDA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to `ggplot2::continuous_scale()`
#' @export
scale_fill_hda_c <- function(palette = c("sequential", "diverging"),
                              direction = 1,
                              na.value = .brands$hda$na_color,
                              guide = "colorbar",
                              ...) {
  palette <- match.arg(palette)
  .scale_brand_continuous("fill", "hda", palette, direction, na.value, guide, ...)
}

#' HDA-branded binned color scale
#'
#' The same sequential/diverging `colorspace` HCL ramps as
#' [scale_color_hda_c()], discretized into classes. Defaults to 7 classes,
#' the count every ramp was tuned and CVD-checked against in the Ramp Lab
#' review (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @section HDA diverging is provisional: `r lifecycle::badge("experimental")`
#'   HDA's diverging ramp (Blue vs Coral) is a near-twin of PHA's (Dark Blue
#'   vs Red) and is pending a follow-up Ramp Lab pass to differentiate it
#'   before final adoption (see `plans/DECISIONS.md`, 2026-07-18). It ships
#'   now so the scale matrix is complete; treat it as subject to change.
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#cfcfd0, HDA Light Gray)
#' @param guide Legend representation for scale
#' @param n.breaks Number of classes; defaults to 7 (see above)
#' @param ... Other arguments passed on to `ggplot2::binned_scale()`
#' @export
scale_color_hda_b <- function(palette = c("sequential", "diverging"),
                               direction = 1,
                               na.value = .brands$hda$na_color,
                               guide = "coloursteps",
                               n.breaks = 7,
                               ...) {
  palette <- match.arg(palette)
  .scale_brand_binned("colour", "hda", palette, direction, na.value, guide, n.breaks, ...)
}

#' @rdname scale_color_hda_b
#' @export
scale_colour_hda_b <- scale_color_hda_b

#' HDA-branded binned fill scale
#'
#' The same sequential/diverging `colorspace` HCL ramps as
#' [scale_fill_hda_c()], discretized into classes. Defaults to 7 classes,
#' the count every ramp was tuned and CVD-checked against in the Ramp Lab
#' review (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @section HDA diverging is provisional: `r lifecycle::badge("experimental")`
#'   HDA's diverging ramp (Blue vs Coral) is a near-twin of PHA's (Dark Blue
#'   vs Red) and is pending a follow-up Ramp Lab pass to differentiate it
#'   before final adoption (see `plans/DECISIONS.md`, 2026-07-18). It ships
#'   now so the scale matrix is complete; treat it as subject to change.
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#cfcfd0, HDA Light Gray)
#' @param guide Legend representation for scale
#' @param n.breaks Number of classes; defaults to 7 (see above)
#' @param ... Other arguments passed on to `ggplot2::binned_scale()`
#' @export
scale_fill_hda_b <- function(palette = c("sequential", "diverging"),
                              direction = 1,
                              na.value = .brands$hda$na_color,
                              guide = "coloursteps",
                              n.breaks = 7,
                              ...) {
  palette <- match.arg(palette)
  .scale_brand_binned("fill", "hda", palette, direction, na.value, guide, n.breaks, ...)
}

#' HFV-branded continuous color scale
#'
#' A sequential or diverging `colorspace` HCL ramp, tuned and CVD-checked
#' against protanopia, deuteranopia, and tritanopia in the Ramp Lab review
#' (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#d6dadd, HFV Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to `ggplot2::continuous_scale()`
#' @export
scale_color_hfv_c <- function(palette = c("sequential", "diverging"),
                               direction = 1,
                               na.value = .brands$hfv$na_color,
                               guide = "colorbar",
                               ...) {
  palette <- match.arg(palette)
  .scale_brand_continuous("colour", "hfv", palette, direction, na.value, guide, ...)
}

#' @rdname scale_color_hfv_c
#' @export
scale_colour_hfv_c <- scale_color_hfv_c

#' HFV-branded continuous fill scale
#'
#' A sequential or diverging `colorspace` HCL ramp, tuned and CVD-checked
#' against protanopia, deuteranopia, and tritanopia in the Ramp Lab review
#' (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#d6dadd, HFV Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to `ggplot2::continuous_scale()`
#' @export
scale_fill_hfv_c <- function(palette = c("sequential", "diverging"),
                              direction = 1,
                              na.value = .brands$hfv$na_color,
                              guide = "colorbar",
                              ...) {
  palette <- match.arg(palette)
  .scale_brand_continuous("fill", "hfv", palette, direction, na.value, guide, ...)
}

#' HFV-branded binned color scale
#'
#' The same sequential/diverging `colorspace` HCL ramps as
#' [scale_color_hfv_c()], discretized into classes. Defaults to 7 classes,
#' the count every ramp was tuned and CVD-checked against in the Ramp Lab
#' review (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#d6dadd, HFV Light Gray)
#' @param guide Legend representation for scale
#' @param n.breaks Number of classes; defaults to 7 (see above)
#' @param ... Other arguments passed on to `ggplot2::binned_scale()`
#' @export
scale_color_hfv_b <- function(palette = c("sequential", "diverging"),
                               direction = 1,
                               na.value = .brands$hfv$na_color,
                               guide = "coloursteps",
                               n.breaks = 7,
                               ...) {
  palette <- match.arg(palette)
  .scale_brand_binned("colour", "hfv", palette, direction, na.value, guide, n.breaks, ...)
}

#' @rdname scale_color_hfv_b
#' @export
scale_colour_hfv_b <- scale_color_hfv_b

#' HFV-branded binned fill scale
#'
#' The same sequential/diverging `colorspace` HCL ramps as
#' [scale_fill_hfv_c()], discretized into classes. Defaults to 7 classes,
#' the count every ramp was tuned and CVD-checked against in the Ramp Lab
#' review (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#d6dadd, HFV Light Gray)
#' @param guide Legend representation for scale
#' @param n.breaks Number of classes; defaults to 7 (see above)
#' @param ... Other arguments passed on to `ggplot2::binned_scale()`
#' @export
scale_fill_hfv_b <- function(palette = c("sequential", "diverging"),
                              direction = 1,
                              na.value = .brands$hfv$na_color,
                              guide = "coloursteps",
                              n.breaks = 7,
                              ...) {
  palette <- match.arg(palette)
  .scale_brand_binned("fill", "hfv", palette, direction, na.value, guide, n.breaks, ...)
}

#' PHA-branded continuous color scale
#'
#' A sequential or diverging `colorspace` HCL ramp, tuned and CVD-checked
#' against protanopia, deuteranopia, and tritanopia in the Ramp Lab review
#' (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#e2e4e3, PHA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to `ggplot2::continuous_scale()`
#' @export
scale_color_pha_c <- function(palette = c("sequential", "diverging"),
                               direction = 1,
                               na.value = .brands$pha$na_color,
                               guide = "colorbar",
                               ...) {
  palette <- match.arg(palette)
  .scale_brand_continuous("colour", "pha", palette, direction, na.value, guide, ...)
}

#' @rdname scale_color_pha_c
#' @export
scale_colour_pha_c <- scale_color_pha_c

#' PHA-branded continuous fill scale
#'
#' A sequential or diverging `colorspace` HCL ramp, tuned and CVD-checked
#' against protanopia, deuteranopia, and tritanopia in the Ramp Lab review
#' (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#e2e4e3, PHA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to `ggplot2::continuous_scale()`
#' @export
scale_fill_pha_c <- function(palette = c("sequential", "diverging"),
                              direction = 1,
                              na.value = .brands$pha$na_color,
                              guide = "colorbar",
                              ...) {
  palette <- match.arg(palette)
  .scale_brand_continuous("fill", "pha", palette, direction, na.value, guide, ...)
}

#' PHA-branded binned color scale
#'
#' The same sequential/diverging `colorspace` HCL ramps as
#' [scale_color_pha_c()], discretized into classes. Defaults to 7 classes,
#' the count every ramp was tuned and CVD-checked against in the Ramp Lab
#' review (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#e2e4e3, PHA Light Gray)
#' @param guide Legend representation for scale
#' @param n.breaks Number of classes; defaults to 7 (see above)
#' @param ... Other arguments passed on to `ggplot2::binned_scale()`
#' @export
scale_color_pha_b <- function(palette = c("sequential", "diverging"),
                               direction = 1,
                               na.value = .brands$pha$na_color,
                               guide = "coloursteps",
                               n.breaks = 7,
                               ...) {
  palette <- match.arg(palette)
  .scale_brand_binned("colour", "pha", palette, direction, na.value, guide, n.breaks, ...)
}

#' @rdname scale_color_pha_b
#' @export
scale_colour_pha_b <- scale_color_pha_b

#' PHA-branded binned fill scale
#'
#' The same sequential/diverging `colorspace` HCL ramps as
#' [scale_fill_pha_c()], discretized into classes. Defaults to 7 classes,
#' the count every ramp was tuned and CVD-checked against in the Ramp Lab
#' review (`plans/ramp-lab/REVIEW.md`).
#'
#' @section Diverging palette usage: 7-class diverging maps built from these
#'   ramps lose sign distinction in their innermost class pair under
#'   protanopia (structural to the shared cream center) — always pair a
#'   `palette = "diverging"` map with a legend or direct labels. See
#'   `plans/DECISIONS.md` (2026-07-18).
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second, as constructed in the Ramp Lab
#'   review; `-1` swaps which arm represents low vs. high.
#' @param na.value Default color for NA values (#e2e4e3, PHA Light Gray)
#' @param guide Legend representation for scale
#' @param n.breaks Number of classes; defaults to 7 (see above)
#' @param ... Other arguments passed on to `ggplot2::binned_scale()`
#' @export
scale_fill_pha_b <- function(palette = c("sequential", "diverging"),
                              direction = 1,
                              na.value = .brands$pha$na_color,
                              guide = "coloursteps",
                              n.breaks = 7,
                              ...) {
  palette <- match.arg(palette)
  .scale_brand_binned("fill", "pha", palette, direction, na.value, guide, n.breaks, ...)
}
