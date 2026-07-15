# hdatools 0.2.0 — Modernization Release Plan

> Approved 2026-07-15. Investigation performed plan-only; execution happens in a separate session. No package source was modified while producing this plan.

## Context

hdatools v0.1.7 (2024-11-19) predates ggplot2 4.0 (S7). It is the shared theming/helper package for three live renv-pinned Quarto projects — **pha-update-2026** and **fhfh** (ggplot2 4.0.3, R 4.6.0) and **faar** (ggplot2 3.5.1, R 4.4.2) — all pinned to the same commit `7ac3e5f`, plus unpinned consumers (rrh-framework, pha-regional-framework, sandbox) that install fresh from `main`. This release removes every deprecated idiom, hardens the fragile `.onLoad` network font loading, brings `theme_pha()` to API parity, and redesigns `add_reliability()` so consumers can delete their duplicated local `flag_reliability()`.

**Hard requirement:** rendered output for the exercised consumer surface must be pixel-equivalent on both ggplot2 3.5.1 and 4.0.3. Exercised surface (verified by grep across all consumers): `theme_hda(flip_gridlines=)`, `theme_pha(base_size=)`, `add_zero_line("x"/"y")`, `scale_fill_hda()`, `scale_fill_pha(direction=-1)`. Nothing else is called anywhere.

