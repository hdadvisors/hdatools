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

test_that("scale_fill_vha maps palette hexes into the built plot", {
  d <- data.frame(x = letters[1:3], y = 1:3, g = letters[1:3])
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, fill = g)) +
      ggplot2::geom_col() + scale_fill_vha()
  )
  expect_identical(unique(bd$data[[1]]$fill), c("#0C4D4F", "#A0D18E", "#ECC51E"))
})

test_that("scale_color_vha(direction = -1) reverses colours in the built plot", {
  d <- data.frame(x = letters[1:3], y = 1:3, g = letters[1:3])
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, colour = g)) +
      ggplot2::geom_point() + scale_color_vha(direction = -1)
  )
  expect_identical(unique(bd$data[[1]]$colour), c("#ECC51E", "#A0D18E", "#0C4D4F"))
})

# --- Pre-refactor identity tests: series lengths, colour aesthetic, gradients ---

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

# --- Continuous/binned ramp scales (item 2.2, new in 0.4.0) ----------------

test_that("continuous sequential scales default to higher value = darker (dark = high convention)", {
  hda_c <- scale_color_hda_c()
  expect_identical(toupper(hda_c$palette(0)), "#F3F1E4")
  expect_identical(toupper(hda_c$palette(1)), "#0A388A")

  hfv_c <- scale_fill_hfv_c()
  expect_identical(toupper(hfv_c$palette(0)), "#F3F1E4")
  expect_identical(toupper(hfv_c$palette(1)), "#005000")

  pha_c <- scale_color_pha_c()
  expect_identical(toupper(pha_c$palette(0)), "#F3F1E4")
  expect_identical(toupper(pha_c$palette(1)), "#811C00")

  vha_c <- scale_color_vha_c()
  expect_identical(toupper(vha_c$palette(0)), "#F3F1E4")
  expect_identical(toupper(vha_c$palette(1)), "#00484A")
})

test_that("continuous diverging scales keep the ramp's own arm1 -> arm2 order", {
  hda_div <- scale_fill_hda_c(palette = "diverging")
  expect_identical(toupper(hda_div$palette(0)), "#00369B")
  expect_identical(toupper(hda_div$palette(1)), "#781C00")

  pha_div <- scale_color_pha_c(palette = "diverging")
  expect_identical(toupper(pha_div$palette(0)), "#00468E")
  expect_identical(toupper(pha_div$palette(1)), "#761E00")

  # VHA's diverging ramp is provisional (Yellow arm reads golden/olive, not
  # bright yellow, at l1 — see roxygen @section and plans/DECISIONS.md).
  vha_div <- scale_fill_vha_c(palette = "diverging")
  expect_identical(toupper(vha_div$palette(0)), "#00767B")
  expect_identical(toupper(vha_div$palette(1)), "#775C00")
})

test_that("direction = -1 reverses continuous scale endpoints", {
  hda_c <- scale_color_hda_c(direction = -1)
  expect_identical(toupper(hda_c$palette(0)), "#0A388A")
  expect_identical(toupper(hda_c$palette(1)), "#F3F1E4")

  hda_div <- scale_fill_hda_c(palette = "diverging", direction = -1)
  expect_identical(toupper(hda_div$palette(0)), "#781C00")
  expect_identical(toupper(hda_div$palette(1)), "#00369B")
})

test_that("continuous/binned scale na.value defaults are the brand greys, including HFV's new one", {
  expect_identical(scale_color_hda_c()$na.value, "#cfcfd0")
  expect_identical(scale_fill_hfv_c()$na.value, "#d6dadd")
  expect_identical(scale_color_pha_c()$na.value, "#e2e4e3")
  expect_identical(scale_color_vha_c()$na.value, "#d6dbdb")
  expect_identical(scale_fill_hda_b()$na.value, "#cfcfd0")
  expect_identical(scale_color_hfv_b()$na.value, "#d6dadd")
  expect_identical(scale_fill_pha_b()$na.value, "#e2e4e3")
  expect_identical(scale_fill_vha_b()$na.value, "#d6dbdb")
})

test_that("binned scales default to n.breaks = 7", {
  expect_identical(scale_color_hda_b()$n.breaks, 7)
  expect_identical(scale_fill_hfv_b()$n.breaks, 7)
  expect_identical(scale_color_pha_b(palette = "diverging")$n.breaks, 7)
  expect_identical(scale_color_vha_b()$n.breaks, 7)
})

test_that("palette argument validates and errors on an unknown value", {
  expect_error(scale_color_hda_c(palette = "not-a-palette"))
  expect_error(scale_fill_hfv_b(palette = "not-a-palette"))
  expect_error(scale_fill_vha_c(palette = "not-a-palette"))
})

test_that("scale_colour_*_c()/_b() aliases are identical to scale_color_*_c()/_b()", {
  expect_identical(scale_colour_hda_c, scale_color_hda_c)
  expect_identical(scale_colour_hfv_c, scale_color_hfv_c)
  expect_identical(scale_colour_pha_c, scale_color_pha_c)
  expect_identical(scale_colour_vha_c, scale_color_vha_c)
  expect_identical(scale_colour_hda_b, scale_color_hda_b)
  expect_identical(scale_colour_hfv_b, scale_color_hfv_b)
  expect_identical(scale_colour_pha_b, scale_color_pha_b)
  expect_identical(scale_colour_vha_b, scale_color_vha_b)
})

test_that("scale_colour_vha discrete alias is identical to scale_color_vha", {
  expect_identical(scale_colour_vha, scale_color_vha)
})

test_that("scale_fill_hda_c() maps a continuous variable into the built plot", {
  d <- data.frame(x = 1:3, y = 1:3, v = c(0, 50, 100))
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, fill = v)) +
      ggplot2::geom_tile() + scale_fill_hda_c()
  )
  fills <- toupper(bd$data[[1]]$fill)
  expect_identical(fills[1], "#F3F1E4")
  expect_identical(fills[3], "#0A388A")
})

test_that("scale_fill_hda_b() discretizes a continuous variable in the built plot", {
  d <- data.frame(x = 1:20, y = 1:20, v = seq(0, 100, length.out = 20))
  bd <- ggplot2::ggplot_build(
    ggplot2::ggplot(d, ggplot2::aes(x, y, fill = v)) +
      ggplot2::geom_tile() + scale_fill_hda_b()
  )
  n_classes <- length(unique(bd$data[[1]]$fill))
  expect_true(n_classes <= 8 && n_classes >= 5)
})

test_that("HFV palette includes the new Leaf and Cerulean colors", {
  expect_identical(unname(hfv_colors["Leaf"]), "#6fb547")
  expect_identical(unname(hfv_colors["Cerulean"]), "#7fc7e0")
})
