# Structural checks on the branded themes: base-size handling (including the
# output-format adjustments applied under knitr), strip.text element class, and
# gridline/`...` passthrough behavior.

test_that("theme_hda applies the (studio) base size to text", {
  th <- theme_hda(base_size = 20)
  expect_equal(ggplot2::calc_element("text", th)$size, 20)
})

test_that("theme_hfv applies the (studio) base size to text", {
  th <- theme_hfv(base_size = 20)
  expect_equal(ggplot2::calc_element("text", th)$size, 20)
})

test_that("theme_hda and theme_hfv use element_markdown for strip text", {
  expect_true(has_element_class(
    ggplot2::calc_element("strip.text", theme_hda()), "element_markdown"
  ))
  expect_true(has_element_class(
    ggplot2::calc_element("strip.text", theme_hfv()), "element_markdown"
  ))
})

test_that("theme_hda/theme_hfv subtract html_adjust under an HTML knitr render", {
  withr::local_options(knitr.in.progress = TRUE)
  local_mocked_bindings(is_html_output = function(...) TRUE, .package = "knitr")
  # Defaults: html_adjust = 4, so base_size 20 -> 16
  expect_equal(ggplot2::calc_element("text", theme_hda(base_size = 20))$size, 16)
  expect_equal(ggplot2::calc_element("text", theme_hfv(base_size = 20))$size, 16)
})

test_that("theme_hda/theme_hfv subtract pdf_adjust under a non-HTML knitr render", {
  withr::local_options(knitr.in.progress = TRUE)
  local_mocked_bindings(is_html_output = function(...) FALSE, .package = "knitr")
  # Defaults: pdf_adjust = 7, so base_size 20 -> 13
  expect_equal(ggplot2::calc_element("text", theme_hda(base_size = 20))$size, 13)
  expect_equal(ggplot2::calc_element("text", theme_hfv(base_size = 20))$size, 13)
})

test_that("theme_pha applies base_size to text, including under knitr", {
  expect_equal(
    ggplot2::calc_element("text", theme_pha(base_size = 60))$size,
    60
  )
  # html_adjust/pdf_adjust default to 0, so a knitr render must not shrink it
  withr::local_options(knitr.in.progress = TRUE)
  expect_equal(
    ggplot2::calc_element("text", theme_pha(base_size = 60))$size,
    60
  )
})

test_that("theme_pha uses element_markdown for strip text", {
  expect_true(has_element_class(
    ggplot2::calc_element("strip.text", theme_pha()), "element_markdown"
  ))
})

test_that("theme_pha flip_gridlines swaps major gridline orientation", {
  default <- theme_pha()
  flipped <- theme_pha(flip_gridlines = TRUE)
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.y", default), "element_line"))
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.x", default), "element_blank"))
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.x", flipped), "element_line"))
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.y", flipped), "element_blank"))
})

test_that("theme_pha passes ... through to ggplot2::theme()", {
  th <- theme_pha(legend.position = "bottom")
  expect_equal(th[["legend.position"]], "bottom")
})
