#' Automatically make Google Fonts available
#'
#' @keywords internal
#' @import sysfonts
#' @import showtext
add_google_fonts <- function() {

  sysfonts::font_add_google("Lato", "Lato") # HDA text
  sysfonts::font_add_google("Roboto Slab", "Roboto Slab") # HDA headers
  sysfonts::font_add_google("Open Sans", "Open Sans") # HFV text
  sysfonts::font_add_google("Poppins", "Poppins", bold.wt = 600) # HFV headers
  sysfonts::font_add_google("Noto Sans", "Noto Sans") # PHA text and headers

  showtext::showtext_auto()

}

#' Get a logo for use in a ggplot2 plot
#'
#' @param type one of "hda" or "hfv"
#'
#' @return a path to an image to be used in ggplot2 plots
#' @export
get_logo <- function(type = c("hda", "hfv"), width = 100) {

  type <- match.arg(type)

  if (type == "hda") {
    path <- "inst/logos/hda-logo-color.png"
  } else {
    path <- "inst/logos/logo_primary.png"
  }

  out <- glue::glue("<img src='{path}' width = '{width}'>")

  out

  }

#' Flip default major gridlines from horizontal to vertical
#'
#' @param color Gridline color
#' @param size Gridline size
#'
#' @import ggplot2
#' @export
flip_gridlines <- function(
    color = "#cbcdcc",
    size = 0.05
) {

  ggplot2::theme(

    panel.grid.major.y = ggplot2::element_blank(),

    panel.grid.major.x = ggplot2::element_line(
      color = color,
      size = size
    )

  )

}

#' Add darker line to zero intercept
#'
#' @param axis Apply to "x" or "y" axis
#'
#' @import ggplot2
#' @export
add_zero_line <- function(axis = c("x", "y")) {

  if(axis == "x") {

    ggplot2::geom_vline(xintercept = 0, color = "#4b4f50", size = 0.5)

  } else {

    ggplot2::geom_hline(yintercept = 0, color = "#4b4f50", size = 0.5)

  }

}
