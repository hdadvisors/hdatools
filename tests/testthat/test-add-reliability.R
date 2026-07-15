# Legacy path (no cv_col supplied): auto-detects a `_cv` column, treats values as
# 0-1 proportions, and uses strict `<` boundaries. Preserved byte-for-byte by the
# 0.2.0 redesign; the new tidy-eval path is exercised in commit 5.

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