**Verified deprecation stages (ggplot2 4.0.3):** nothing in hdatools hard-errors today — `size=` on elements/geoms and `scale_name=` all *warn* (4.0.0 policy: only pre-3.0.0 deprecations became errors). The one real 4.0 breakage risk is ggtext 0.1.2 (S3 elements under S7; strip.text is the buggy path — pha's CLAUDE.md "class clash" gotcha).

**User decisions (locked):** bundle font TTFs in the package · version 0.2.0 · ggiraph → Suggests · Authors@R name-swap fixed + Jonathan becomes maintainer (cre).

---

## (a) Ranked fix list

### Tier 1 — must-fix for ggplot2 4.0 era (all currently emit deprecation warnings)

| # | Target | Change | Compat notes |
|---|--------|--------|--------------|
| 1 | `R/scales.R` — 6 discrete scales | Drop positional `"hda"/"hfv"/"pha"` (lands in deprecated `scale_name`). New shape: `ggplot2::discrete_scale(aesthetics = "fill", palette = hda_pal_discrete(direction = direction, repeat_pal = repeat_pal), ...)`. `palette` MUST stay named — `scale_name` still occupies positional slot 2 on both 3.5.x and 4.0.x. | Identical output. Requires ggplot2 ≥ 3.5.0 (`scale_name` gained its `deprecated()` default in 3.5.0) → new DESCRIPTION floor; faar's 3.5.1 clears it. |
| 2 | `R/scales.R` — 3 gradient scales | Delete the `scale_name = "hda"/"pha"` line from each `continuous_scale()` call; everything else already named. Leave `aesthetics = "color"` as-is (both versions standardize aes names). | Identical output. |
| 3 | `R/themes.R` — all 3 themes | `element_rect(size = 0.5)` → `linewidth = 0.5`; `element_line(size = 1)` → `linewidth = 1`; gridline `element_line(size = 0.05)` → `linewidth = 0.05` (hda ×2, hfv ×2, pha ×1). | 1:1 rename since ggplot2 3.4.0; pixel-identical on 3.5.1 and 4.0.3. |
| 4 | `R/theme_helpers.R` — `add_zero_line()` | `geom_vline/geom_hline(..., size = 0.5)` → `linewidth = 0.5`. | Identical output. |
| 5 | `R/theme_helpers.R` — `flip_gridlines()` | Rename user-facing `size` param → `linewidth`, keeping compat shim: `flip_gridlines(color = "#cbcdcc", linewidth = 0.05, size = deprecated())`; if `lifecycle::is_present(size)` → `deprecate_warn("0.2.0", "flip_gridlines(size)", "flip_gridlines(linewidth)")` and use it. | API-breaking only for callers passing `size=` — grep found none (consumers only use the `flip_gridlines=` THEME argument, a different thing). lifecycle is already a hard transitive dep (zero install cost). |

### Tier 2 — quality / robustness

| # | Target | Change | Compat notes |
|---|--------|--------|--------------|
| 6 | Fonts: `R/zzz.R`, `R/theme_helpers.R`, new `inst/fonts/` | **Bundle static TTFs** and register offline. New exported `register_hda_fonts(quiet = FALSE)` using `sysfonts::font_add()` on `system.file("fonts", ...)` paths: Lato (Reg/Bold/Italic), Roboto Slab (Reg/Bold), Open Sans (Reg/Bold/Italic), Poppins (Reg/**SemiBold** as bold face — preserves current `bold.wt = 600`), Noto Sans (Reg/Bold/Italic). Executor downloads TTFs from google/fonts GitHub (same files `font_add_google` serves); include `inst/fonts/LICENSES.md` with OFL/Apache texts (redistribution requires license text to travel with fonts). Opt-out: `getOption("hdatools.fonts", TRUE)` or env `HDATOOLS_NO_FONTS`. `showtext_auto()` + `knitr::opts_chunk$set(fig.showtext = TRUE)` run only if registration succeeded, wrapped in tryCatch. `.onLoad` calls `register_hda_fonts(quiet = TRUE)`; `packageStartupMessage` moves to `.onAttach` (CRAN convention). Keep `add_google_fonts()` as internal alias (never exported — no compat concern). | Fonts stay automatic (consumers have zero local fallback — pha/fhfh/faar all rely on .onLoad). Kills per-session network downloads AND the offline-`library()` failure. Risk: bundled files could differ sub-pixel from Google-served versions → gated by render-compare (rollout step 4). Repo grows ~3-6MB. |
| 7 | `R/themes.R` — `theme_pha()` parity | New signature: `theme_pha(base_size = 10, base_family = "Noto Sans", flip_gridlines = FALSE, output_format = NULL, html_adjust = 0, pdf_adjust = 0, ...)`. Body mirrors theme_hda structurally: `adjust_base_size(base_size, html_adjust, pdf_adjust, actual_format)` — **defaults 0/0 make this a no-op in every format**, so `theme_pha(base_size = 60)` in a knitr render still yields 60 (copying hda's hardcoded 4/7 would silently shrink consumer charts). Same `if (flip_gridlines)` block as hda with identical current values. Append `base_theme + ggplot2::theme(...)` passthrough (empty `theme()` = no-op). Fix roxygen `base_size` doc (says 14, code is 10). **Do NOT touch** pha's distinct lineheight 1, subtitle margins t=5/b=20, missing title margin — visible-output constants, harmonization deferred. Also lift `html_adjust = 4, pdf_adjust = 7` into explicit defaulted params on theme_hda/theme_hfv (defaults = current behavior). | Default output unchanged; new capability opt-in per call. |
| 8 | `R/themes.R` — theme_pha `strip.text` | Add `strip.text = ggtext::element_markdown(size = adjusted_base_size, family = base_family, color = "#383c3d", margin = ggplot2::margin(b = 5, t = 2), vjust = 0, lineheight = 1.1)` — parity with hda/hfv, and makes `markdown_wrap_gen()` labellers render correctly with theme_pha. **Mandatory diagnostic first** (see Verification): reproduce the pha "class clash" (S7 `element_text()` override merged into a theme containing S3 ggtext elements fails ggplot2 4.0's class-compat check in merge/inherit), confirm the supported idioms work. Guard: grep pha/fhfh for faceted theme_pha charts in currently-rendered docs — if any exist, use theme_minimal-inherited metrics (`size = adjusted_base_size * 0.8`, no margin) instead of hda metrics for visual parity. Document override guidance in roxygen on all 3 themes + README: *override strips with `ggtext::element_markdown()`, never raw `element_text()`, under ggplot2 ≥ 4.0*. | Only affects faceted theme_pha plots — consumers currently de-facet (the workaround this removes). Keep ggtext this release: 0.1.2 works via S3 bridge for the used paths; S7 rewrite in progress upstream (ggtext #128; #135 "Update package on CRAN" opened 2026-07-15). |
| 9 | `R/add_reliability.R` — redesign | New signature: `add_reliability(data, cv_col = NULL, scale = c("percent", "proportion"))`. `rlang::quo_is_null(rlang::enquo(cv_col))` branches: **NULL → legacy path byte-for-byte** (`_cv$` auto-detect, 0-1, strict `<` boundaries — preserves documented behavior; nobody uses it). **Supplied → new path**: `{{ cv_col }}` tidy-eval, `match.arg(scale)`, thresholds `c(15, 30)` percent / `c(0.15, 0.30)` proportion, **`<=` boundaries** (must match consumers: CV exactly 15 = "High"), `is.na() → NA` first, returns character (not factor — factor would change downstream sorts). Default `"percent"` = zero-config swap for all three consumers: `flag_reliability(df, cv_col = cv)` → `add_reliability(df, cv_col = cv)`, delete local fn. No scale auto-detection (silent misclassification on all-CV≤1 percent tables). Adds `rlang` to Imports. | Legacy path unchanged; new path unused-name-safe (no consumer calls add_reliability today). |
| 10 | `R/theme_helpers.R` — `get_logo()` | Replace hardcoded `"inst/logos/..."` with `system.file("logos", file, package = "hdatools")` + `nzchar` check + error; add missing `@param width` roxygen. No pha logo (no asset exists — deferred). | Currently broken when installed; no callers. Return changes from broken relative path to working absolute path. |
| 11 | `tests/` — new testthat suite | Full suite (see Verification). Deprecation tests are red on current code / green after Tier 1. No vdiffr; `ggplot_build()`-based so no fonts needed in CI. | New; no consumer impact. |

### Tier 3 — housekeeping

| # | Target | Change |
|---|--------|--------|
| 12 | `DESCRIPTION` | `Version: 0.2.0`; drop `Date:` and `LazyData: true` (no data/ → check NOTE); delete legacy `Author:` line; fix all three `person()` given/family swaps; **Jonathan Knopf = cre** (jonathan@hdadvisors.net), Kyle Walker → aut; add `URL:`/`BugReports:`; `Depends: R (>= 4.1)` (native pipe in add_reliability); floors: `ggplot2 (>= 3.5.0)` [load-bearing], `dplyr (>= 1.1.0)`, `ggtext (>= 0.1.2)`, `scales (>= 1.3.0)`, `rlang (>= 1.1.0)`, `lifecycle`, `showtext (>= 0.9)`, `sysfonts (>= 0.8)`, `glue (>= 1.6.0)`, `knitr (>= 1.42)`, `stringr (>= 1.5.0)` — all deliberately below every consumer lockfile so nothing is forced to upgrade. **ggiraph → Suggests** `(>= 0.8.7)` + `testthat (>= 3.1.5)`, `withr`. License: keep `file LICENSE`, update year to 2022–2026 (MIT switch = deferred owner decision). |
| 13 | Namespace slimming | New `R/hdatools-package.R` with `"_PACKAGE"` + `@importFrom ggplot2 %+replace%` (the only unqualified ggplot2 symbol) + `@importFrom rlang enquo quo_is_null .data`. Delete every `@import` tag (ggplot2/ggtext ×3 in themes.R; ggplot2/scales in scales.R; sysfonts/showtext/ggplot2/ggiraph in theme_helpers.R; dplyr ×2 in fct_case_when.R) — all calls already `pkg::`-qualified except bare `girafe(` → `ggiraph::girafe(`. Keep `@importFrom knitr opts_chunk`, `@importFrom stringr str_wrap`. Rationale: dplyr 1.2.0 added 6 new exports; `@import dplyr` is a collision hazard. |
| 14 | `publish_plot()` | `requireNamespace("ggiraph", quietly = TRUE)` guard with informative install error; call stays `ggiraph::girafe(ggobj = plot, height_svg = 4)` (named `ggobj` — ggiraph 0.9.3 reordered args; 0.9.6 is S7-fine). |
| 15 | Dead weight | Delete `data-raw/DATASET.R` (dead usethis boilerplate). Add `^docs$`, `^_pkgdown\.yml$`, `^vignettes$` handling to `.Rbuildignore` (currently only Rproj + data-raw). Move `vignettes/branded-themes.Rmd` → `vignettes/articles/` (no `VignetteBuilder:` exists; pkgdown still builds it, R CMD check ignores it, no new deps). |
| 16 | `README.md` | Fix broken `add_reliability` example (uses `cv` col against `_cv$` rule + 10 values into 8 rows): new example `data \|> mutate(cv = runif(8, 0, 50)) \|> add_reliability(cv_col = cv)` + a second snippet showing legacy `_cv` auto-detect. Add font-bundling note + strip.text override guidance. |
| 17 | `NEWS.md` | Full `# hdatools 0.2.0` section (deprecation fixes, theme_pha parity, add_reliability, ggiraph→Suggests, bundled fonts, floors, maintainer change); terse backfill stubs for 0.1.1–0.1.7 ("see git history"). |
| 18 | pkgdown | `pkgdown::build_site()` at the end; commit regenerated `docs/` (stale at 0.1.6, contains leftover `hello.html`). |

---

## (b) Dependency compatibility matrix

| Import | Pinned (pha/fhfh) | faar | Latest CRAN | Issues found | Action |
|---|---|---|---|---|---|
| ggplot2 | 4.0.3 | 3.5.1 | 4.0.3 (2026-04-22) | `size=`/`scale_name=` warnings; S7 strict element validation; subtitle/caption now inherit from `text` not `title` (we set all explicitly) | linewidth=, drop scale_name, floor ≥ 3.5.0 |
| scales | 1.4.0 | — | 1.4.0 (2025-04-24) | none — `gradient_n_pal()` is a permanent un-deprecated alias of `pal_gradient_n()` | none |
| ggtext | 0.1.2 | — | 0.1.2 (2022!) | Not S7-native; strip.text buggy (rotated worst); S7 rewrite upstream (#128), CRAN-update issue #135 opened 2026-07-15 | Keep; add strip guidance; monitor for 0.1.3 |
| showtext | 0.9-8 | — | 0.9-8 (2026-03-21) | none in API; our .onLoad pattern was the problem | bundled-font rework |
| sysfonts | 0.8.9 | — | 0.8.9 (2024-03) | none; `font_add()` stable | use for bundled TTFs |
| dplyr | 1.2.1 | — | 1.2.1 (2026-04) | `case_when()` unchanged; 1.2.0 added 6 new exports → `@import dplyr` collision hazard; `recode_values()`/`replace_values()` new+stable (no fit for fct_case_when — deferred) | qualified calls only, drop @import |
| knitr | 1.51 | — | 1.51 (2025-12) | none — `opts_chunk`, `is_html_output()`, `knitr.in.progress` all current | none |
| ggiraph | 0.9.6 | — | 0.9.6 (2026-05) | S7-compatible since 0.9.5; args reordered 0.9.3 (we call named) | → Suggests + guard |
| glue | 1.8.1 | — | 1.8.1 (2026-04) | none | none |
| stringr | 1.6.0 | — | 1.6.0 (2025-11) | none for `str_wrap()` | none |
| *(new)* rlang | 1.1.x present | — | current | — | add to Imports (tidy-eval in add_reliability) |
| *(new)* lifecycle | present (transitive) | — | current | — | add to Imports (flip_gridlines shim) |

---

## (c) Version & scope boundary

**Version: 0.2.0** (user-confirmed). Minor-bump justification: new API surface (`add_reliability` signature, `register_hda_fonts()`), Imports→Suggests move, new version floors. Rendered output unchanged. First git tag ever: annotated `v0.2.0`; also retro-tag `v0.1.7` at `7ac3e5f` for rollback clarity.

**Deferred (out of scope), one line each:**
- **marquee migration** (replace ggtext) — changes text metrics on every chart; upstream ggtext S7 release may land first.
- **ggplot2 4.0 theming adoption** (`element_geom`, ink/paper/accent, `margin_part()`) — 4.0-only API; breaks the faar 3.5.1 requirement.
- **scales 1.4 palette registry** — zero consumer-visible benefit; adds floor pressure.
- **recode_values/replace_values-based helpers** — new feature surface, not modernization.
- **pha logo asset + `get_logo("pha")`** — blocked on brand collateral, not code.
- **systemfonts/ragg migration** — showtext draws glyphs as polygons; switching guarantees pixel differences.
- **theme_pha styling harmonization** (lineheight/margins to match hda) — intentional-output-change release only.
- **MIT license switch; CRAN prep** — owner decisions, flagged not blocking.

---

## (d) Rollout

Work on branch `release-0.2.0`; merge to main IS the release event for unpinned consumers, so nothing merges until verification passes.

**Commit order** (each: `devtools::document()` + `devtools::test()` via Rscript temp files — never inline R):
1. Test infra + red tests (deprecation tests fail on current code — record baseline)
2. Scales: drop scale_name, all-named calls (Tier 1 #1-2)
3. size→linewidth everywhere (#3-5)
4. theme_pha parity + strip.text (#7-8, diagnostic first)
5. add_reliability redesign (#9)
6. get_logo fix (#10)
7. Bundled fonts (#6 — download TTFs from google/fonts GitHub, LICENSES.md)
8. Namespace/DESCRIPTION/dead-weight cleanup (#12-15) + `document()`
9. README + NEWS + roxygen text (#16-17)
10. Version bump + pkgdown rebuild (#18)

**Checks before merge:**
- `devtools::check()` under R 4.6/ggplot2 4.0.3: 0 ERROR/0 WARNING; accepted NOTEs: nonstandard license only. Watch for "no visible global function definition" — the tell that namespace slimming broke an unqualified call; verify `%+replace%` lands in NAMESPACE.
- **Dual-version test**: run the test suite against ggplot2 3.5.1 (throwaway lib via `remotes::install_version("ggplot2", "3.5.1", lib = tmp)`, prepend to `.libPaths()`; install testthat ≥ 3.1.5 there too — do NOT touch faar's lockfile).
- **Render-compare gate (pixel-parity proof)**: in pha-update-2026 and fhfh, `renv::install("hdadvisors/hdatools@release-0.2.0")` (NO snapshot), re-render 2-3 representative chapters, compare chart PNGs vs current-release renders with a perceptual metric (`magick::image_compare(metric = "AE")`) — not md5 (showtext DPI makes byte-diffs noisy). Bundled fonts: allow sub-pixel text AE, eyeball anything flagged.

**Release:** merge → main; `git tag -a v0.2.0 -m "hdatools 0.2.0"`; `git tag -a v0.1.7 7ac3e5f -m "hdatools 0.1.7 (retroactive)"`; push with `--tags`. Commit messages: no Claude/Anthropic co-author.

**Per pinned consumer** (pha-update-2026, fhfh — their own sessions, after release):
```r
renv::install("hdadvisors/hdatools@v0.2.0")   # set GITHUB_PAT to avoid rate limits
renv::snapshot()
```
Then: swap `flag_reliability(df, cv_col = x)` → `hdatools::add_reliability(df, cv_col = x)`, delete local fn; full re-render; verify (i) no lifecycle warnings in render log, (ii) reliability tables identical row-for-row, (iii) charts vs baseline. Commit lockfile + swap together (pha CLAUDE.md already anticipates this commit).

**faar**: no forced move — old hdatools keeps working at its pin. Recommend bumping to v0.2.0 at faar's next active session WITHOUT touching ggplot2 (all new idioms work on 3.5.1; floors chosen below its stack), with a one-document render check. Never as a drive-by.

**Unpinned consumers** (rrh-framework, sandbox): pick up main automatically on next install — covered by the pre-merge gates. sandbox/hdatools/ test scripts are a good interactive smoke-test.

---

## Verification (executor)

1. **Red→green deprecation tests**: `expect_no_condition(..., class = "lifecycle_warning_deprecated")` on all themes/scales/helpers + one full exercised-surface `ggplot_build()`. Red before Tier 1, green after (testthat 3e sets lifecycle verbosity so soft-deprecations warn in tests).
2. **strip.text diagnostic** (before/after commit 4, under 4.0.3): faceted plot A) `+ theme_pha() + theme(strip.text = element_text(...))` — capture exact clash error; B) same with theme_hda; C) override via `ggtext::element_markdown()` — must be clean; D) `theme_pha(strip.text = element_markdown(...))` passthrough — must be clean. Paste A's error into the PR description.
3. **Palette flow**: `ggplot_build()` assertions — exact hexes in order, `direction = -1` reversal (lock pha's), `repeat_pal` recycling at n=8.
4. **Theme structure**: `calc_element("text", theme_pha(base_size = 60))$size == 60` including under `withr::local_options(knitr.in.progress = TRUE)` (proves html_adjust=0 no-op); flip_gridlines swaps blank/line; strip.text has element_markdown class; `...` passthrough lands. Element-class checks via a `grepl`-based helper (S7 gives `"ggplot2::element_line"`, S3 gives `"element_line"` — one idiom, both versions).
5. **Helpers**: add_zero_line linewidth 0.5/colour via built-plot data; adjust_base_size arithmetic; markdown_wrap_gen `<br>`; get_logo file.exists on extracted path; publish_plot passthrough outside knitr; add_reliability boundary tables both paths (legacy `<`: 0.15→"Medium"; new `<=`: 15→"High"); fct_case_when ordering/dir/dedup.
6. **Fonts**: `system.file("fonts", ...)` files exist; `register_hda_fonts()` TRUE offline; families in `sysfonts::font_families()`; opt-out path returns FALSE untouched. No test uses `print()`/`ggplotGrob()` text drawing → CI needs no fonts except these.
7. Dual-version run + render-compare gate per Rollout.

## (e) Open questions / deferred owner decisions

- **MIT license switch** — keep proprietary `file LICENSE` for now (permanent R CMD check NOTE accepted); revisit if the package should be publicly reusable.
- **ggtext 0.1.3 watch** — if the S7 ggtext release (issue #135) lands mid-implementation, bump the ggtext floor and re-run the strip.text diagnostic; do not otherwise change approach.
- **faar bump timing** — deferred to faar's next active session (owner schedules).
- **pha logo asset** — provide brand PNG when available; `get_logo("pha")` is a 3-line follow-up.

## Critical files
`R/themes.R` · `R/scales.R` · `R/theme_helpers.R` · `R/zzz.R` · `R/add_reliability.R` · `R/fct_case_when.R` (imports only) · `DESCRIPTION` · new: `R/hdatools-package.R`, `tests/testthat/*`, `inst/fonts/**` · regenerated: `NAMESPACE`, `man/`, `docs/`
