# Installs hdatools' R dev toolchain for a Claude Code on the web session.
# Called from session-start.sh after system packages (r-base, pandoc, and
# the compiled-package system libs) are in place.

# Posit Package Manager's index is reachable but its package downloads
# redirect to a separate backend host, and R doesn't retry a failed
# per-package download against the next listed repo — so a second repo here
# doesn't add resilience, only a different single point of failure. Plain
# CRAN alone is proven to work end to end (source builds, no redirects).
options(repos = c(CRAN = "https://cloud.r-project.org"))

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
