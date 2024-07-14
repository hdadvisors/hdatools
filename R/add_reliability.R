#' Add reliability labels based on coefficient of variation
#'
#' This function adds a new column called 'reliability' to the input dataset
#' based on the coefficient of variation (CV) values in a column ending with "_cv".
#'
#' The reliability is categorized as:
#'
#' \itemize{
#'   \item High: CV < 0.15
#'   \item Medium: 0.15 <= CV < 0.30
#'   \item Low: CV >= 0.30
#' }
#'
#' @param data A data frame or tibble containing a column ending with "_cv"
#'
#' @return The input data frame with an additional 'reliability' column
#'
#' @export
#'
#' @examples
#' # Create a sample dataset
#' df <- data.frame(
#'   location = c("A", "B", "C", "D"),
#'   value_cv = c(0.05, 0.20, 0.35, NA)
#' )
#'
#' # Add reliability column
#' result <- df |>
#'   add_reliability()
add_reliability <- function(data) {
  # Find the column name ending with "_cv"
  cv_col <- names(data)[grep("_cv$", names(data))]

  # Check if a CV column was found
  if (length(cv_col) == 0) {
    stop("No column ending with '_cv' found in the data.")
  } else if (length(cv_col) > 1) {
    warning("Multiple columns ending with '_cv' found. Using the first one.")
    cv_col <- cv_col[1]
  }

  # Add the reliability column based on the CV values
  data |>
    dplyr::mutate(reliability = dplyr::case_when(
      .data[[cv_col]] < 0.15 ~ "High",
      .data[[cv_col]] >= 0.15 & .data[[cv_col]] < 0.30 ~ "Medium",
      .data[[cv_col]] >= 0.30 ~ "Low",
      TRUE ~ NA_character_  # For any other case (e.g., NA values)
    ))
}
