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
