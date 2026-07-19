# Internal factory. Returns a function(color, n) that builds a focus/emphasis
# palette: the named brand color hex at position 1, then (n - 1) copies of the
# brand's neutral gray. Intended for "highlight one series, mute the rest" plots.
# `accessor` is the per-brand .*_color() function object; `na_color` is the
# brand's neutral from .brands$<brand>$na_color.
.brand_focus_pal <- function(accessor, na_color, brand_name) {
  function(color, n = 5) {
    if (!is.numeric(n) || length(n) != 1L || n < 1L) {
      stop("`n` must be a positive integer.", call. = FALSE)
    }
    n <- as.integer(n)
    focus_hex <- unname(accessor(color))
    c(focus_hex, rep(na_color, n - 1L))
  }
}

#' Focus/emphasis palette for HDA
#'
#' Returns a character vector of `n` hex colors for "highlight one series,
#' mute the rest" charts. The first element is the brand hex for `color`;
#' the remaining `n - 1` elements are HDA's neutral gray (`#cfcfd0`). Pass
#' the result to [ggplot2::scale_fill_manual()] or
#' [ggplot2::scale_colour_manual()].
#'
#' @param color A valid HDA color name (e.g. `"Blue"`, `"Green"`).
#' @param n Total number of series (focus + muted). Must be a positive integer.
#'
#' @return An unnamed character vector of length `n`.
#'
#' @examples
#' hda_focus_pal("Blue", n = 4)
#'
#' @seealso [hda_color()], [hfv_focus_pal()], [pha_focus_pal()], [vha_focus_pal()]
#' @export
hda_focus_pal <- .brand_focus_pal(hda_color, .brands$hda$na_color, "HDA")

#' Focus/emphasis palette for HFV
#'
#' Returns a character vector of `n` hex colors for "highlight one series,
#' mute the rest" charts. The first element is the brand hex for `color`;
#' the remaining `n - 1` elements are HFV's neutral gray (`#d6dadd`). Pass
#' the result to [ggplot2::scale_fill_manual()] or
#' [ggplot2::scale_colour_manual()].
#'
#' @param color A valid HFV color name (e.g. `"Shadow"`, `"Sky"`).
#' @param n Total number of series (focus + muted). Must be a positive integer.
#'
#' @return An unnamed character vector of length `n`.
#'
#' @examples
#' hfv_focus_pal("Shadow", n = 4)
#'
#' @seealso [hfv_color()], [hda_focus_pal()], [pha_focus_pal()], [vha_focus_pal()]
#' @export
hfv_focus_pal <- .brand_focus_pal(hfv_color, .brands$hfv$na_color, "HFV")

#' Focus/emphasis palette for PHA
#'
#' Returns a character vector of `n` hex colors for "highlight one series,
#' mute the rest" charts. The first element is the brand hex for `color`;
#' the remaining `n - 1` elements are PHA's neutral gray (`#e2e4e3`). Pass
#' the result to [ggplot2::scale_fill_manual()] or
#' [ggplot2::scale_colour_manual()].
#'
#' @param color A valid PHA color name (e.g. `"Green"`, `"Orange"`).
#' @param n Total number of series (focus + muted). Must be a positive integer.
#'
#' @return An unnamed character vector of length `n`.
#'
#' @examples
#' pha_focus_pal("Green", n = 4)
#'
#' @seealso [pha_color()], [hda_focus_pal()], [hfv_focus_pal()], [vha_focus_pal()]
#' @export
pha_focus_pal <- .brand_focus_pal(pha_color, .brands$pha$na_color, "PHA")

#' Focus/emphasis palette for VHA
#'
#' Returns a character vector of `n` hex colors for "highlight one series,
#' mute the rest" charts. The first element is the brand hex for `color`;
#' the remaining `n - 1` elements are VHA's neutral gray (`#d6dbdb`). Pass
#' the result to [ggplot2::scale_fill_manual()] or
#' [ggplot2::scale_colour_manual()].
#'
#' @param color A valid VHA color name (e.g. `"Dark Turq"`, `"Yellow"`).
#' @param n Total number of series (focus + muted). Must be a positive integer.
#'
#' @return An unnamed character vector of length `n`.
#'
#' @examples
#' vha_focus_pal("Dark Turq", n = 4)
#'
#' @seealso [vha_color()], [hda_focus_pal()], [hfv_focus_pal()], [pha_focus_pal()]
#' @export
vha_focus_pal <- .brand_focus_pal(vha_color, .brands$vha$na_color, "VHA")
