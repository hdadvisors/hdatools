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
