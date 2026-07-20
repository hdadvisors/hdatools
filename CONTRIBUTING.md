# Contributing to hdatools

`hdatools` is a proprietary R package. External contributions are by invitation
only. This file is the working guide for Jonathan and any collaborators
(including Maria) picking up the codebase.

## Getting started (new contributor)

1. **Clone and open in RStudio** (or any editor):
   ```bash
   git clone https://github.com/hdadvisors/hdatools.git
   cd hdatools
   ```
2. **Install R dependencies** — from an R console at the repo root:
   ```r
   install.packages("pak")
   pak::local_install_dev_deps()
   ```
   This installs everything in `DESCRIPTION` (Imports + Suggests) plus
   devtools, roxygen2, and pkgdown.
3. **Run the dev loop** to confirm everything is green before touching code —
   see [The dev loop](#the-dev-loop) below.
4. **Read [`CLAUDE.md`](CLAUDE.md)** — authoritative for conventions, never
   hand-edit generated files (`NAMESPACE`, `man/`, `docs/`), and the release
   checklist lives there.
5. **Read [`plans/DECISIONS.md`](plans/DECISIONS.md)** — every settled design
   decision. Don't re-litigate; if implementation contradicts a decision, raise
   it explicitly.

## The dev loop

Run these in order after changing R source or roxygen comments:

1. `devtools::document()` — regenerates `NAMESPACE` and `man/*.Rd`.
2. `devtools::test()` — full testthat suite (edition 3).
3. `devtools::check()` — `R CMD check`. Target: **0 errors, 0 warnings**.
   The only accepted NOTE is the proprietary-license one. See `CLAUDE.md` for
   cloud-session NOTE exceptions.
4. `pkgdown::build_site()` — rebuilds `docs/`. See `CLAUDE.md` for the Pandoc
   gotcha on local machines and the partial-rebuild shortcut.

Never run R inline (`Rscript -e "..."`). Write a temp file and run it:
```bash
Rscript /path/to/script.R 2>&1
```

## Versioning & releases

**Version numbers** follow [SemVer](https://semver.org/) with R conventions:

| Bump | When |
|---|---|
| `PATCH` (`0.5.1`) | Fixes, docs, cleanup — no API or output change |
| `MINOR` (`0.6.0`) | New capability, or backward-compatible behavior change (fhfh surface intact) |
| `MAJOR` (`1.0.0`) | Reserved — fhfh-surface break or explicit "stable" signal |

Between releases, `DESCRIPTION` carries a four-component dev version like
`0.5.0.9000`. The `.9000` suffix means "development state after 0.5.0"; bump
the suffix (`.9001`, `.9002`, …) mid-cycle when a meaningful user-facing chunk
lands, so `sessionInfo()` is unambiguous when debugging a consumer.

**Release = annotated tag + GitHub Release**, with the relevant NEWS section
as the release notes. The full release checklist is in
[`CLAUDE.md`](CLAUDE.md#release-checklist) — follow it exactly, don't skip
steps.

### Release-when-ready flow

There are no fixed milestones. Ship a release when:

- The work in the current dev cycle is complete and tested, **or**
- A consumer needs a specific fix or feature and it's clean enough to tag.

Branch off `main` for the work, open a PR when ready for a final check, merge
to `main` after CI passes and the release checklist is satisfied, then tag and
create the GitHub Release from the merged commit.

Consumer rollout (bumping the pin in pha-update-2026, fhfh, etc.) happens in
those repos' own sessions — never as a drive-by. See
[`plans/consumer-rollout.md`](plans/consumer-rollout.md) for the reusable
procedure.

## NEWS, tests, and docs rules

**NEWS.md** — every user-facing change gets a bullet under
`# hdatools (development version)` in the same session it lands. Never
reconstruct at release time. Verified claim-by-claim at release (checklist
step 3).

**Tests** — `CLAUDE.md`'s testing conventions apply verbatim: a red test is a
finding about the code, not the test. Never modify a test to make it pass; fix
the code, or change the test deliberately and say so. Snapshots are reviewed
(`testthat::snapshot_review()`) before accepting — never blanket-accept.

**Docs** — roxygen, README, and pkgdown updates land in the same session as
the code they document. `devtools::document()` runs before every commit that
touches roxygen comments. Everything under `docs/` and `man/` is generated —
never hand-edit.

## Filing issues

Use GitHub Issues as the primary tracker. Before opening an issue:

- Check open issues for duplicates.
- For design decisions (ramp parameters, palette choices, API shape), check
  [`plans/DECISIONS.md`](plans/DECISIONS.md) — settled decisions are not
  re-litigated unless implementation surfaces a real contradiction.

Issue templates are in [`.github/ISSUE_TEMPLATE/`](.github/ISSUE_TEMPLATE/).
Use the **bug** template for incorrect output or errors, and the
**feature/enhancement** template for new capabilities or behavior changes.

Label guide:

| Label | Use for |
|---|---|
| `bug` | Incorrect output, errors, or regressions |
| `enhancement` | Improvement to existing behavior |
| `feature` | New capability |
| `chore` | Maintenance, cleanup, internal-only |
| `docs` | Documentation only |
| `design-decision` | Requires a deliberate design call before coding |
