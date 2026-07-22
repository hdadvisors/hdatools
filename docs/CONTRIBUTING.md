# Contributing to hdatools

`hdatools` is a proprietary R package. External contributions are by
invitation only. This file is the working guide for Jonathan and any
collaborators (including Maria) picking up the codebase.

## Getting started (new contributor)

1.  **Clone and open in RStudio** (or any editor):

    ``` bash
    git clone https://github.com/hdadvisors/hdatools.git
    cd hdatools
    ```

2.  **Install R dependencies** — from an R console at the repo root:

    ``` r

    install.packages("pak")
    pak::local_install_dev_deps()
    ```

    This installs everything in `DESCRIPTION` (Imports + Suggests) plus
    devtools, roxygen2, and pkgdown.

3.  **Run the dev loop** to confirm everything is green before touching
    code — see [The dev loop](#the-dev-loop) below.

4.  **Read
    [`CLAUDE.md`](https://hdadvisors.github.io/hdatools/CLAUDE.md).**
    It’s authoritative for conventions. Never hand-edit generated files
    (`NAMESPACE`, `man/`, `docs/`). The release checklist lives there.

5.  **Read
    [`plans/DECISIONS.md`](https://hdadvisors.github.io/hdatools/plans/DECISIONS.md)**
    — every settled design decision. Don’t re-litigate. If
    implementation contradicts a decision, raise it explicitly.

## The dev loop

Run these in order after changing R source or roxygen comments:

1.  [`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
    — regenerates `NAMESPACE` and `man/*.Rd`.
2.  [`devtools::test()`](https://devtools.r-lib.org/reference/test.html)
    — full testthat suite (edition 3).
3.  [`devtools::check()`](https://devtools.r-lib.org/reference/check.html)
    — `R CMD check`. Target: **0 errors, 0 warnings**. The only accepted
    NOTE is the proprietary-license one. See `CLAUDE.md` for
    cloud-session NOTE exceptions.
4.  [`pkgdown::build_site()`](https://pkgdown.r-lib.org/reference/build_site.html)
    — rebuilds `docs/`. See `CLAUDE.md` for the Pandoc gotcha on local
    machines and the partial-rebuild shortcut.

Never run R inline (`Rscript -e "..."`). Write a temp file and run it:

``` bash
Rscript /path/to/script.R 2>&1
```

## Commit message convention

Commit messages follow a lightweight Conventional Commits shape:
`type(scope): subject`.

**Type** — one of:

| Type | Use for |
|----|----|
| `feat` | A new capability or exported function |
| `fix` | A bug fix |
| `docs` | Documentation only — README, CLAUDE.md, roxygen, vignettes, pkgdown |
| `chore` | Maintenance, cleanup, dependency bumps, internal-only refactors |
| `test` | Test-only changes |
| `refactor` | Internal restructuring with no behavior change |
| `perf` | Performance improvement with no behavior change |
| `release` | Version bump and release housekeeping — `DESCRIPTION` version, `NEWS.md` heading move, tag |

**Scope** — the functional area touched, in parentheses: `themes`,
`scales`, `fonts`, `colors`, `docs`, `ci`, or similar. Omit the scope if
a change is too broad to name one area.

**Subject** — imperative mood, no trailing period,
e.g. `fix(scales): correct diverging ramp midpoint`. Reference an issue
number in the body when one exists (`Closes #24`).

This is a convention checked in PR review, not enforced by tooling — no
commit-msg linter, no CI gate. It exists to make `git log`/`git blame`
scannable by type and area. It does not drive version bumps or changelog
generation. NEWS.md entries and version numbers are still decided by
hand (see below).

## Versioning & releases

**Version numbers** follow [SemVer](https://semver.org/) with R
conventions:

| Bump | When |
|----|----|
| `PATCH` (`0.5.1`) | Fixes, docs, cleanup — no API or output change |
| `MINOR` (`0.6.0`) | New capability, or backward-compatible behavior change (fhfh surface intact) |
| `MAJOR` (`1.0.0`) | Reserved — fhfh-surface break or explicit “stable” signal |

semver.org itself allows any breaking change in a `0.y.z` release. Under
strict SemVer, hdatools could break the fhfh surface tomorrow and still
call it `0.6.0`. hdatools doesn’t do that. The `MAJOR` row above is a
deliberate, stricter-than-spec choice, in force since the fhfh-surface
contract was set (`plans/DECISIONS.md`, 2026-07-16). Treat 0.x as
already carrying a 1.0-level stability commitment for the fhfh surface
specifically. Everything else may still evolve through soft-deprecation.

**`1.0.0` bar** — cut `1.0.0` once both hold:

- A full quarter has passed on a tagged 0.x release with zero
  fhfh-surface-breaking changes needed.
- HDA’s and VHA’s currently-provisional diverging ramps (issues \#24,
  \#25) are finalized, so no export ships with a “provisional” caveat.

Until then, 0.x releases continue on the table above.

Between releases, `DESCRIPTION` carries a four-component dev version
like `0.5.0.9000`. The `.9000` suffix means “development state after
0.5.0.” Bump the suffix (`.9001`, `.9002`, …) mid-cycle when a
meaningful user-facing chunk lands. This keeps
[`sessionInfo()`](https://rdrr.io/r/utils/sessionInfo.html) unambiguous
when debugging a consumer.

**Release = annotated tag + GitHub Release**, with the relevant NEWS
section as the release notes. The full release checklist is in
[`CLAUDE.md`](https://hdadvisors.github.io/hdatools/CLAUDE.html#release-checklist).
Follow it exactly. Don’t skip steps.

### Release-when-ready flow

There are no fixed milestones. Ship a release when:

- The work in the current dev cycle is complete and tested, **or**
- A consumer needs a specific fix or feature and it’s clean enough to
  tag.

Follow this sequence:

1.  Branch off `main` for the work.
2.  Open a PR when ready for a final check.
3.  Merge to `main` after CI passes and the release checklist is
    satisfied.
4.  Tag and create the GitHub Release from the merged commit.

Consumer rollout (bumping the pin in pha-update-2026, fhfh, etc.)
happens in those repos’ own sessions — never as a drive-by. See
[`plans/consumer-rollout.md`](https://hdadvisors.github.io/hdatools/plans/consumer-rollout.md)
for the reusable procedure.

## NEWS, tests, and docs rules

**NEWS.md** — every user-facing change gets a bullet under
`# hdatools (development version)` in the same session it lands. Never
reconstruct at release time. Verified claim-by-claim at release
(checklist step 3). Group bullets under `## Breaking Changes` /
`## Removed` / `## Deprecated` / `## Features` / `## Bug Fixes` /
`## Documentation` / `## Internal` — include only the headings a release
actually needs, in that order. This groups by the same `type` taxonomy
as the commit convention above, so a release’s shape is legible at a
glance.

**Tests** — `CLAUDE.md`’s testing conventions apply verbatim: a red test
is a finding about the code, not the test. Never modify a test to make
it pass. Fix the code, or change the test deliberately and say so.
Snapshots are reviewed
([`testthat::snapshot_review()`](https://testthat.r-lib.org/reference/snapshot_accept.html))
before accepting — never blanket-accept.

**Docs** — roxygen, README, and pkgdown updates land in the same session
as the code they document.
[`devtools::document()`](https://devtools.r-lib.org/reference/document.html)
runs before every commit that touches roxygen comments. Everything under
`docs/` and `man/` is generated — never hand-edit.

## Filing issues

Use GitHub Issues as the primary tracker. Before opening an issue:

- Check open issues for duplicates.
- For design decisions (ramp parameters, palette choices, API shape),
  check
  [`plans/DECISIONS.md`](https://hdadvisors.github.io/hdatools/plans/DECISIONS.md).
  Settled decisions are not re-litigated unless implementation surfaces
  a real contradiction.

Issue templates are in
[`.github/ISSUE_TEMPLATE/`](https://hdadvisors.github.io/hdatools/.github/ISSUE_TEMPLATE/):
**bug** for incorrect output or errors, **feature/enhancement** for new
capabilities or behavior changes, **chore** for maintenance and cleanup,
**docs** for a documentation gap, and **design-decision** for a design
call that needs to be settled before coding.

Label guide:

| Label             | Use for                                         |
|-------------------|-------------------------------------------------|
| `bug`             | Incorrect output, errors, or regressions        |
| `enhancement`     | Improvement to existing behavior                |
| `feature`         | New capability                                  |
| `chore`           | Maintenance, cleanup, internal-only             |
| `docs`            | Documentation only                              |
| `design-decision` | Requires a deliberate design call before coding |
