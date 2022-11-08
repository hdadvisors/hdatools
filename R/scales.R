#' Generate a discrete HDA color palette
#'
#' @param direction If -1, reverse the palette; defaults to 1
#'
#' @return n colors (generally passed to ggplot2)
#' @export
hda_pal_discrete <- function(direction = 1) {

  pal <- c(
    "#445ca9", # Blue
    "#8baeaa", # Green
    "#e9ab3f", # Yellow
    "#e76f52"  # Coral
  )

  function(n) {

    pal_n <- pal[1:n]

    if (direction == -1) {
      return(rev(pal_n))
    } else {
      return(pal_n)
    }

  }

}

#' HDA-branded discrete color scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @import ggplot2
#' @export
scale_color_hda <- function(direction = 1, ...) {
  ggplot2::discrete_scale(
    "colour", "hda", palette = hda_pal_discrete(direction = direction),
    ...
  )
}

#' HDA-branded discrete fill scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @import ggplot2
#' @export
scale_fill_hda <- function(direction = 1, ...) {
  ggplot2::discrete_scale(
    "fill", "hda", palette = hda_pal_discrete(direction),
    ...
  )
}

#' HDA-branded 4-color continuous color scale
#'
#' @param colors Vector of colors
#' @param values If colors should not be evenly positioned along the gradient, this vector gives the position (between 0 and 1) for each color in the vector
#' @param space Color space in which to calculate gradient. Must be "Lab" - other values depreciated
#' @param na.value Default color for NA values (#cfcfd0, HDA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to continuous_scale()
#' @import ggplot2, scales
#' @export
scale_color_gradient_hda <- function(...,
                                     colors = c("#445ca9","#8baeaa","#e9ab3f","#e76f52"),
                                     values = NULL,
                                     space = "Lab",
                                     na.value = "cfcfd0",
                                     guide = "colorbar") {
  ggplot2::continuous_scale(
    aesthetics = "color",
    scale_name = "hda",
    palette = scales::gradient_n_pal(colors, values, space),
    na.value = na.value,
    guide = guide,
    ...
  )
}
