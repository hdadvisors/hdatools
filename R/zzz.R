.hdatools_fonts_registered <- FALSE

.onLoad <- function(libname, pkgname) {
  .hdatools_fonts_registered <<- isTRUE(register_hda_fonts(quiet = TRUE))
}

.onAttach <- function(libname, pkgname) {
  if (.hdatools_fonts_registered) {
    packageStartupMessage("hdatools: registered on-brand fonts.")
  }
}
