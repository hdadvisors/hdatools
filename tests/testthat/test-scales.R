test_that("discrete palettes return the exact brand hexes in order", {
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
  expect_identical(hda_pal_discrete(direction = -1)(6), rev(hda_pal_discrete()(6)))
  expect_identical(hfv_pal_discrete(direction = -1)(6), rev(hfv_pal_discrete()(6)))
  expect_identical(pha_pal_discrete(direction = -1)(6), rev(pha_pal_discrete()(6)))
})

test_that("repeat_pal recycles the palette past its length", {
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
