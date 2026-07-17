# Internal theme builder shared by theme_hda()/theme_hfv()/theme_pha().
# Reproduces each brand's theme element-by-element from its .brands entry;
# see R/brands.R for the per-brand font/margin/size fields it reads.
.brand_theme <- function(
    spec,
    base_size,
    base_family,
    flip_gridlines = FALSE,
    output_format = NULL,
    html_adjust,
    pdf_adjust,
    ...
) {

  actual_format <- get_output_format(output_format)
  adjusted_base_size <- adjust_base_size(base_size, html_adjust, pdf_adjust, actual_format)

  # NULL in spec$theme_fonts means "track the caller's base_family" rather
  # than a brand-fixed family (see R/brands.R).
  font_for <- function(fixed) if (is.null(fixed)) base_family else fixed

  # flip_gridlines() below calls the *exported* helper of the same name.
  # A function call in R only searches for function bindings, so this always
  # resolves to hdatools::flip_gridlines() and never to the logical
  # `flip_gridlines` argument, even though they share a name.
  gridline <- flip_gridlines()$panel.grid.major.x

  if (isTRUE(flip_gridlines)) {
    grid_elements <- list(
      panel.grid.major.y = ggplot2::element_blank(),
      panel.grid.major.x = gridline
    )
  } else {
    grid_elements <- list(
      panel.grid.major.x = ggplot2::element_blank(),
      panel.grid.major.y = gridline
    )
  }

  elements <- c(
    list(

      rect = ggplot2::element_rect(
        fill = "white",
        colour = "black",
        linewidth = 0.5,
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
        lineheight = spec$lineheight,
        margin = ggplot2::margin(),
        debug = FALSE
      ),

      line = ggplot2::element_line(
        colour = "#000000",
        linewidth = 1,
        linetype = 1L,
        lineend = "butt"
      ),

      plot.title = ggtext::element_markdown(
        size = adjusted_base_size * 1.25,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = spec$theme_margins$title,
        face = "bold",
        family = font_for(spec$theme_fonts$title)
      ),

      plot.subtitle = ggtext::element_markdown(
        size = adjusted_base_size * 1.125,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = spec$theme_margins$subtitle,
        face = "plain",
        family = font_for(spec$theme_fonts$subtitle)
      ),

      plot.caption = ggtext::element_markdown(
        size = adjusted_base_size * 0.875,
        color = "#383c3d",
        hjust = 0L,
        vjust = 0L,
        margin = ggplot2::margin(t = 10, unit = "pt"),
        lineheight = 1.1,
        face = "plain",
        family = font_for(spec$theme_fonts$caption)
      ),

      strip.text = ggtext::element_markdown(
        size = adjusted_base_size,
        family = font_for(spec$theme_fonts$strip),
        color = "#383c3d",
        margin = ggplot2::margin(b = 5, t = 2),
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

    ),
    grid_elements
  )

  base_theme <- ggplot2::theme_minimal() %+replace% do.call(ggplot2::theme, elements)

  base_theme + ggplot2::theme(...)

}

#' Use an HDAdvisors-branded ggplot2 theme
#'
#' @param base_size The base size of text elements; defaults to 14
#' @param base_family The base font family; defaults to "Lato"
#' @param flip_gridlines Orientation of major gridlines; defaults to FALSE for y-axis
#' @param output_format Optional manual specification of output format
#' @param html_adjust Amount subtracted from base_size for HTML output; defaults to 4
#' @param pdf_adjust Amount subtracted from base_size for PDF output; defaults to 7
#' @param ... Additional arguments passed to ggplot2::theme()
#'
#' @details When overriding strip text under ggplot2 >= 4.0, use
#'   `ggtext::element_markdown()`, never a raw `ggplot2::element_text()`: the
#'   branded strip element is a ggtext markdown element, and ggplot2 4.0 only
#'   merges theme elements of the same class.
#'
#' @export
theme_hda <- function(
    base_size = 14,
    base_family = "Lato",
    flip_gridlines = FALSE,
    output_format = NULL,
    html_adjust = 4,
    pdf_adjust = 7,
    ... # Additional ggplot2::theme() arguments
) {
  .brand_theme(
    .brands$hda,
    base_size = base_size,
    base_family = base_family,
    flip_gridlines = flip_gridlines,
    output_format = output_format,
    html_adjust = html_adjust,
    pdf_adjust = pdf_adjust,
    ...
  )
}


#' Use a HousingForward Virginia-branded ggplot2 theme
#'
#' @param base_size The base size of text elements; defaults to 14
#' @param base_family The base font family; defaults to "Open Sans"
#' @param flip_gridlines Orientation of major gridlines; defaults to FALSE for y-axis
#' @param output_format Optional manual specification of output format
#' @param html_adjust Amount subtracted from base_size for HTML output; defaults to 4
#' @param pdf_adjust Amount subtracted from base_size for PDF output; defaults to 7
#' @param ... Additional arguments passed to ggplot2::theme()
#'
#' @details When overriding strip text under ggplot2 >= 4.0, use
#'   `ggtext::element_markdown()`, never a raw `ggplot2::element_text()`: the
#'   branded strip element is a ggtext markdown element, and ggplot2 4.0 only
#'   merges theme elements of the same class.
#'
#' @export
theme_hfv <- function(
    base_size = 14,
    base_family = "Open Sans",
    flip_gridlines = FALSE,
    output_format = NULL,
    html_adjust = 4,
    pdf_adjust = 7,
    ... # Additional ggplot2::theme() arguments
) {
  .brand_theme(
    .brands$hfv,
    base_size = base_size,
    base_family = base_family,
    flip_gridlines = flip_gridlines,
    output_format = output_format,
    html_adjust = html_adjust,
    pdf_adjust = pdf_adjust,
    ...
  )
}

#' Use a PHA-branded ggplot2 theme
#'
#' @param base_size The base size of text elements; defaults to 10
#' @param base_family The base font family; defaults to "Noto Sans"
#' @param flip_gridlines Orientation of major gridlines; defaults to FALSE for y-axis
#' @param output_format Optional manual specification of output format
#' @param html_adjust Amount subtracted from base_size for HTML output; defaults to 0
#' @param pdf_adjust Amount subtracted from base_size for PDF output; defaults to 0
#' @param ... Additional arguments passed to ggplot2::theme()
#'
#' @details When overriding strip text under ggplot2 >= 4.0, use
#'   `ggtext::element_markdown()`, never a raw `ggplot2::element_text()`: the
#'   branded strip element is a ggtext markdown element, and ggplot2 4.0 only
#'   merges theme elements of the same class.
#'
#' @export
theme_pha <- function(
    base_size = 10,
    base_family = "Noto Sans",
    flip_gridlines = FALSE,
    output_format = NULL,
    html_adjust = 0,
    pdf_adjust = 0,
    ... # Additional ggplot2::theme() arguments
) {
  .brand_theme(
    .brands$pha,
    base_size = base_size,
    base_family = base_family,
    flip_gridlines = flip_gridlines,
    output_format = output_format,
    html_adjust = html_adjust,
    pdf_adjust = pdf_adjust,
    ...
  )
}
