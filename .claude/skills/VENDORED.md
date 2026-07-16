# Vendored skills

These skill folders are copied verbatim from
[posit-dev/skills](https://github.com/posit-dev/skills) (MIT licensed), pinned to
the `main` branch as of vendoring on 2026-07-16:

- `create-release-checklist/` — Aaron Jacobs (@atheriel). Generates an R-package
  release checklist and files it as a GitHub issue.
- `r-package-development/` — Simon P. Couch (@simonpcouch). The devtools /
  roxygen2 / testthat development loop.
- `testing-r-packages/` — Garrick Aden-Buie. testthat 3e conventions, fixtures,
  mocking, and snapshots.

**Local override:** these skills assume R is on PATH and use inline `Rscript -e`.
In this repo R is not on PATH and inline execution is unreliable — follow the
temp-file convention in the repo `CLAUDE.md` instead.

To update: re-download from the upstream repo. Do not hand-edit vendored files.
