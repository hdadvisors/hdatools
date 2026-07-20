# Consumer rollout guide — hdatools v0.5.0

**Status:** not yet executed. Written after the hdatools v0.5.0 release
(tagged/pushed separately — confirm that's done before starting this).

**Scope:** `pha-update-2026` and `fhfh` only. `faar` is explicitly excluded
from this rollout — do not touch it.

**Do not run this from the hdatools repo.** Each repo below gets its own
session, working from that repo's own directory, one at a time — not in
parallel. If a repo shows unexpected regressions, stop and report before
touching the next one.

## Background (why each step below is necessary)

- Neither `pha-update-2026` nor `fhfh` has a `DESCRIPTION` file — they're
  Quarto book projects, not R packages. The hdatools pin therefore lives
  **only** in each repo's `renv.lock`, under the `Packages.hdatools` block
  (`Version`/`Source`/`RemoteRef`/`RemoteSha`). There's no `Remotes:` field
  to edit anywhere.
- Both repos currently pin hdatools `0.1.7` via GitHub
  (`RemoteUsername: hdadvisors`, `RemoteRepo: hdatools`, `RemoteRef: main`,
  same `RemoteSha: 7ac3e5f04bac...`) — confirmed stale, pre-dating this
  release by a wide margin.
- Each repo's `.Rprofile` sources `renv/activate.R` automatically, so a bare
  `Rscript` process with `setwd()` into that repo's root auto-activates that
  repo's isolated renv library — no manual `renv::activate()` call needed.
- Both `_quarto.yml` files set `execute: freeze: auto` (Quarto book projects,
  `output-dir: docs`). Freeze caches rendered output keyed on the `.qmd`
  source file's hash, **not** on package versions — bumping hdatools alone
  will **not** invalidate the cache, and a render would silently reuse old
  output, proving nothing about the bump. The `_freeze/` directory must be
  invalidated (deleted, at least for the chapters being checked) before
  re-rendering.
- `docs/` (rendered HTML output) and `_freeze/` are both git-tracked in both
  repos, so git itself is the "before" baseline — no manual copy-aside step
  needed. `git diff`/`git show` after rendering tells you exactly what
  changed.
- `fhfh/_quarto.yml` already sets `knitr: opts_chunk: dev: "ragg_png"` (line
  11) — needed for hdatools' systemfonts-based font stack (0.3.0+) to
  actually render the bundled brand fonts. **`pha-update-2026/_quarto.yml`
  does not have this set.** Expect font-rendering differences in
  `pha-update-2026`'s figures after the bump — that's the known,
  NEWS-documented consequence of the font-stack migration
  (showtext/sysfonts → systemfonts), not a bug. Anything beyond font
  rendering (layout shifts, broken plots, wrong colors, missing data) is a
  real regression worth stopping over.
- `fhfh` currently has one pre-existing, unrelated uncommitted change: a
  modified `_quarto.yml`. Don't touch or stage it — it's not part of this
  rollout. (`pha-update-2026` is currently clean.)

## Recommended order

1. **`pha-update-2026` first** — cleanest git state, smallest book, no
   pre-existing dirty files. Running it first validates the whole procedure
   and cleanly surfaces the missing `ragg_png` config as an expected diff.
2. **`fhfh` second** — already has the font config right, but has to work
   around its unrelated dirty `_quarto.yml`.

## Per-repo procedure

Run each step as a temp `.R` script under that session's own scratchpad,
`setwd()`'d into the repo root, executed via `Rscript <file> 2>&1` — never
inline `Rscript -e`.

1. **Bump the pin:**
   ```r
   setwd("R:/hda/<repo>")
   renv::install("hdadvisors/hdatools@v0.5.0")
   renv::snapshot()
   ```
   Confirm afterward by reading the `hdatools` block in `renv.lock` — Version
   should read `0.5.0`, `RemoteRef` should read `v0.5.0`, and `RemoteSha`
   should match the v0.5.0 tag's commit.

2. **Invalidate the freeze cache** before rendering, or the render will
   silently no-op:
   ```bash
   rm -rf _freeze/
   ```
   (Safe and reversible — it's git-tracked; `git checkout -- _freeze` restores
   it at any point.)

3. **Render:**
   ```bash
   quarto render
   ```
   (Run from the repo root — both are `execute-dir: project` books, so
   render at the project level, not per-chapter.)

4. **Compare against the git baseline:**
   - Coarse view: `git diff --stat -- docs _freeze` (binary image diffs show
     as `Bin NNNN -> MMMM bytes` — a quick signal of which figures actually
     changed).
   - Text diff: `git diff -- docs/<chapter>.html` — ignore the `date: today`
     re-stamp noise on every render.
   - For any changed PNG: extract the pre-bump version and view both:
     ```bash
     git show HEAD:docs/<chapter>_files/figure-html/<fig>.png > <scratchpad>/<repo>_before_<fig>.png
     ```
     then use the Read tool to view the extracted "before" PNG next to the
     current working-tree "after" PNG.

5. **Classify the diff:**
   - Font-rendering changes only (expected in `pha-update-2026`, already
     correct in `fhfh`) → not a regression, note it in the report.
   - Anything else changed (layout, data values, missing plots, broken
     colors) → stop, report the specific file(s) and what changed, and do
     **not** proceed to the next repo until this is resolved.

6. **After reporting**, ask the user whether to discard the render
   (`git checkout -- docs _freeze`, keeping only the `renv.lock` bump) or
   leave it uncommitted for further review. This task doesn't call for a
   commit either way — that's a judgment call to surface each time, not
   assume.

## Starter prompts

### `pha-update-2026`

> Bump the hdatools pin in `R:\hda\pha-update-2026` to `v0.5.0` and verify
> the rendered book still looks right. This repo is a Quarto book project
> (not an R package) — the hdatools pin lives only in `renv.lock`. Steps:
> (1) `setwd()` into the repo, run `renv::install("hdadvisors/hdatools@v0.5.0")`
> then `renv::snapshot()`, confirm the `renv.lock` hdatools block updated;
> (2) delete `_freeze/` (git-tracked, safe/reversible) since `execute: freeze:
> auto` would otherwise silently reuse cached pre-bump output; (3) run
> `quarto render` from the repo root; (4) compare against git — `git diff
> --stat -- docs _freeze` for a coarse view, then look closer at any changed
> HTML/PNG (extract the pre-bump PNG via `git show HEAD:<path>` and view both
> old/new side by side). Note: `pha-update-2026/_quarto.yml` does NOT set
> `dev: "ragg_png"`, so font-rendering differences in figures are EXPECTED
> (systemfonts migration) — not a bug. Anything else that changed (layout,
> data, colors, missing content) is a real regression — stop and report
> instead of proceeding. Full context/rationale is in
> `R:\hda\hdatools\plans\consumer-rollout-v0.5.0.md`.

### `fhfh`

> Bump the hdatools pin in `R:\hda\fhfh` to `v0.5.0` and verify the rendered
> book still looks right. This repo is a Quarto book project (not an R
> package) — the hdatools pin lives only in `renv.lock`. Steps: (1)
> `setwd()` into the repo, run `renv::install("hdadvisors/hdatools@v0.5.0")`
> then `renv::snapshot()`, confirm the `renv.lock` hdatools block updated;
> (2) delete `_freeze/` (git-tracked, safe/reversible) since `execute: freeze:
> auto` would otherwise silently reuse cached pre-bump output; (3) run
> `quarto render` from the repo root; (4) compare against git — `git diff
> --stat -- docs _freeze` for a coarse view, then look closer at any changed
> HTML/PNG (extract the pre-bump PNG via `git show HEAD:<path>` and view both
> old/new side by side). Note: this repo already has `_quarto.yml`'s `knitr:
> opts_chunk: dev: "ragg_png"` set correctly, so figures should render with
> hdatools' bundled fonts without further config — any font-related
> difference here should look like an *improvement*, not breakage. Also
> note: `_quarto.yml` has a pre-existing unrelated modification (uncommitted,
> not part of this task) — leave it untouched, don't stage or revert it.
> Anything beyond expected font-rendering improvements (layout, data,
> colors, missing content) is a real regression — stop and report. Full
> context/rationale is in
> `R:\hda\hdatools\plans\consumer-rollout-v0.5.0.md`.
