test_that("span helpers return correct HTML string", {
  expect_identical(hda_span("hello", "Blue"),
                   "<span style='color:#445ca9'>hello</span>")
  expect_identical(hfv_span("hello", "Shadow"),
                   "<span style='color:#334a66'>hello</span>")
  expect_identical(pha_span("hello", "Green"),
                   "<span style='color:#5bab8e'>hello</span>")
  expect_identical(vha_span("hello", "Dark Turq"),
                   "<span style='color:#0C4D4F'>hello</span>")
})

test_that("span helpers embed brand hex from the accessor", {
  expect_identical(
    hda_span("x", "Sea Green"),
    sprintf("<span style='color:%s'>x</span>", unname(hda_color("Sea Green")))
  )
  expect_identical(
    hfv_span("x", "Sky"),
    sprintf("<span style='color:%s'>x</span>", unname(hfv_color("Sky")))
  )
  expect_identical(
    pha_span("x", "Dark Blue"),
    sprintf("<span style='color:%s'>x</span>", unname(pha_color("Dark Blue")))
  )
  expect_identical(
    vha_span("x", "Yellow"),
    sprintf("<span style='color:%s'>x</span>", unname(vha_color("Yellow")))
  )
})

test_that("span helpers return a length-1 character string", {
  result <- hda_span("text", "Blue")
  expect_type(result, "character")
  expect_length(result, 1L)
})

test_that("span helpers error on unknown color name", {
  expect_snapshot(hda_span("x", "Magenta"), error = TRUE)
  expect_snapshot(hfv_span("x", "Neon"),    error = TRUE)
  expect_snapshot(pha_span("x", "Gold"),    error = TRUE)
  expect_snapshot(vha_span("x", "Magenta"), error = TRUE)
})
