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

# --- Pre-refactor identity tests: colours, lineheights, default sizes ---

test_that("theme_hda default text colour, lineheight, and base_size", {
  el <- ggplot2::calc_element("text", theme_hda())
  expect_identical(el$colour, "#383c3d")
  expect_equal(el$lineheight, 0.9)
  expect_equal(el$size, 14)
})

test_that("theme_hfv default text colour, lineheight, and base_size", {
  el <- ggplot2::calc_element("text", theme_hfv())
  expect_identical(el$colour, "#383c3d")
  expect_equal(el$lineheight, 0.9)
  expect_equal(el$size, 14)
})

test_that("theme_pha default text colour, lineheight, and base_size", {
  el <- ggplot2::calc_element("text", theme_pha())
  expect_identical(el$colour, "#383c3d")
  expect_equal(el$lineheight, 1)
  expect_equal(el$size, 10)
})

test_that("all themes use #cbcdcc gridlines at linewidth 0.05 (default orientation)", {
  for (th in list(theme_hda(), theme_hfv(), theme_pha())) {
    y_el <- ggplot2::calc_element("panel.grid.major.y", th)
    expect_true(has_element_class(y_el, "element_line"))
    expect_identical(y_el$colour, "#cbcdcc")
    expect_equal(y_el$linewidth, 0.05)
    expect_true(has_element_class(
      ggplot2::calc_element("panel.grid.major.x", th), "element_blank"
    ))
  }
})

test_that("theme_hda flip_gridlines swaps major gridline orientation", {
  default <- theme_hda()
  flipped <- theme_hda(flip_gridlines = TRUE)
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.y", default), "element_line"))
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.x", default), "element_blank"))
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.x", flipped), "element_line"))
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.y", flipped), "element_blank"))
  expect_identical(
    ggplot2::calc_element("panel.grid.major.x", flipped)$colour, "#cbcdcc"
  )
})

test_that("theme_hfv flip_gridlines swaps major gridline orientation", {
  default <- theme_hfv()
  flipped <- theme_hfv(flip_gridlines = TRUE)
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.y", default), "element_line"))
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.x", default), "element_blank"))
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.x", flipped), "element_line"))
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.y", flipped), "element_blank"))
})

test_that("theme_hda passes ... through to ggplot2::theme()", {
  th <- theme_hda(legend.position = "bottom")
  expect_equal(th[["legend.position"]], "bottom")
})

test_that("theme_hfv passes ... through to ggplot2::theme()", {
  th <- theme_hfv(legend.position = "bottom")
  expect_equal(th[["legend.position"]], "bottom")
})

test_that("plot.title size is base_size * 1.25 for all themes", {
  expect_equal(ggplot2::calc_element("plot.title", theme_hda())$size, 14 * 1.25)
  expect_equal(ggplot2::calc_element("plot.title", theme_hfv())$size, 14 * 1.25)
  expect_equal(ggplot2::calc_element("plot.title", theme_pha())$size, 10 * 1.25)
})

test_that("plot.subtitle size is base_size * 1.125 for all themes", {
  expect_equal(ggplot2::calc_element("plot.subtitle", theme_hda())$size, 14 * 1.125)
  expect_equal(ggplot2::calc_element("plot.subtitle", theme_hfv())$size, 14 * 1.125)
  expect_equal(ggplot2::calc_element("plot.subtitle", theme_pha())$size, 10 * 1.125)
})
