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
    "#e76f52", # Coral
    "#a97a92", # Lavender
    "#8abc8e"  # Sea Green
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

#' Generate a discrete HFV color palette
#'
#' @param direction If -1, reverse the palette; defaults to 1
#'
#' @return n colors (generally passed to ggplot2)
#' @export
hfv_pal_discrete <- function(direction = 1) {

  pal <- c(
    "#334a66", # Shadow
    "#66cccc", # Sky
    "#a29dd4", # Lilac
    "#50aaa7", # Grass
    "#c0327e", # Berry
    "#ec7c53"  # Desert
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

#' Generate a discrete PHA color palette
#'
#' @param direction If -1, reverse the palette; defaults to 1
#'
#' @return n colors (generally passed to ggplot2)
#' @export
pha_pal_discrete <- function(direction = 1) {

  pal <- c(
    "#5bab8e", # Green
    "#a6cccc", # Light Blue
    "#f39152", # Orange
    "#be451c", # Red
    "#a5add0", # Purple
    "#2b6b9c"  # Dark Blue
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

#' HFV-branded discrete color scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @import ggplot2
#' @export
scale_color_hfv <- function(direction = 1, ...) {
  ggplot2::discrete_scale(
    "colour", "hfv", palette = hfv_pal_discrete(direction = direction),
    ...
  )
}

#' PHA-branded discrete color scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @import ggplot2
#' @export
scale_color_pha <- function(direction = 1, ...) {
  ggplot2::discrete_scale(
    "colour", "pha", palette = pha_pal_discrete(direction = direction),
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

#' HFV-branded discrete fill scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @import ggplot2
#' @export
scale_fill_hfv <- function(direction = 1, ...) {
  ggplot2::discrete_scale(
    "fill", "hfv", palette = hfv_pal_discrete(direction),
    ...
  )
}

#' PHA-branded discrete fill scale
#'
#' @param direction If -1, reverse the scale (defaults to 1)
#' @import ggplot2
#' @export
scale_fill_pha <- function(direction = 1, ...) {
  ggplot2::discrete_scale(
    "fill", "pha", palette = pha_pal_discrete(direction),
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
#' @import ggplot2
#' @import scales
#' @export
scale_color_gradient_hda <- function(...,
                                     colors = c("#445ca9","#8baeaa","#e9ab3f","#e76f52"),
                                     values = NULL,
                                     space = "Lab",
                                     na.value = "#cfcfd0",
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

#' PHA-branded 4-color continuous color scale
#'
#' @param colors Vector of colors
#' @param values If colors should not be evenly positioned along the gradient, this vector gives the position (between 0 and 1) for each color in the vector
#' @param space Color space in which to calculate gradient. Must be "Lab" - other values depreciated
#' @param na.value Default color for NA values (#e2e4e3, PHA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to continuous_scale()
#' @import ggplot2
#' @import scales
#' @export
scale_color_gradient_pha <- function(...,
                                     colors = c("#5bab8e","#a6cccc","#f39152","#be451c"),
                                     values = NULL,
                                     space = "Lab",
                                     na.value = "#e2e4e3",
                                     guide = "colorbar") {
  ggplot2::continuous_scale(
    aesthetics = "color",
    scale_name = "pha",
    palette = scales::gradient_n_pal(colors, values, space),
    na.value = na.value,
    guide = guide,
    ...
  )
}

#' PHA-branded 4-color continuous fill scale
#'
#' @param colors Vector of colors
#' @param values If colors should not be evenly positioned along the gradient, this vector gives the position (between 0 and 1) for each color in the vector
#' @param space Color space in which to calculate gradient. Must be "Lab" - other values depreciated
#' @param na.value Default color for NA values (#e2e4e3, PHA Light Gray)
#' @param guide Legend representation for scale
#' @param ... Other arguments passed on to continuous_scale()
#' @import ggplot2
#' @import scales
#' @export
scale_fill_gradient_pha <- function(...,
                                     colors = c("#5bab8e","#a6cccc","#f39152","#be451c"),
                                     values = NULL,
                                     space = "Lab",
                                     na.value = "#e2e4e3",
                                     guide = "colorbar") {
  ggplot2::continuous_scale(
    aesthetics = "fill",
    scale_name = "pha",
    palette = scales::gradient_n_pal(colors, values, space),
    na.value = na.value,
    guide = guide,
    ...
  )
}
