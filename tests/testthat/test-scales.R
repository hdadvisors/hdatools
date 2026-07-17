test_that("discrete palettes return the exact brand hexes in order", {
  # *_pal_discrete() is soft-deprecated as of 0.3.0; this test asserts the
  # underlying values are unchanged, so the deprecation notice is expected
  # and not itself under test here.
  withr::local_options(lifecycle_verbosity = "quiet")
  expect_identical(
    hda_pal_discrete()(6),
    c("#445ca9", "#8baeaa", "#e9ab3f", "#e76f52", "#a97a92", "#8abc8e")
  )
  expect_identical(
    hfv_pal_discrete()(6),
    c("#334a66", "#66cccc", "#a29dd4", "#50aaa7", "#c0327e", "#ec7c53")
  )
  expect_identical(
    pha_pal_discrete()(6),
    c("#5bab8e", "#a6cccc", "#f39152", "#be451c", "#a5add0", "#2b6b9c")
  )
})

test_that("direction = -1 reverses discrete palettes", {
  withr::local_options(lifecycle_verbosity = "quiet")
  expect_identical(hda_pal_discrete(direction = -1)(6), rev(hda_pal_discrete()(6)))
  expect_identical(hfv_pal_discrete(direction = -1)(6), rev(hfv_pal_discrete()(6)))
  expect_identical(pha_pal_discrete(direction = -1)(6), rev(pha_pal_discrete()(6)))
})

test_that("repeat_pal recycles the palette past its length", {
  withr::local_options(lifecycle_verbosity = "quiet")
  out <- hda_pal_discrete(repeat_pal = TRUE)(8)
  base6 <- hda_pal_discrete()(6)
  expect_length(out, 8)
  expect_identical(out[1:6], base6)
  expect_identical(out[7:8], base6[1:2])
})

test_that("scale_fill_hda maps palette hexes into the built plot", {
  d <- data.frame(x = letters[1:3], y = 1:3, g = letters[1:3])
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, fill = g)) +
      ggplot2::geom_col() + scale_fill_hda()
  )
  expect_identical(unique(bd$data[[1]]$fill), c("#445ca9", "#8baeaa", "#e9ab3f"))
})

test_that("scale_fill_pha(direction = -1) reverses fills in the built plot", {
  d <- data.frame(x = letters[1:3], y = 1:3, g = letters[1:3])
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, fill = g)) +
      ggplot2::geom_col() + scale_fill_pha(direction = -1)
  )
  expect_identical(unique(bd$data[[1]]$fill), c("#f39152", "#a6cccc", "#5bab8e"))
})

# --- Pre-refactor identity tests: series lengths, colour aesthetic, gradients ---

test_that("discrete palettes return correct first-n hexes for n = 1 through 5", {
  withr::local_options(lifecycle_verbosity = "quiet")
  hda_full <- c("#445ca9", "#8baeaa", "#e9ab3f", "#e76f52", "#a97a92", "#8abc8e")
  hfv_full <- c("#334a66", "#66cccc", "#a29dd4", "#50aaa7", "#c0327e", "#ec7c53")
  pha_full <- c("#5bab8e", "#a6cccc", "#f39152", "#be451c", "#a5add0", "#2b6b9c")
  for (n in 1:5) {
    expect_identical(hda_pal_discrete()(n), hda_full[1:n])
    expect_identical(hfv_pal_discrete()(n), hfv_full[1:n])
    expect_identical(pha_pal_discrete()(n), pha_full[1:n])
  }
})

test_that("scale_fill_hda(-1) positional direction reverses fills (faar idiom)", {
  d <- data.frame(x = letters[1:3], y = 1:3, g = letters[1:3])
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, fill = g)) +
      ggplot2::geom_col() + scale_fill_hda(-1)
  )
  expect_identical(unique(bd$data[[1]]$fill), c("#e9ab3f", "#8baeaa", "#445ca9"))
})

test_that("scale_fill_hfv maps palette hexes into the built plot", {
  d <- data.frame(x = letters[1:3], y = 1:3, g = letters[1:3])
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, fill = g)) +
      ggplot2::geom_col() + scale_fill_hfv()
  )
  expect_identical(unique(bd$data[[1]]$fill), c("#334a66", "#66cccc", "#a29dd4"))
})

test_that("scale_color_hda maps palette hexes into the built plot", {
  d <- data.frame(x = letters[1:3], y = 1:3, g = letters[1:3])
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g)) +
      ggplot2::geom_point() + scale_color_hda()
  )
  expect_identical(unique(bd$data[[1]]$colour), c("#445ca9", "#8baeaa", "#e9ab3f"))
})

test_that("scale_color_hfv maps palette hexes into the built plot", {
  d <- data.frame(x = letters[1:3], y = 1:3, g = letters[1:3])
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g)) +
      ggplot2::geom_point() + scale_color_hfv()
  )
  expect_identical(unique(bd$data[[1]]$colour), c("#334a66", "#66cccc", "#a29dd4"))
})

test_that("scale_color_pha maps palette hexes into the built plot", {
  d <- data.frame(x = letters[1:3], y = 1:3, g = letters[1:3])
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g)) +
      ggplot2::geom_point() + scale_color_pha()
  )
  expect_identical(unique(bd$data[[1]]$colour), c("#5bab8e", "#a6cccc", "#f39152"))
})

test_that("gradient scale palette endpoints are the brand anchor colours", {
  withr::local_options(lifecycle_verbosity = "quiet")
  hda_g <- scale_color_gradient_hda()
  expect_identical(tolower(hda_g$palette(0)), "#445ca9")
  expect_identical(tolower(hda_g$palette(1)), "#e76f52")

  pha_color_g <- scale_color_gradient_pha()
  expect_identical(tolower(pha_color_g$palette(0)), "#5bab8e")
  expect_identical(tolower(pha_color_g$palette(1)), "#be451c")

  pha_fill_g <- scale_fill_gradient_pha()
  expect_identical(tolower(pha_fill_g$palette(0)), "#5bab8e")
  expect_identical(tolower(pha_fill_g$palette(1)), "#be451c")
})

test_that("gradient scale na.value defaults are the brand greys", {
  withr::local_options(lifecycle_verbosity = "quiet")
  expect_identical(scale_color_gradient_hda()$na.value, "#cfcfd0")
  expect_identical(scale_color_gradient_pha()$na.value, "#e2e4e3")
  expect_identical(scale_fill_gradient_pha()$na.value, "#e2e4e3")
})

# --- scale_colour_*() aliases (item 1.4, new in 0.3.0) ---

test_that("scale_colour_*() discrete aliases are identical to scale_color_*()", {
  expect_identical(scale_colour_hda, scale_color_hda)
  expect_identical(scale_colour_hfv, scale_color_hfv)
  expect_identical(scale_colour_pha, scale_color_pha)
})

test_that("scale_colour_*() discrete aliases map palette hexes into the built plot", {
  d <- data.frame(x = letters[1:3], y = 1:3, g = letters[1:3])
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g)) +
      ggplot2::geom_point() + scale_colour_hda()
  )
  expect_identical(unique(bd$data[[1]]$colour), c("#445ca9", "#8baeaa", "#e9ab3f"))
})

test_that("scale_colour_gradient_*() aliases are identical to scale_color_gradient_*()", {
  expect_identical(scale_colour_gradient_hda, scale_color_gradient_hda)
  expect_identical(scale_colour_gradient_pha, scale_color_gradient_pha)
})
