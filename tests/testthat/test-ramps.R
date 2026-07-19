# Pins .ramp_hex_sequential()/.ramp_hex_diverging() at n = 7 to the exact
# verified hex arrays in plans/ramp-lab/REVIEW.md (signed off 2026-07-18).
# These are the numbers the Ramp Lab review actually reviewed and CVD-checked
# — if one of these ever changes, it should be a deliberate ramp-lab decision,
# not an incidental side effect of touching R/brands.R or R/ramps.R.

test_that("HDA sequential ramp pins to the verified 7-class hex", {
  expect_identical(
    toupper(.ramp_hex_sequential("hda", 7)),
    c("#0A388A", "#006087", "#007D84", "#359784", "#81B090", "#BCCBAE", "#F3F1E4")
  )
})

test_that("HDA diverging ramp pins to the verified 7-class hex", {
  expect_identical(
    toupper(.ramp_hex_diverging("hda", 7)),
    c("#00369B", "#00828A", "#80B591", "#F3F1E4", "#BEA680", "#9A6330", "#781C00")
  )
})

test_that("HFV sequential ramp pins to the verified 7-class hex", {
  expect_identical(
    toupper(.ramp_hex_sequential("hfv", 7)),
    c("#005000", "#3D6800", "#678136", "#8C9B64", "#B0B68F", "#D2D3B9", "#F3F1E4")
  )
})

test_that("HFV diverging ramp pins to the verified 7-class hex", {
  expect_identical(
    toupper(.ramp_hex_diverging("hfv", 7)),
    c("#004C00", "#607B27", "#ABB186", "#F3F1E4", "#7BB9A9", "#5C71A7", "#81004D")
  )
})

test_that("PHA sequential ramp pins to the verified 7-class hex", {
  expect_identical(
    toupper(.ramp_hex_sequential("pha", 7)),
    c("#811C00", "#924500", "#A36831", "#B38A5A", "#C4AC84", "#D8CEB2", "#F3F1E4")
  )
})

test_that("PHA diverging ramp pins to the verified 7-class hex", {
  expect_identical(
    toupper(.ramp_hex_diverging("pha", 7)),
    c("#00468E", "#00827F", "#86B48F", "#F3F1E4", "#BDA682", "#996436", "#761E00")
  )
})

test_that(".ramp_hex() dispatches on palette type", {
  expect_identical(.ramp_hex("hda", "sequential", 7), .ramp_hex_sequential("hda", 7))
  expect_identical(.ramp_hex("hda", "diverging", 7), .ramp_hex_diverging("hda", 7))
})

test_that("ramp endpoints are stable across stop density (n = 7 vs n = 32)", {
  # colorspace::sequential_hcl()'s endpoints are always exactly the specified
  # h/c/l regardless of n, so the continuous scales' dense (n = 32) stops
  # share exact endpoints with the reviewed/pinned n = 7 hex above.
  seq7 <- .ramp_hex_sequential("hda", 7)
  seq32 <- .ramp_hex_sequential("hda", 32)
  expect_identical(seq7[1], seq32[1])
  expect_identical(seq7[7], seq32[32])

  div7 <- .ramp_hex_diverging("hda", 7)
  div32 <- .ramp_hex_diverging("hda", 32)
  expect_identical(div7[1], div32[1])
  expect_identical(div7[length(div7)], div32[length(div32)])
})
