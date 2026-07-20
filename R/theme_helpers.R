#' Register hdatools' bundled fonts for use in plots and knitr output
#'
#' Registers the font faces bundled in `inst/fonts/` (Lato and Roboto Slab for
#' `theme_hda()`, Open Sans and Poppins for `theme_hfv()`, Noto Sans for
#' `theme_pha()`, Montserrat for `theme_vha()`) with \pkg{systemfonts}, making
#' them available by name to \pkg{ragg} graphics devices (and any other
#' systemfonts-aware device). Everything is read from files installed with
#' the package, so this never makes a network request.
#'
#' Rendering with these fonts requires a systemfonts-aware device — for
#' knitr/Quarto output, set `dev: "ragg_png"` (see `README.md`); the default
#' Cairo device does not consult the systemfonts registry.
#'
#' Registration can be skipped by setting `options(hdatools.fonts = FALSE)`
#' or the environment variable `HDATOOLS_NO_FONTS` to any non-empty value —
#' useful if a consumer wants to supply its own font setup.
#'
#' Each bundled family is registered independently. `systemfonts::register_font()`
#' refuses to register a name that already matches an installed system font
#' (e.g. Open Sans ships with several common apps) — when that happens, this
#' function leaves that one family alone (the system copy resolves under the
#' same name anyway) and still registers the rest.
#'
#' @param quiet If `TRUE`, suppresses the message emitted when registering a
#'   family unexpectedly fails (a name collision with an installed system
#'   font is never reported, since it is not a failure). Registration issues
#'   are non-fatal: hdatools falls back to whatever fonts are already
#'   available on the system.
#'
#' @return Invisibly, `TRUE` if every bundled family is available (registered
#'   by hdatools or already present as a system font), `FALSE` if skipped via
#'   the opt-out or if a family failed to register for an unexpected reason.
#'
#' @export
register_hda_fonts <- function(quiet = FALSE) {

  opt_in <- isTRUE(getOption("hdatools.fonts", TRUE)) &&
    !nzchar(Sys.getenv("HDATOOLS_NO_FONTS"))

  if (!opt_in) {
    return(invisible(FALSE))
  }

  font_path <- function(family_dir, file) {
    system.file("fonts", family_dir, file, package = "hdatools")
  }

  families <- list(
    "Lato" = list(
      plain  = font_path("lato", "Lato-Regular.ttf"),
      bold   = font_path("lato", "Lato-Bold.ttf"),
      italic = font_path("lato", "Lato-Italic.ttf")
    ),
    "Roboto Slab" = list(
      plain = font_path("roboto-slab", "RobotoSlab-Regular.ttf"),
      bold  = font_path("roboto-slab", "RobotoSlab-Bold.ttf")
    ),
    "Open Sans" = list(
      plain  = font_path("open-sans", "OpenSans-Regular.ttf"),
      bold   = font_path("open-sans", "OpenSans-Bold.ttf"),
      italic = font_path("open-sans", "OpenSans-Italic.ttf")
    ),
    "Poppins" = list(
      plain = font_path("poppins", "Poppins-Regular.ttf"),
      bold  = font_path("poppins", "Poppins-SemiBold.ttf")
    ),
    "Noto Sans" = list(
      plain  = font_path("noto-sans", "NotoSans-Regular.ttf"),
      bold   = font_path("noto-sans", "NotoSans-Bold.ttf"),
      italic = font_path("noto-sans", "NotoSans-Italic.ttf")
    ),
    "Montserrat" = list(
      plain = font_path("montserrat", "Montserrat-Regular.ttf"),
      bold  = font_path("montserrat", "Montserrat-SemiBold.ttf")
    )
  )

  ok <- vapply(names(families), function(name) {
    tryCatch({
      do.call(systemfonts::register_font, c(list(name = name), families[[name]]))
      TRUE
    }, error = function(e) {
      if (startsWith(conditionMessage(e), "A system font called")) {
        return(TRUE)
      }
      if (!quiet) {
        packageStartupMessage(
          "hdatools: could not register bundled font '", name, "' (",
          conditionMessage(e), ")"
        )
      }
      FALSE
    })
  }, logical(1))

  invisible(all(ok))

}

#' Generate a function to wrap and format facet labels with markdown
#'
#' This function creates a labeller function for use with ggplot2 facets.
#' It wraps long labels to a specified width and formats them as markdown,
#' which allows them to be rendered correctly when using ggtext::element_markdown()
#' in themes.
#'
#' @param width An integer specifying the maximum number of characters
#'   before wrapping the text. Default is 25.
#'
#' @return A function that takes a vector of labels and returns a list of
#'   wrapped and formatted labels.
#'
#' @examples
#' \dontrun{
#' library(ggplot2)
#' library(hdatools)
#'
#' ggplot(mtcars, aes(mpg, wt)) +
#'   geom_point() +
#'   facet_wrap(~vs, labeller = markdown_wrap_gen(width = 20)) +
#'   theme_hda()
#' }
#'
#' @export
markdown_wrap_gen <- function(width = 25) {
  function(labels) {
    labels <- sapply(labels, function(x) {
      wrapped <- stringr::str_wrap(x, width = width)
      wrapped
    })
    lapply(labels, function(x) gsub("\n", "<br>", x))
  }
}

