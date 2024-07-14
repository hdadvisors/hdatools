#' Create a factor with case_when logic and automatic level ordering
#'
#' This function combines the functionality of \code{dplyr::case_when()} with
#' automatic factor level ordering. It creates a factor where the levels are
#' ordered according to the sequence they appear in the case_when conditions.
#'
#' @param ... A series of two-sided formulas. The left hand side (LHS) determines
#'   which values match this case. The right hand side (RHS) provides the value
#'   to use for the output.
#' @param dir Direction of factor levels. Use 1 for the same order as input (default),
#'   or -1 to reverse the order.
#'
#' @return A factor with levels ordered according to their appearance in the
#'   case_when conditions, and the specified direction.
#'
#' @import dplyr
#'
#' @note This function was adapted from an answer provided to StackOverflow post
#'   [#69333730](https://stackoverflow.com/a/69333730).
#'
#' @examples
#' library(dplyr)
#' library(tibble)
#'
#' # Create a sample dataset of cost burden percent values
#' set.seed(123)
#' cost_burden <- tibble(
#'   pct = runif(100, min = 0, max = 1)
#' )
#'
#' # Apply fct_case_when to create labels
#' cost_burden_label <- cost_burden |>
#'   mutate(
#'     cb = fct_case_when(
#'       pct < 0.30 ~ "Not cost-burdened",
#'       pct < 0.50 ~ "Cost-burdened",
#'       pct >= 0.50 ~ "Severely cost-burdened"
#'     )
#'   )
#'
#' # Check the levels of the new factor column
#' levels(cost_burden_label$cb)
#'
#' @import dplyr
#' @export

fct_case_when <- function(..., dir = 1) {
  # Capture all arguments passed to the function
  args <- list(...)

  # Extract the right-hand side (RHS) of each formula in the arguments
  # This will be used as the levels for the factor
  levels <- sapply(args, function(f) as.character(f[[3]]))

  # Remove any NA values from the levels
  levels <- levels[!is.na(levels)]

  # Remove duplicates while preserving order
  levels <- unique(levels)

  # Reverse the order of levels if dir is -1
  if (dir == -1) {
    levels <- rev(levels)
  }

  # Create a factor using case_when for the values and the extracted levels
  # This ensures the factor levels are in the order specified by the user
  factor(dplyr::case_when(...), levels = levels)
}
