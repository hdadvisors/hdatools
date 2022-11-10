#' Use an HDAdvisors-branded ggplot2 theme
#'
#' @param base_size The base size of text elements; defaults to 14
#' @param base_family The base font family; defaults to "Lato"
#'
#' @import ggplot2
#' @import ggtext
#' @export
theme_hda <- function(
    base_size = 14,
    base_family = "Lato"
  ) {

  # Add Lato / Roboto if not available
  add_google_fonts()

  ggplot2::theme_minimal() %+replace%

  ggplot2::theme(

    rect = ggplot2::element_rect(
      fill = "white",
      colour = "black",
      size = 0.5,
      linetype = 1L
    ),

    text = ggplot2::element_text(
      family = base_family,
      face = "plain",
      size = base_size,
      colour = "black",
      hjust = 0.5,
      vjust = 0.5,
      angle = 0,
      lineheight = 0.9,
      margin = ggplot2::margin(),
      debug = FALSE
    ),

    line = ggplot2::element_line(colour = "#000000",
                                 size = 1,
                                 linetype = 1L,
                                 lineend = "butt"),

    plot.title = ggplot2::element_text(
      size = base_size * 1.5,
      hjust = 0L,
      vjust = 0L,
      face = "bold",
      family = "Roboto Slab"
    ),

    plot.subtitle = ggplot2::element_text(
      size = base_size * 1.25,
      hjust = 0L,
      vjust = 0L,
      face = "bold",
      family = "Roboto Slab"
    ),

    plot.caption = ggtext::element_markdown(hjust = 1, vjust = 0)

  )

}


#' Use a HousingForward Virginia-branded ggplot2 theme
#'
#' @param base_size The base size of text elements; defaults to 14
#' @param base_family The base font family; defaults to "Open Sans"
#'
#' @import ggplot2
#' @import ggtext
#' @export
theme_hfv <- function(
    base_size = 14,
    base_family = "Open Sans"
) {

  # Add Lato / Roboto if not available
  add_google_fonts()

  ggplot2::theme_minimal() %+replace%

    ggplot2::theme(

      rect = ggplot2::element_rect(
        fill = "white",
        colour = "black",
        size = 0.5,
        linetype = 1L
      ),

      text = ggplot2::element_text(
        family = base_family,
        face = "plain",
        size = base_size,
        colour = "black",
        hjust = 0.5,
        vjust = 0.5,
        angle = 0,
        lineheight = 0.9,
        margin = ggplot2::margin(),
        debug = FALSE
      ),

      line = ggplot2::element_line(colour = "#000000",
                                   size = 1,
                                   linetype = 1L,
                                   lineend = "butt"),

      plot.title = ggplot2::element_text(
        size = base_size * 1.5,
        hjust = 0L,
        vjust = 0L,
        face = "bold",
        family = "Poppins"
      ),

      plot.subtitle = ggplot2::element_text(
        size = base_size * 1.25,
        hjust = 0L,
        vjust = 0L,
        face = "bold",
        family = "Poppins"
      ),

      plot.caption = ggtext::element_markdown(hjust = 1, vjust = 0)

    )

}

#' Use a PHA-branded ggplot2 theme
#'
#' @param base_size The base size of text elements; defaults to 14
#' @param base_family The base font family; defaults to "Noto Sans"
#'
#' @import ggplot2
#' @import ggtext
#' @export
theme_pha <- function(
    base_size = 14,
    base_family = "Noto Sans"
) {

  # Add Noto Sans if not available
  add_google_fonts()

  ggplot2::theme_minimal() %+replace%

    ggplot2::theme(

      rect = ggplot2::element_rect(
        fill = "white",
        colour = "black",
        size = 0.5,
        linetype = 1L
      ),

      text = ggplot2::element_text(
        family = base_family,
        face = "plain",
        size = base_size,
        colour = "#383c3d",
        hjust = 0.5,
        vjust = 0.5,
        angle = 0,
        lineheight = 1,
        margin = ggplot2::margin(),
        debug = FALSE
      ),

      line = ggplot2::element_line(colour = "#000000",
                                   size = 1,
                                   linetype = 1L,
                                   lineend = "butt"),

      plot.title = ggplot2::element_text(
        size = base_size * 1.25,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        face = "bold",
        family = "Noto Sans"
      ),

      plot.subtitle = ggplot2::element_text(
        size = base_size * 1.125,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = ggplot2::margin(t = 3, b = 3, unit = "pt"),
        face = "plain",
        family = "Noto Sans"
      ),

      plot.caption = ggtext::element_markdown(
        size = base_size * 0.875,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = ggplot2::margin(t = 10, unit = "pt"),
        lineheight = 0.9,
        face = "plain",
        family = "Noto Sans"
        ),

      axis.title = ggplot2::element_blank(),

      panel.background = ggplot2::element_blank(),

      legend.title = ggplot2::element_blank(),

      axis.ticks = ggplot2::element_blank(),

      panel.grid.major.x = ggplot2::element_blank(),

      panel.grid.major.y = ggplot2::element_line(
        color = "grey95",
        size = 0.05
        )

    )

}
