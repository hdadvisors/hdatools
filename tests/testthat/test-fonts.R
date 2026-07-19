# register_hda_fonts() reads only files installed with the package, so these
# tests never make a network request (release plan, Verification §6).

test_that("the bundled font files ship with the package", {
  files <- list(
    c("lato",        "Lato-Regular.ttf"),
    c("lato",        "Lato-Bold.ttf"),
    c("lato",        "Lato-Italic.ttf"),
    c("roboto-slab", "RobotoSlab-Regular.ttf"),
    c("roboto-slab", "RobotoSlab-Bold.ttf"),
    c("open-sans",   "OpenSans-Regular.ttf"),
    c("open-sans",   "OpenSans-Bold.ttf"),
    c("open-sans",   "OpenSans-Italic.ttf"),
    c("poppins",     "Poppins-Regular.ttf"),
    c("poppins",     "Poppins-SemiBold.ttf"),
    c("noto-sans",   "NotoSans-Regular.ttf"),
    c("noto-sans",   "NotoSans-Bold.ttf"),
    c("noto-sans",   "NotoSans-Italic.ttf"),
    c("montserrat",  "Montserrat-Regular.ttf"),
    c("montserrat",  "Montserrat-SemiBold.ttf")
  )
  for (f in files) {
    path <- system.file("fonts", f[[1]], f[[2]], package = "hdatools")
    expect_true(nzchar(path), info = paste(f[[1]], f[[2]]))
    expect_true(file.exists(path), info = paste(f[[1]], f[[2]]))
  }
})

test_that("register_hda_fonts() registers the six bundled families offline", {
  expect_true(register_hda_fonts(quiet = TRUE))
  fams <- sysfonts::font_families()
  for (family in c("Lato", "Roboto Slab", "Open Sans", "Poppins", "Noto Sans", "Montserrat")) {
    expect_true(family %in% fams, info = family)
  }
})

test_that("register_hda_fonts() opt-out via option returns FALSE", {
  withr::local_options(hdatools.fonts = FALSE)
  expect_false(register_hda_fonts(quiet = TRUE))
})

test_that("register_hda_fonts() opt-out via env var returns FALSE", {
  withr::local_envvar(HDATOOLS_NO_FONTS = "1")
  expect_false(register_hda_fonts(quiet = TRUE))
})
