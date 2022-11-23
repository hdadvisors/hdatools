.onLoad <- function(libname, pkgname) {
  packageStartupMessage("Loading on-brand Google fonts")
  add_google_fonts()
}
