# Consumer rollout procedure

Reusable procedure for bumping the hdatools pin in consumer repos after a
release. Execute each repo in its own Claude Code session, one at a time.
Version-specific notes (which repos, expected diffs) belong in the GitHub
Issue filed for that release's rollout — not here.

## Background

Consumer repos (pha-update-2026, fhfh, vhtf, fed-workforce) are Quarto book
projects, not R packages. The hdatools pin lives **only** in each repo's
`renv.lock`, under the `Packages.hdatools` block (`Version` / `Source` /
`RemoteRef` / `RemoteSha`). There is no `Remotes:` field.

Each repo's `.Rprofile` sources `renv/activate.R` automatically — a bare
`Rscript` process with `setwd()` into the repo root auto-activates the renv
library. No manual `renv::activate()` needed.

Both `docs/` (rendered HTML) and `_freeze/` are git-tracked, so the git
baseline is automatic — no manual copy-aside step needed.

## Order guidance

Prefer the cleanest-state repo first to validate the procedure, then move to
repos with pre-existing dirty files. Stop on any unexpected regression before
touching the next repo.

## Per-repo procedure

Run each step as a temp `.R` or `.sh` script under that session's scratchpad,
`setwd()`'d into the repo root, executed via `Rscript <file> 2>&1` — never
inline `Rscript -e`.

### 1. Bump the pin

```r
setwd("R:/hda/<repo>")
renv::install("hdadvisors/hdatools@vX.Y.Z")
renv::snapshot()
```

Confirm: read the `hdatools` block in `renv.lock` — `Version` should match the
release tag, `RemoteRef` should be `vX.Y.Z`, and `RemoteSha` should match the
tagged commit.

### 2. Invalidate the freeze cache

Repos using `execute: freeze: auto` will silently reuse cached output if the
`_freeze/` directory isn't cleared. Delete it before rendering:

```bash
rm -rf _freeze/
```

Safe and reversible — `_freeze/` is git-tracked; `git checkout -- _freeze`
restores it.

### 3. Render

```bash
quarto render
```

Run from the repo root (both books use `execute-dir: project`).

### 4. Compare against the git baseline

```bash
git diff --stat -- docs _freeze
```

Coarse view: binary image diffs show as `Bin NNNN -> MMMM bytes`.

For changed HTML:
```bash
git diff -- docs/<chapter>.html
```
Ignore `date: today` re-stamp noise.

For changed PNGs — extract the pre-bump version and view both:
```bash
git show HEAD:docs/<chapter>_files/figure-html/<fig>.png > <scratchpad>/before_<fig>.png
```
Then use the Read tool to view old and new side by side.

### 5. Classify the diff

- **Font-rendering changes only** (expected when `dev: ragg_png` was not
  previously set, or when bundled fonts changed) → not a regression; note in
  the report.
- **Anything else** (layout shifts, broken plots, wrong colors, missing data,
  data-value changes) → stop, report the specific file(s), and do **not**
  proceed to the next repo until resolved.

### 6. After reporting

Ask the user whether to discard the render (`git checkout -- docs _freeze`,
keeping only the `renv.lock` bump) or leave it uncommitted for further review.
Don't commit either way without explicit direction.

## Font-stack note

Since 0.5.0 hdatools uses systemfonts/ragg instead of showtext/sysfonts.
Consumer repos must set `dev: ragg_png` in their Quarto YAML for bundled brand
fonts to render:

```yaml
# _quarto.yml
knitr:
  opts_chunk:
    dev: "ragg_png"
```

Without this, figures render with system fallback fonts. That's the expected,
NEWS-documented consequence — not a bug. Anything beyond font rendering is a
real regression.
