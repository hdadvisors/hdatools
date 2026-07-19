# Internal factory. Returns a function(text, color) that wraps `text` in a
# ggtext-compatible HTML span colored with the brand hex for `color`.
# `accessor` is the per-brand .*_color() function object.
.brand_span <- function(accessor) {
  function(text, color) {
    hex <- unname(accessor(color))
    sprintf("<span style='color:%s'>%s</span>", hex, text)
  }
}

#' Wrap text in a brand-colored HTML span (HDA)
#'
#' Produces a `<span style='color:#…'>text</span>` tag for use with
#' [ggtext::element_markdown()] or [ggtext::element_textbox()]. Color is
#' resolved through [hda_color()], so invalid names error with the valid list.
#'
#' @param text Character string to wrap.
#' @param color A valid HDA color name (e.g. `"Blue"`, `"Sea Green"`).
#'
#' @return A character string containing the HTML span tag.
#'
#' @examples
#' hda_span("Housing Data Advisors", "Blue")
#' hda_span("note", "Green")
#'
#' @seealso [hda_color()], [hfv_span()], [pha_span()], [vha_span()]
#' @export
hda_span <- .brand_span(hda_color)

#' Wrap text in a brand-colored HTML span (HFV)
#'
#' Produces a `<span style='color:#…'>text</span>` tag for use with
#' [ggtext::element_markdown()] or [ggtext::element_textbox()]. Color is
#' resolved through [hfv_color()], so invalid names error with the valid list.
#'
#' @param text Character string to wrap.
#' @param color A valid HFV color name (e.g. `"Shadow"`, `"Sky"`).
#'
#' @return A character string containing the HTML span tag.
#'
#' @examples
#' hfv_span("HousingForward Virginia", "Shadow")
#' hfv_span("note", "Sky")
#'
#' @seealso [hfv_color()], [hda_span()], [pha_span()], [vha_span()]
#' @export
hfv_span <- .brand_span(hfv_color)

#' Wrap text in a brand-colored HTML span (PHA)
#'
#' Produces a `<span style='color:#…'>text</span>` tag for use with
#' [ggtext::element_markdown()] or [ggtext::element_textbox()]. Color is
#' resolved through [pha_color()], so invalid names error with the valid list.
#'
#' @param text Character string to wrap.
#' @param color A valid PHA color name (e.g. `"Green"`, `"Dark Blue"`).
#'
#' @return A character string containing the HTML span tag.
#'
#' @examples
#' pha_span("Partnership for Housing Affordability", "Green")
#' pha_span("note", "Dark Blue")
#'
#' @seealso [pha_color()], [hda_span()], [hfv_span()], [vha_span()]
#' @export
pha_span <- .brand_span(pha_color)

#' Wrap text in a brand-colored HTML span (VHA)
#'
#' Produces a `<span style='color:#…'>text</span>` tag for use with
#' [ggtext::element_markdown()] or [ggtext::element_textbox()]. Color is
#' resolved through [vha_color()], so invalid names error with the valid list.
#'
#' @param text Character string to wrap.
#' @param color A valid VHA color name (e.g. `"Dark Turq"`, `"Yellow"`).
#'
#' @return A character string containing the HTML span tag.
#'
#' @examples
#' vha_span("Virginia Housing Alliance", "Dark Turq")
#' vha_span("note", "Yellow")
#'
#' @seealso [vha_color()], [hda_span()], [hfv_span()], [pha_span()]
#' @export
vha_span <- .brand_span(vha_color)
