test_that("exported color vectors equal .brands palette exactly", {
  expect_identical(hda_colors, hdatools:::.brands$hda$palette)
  expect_identical(hfv_colors, hdatools:::.brands$hfv$palette)
  expect_identical(pha_colors, hdatools:::.brands$pha$palette)
  expect_identical(vha_colors, hdatools:::.brands$vha$palette)
})

test_that("color vectors are named character vectors", {
  expect_type(hda_colors, "character")
  expect_type(hfv_colors, "character")
  expect_type(pha_colors, "character")
  expect_type(vha_colors, "character")
  expect_named(hda_colors)
  expect_named(hfv_colors)
  expect_named(pha_colors)
  expect_named(vha_colors)
})

test_that("hda_color() returns the correct hex for known names", {
  expect_identical(hda_color("Blue"),      c(Blue      = "#445ca9"))
  expect_identical(hda_color("Green"),     c(Green     = "#8baeaa"))
  expect_identical(hda_color("Sea Green"), c(`Sea Green` = "#8abc8e"))
})

test_that("hfv_color() returns the correct hex for known names", {
  expect_identical(hfv_color("Shadow"), c(Shadow = "#334a66"))
  expect_identical(hfv_color("Sky"),    c(Sky    = "#66cccc"))
  expect_identical(hfv_color("Desert"), c(Desert = "#ec7c53"))
})

test_that("pha_color() returns the correct hex for known names", {
  expect_identical(pha_color("Green"),      c(Green      = "#5bab8e"))
  expect_identical(pha_color("Light Blue"), c(`Light Blue` = "#a6cccc"))
  expect_identical(pha_color("Dark Blue"),  c(`Dark Blue`  = "#2b6b9c"))
})

test_that("vha_color() returns the correct hex for known names", {
  expect_identical(vha_color("Dark Turq"),  c(`Dark Turq` = "#0C4D4F"))
  expect_identical(vha_color("Yellow"),     c(Yellow      = "#ECC51E"))
  expect_identical(vha_color("Light Turq"), c(`Light Turq` = "#19787B"))
})

test_that("accessor errors on unknown name with valid names listed", {
  expect_error(hda_color("Magenta"), "valid HDA color name", fixed = FALSE)
  expect_error(hda_color("Magenta"), "Blue",                 fixed = FALSE)

  expect_error(hfv_color("Neon"),    "valid HFV color name", fixed = FALSE)
  expect_error(hfv_color("Neon"),    "Sky",                  fixed = FALSE)

  expect_error(pha_color("Gold"),    "valid PHA color name", fixed = FALSE)
  expect_error(pha_color("Gold"),    "Green",                fixed = FALSE)

  expect_error(vha_color("Magenta"), "valid VHA color name", fixed = FALSE)
  expect_error(vha_color("Magenta"), "Dark Turq",            fixed = FALSE)
})

test_that("accessor returns a named scalar", {
  result <- hda_color("Blue")
  expect_length(result, 1L)
  expect_identical(names(result), "Blue")
})

test_that("hda_colors works with scale_fill_manual without warning", {
  d <- data.frame(x = names(hda_colors)[1:3], y = 1:3, g = names(hda_colors)[1:3])
  expect_no_warning(
    ggplot2::ggplot_build(
      ggplot2::ggplot(d, ggplot2::aes(x, y, fill = g)) +
        ggplot2::geom_col() +
        ggplot2::scale_fill_manual(values = hda_colors)
    )
  )
})
