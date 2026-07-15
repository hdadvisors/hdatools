# Structural theme checks that hold on both pre- and post-Tier-1 code. Themes are
# constructed under suppressWarnings() because pre-Tier-1 code still emits the
# `size=` deprecation warning; the structural expectations here are unaffected by
# that migration.

test_that("theme_hda applies the (studio) base size to text", {
  th <- suppressWarnings(theme_hda(base_size = 20))
  expect_equal(ggplot2::calc_element("text", th)$size, 20)
})

test_that("theme_hfv applies the (studio) base size to text", {
  th <- suppressWarnings(theme_hfv(base_size = 20))
  expect_equal(ggplot2::calc_element("text", th)$size, 20)
})

test_that("theme_hda and theme_hfv use element_markdown for strip text", {
  expect_true(has_element_class(
    ggplot2::calc_element("strip.text", suppressWarnings(theme_hda())),
    "element_markdown"
  ))
  expect_true(has_element_class(
    ggplot2::calc_element("strip.text", suppressWarnings(theme_hfv())),
    "element_markdown"
  ))
})

test_that("theme_pha applies base_size to text, including under knitr", {
  expect_equal(
    ggplot2::calc_element("text", suppressWarnings(theme_pha(base_size = 60)))$size,
    60
  )
  withr::local_options(knitr.in.progress = TRUE)
  expect_equal(
    ggplot2::calc_element("text", suppressWarnings(theme_pha(base_size = 60)))$size,
    60
  )
})
