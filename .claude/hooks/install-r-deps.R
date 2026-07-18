# Installs hdatools' R dev toolchain for a Claude Code on the web session.
# Called from session-start.sh after system packages (r-base, pandoc, and
# the compiled-package system libs) are in place.

repos <- c(
  P3M = "https://packagemanager.posit.co/cran/__linux__/noble/latest",
  CRAN = "https://cloud.r-project.org"
)
options(repos = repos)

if (!requireNamespace("devtools", quietly = TRUE)) {
  install.packages("devtools")
}

# Installs DESCRIPTION's Imports/Depends/Suggests plus devtools' own
# recommended tooling (roxygen2, testthat, etc.).
devtools::install_dev_deps(dependencies = TRUE, upgrade = "never")

# Used by the release checklist (CLAUDE.md) but not declared in DESCRIPTION.
extra <- c("pkgdown", "urlchecker", "spelling")
missing <- extra[!vapply(extra, requireNamespace, logical(1), quietly = TRUE)]
if (length(missing) > 0) {
  install.packages(missing)
}
