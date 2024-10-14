#' Use an HDAdvisors-branded ggplot2 theme
#'
#' @param base_size The base size of text elements; defaults to 14
#' @param base_family The base font family; defaults to "Lato"
#' @param flip_gridlines Orientation of major gridlines; defaults to FALSE for y-axis
#' @param output_format Optional manual specification of output format
#' @param ... Additional arguments passed to ggplot2::theme()
#'
#' @import ggplot2
#' @import ggtext
#' @export
theme_hda <- function(
    base_size = 14,
    base_family = "Lato",
    flip_gridlines = FALSE,
    output_format = NULL,
    ... # Additional ggplot2::theme() arguments
) {

  # Determine the actual output format
  actual_format <- get_output_format(output_format)

  # Adjust base_size based on output format
  adjusted_base_size <- adjust_base_size(base_size, 4, 7, actual_format)

  # Create base theme
  base_theme <- ggplot2::theme_minimal() %+replace%

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
        size = adjusted_base_size,
        colour = "#383c3d",
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

      plot.title = ggtext::element_markdown(
        size = adjusted_base_size * 1.25,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = ggplot2::margin(b = 10, unit = "pt"),
        face = "bold",
        family = "Roboto Slab"
      ),

      plot.subtitle = ggtext::element_markdown(
        size = adjusted_base_size * 1.125,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = ggplot2::margin(t = -5, b = 10, unit = "pt"),
        face = "plain",
        family = "Roboto Slab"
      ),

      plot.caption = ggtext::element_markdown(
        size = adjusted_base_size * 0.875,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = ggplot2::margin(t = 10, unit = "pt"),
        lineheight = 1.1,
        face = "plain",
        family = "Lato"
      ),

      strip.text = ggtext::element_markdown(
        size = adjusted_base_size,
        family = "Lato",
        color = "#383c3d",
        margin = ggplot2::margin(b = 5, t = 0),
        vjust = 0,
        lineheight = 1.1
      ),

      plot.title.position = "plot",

      plot.caption.position = "plot",

      panel.background = ggplot2::element_blank(),

      panel.grid.minor = ggplot2::element_blank(),

      legend.position = "none",

      legend.title = ggplot2::element_blank(),

      axis.title = ggplot2::element_blank(),

      axis.ticks = ggplot2::element_blank()

    ) +

    if(flip_gridlines == FALSE) {

      ggplot2::theme(

        panel.grid.major.x = ggplot2::element_blank(),

        panel.grid.major.y = ggplot2::element_line(
          color = "#cbcdcc",
          size = 0.05
        )

      )

    } else {

      ggplot2::theme(

        panel.grid.major.y = ggplot2::element_blank(),

        panel.grid.major.x = ggplot2::element_line(
          color = "#cbcdcc",
          size = 0.05
        )

      )

    }

  # Combine base theme and additional arguments
  base_theme + ggplot2::theme(...)

}


#' Use a HousingForward Virginia-branded ggplot2 theme
#'
#' @param base_size The base size of text elements; defaults to 10
#' @param base_family The base font family; defaults to "Open Sans"
#' @param flip_gridlines Orientation of major gridlines; defaults to FALSE for y-axis
#'
#' @import ggplot2
#' @import ggtext
#' @export
theme_hfv <- function(
    base_size = 10,
    base_family = "Open Sans",
    flip_gridlines = FALSE
) {

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
        lineheight = 0.9,
        margin = ggplot2::margin(),
        debug = FALSE
      ),

      line = ggplot2::element_line(colour = "#000000",
                                   size = 1,
                                   linetype = 1L,
                                   lineend = "butt"),

      plot.title = ggtext::element_textbox_simple(
        size = base_size * 1.25,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = ggplot2::margin(b = 10, unit = "pt"),
        face = "bold",
        family = "Open Sans"
      ),

      plot.subtitle = ggtext::element_textbox_simple(
        size = base_size,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = ggplot2::margin(t = -5, b = 10, unit = "pt"),
        face = "plain",
        family = "Open Sans"
      ),

      plot.caption = ggtext::element_textbox_simple(
        size = base_size * 0.875,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = ggplot2::margin(t = 10, unit = "pt"),
        lineheight = 1.1,
        face = "plain",
        family = "Open Sans"
      ),

      plot.title.position = "plot",

      plot.caption.position = "plot",

      panel.background = ggplot2::element_blank(),

      panel.grid.minor = ggplot2::element_blank(),

      legend.position = "none",

      legend.title = ggplot2::element_blank(),

      axis.title = ggplot2::element_blank(),

      axis.ticks = ggplot2::element_blank()

    ) +

    if(flip_gridlines == FALSE) {

      ggplot2::theme(

        panel.grid.major.x = ggplot2::element_blank(),

        panel.grid.major.y = ggplot2::element_line(
          color = "#cbcdcc",
          size = 0.05
        )

      )

    } else {

      ggplot2::theme(

        panel.grid.major.y = ggplot2::element_blank(),

        panel.grid.major.x = ggplot2::element_line(
          color = "#cbcdcc",
          size = 0.05
        )

      )

    }

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
    base_size = 10,
    base_family = "Noto Sans"
) {

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

      plot.title = ggtext::element_markdown(
        size = base_size * 1.25,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        face = "bold",
        family = "Noto Sans"
      ),

      plot.subtitle = ggtext::element_markdown(
        size = base_size * 1.125,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = ggplot2::margin(t = 5, b = 20, unit = "pt"),
        face = "plain",
        family = "Noto Sans"
      ),

      plot.caption = ggtext::element_markdown(
        size = base_size * 0.875,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = ggplot2::margin(t = 10, unit = "pt"),
        lineheight = 1.1,
        face = "plain",
        family = "Noto Sans"
        ),

      plot.title.position = "plot",

      plot.caption.position = "plot",

      panel.background = ggplot2::element_blank(),

      panel.grid.major.x = ggplot2::element_blank(),

      panel.grid.major.y = ggplot2::element_line(
        color = "#cbcdcc",
        size = 0.05
        ),

      panel.grid.minor = ggplot2::element_blank(),

      legend.position = "none",

      legend.title = ggplot2::element_blank(),

      axis.title = ggplot2::element_blank(),

      axis.ticks = ggplot2::element_blank()

    )

}
