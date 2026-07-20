# Internal palette factory used by .scale_brand_discrete; wraps a raw hex
# vector with direction/repeat_pal logic.
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

#' VHA-branded discrete color scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @param repeat_pal If TRUE, repeat the palette enough times to account for all discrete values
#' @param ... Additional arguments passed to ggplot2::discrete_scale()
#' @export
scale_color_vha <- function(direction = 1, repeat_pal = FALSE, ...) {
  .scale_brand_discrete("colour", "vha", direction, repeat_pal, ...)
}

#' @rdname scale_color_vha
#' @export
scale_colour_vha <- scale_color_vha

#' VHA-branded discrete fill scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @param repeat_pal If TRUE, repeat the palette enough times to account for all discrete values
#' @param ... Additional arguments passed to ggplot2::discrete_scale()
#' @export
scale_fill_vha <- function(direction = 1, repeat_pal = FALSE, ...) {
  .scale_brand_discrete("fill", "vha", direction, repeat_pal, ...)
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

#' VHA-branded continuous color scale
#'
#' A sequential or diverging `colorspace` HCL ramp.
#'
#' @section Diverging ramp is provisional: `r lifecycle::badge("experimental")`
#'   VHA's diverging ramp pairs Dark Turq against Yellow, the palette's only
#'   warm hue. Yellow's natural HCL lightness is too high to survive as a
#'   dark, saturated anchor, so that arm renders golden/olive rather than
#'   bright yellow — a sRGB gamut limit, not a tuning slip. Still monotonic
#'   and distinguishable under protanopia/deuteranopia/tritanopia simulation,
#'   but — like HDA's diverging ramp — a candidate for a follow-up Ramp Lab
#'   pass (`plans/DECISIONS.md`).
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second; `-1` swaps which arm represents
#'   low vs. high.
#' @param na.value Default color for NA values (#d6dbdb, VHA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to `ggplot2::continuous_scale()`
#' @export
scale_color_vha_c <- function(palette = c("sequential", "diverging"),
                               direction = 1,
                               na.value = .brands$vha$na_color,
                               guide = "colorbar",
                               ...) {
  palette <- match.arg(palette)
  .scale_brand_continuous("colour", "vha", palette, direction, na.value, guide, ...)
}

#' @rdname scale_color_vha_c
#' @export
scale_colour_vha_c <- scale_color_vha_c

#' VHA-branded continuous fill scale
#'
#' A sequential or diverging `colorspace` HCL ramp.
#'
#' @section Diverging ramp is provisional: `r lifecycle::badge("experimental")`
#'   VHA's diverging ramp pairs Dark Turq against Yellow, the palette's only
#'   warm hue. Yellow's natural HCL lightness is too high to survive as a
#'   dark, saturated anchor, so that arm renders golden/olive rather than
#'   bright yellow — a sRGB gamut limit, not a tuning slip. Still monotonic
#'   and distinguishable under protanopia/deuteranopia/tritanopia simulation,
#'   but — like HDA's diverging ramp — a candidate for a follow-up Ramp Lab
#'   pass (`plans/DECISIONS.md`).
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second; `-1` swaps which arm represents
#'   low vs. high.
#' @param na.value Default color for NA values (#d6dbdb, VHA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to `ggplot2::continuous_scale()`
#' @export
scale_fill_vha_c <- function(palette = c("sequential", "diverging"),
                              direction = 1,
                              na.value = .brands$vha$na_color,
                              guide = "colorbar",
                              ...) {
  palette <- match.arg(palette)
  .scale_brand_continuous("fill", "vha", palette, direction, na.value, guide, ...)
}

#' VHA-branded binned color scale
#'
#' The same sequential/diverging `colorspace` HCL ramps as
#' [scale_color_vha_c()], discretized into classes. Defaults to 7 classes.
#'
#' @section Diverging ramp is provisional: `r lifecycle::badge("experimental")`
#'   See [scale_color_vha_c()] for the Yellow-arm gamut caveat.
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second; `-1` swaps which arm represents
#'   low vs. high.
#' @param na.value Default color for NA values (#d6dbdb, VHA Light Gray)
#' @param guide Legend representation for scale
#' @param n.breaks Number of classes; defaults to 7
#' @param ... Other arguments passed on to `ggplot2::binned_scale()`
#' @export
scale_color_vha_b <- function(palette = c("sequential", "diverging"),
                               direction = 1,
                               na.value = .brands$vha$na_color,
                               guide = "coloursteps",
                               n.breaks = 7,
                               ...) {
  palette <- match.arg(palette)
  .scale_brand_binned("colour", "vha", palette, direction, na.value, guide, n.breaks, ...)
}

#' @rdname scale_color_vha_b
#' @export
scale_colour_vha_b <- scale_color_vha_b

#' VHA-branded binned fill scale
#'
#' The same sequential/diverging `colorspace` HCL ramps as
#' [scale_fill_vha_c()], discretized into classes. Defaults to 7 classes.
#'
#' @section Diverging ramp is provisional: `r lifecycle::badge("experimental")`
#'   See [scale_color_vha_c()] for the Yellow-arm gamut caveat.
#'
#' @param palette One of `"sequential"` (default) or `"diverging"`
#' @param direction For `palette = "sequential"`, `1` (default) maps higher
#'   values to darker colors; `-1` reverses so higher values are lighter. For
#'   `palette = "diverging"`, `1` (default) maps low values toward the first
#'   arm and high values toward the second; `-1` swaps which arm represents
#'   low vs. high.
#' @param na.value Default color for NA values (#d6dbdb, VHA Light Gray)
#' @param guide Legend representation for scale
#' @param n.breaks Number of classes; defaults to 7
#' @param ... Other arguments passed on to `ggplot2::binned_scale()`
#' @export
scale_fill_vha_b <- function(palette = c("sequential", "diverging"),
                              direction = 1,
                              na.value = .brands$vha$na_color,
                              guide = "coloursteps",
                              n.breaks = 7,
                              ...) {
  palette <- match.arg(palette)
  .scale_brand_binned("fill", "vha", palette, direction, na.value, guide, n.breaks, ...)
}