#' Determine the current output format
#'
#' This function checks the current environment to determine whether the code
#' is being run in an interactive session (like RStudio), or as part of rendering
#' an HTML or PDF document.
#'
#' @param manual_format An optional string specifying the format. If provided,
#'   this overrides the automatic detection.
#'
#' @return A string indicating the detected format: "studio" for interactive
#'   sessions, "html" for HTML output, or "pdf" for PDF output.
#'
#' @examples
#' # Automatic detection
#' get_output_format()
#'
#' # Manual override
#' get_output_format("pdf")
#'
#' @export
get_output_format <- function(manual_format = NULL) {
  if (!is.null(manual_format)) {
    return(manual_format)
  } else {
    # Check if we're in a knitr context
    in_knitr <- isTRUE(getOption('knitr.in.progress'))

    if (in_knitr) {
      # We're rendering a document
      if (knitr::is_html_output()) {
        return("html")
      } else {
        return("pdf")
      }
    } else {
      # We're likely in RStudio or another interactive environment
      return("studio")
    }
  }
}

#' Adjust base size for different output formats
#'
#' This function adjusts the base font size depending on the output format
#' (studio, HTML, or PDF).
#'
#' @param base_size The base font size for studio/interactive output.
#' @param html_adjust The amount to subtract from base_size for HTML output.
#' @param pdf_adjust The amount to subtract from base_size for PDF output.
#' @param format The output format, as returned by get_output_format().
#'
#' @return An adjusted base size appropriate for the specified output format.
#'
#' @examples
#' adjust_base_size(12, 2, 5, "html")  # Returns 10
#' adjust_base_size(12, 2, 5, "pdf")   # Returns 7
#' adjust_base_size(12, 2, 5, "studio")  # Returns 12
#'
#' @export
adjust_base_size <- function(base_size, html_adjust, pdf_adjust, format) {
  switch(format,
         "html" = base_size - html_adjust,
         "pdf" = base_size - pdf_adjust,
         base_size  # Default for "studio" or any other value
  )
}

#' Flip default major gridlines from horizontal to vertical
#'
#' @param color Gridline color
#' @param linewidth Gridline width
#' @param size `r lifecycle::badge("deprecated")` Use `linewidth` instead.
#'
#' @export
flip_gridlines <- function(
    color = "#cbcdcc",
    linewidth = 0.05,
    size = lifecycle::deprecated()
) {

  if (lifecycle::is_present(size)) {
    lifecycle::deprecate_warn(
      "0.2.0", "flip_gridlines(size)", "flip_gridlines(linewidth)"
    )
    linewidth <- size
  }

  ggplot2::theme(

    panel.grid.major.y = ggplot2::element_blank(),

    panel.grid.major.x = ggplot2::element_line(
      color = color,
      linewidth = linewidth
    )

  )

}

#' Add darker line to zero intercept
#'
#' @param axis Apply to "x" or "y" axis.  Defaults to "y".
#'
#' @export
add_zero_line <- function(axis = c("y", "x")) {

  axis <- match.arg(axis)

  if(axis == "x") {

    ggplot2::geom_vline(xintercept = 0, color = "#4b4f50", linewidth = 0.5)

  } else {

    ggplot2::geom_hline(yintercept = 0, color = "#4b4f50", linewidth = 0.5)

  }

}

#' Create dynamic graphic from plot object when document rendered as HTML
#'
#' @param plot ggplot object
#'
#' @export
publish_plot <- function(plot) {

  if (knitr::is_html_output()) {

    if (!requireNamespace("ggiraph", quietly = TRUE)) {
      stop(
        "Package \"ggiraph\" is required to use publish_plot() for HTML output. ",
        "Install it with install.packages(\"ggiraph\").",
        call. = FALSE
      )
    }

    ggiraph::girafe(ggobj = plot,
                     height_svg = 4)

  } else {

    plot

  }

}

#' Get a logo for use in a ggplot2 plot
#'
#' @param type one of "hda" or "hfv"
#' @param width Image width in pixels; defaults to 100
#'
#' @return A length-one character (glue) string containing an HTML `<img>` tag
#'   that points at the installed logo file, sized to `width`. Intended for use
#'   in ggtext-rendered plot elements such as a markdown title or caption.
#' @export
get_logo <- function(type = c("hda", "hfv"), width = 100) {

  type <- match.arg(type)

  file <- if (type == "hda") "hda-logo-color.png" else "logo_primary.png"

  path <- system.file("logos", file, package = "hdatools")

  if (!nzchar(path)) {
    stop("Logo file '", file, "' not found in the hdatools installation.")
  }

  glue::glue("<img src='{path}' width = '{width}'>")

}
