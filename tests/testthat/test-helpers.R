test_that("adjust_base_size subtracts the format-specific amount", {
  expect_equal(adjust_base_size(12, 2, 5, "html"), 10)
  expect_equal(adjust_base_size(12, 2, 5, "pdf"), 7)
  expect_equal(adjust_base_size(12, 2, 5, "studio"), 12)
  expect_equal(adjust_base_size(12, 2, 5, "anything-else"), 12)
})

test_that("markdown_wrap_gen wraps text and converts newlines to <br>", {
  f <- markdown_wrap_gen(width = 5)
  out <- unlist(f("one two three"))
  expect_true(any(grepl("<br>", out)))
  expect_false(any(grepl("\n", out)))
})

test_that("get_output_format honors a manual override", {
  expect_equal(get_output_format("pdf"), "pdf")
  expect_equal(get_output_format("html"), "html")
})

test_that("get_output_format returns studio outside a knitr render", {
  withr::local_options(knitr.in.progress = NULL)
  expect_equal(get_output_format(), "studio")
})

test_that("add_zero_line draws a line at the expected linewidth and colour", {
  d <- data.frame(x = letters[1:3], y = 1:3)
  bd <- suppressWarnings(ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y)) +
      ggplot2::geom_point() + add_zero_line("y")
  ))
  layer <- bd$data[[2]]
  expect_equal(unique(layer$linewidth), 0.5)
  expect_equal(unique(layer$colour), "#4b4f50")
})

test_that("flip_gridlines applies linewidth to the vertical gridlines", {
  full <- suppressWarnings(theme_hda()) + flip_gridlines(linewidth = 0.2)
  expect_equal(ggplot2::calc_element("panel.grid.major.x", full)$linewidth, 0.2)
  expect_true(has_element_class(
    ggplot2::calc_element("panel.grid.major.y", full), "element_blank"
  ))
})

test_that("flip_gridlines(size=) warns but still applies the value", {
  withr::local_options(lifecycle_verbosity = "warning")
  expect_warning(
    th <- flip_gridlines(size = 0.2),
    class = "lifecycle_warning_deprecated"
  )
  full <- suppressWarnings(theme_hda()) + th
  expect_equal(ggplot2::calc_element("panel.grid.major.x", full)$linewidth, 0.2)
})

test_that("publish_plot returns the plot unchanged outside HTML output", {
  withr::local_options(knitr.in.progress = NULL)
  p <- ggplot2::ggplot(data.frame(x = 1:3, y = 1:3), ggplot2::aes(x, y)) +
    ggplot2::geom_point()
  expect_identical(publish_plot(p), p)
})

test_that("fct_case_when orders levels by first appearance", {
  x <- c(0.1, 0.4, 0.7)
  f <- fct_case_when(
    x < 0.3 ~ "Low",
    x < 0.5 ~ "Mid",
    x >= 0.5 ~ "High"
  )
  expect_s3_class(f, "factor")
  expect_identical(levels(f), c("Low", "Mid", "High"))
  expect_identical(as.character(f), c("Low", "Mid", "High"))
})

test_that("fct_case_when reverses levels with dir = -1 and dedups", {
  x <- c(0.1, 0.4, 0.7, 0.8)
  f <- fct_case_when(
    x < 0.3 ~ "Low",
    x < 0.5 ~ "Mid",
    x >= 0.5 ~ "High",
    dir = -1
  )
  expect_identical(levels(f), c("High", "Mid", "Low"))
})
