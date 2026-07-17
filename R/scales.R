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
  lifecycle::deprecate_soft("0.3.0", "scale_color_gradient_hda()")
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
  lifecycle::deprecate_soft("0.3.0", "scale_color_gradient_pha()")
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
  lifecycle::deprecate_soft("0.3.0", "scale_fill_gradient_pha()")
  .scale_brand_gradient("fill", colors, values, space, na.value, guide, ...)
}
