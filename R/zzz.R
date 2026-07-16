.onLoad <- function(libname, pkgname) {
  register_hda_fonts(quiet = TRUE)
}

.onAttach <- function(libname, pkgname) {
  packageStartupMessage("Loading on-brand fonts")
}
