#' Named HDA color vector
#'
#' A named character vector of the six HDA brand colors, taken directly from
#' the internal `.brands` registry. Names are the canonical color labels
#' (e.g. `"Blue"`, `"Green"`).
#'
#' Use `hda_colors["Blue"]` to pull a single hex by name, or pass the whole
#' vector to `scale_fill_manual(values = hda_colors)` for manual scales.
#'
#' @examples
#' hda_colors
#' hda_colors["Blue"]
#' hda_colors[c("Blue", "Yellow")]
#'
#' @seealso [hda_color()], [hfv_colors], [pha_colors]
#' @export
hda_colors <- .brands$hda$palette

#' Named HFV color vector
#'
#' A named character vector of the six HFV brand colors, taken directly from
#' the internal `.brands` registry. Names are the canonical color labels
#' (e.g. `"Shadow"`, `"Sky"`).
#'
#' @examples
#' hfv_colors
#' hfv_colors["Sky"]
#'
#' @seealso [hfv_color()], [hda_colors], [pha_colors]
#' @export
hfv_colors <- .brands$hfv$palette

#' Named PHA color vector
#'
#' A named character vector of the six PHA brand colors, taken directly from
#' the internal `.brands` registry. Names are the canonical color labels
#' (e.g. `"Green"`, `"Orange"`).
#'
#' @examples
#' pha_colors
#' pha_colors["Green"]
#'
#' @seealso [pha_color()], [hda_colors], [hfv_colors]
#' @export
pha_colors <- .brands$pha$palette

# Internal accessor factory used by the three per-brand exports below.
.brand_color <- function(palette, brand_name) {
  function(name) {
    if (!name %in% names(palette)) {
      valid <- paste(names(palette), collapse = ", ")
      stop(
        sprintf(
          '"%s" is not a valid %s color name. Valid names: %s.',
          name, brand_name, valid
        ),
        call. = FALSE
      )
    }
    palette[name]
  }
}

#' Look up a single HDA color by name
#'
#' Returns the hex value for the named HDA brand color. Errors with the list
#' of valid names when the name is not found.
#'
#' @param name A single color name, e.g. `"Blue"` or `"Sea Green"`.
#'
#' @return A named character scalar (hex color).
#'
#' @examples
#' hda_color("Blue")
#' hda_color("Sea Green")
#'
#' @seealso [hda_colors]
#' @export
hda_color <- .brand_color(.brands$hda$palette, "HDA")

#' Look up a single HFV color by name
#'
#' Returns the hex value for the named HFV brand color. Errors with the list
#' of valid names when the name is not found.
#'
#' @param name A single color name, e.g. `"Sky"` or `"Shadow"`.
#'
#' @return A named character scalar (hex color).
#'
#' @examples
#' hfv_color("Sky")
#' hfv_color("Shadow")
#'
#' @seealso [hfv_colors]
#' @export
hfv_color <- .brand_color(.brands$hfv$palette, "HFV")

#' Look up a single PHA color by name
#'
#' Returns the hex value for the named PHA brand color. Errors with the list
#' of valid names when the name is not found.
#'
#' @param name A single color name, e.g. `"Green"` or `"Dark Blue"`.
#'
#' @return A named character scalar (hex color).
#'
#' @examples
#' pha_color("Green")
#' pha_color("Dark Blue")
#'
#' @seealso [pha_colors]
#' @export
pha_color <- .brand_color(.brands$pha$palette, "PHA")
