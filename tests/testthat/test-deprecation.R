# Regression guard: the themes, scales, and helpers must use no deprecated
# ggplot2 idioms (e.g. `size=` on elements/geoms, positional `scale_name`).
# Running under `lifecycle_verbosity = "error"` turns any such idiom into a hard
# error, and unlike deprecation *warnings* these errors are not subject to
# lifecycle's once-per-session frequency gating, so each check fires every time.

test_that("themes use no deprecated ggplot2 idioms", {
  withr::local_options(lifecycle_verbosity = "error")
  expect_no_error(theme_hda(), class = "lifecycle_error_deprecated")
  expect_no_error(theme_hfv(), class = "lifecycle_error_deprecated")
  expect_no_error(theme_pha(), class = "lifecycle_error_deprecated")
})

test_that("discrete scales use no deprecated ggplot2 idioms", {
  withr::local_options(lifecycle_verbosity = "error")
  expect_no_error(scale_fill_hda(), class = "lifecycle_error_deprecated")
  expect_no_error(scale_fill_hfv(), class = "lifecycle_error_deprecated")
  expect_no_error(scale_fill_pha(), class = "lifecycle_error_deprecated")
  expect_no_error(scale_color_hda(), class = "lifecycle_error_deprecated")
  expect_no_error(scale_color_hfv(), class = "lifecycle_error_deprecated")
  expect_no_error(scale_color_pha(), class = "lifecycle_error_deprecated")
})

test_that("gradient scales use no deprecated ggplot2 idioms", {
  withr::local_options(lifecycle_verbosity = "error")
  # Call the internal constructor directly: the exported scale_*_gradient_*()
  # wrappers are themselves soft-deprecated as of 0.3.0 (see test-scales.R), so
  # calling them here would trip this guard on our own deprecation notice
  # instead of a ggplot2-idiom regression.
  expect_no_error(
    .scale_brand_gradient("color", .brands$hda$gradient, NULL, "Lab", .brands$hda$na_color, "colorbar"),
    class = "lifecycle_error_deprecated"
  )
  expect_no_error(
    .scale_brand_gradient("color", .brands$pha$gradient, NULL, "Lab", .brands$pha$na_color, "colorbar"),
    class = "lifecycle_error_deprecated"
  )
  expect_no_error(
    .scale_brand_gradient("fill", .brands$pha$gradient, NULL, "Lab", .brands$pha$na_color, "colorbar"),
    class = "lifecycle_error_deprecated"
  )
})

test_that("theme helpers use no deprecated ggplot2 idioms", {
  withr::local_options(lifecycle_verbosity = "error")
  expect_no_error(flip_gridlines(), class = "lifecycle_error_deprecated")

  d <- data.frame(x = letters[1:3], y = 1:3)
  expect_no_error(
    ggplot2::ggplot_build(
      ggplot2::ggplot(d, ggplot2::aes(x, y)) +
        ggplot2::geom_point() + add_zero_line("y")
    ),
    class = "lifecycle_error_deprecated"
  )
  expect_no_error(
    ggplot2::ggplot_build(
      ggplot2::ggplot(d, ggplot2::aes(x, y)) +
        ggplot2::geom_point() + add_zero_line("x")
    ),
    class = "lifecycle_error_deprecated"
  )
})

test_that("exercised consumer surface builds with no deprecated idioms", {
  withr::local_options(lifecycle_verbosity = "error")
  d <- data.frame(x = letters[1:3], y = 1:3, g = letters[1:3])

  p1 <- ggplot2::ggplot(d, ggplot2::aes(x, y, fill = g)) +
    ggplot2::geom_col() +
    scale_fill_hda() +
    add_zero_line("y") +
    theme_hda(flip_gridlines = TRUE)
  expect_no_error(ggplot2::ggplot_build(p1), class = "lifecycle_error_deprecated")

  p2 <- ggplot2::ggplot(d, ggplot2::aes(x, y, fill = g)) +
    ggplot2::geom_col() +
    scale_fill_pha(direction = -1) +
    theme_pha(base_size = 10)
  expect_no_error(ggplot2::ggplot_build(p2), class = "lifecycle_error_deprecated")
})
