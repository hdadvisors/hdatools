#' Add reliability labels based on coefficient of variation
#'
#' Adds a `reliability` column that classifies each row by its coefficient of
#' variation (CV). There are two ways to call it:
#'
#' \itemize{
#'   \item **Supply `cv_col` (recommended).** The named column is classified with
#'     `<=` boundaries on the chosen `scale`. With `scale = "percent"` (the
#'     default) a CV of exactly 15 is "High" and exactly 30 is "Medium".
#'   \item **Omit `cv_col` (legacy).** The single column ending in `_cv` is
#'     auto-detected and treated as a 0-1 proportion with strict `<` boundaries
#'     (High: CV < 0.15; Medium: 0.15 <= CV < 0.30; Low: CV >= 0.30).
#' }
#'
#' Missing CV values yield `NA`. The result is a character column (not a factor).
#'
#' @param data A data frame or tibble.
#' @param cv_col The column of CV values to classify. If `NULL` (the default),
#'   the legacy `_cv` auto-detection path is used.
#' @param scale Whether `cv_col` is on a `"percent"` (0-100, the default) or
#'   `"proportion"` (0-1) scale. Ignored on the legacy path.
#'
#' @return The input data frame with an additional `reliability` character column.
#'
#' @export
#'
#' @examples
#' # Recommended: name the CV column (percent scale)
#' df <- data.frame(location = c("A", "B", "C", "D"), cv = c(5, 15, 30, NA))
#' add_reliability(df, cv_col = cv)
#'
#' # Legacy: auto-detect a _cv column on the 0-1 proportion scale
#' df2 <- data.frame(location = c("A", "B", "C"), value_cv = c(0.05, 0.20, 0.35))
#' add_reliability(df2)
add_reliability <- function(data, cv_col = NULL, scale = c("percent", "proportion")) {

  cv_quo <- rlang::enquo(cv_col)

  # Legacy path: no column supplied. Auto-detect a single `_cv` column, treat
  # values as 0-1 proportions with strict `<` boundaries. Preserved byte-for-byte.
  if (rlang::quo_is_null(cv_quo)) {

    cv_col <- names(data)[grep("_cv$", names(data))]

    if (length(cv_col) == 0) {
      stop("No column ending with '_cv' found in the data.")
    } else if (length(cv_col) > 1) {
      warning("Multiple columns ending with '_cv' found. Using the first one.")
      cv_col <- cv_col[1]
    }

    return(
      data |>
        dplyr::mutate(reliability = dplyr::case_when(
          .data[[cv_col]] < 0.15 ~ "High",
          .data[[cv_col]] >= 0.15 & .data[[cv_col]] < 0.30 ~ "Medium",
          .data[[cv_col]] >= 0.30 ~ "Low",
          TRUE ~ NA_character_  # For any other case (e.g., NA values)
        ))
    )

  }

  # New path: a column was supplied. Classify with `<=` boundaries on the chosen
  # scale so that a CV exactly on a threshold takes the more reliable label.
  scale <- match.arg(scale)
  thresholds <- if (scale == "percent") c(15, 30) else c(0.15, 0.30)

  data |>
    dplyr::mutate(reliability = dplyr::case_when(
      is.na({{ cv_col }}) ~ NA_character_,
      {{ cv_col }} <= thresholds[1] ~ "High",
      {{ cv_col }} <= thresholds[2] ~ "Medium",
      TRUE ~ "Low"
    ))
}
