test_that("focus palettes return a character vector of length n", {
  expect_length(hda_focus_pal("Blue",      n = 5), 5L)
  expect_length(hfv_focus_pal("Shadow",    n = 3), 3L)
  expect_length(pha_focus_pal("Green",     n = 4), 4L)
  expect_length(vha_focus_pal("Dark Turq", n = 6), 6L)
  expect_type(hda_focus_pal("Blue", n = 4), "character")
})

test_that("focus palette first element matches the brand color accessor", {
  expect_identical(hda_focus_pal("Blue",      n = 3)[[1]], unname(hda_color("Blue")))
  expect_identical(hfv_focus_pal("Sky",       n = 3)[[1]], unname(hfv_color("Sky")))
  expect_identical(pha_focus_pal("Orange",    n = 3)[[1]], unname(pha_color("Orange")))
  expect_identical(vha_focus_pal("Yellow",    n = 3)[[1]], unname(vha_color("Yellow")))
})

test_that("focus palette muted elements equal the brand na_color", {
  pal <- hda_focus_pal("Blue", n = 4)
  expect_identical(pal[-1], rep(hdatools:::.brands$hda$na_color, 3L))

  pal <- hfv_focus_pal("Shadow", n = 4)
  expect_identical(pal[-1], rep(hdatools:::.brands$hfv$na_color, 3L))

  pal <- pha_focus_pal("Green", n = 4)
  expect_identical(pal[-1], rep(hdatools:::.brands$pha$na_color, 3L))

  pal <- vha_focus_pal("Dark Turq", n = 4)
  expect_identical(pal[-1], rep(hdatools:::.brands$vha$na_color, 3L))
})

test_that("focus palette with n = 1 returns just the focus color", {
  pal <- hda_focus_pal("Green", n = 1)
  expect_length(pal, 1L)
  expect_identical(pal[[1]], unname(hda_color("Green")))
})

test_that("focus palette errors on invalid color name", {
  expect_snapshot(hda_focus_pal("Magenta", n = 3), error = TRUE)
  expect_snapshot(hfv_focus_pal("Neon",    n = 3), error = TRUE)
  expect_snapshot(pha_focus_pal("Gold",    n = 3), error = TRUE)
  expect_snapshot(vha_focus_pal("Magenta", n = 3), error = TRUE)
})

test_that("focus palette errors on invalid n", {
  expect_snapshot(hda_focus_pal("Blue", n = 0),    error = TRUE)
  expect_snapshot(hda_focus_pal("Blue", n = -1),   error = TRUE)
  expect_snapshot(hda_focus_pal("Blue", n = "two"), error = TRUE)
})
