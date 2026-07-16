# Legacy path (no cv_col supplied): auto-detects a `_cv` column, treats values as
# 0-1 proportions, and uses strict `<` boundaries. The new tidy-eval path
# (cv_col supplied) uses `<=` boundaries on the chosen scale.

test_that("add_reliability legacy path classifies by _cv column with < boundaries", {
  df <- data.frame(
    loc = letters[1:5],
    value_cv = c(0.05, 0.15, 0.20, 0.30, NA)
  )
  out <- add_reliability(df)
  expect_type(out$reliability, "character")
  expect_identical(out$reliability, c("High", "Medium", "Medium", "Low", NA))
})

test_that("add_reliability legacy path errors when no _cv column is present", {
  expect_error(add_reliability(data.frame(a = 1:3)), "_cv")
})

test_that("add_reliability legacy path warns and uses the first of multiple _cv columns", {
  df <- data.frame(a_cv = c(0.05, 0.20), b_cv = c(0.40, 0.40))
  expect_warning(out <- add_reliability(df), "Multiple columns")
  # Classification comes from a_cv (the first column), not b_cv
  expect_identical(out$reliability, c("High", "Medium"))
})

# New path (cv_col supplied): tidy-eval, `<=` boundaries, NA -> NA, character out.

test_that("add_reliability new path uses <= boundaries on the percent scale", {
  df <- data.frame(x = letters[1:6], cv = c(0, 15, 15.0001, 30, 30.0001, NA))
  out <- add_reliability(df, cv_col = cv)
  expect_type(out$reliability, "character")
  expect_identical(
    out$reliability,
    c("High", "High", "Medium", "Medium", "Low", NA)
  )
})

test_that("add_reliability new path supports the proportion scale", {
  df <- data.frame(x = letters[1:5], cv = c(0.10, 0.15, 0.20, 0.30, 0.31))
  out <- add_reliability(df, cv_col = cv, scale = "proportion")
  expect_identical(out$reliability, c("High", "High", "Medium", "Medium", "Low"))
})

test_that("add_reliability new path treats CV exactly 15 percent as High", {
  expect_identical(
    add_reliability(data.frame(cv = 15), cv_col = cv)$reliability,
    "High"
  )
})
