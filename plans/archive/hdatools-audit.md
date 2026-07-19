> **ARCHIVED — completed.** Post-v0.2.0 audit session, 2026-07-15; all findings addressed
> before Phase 0 kicked off. Kept for historical reference; content below is unedited.

\# hdatools post-v0.2.0 audit — findings and follow-up plan



\## Context



v0.2.0 shipped (merged, tagged v0.2.0 + retroactive v0.1.7, pushed 2026-07-15). This session audited the repo's post-release state — internal docs, R source, pkgdown site, tests, licensing — and evaluated two external Claude-skill repos for adoption. \*\*No blocking findings.\*\* NEWS.md was verified claim-by-claim against the code and is accurate; the pkgdown site is fully rebuilt and clean (all 25 exports have pages, no orphaned `add\_google\_fonts.html`/`hello.html`, article + redirect stub correct, sitemap clean). What remains is a modest set of should-fix items (one real documentation-rendering defect, one packaging hygiene gap, two test-coverage gaps promised by the release plan) plus housekeeping.



Nothing package-side blocks the pending consumer `add\_reliability()` swap — README, Rd, and NEWS all document both the `cv\_col` and legacy paths.



\---



\## 1. Audit findings



\### Internal docs



| # | Finding | File | Severity | Fix |

|---|---------|------|----------|-----|

| D1 | Roxygen markdown mode is \*\*not enabled\*\*, but roxygen comments use markdown (`\*\*bold\*\*`, backticks). Generated Rd contains the syntax literally — installed help pages (and pkgdown reference pages) render raw `\*\*` and `` ` `` | DESCRIPTION (no `Roxygen: list(markdown = TRUE)`); visible in man/add\_reliability.Rd:26-32, man/register\_hda\_fonts.Rd, man/theme\_\*.Rd | \*\*should-fix\*\* | Add `Roxygen: list(markdown = TRUE)` to DESCRIPTION, re-run `devtools::document()`, rebuild pkgdown. Review Rd diff (markdown → `\\strong{}`/`\\code{}` only) |

| D2 | `get\_logo()` `@return` says "a path to an image" but it returns a glue string containing an HTML `<img>` tag | R/theme\_helpers.R:284 (roxygen), man/get\_logo.Rd:15 | should-fix | Correct the `@return` text; re-document |

| D3 | NEWS claims namespace keeps "only `%+replace%` and rlang's tidy-eval helpers as bare imports" — but NAMESPACE also retains `importFrom(stringr,str\_wrap)`, and the `enquo`/`quo\_is\_null` bare imports are unused (code calls them `rlang::`-qualified; only `.data` is used bare) | NEWS.md:56-58, NAMESPACE:28-32, R/hdatools-package.R:3, R/theme\_helpers.R:118 | nice-to-have | Drop unused `@importFrom` tags (keep `.data`, `%+replace%`), re-document; no NEWS edit needed once true |

| D4 | README "Features" list omits four exports: `flip\_gridlines()`, `get\_logo()`, `get\_output\_format()`, `adjust\_base\_size()` | README.md:41-48 | nice-to-have | Add one-liners to the utility list |

| D5 | Both planning docs are fully executed and now stale as "plans": modernization plan items 1-18 all landed; strip-text diagnostic ran and its post-commit-4 confirmations hold | plans/hdatools-modernization.md, plans/strip-text-diagnostic.md | should-fix (as part of R2 below) | Move to `plans/archive/` with a short completion header ("Shipped as v0.2.0, 2026-07-15; see NEWS.md. Open item — consumer add\_reliability swap — tracked in consumer repos"), don't rewrite content |



NEWS.md 0.2.0 accuracy: \*\*verified claim-by-claim against code — accurate.\*\* (cv\_col semantics incl. `<=` vs `<` boundaries ✓, flip\_gridlines lifecycle shim ✓, ggiraph Suggests + install-hint error ✓, 5 bundled families + both opt-outs ✓, theme\_pha parity with 0/0 defaults ✓, hda/hfv explicit 4/7 adjusts ✓, get\_logo system.file ✓, scale\_name/linewidth/floors ✓, Authors/URL/Date/LazyData ✓, data-raw removed ✓, vignette moved ✓.)



\### Scripts / packaging



| # | Finding | File | Severity | Fix |

|---|---------|------|----------|-----|

| R1 | DESCRIPTION deps are clean: every Imports package is actually used with `::` qualification; ggiraph correctly guarded by `requireNamespace()` in the HTML branch only; withr used by tests. `Config/roxygen2/version: 8.0.0` matches installed roxygen2 8.0.0 (verified via Rscript) — not an issue | DESCRIPTION, R/theme\_helpers.R:260 | — | none |

| R2 | `.Rbuildignore` is missing `^plans$` — plans/ is git-tracked, so `R CMD build` includes it in the tarball → non-standard-directory check NOTE | .Rbuildignore | \*\*should-fix\*\* | Add `^plans$` (archiving per D5 doesn't remove the need) |

| R3 | `add\_google\_fonts()` survives as an internal alias — intentional per plan item #6, but it has zero callers anywhere (consumers relied on `.onLoad`, never called it directly) and no Rd. Dead code | R/theme\_helpers.R:89-92 | nice-to-have (owner decision) | Recommend delete; keep only if you want belt-and-braces for scripts calling it via `:::` |

| R4 | `.onAttach()` prints "Loading on-brand fonts" unconditionally — even when registration was skipped via `HDATOOLS\_NO\_FONTS`/`options(hdatools.fonts = FALSE)` or failed | R/zzz.R:5-7 | nice-to-have | Have `.onLoad` stash `register\_hda\_fonts()`'s result; message conditionally |

| R5 | New-path `add\_reliability()` references `thresholds\[1]`/`\[2]` inside `mutate()`+`case\_when()` — a data column literally named `thresholds` would shadow the local variable (data masking) | R/add\_reliability.R:70-74 | nice-to-have | Inject with `!!thresholds\[1]` / `.env$thresholds` |

| R6 | data-raw/DATASET.R: confirmed removed; no references remain | — | — | none |



\### pkgdown site



Site is \*\*clean\*\* (verified against NAMESPACE, man/, NEWS.md, sitemap, article paths; single fresh rebuild Jul 15 23:52). Remaining minor items:



| # | Finding | File | Severity | Fix |

|---|---------|------|----------|-----|

| P1 | Navbar config lists a `tutorials` slot and an empty `docs/tutorials/` dir exists (pre-existing, harmless) | \_pkgdown.yml:14, docs/tutorials/ | nice-to-have | Drop the navbar entry on next rebuild |

| P2 | If D1 (roxygen markdown) is fixed, the reference pages currently showing literal `\*\*`/backticks must be regenerated | docs/reference/\*.html | (follows D1) | `pkgdown::build\_site()` after re-documenting |

| P3 | `template: params: bootswatch: cosmo` is legacy pkgdown-1.x/BS3 syntax; works, but pkgdown 2.x prefers `template: bootstrap: 5` — \*\*changes the site's look\*\*, so out of scope unless wanted | \_pkgdown.yml:3-5 | nice-to-have (optional) | Defer; separate decision |



\### Tests



| # | Finding | File | Severity | Fix |

|---|---------|------|----------|-----|

| T1 | `register\_hda\_fonts()` has \*\*zero tests\*\*, despite the release plan's Verification §6 promising them (files exist via `system.file()`, returns TRUE, families appear in `sysfonts::font\_families()`, opt-out via option/env-var returns FALSE) | tests/testthat/ (no test-fonts.R) | \*\*should-fix\*\* | New `test-fonts.R` implementing exactly §6; use `withr::local\_options()`/`local\_envvar()` |

| T2 | `publish\_plot()` HTML branch untested — only the non-HTML passthrough is covered. Neither the `ggiraph::girafe()` path nor the Suggests-guard error has a test | tests/testthat/test-helpers.R:54-59 | should-fix | Add: (a) girafe-object test under `skip\_if\_not\_installed("ggiraph")` + mocked `knitr::is\_html\_output`; (b) guard-error test via `testthat::local\_mocked\_bindings(requireNamespace = function(...) FALSE, .package = "base")` — or accept (a) only if base-mocking proves brittle |

| T3 | Legacy-path multiple-`\_cv`-columns warning (uses first) untested | R/add\_reliability.R:47-49 | nice-to-have | One `expect\_warning()` test |

| T4 | `html\_adjust`/`pdf\_adjust` under knitr tested only for theme\_pha; theme\_hda/theme\_hfv's newly-explicit params untested | tests/testthat/test-themes.R | nice-to-have | Mirror the pha knitr test with hda's 4/7 defaults |

| T5 | Stale migration narration: test-deprecation.R:1-6 and test-themes.R:1-4 comments describe the pre-migration "red baseline"/"pre-Tier-1" world; the `suppressWarnings()` wrappers throughout test-themes.R are no longer needed (nothing warns anymore) | tests/testthat/test-deprecation.R, test-themes.R | nice-to-have | Trim comments; drop suppressWarnings |



\### Everything else



| # | Finding | File | Severity | Fix |

|---|---------|------|----------|-----|

| O1 | inst/fonts/LICENSES.md manifest matches the 13 bundled TTFs one-for-one; per-family OFL.txt/LICENSE.txt files present; OFL + Apache texts included. \*\*Caveat: I verified the manifest against the file list and license texts — I cannot verify offline that the binaries genuinely originate from the pinned google/fonts commit\*\* | inst/fonts/ | — (clean, with stated limit) | none |

| O2 | Article `branded-themes.Rmd` requires tidycensus + a Census API key + network to rebuild — fine for a manually-built article, but a rebuild-fragility to know about. Also doesn't showcase anything from 0.2.0 (no theme\_pha, no `add\_reliability(cv\_col=)`), and uses `T` for `TRUE` | vignettes/articles/branded-themes.Rmd | nice-to-have | Optional future enhancement; not part of this cleanup |

| O3 | `vignettes/img/branded\_plot.png` is orphaned — nothing references it | vignettes/img/ | nice-to-have | Delete |

| O4 | Repo has \*\*no CLAUDE.md and no .claude/\*\* — the Rscript-not-on-PATH gotcha (use `C:\\R\\R-4.6.0\\bin\\Rscript.exe`), the temp-file R convention, and the document→test→check→pkgdown loop live nowhere | repo root | should-fix | Create CLAUDE.md (see step 4 below) |

| O5 | `License: file LICENSE` (proprietary) → permanent R CMD check NOTE; accepted owner decision per the release plan | DESCRIPTION:11 | — | none |



\---



\## 2. External skill repos — go/no-go



\### posit-dev/skills — \*\*GO (selective adoption)\*\*



MIT-licensed Claude Code plugin marketplace from Posit; skills verified by reading actual SKILL.md contents. Worth adopting:



\- \*\*`r-lib/r-package-development`\*\* (Simon Couch) — codifies exactly hdatools' loop: `devtools::document()`/`test()`/`check()`, `pkgdown::check\_pkgdown()`, `\_pkgdown.yml` upkeep for new topics, NEWS.md bullet conventions. Near-exact fit.

\- \*\*`r-lib/testing-r-packages`\*\* (Garrick Aden-Buie) — testthat 3e conventions, `helper-\*.R`/fixtures, snapshot testing (`snapshot\_review()`/`accept()`), `local\_mocked\_bindings()` — directly relevant to T1/T2 above and future visual-snapshot work.

\- \*\*`open-source/create-release-checklist`\*\* (Aaron Jacobs) — generates a per-release Markdown checklist from DESCRIPTION/NEWS.md and files a GitHub issue via `gh`. Would make the currently ad-hoc release process (what we just did by hand for 0.2.0) repeatable. Vendor just this skill folder (SKILL.md + scripts/generate\_checklist.R) rather than installing its whole plugin.



Skip: cran-extrachecks (not CRAN-bound), lifecycle (no formal deprecation cycle needed at this consumer count), cli/r-cli-app/mirai/r-oop/ggsql/shiny (irrelevant), github pr-\* (solo-maintainer, mostly-main workflow), posit-dev workflow skills (duplicate built-ins), alt-text/brand-yml/quarto (already installed via the quarto plugin — this marketplace is partly in use already).



Both adopted skills assume inline `Rscript -e`; a CLAUDE.md line overriding to the temp-file convention handles that.



\### ab604/claude-code-r-skills — \*\*NO-GO as an install; harvest \~25 lines\*\*



MIT-licensed prose-only knowledge pack (no scripts/automation). Its /verify, /code-review, /plan commands and hooks duplicate or conflict with built-ins (name collisions with the environment's own /verify and /code-review; its block-stray-.md-files hook directly contradicts the "docs are first-class deliverables" convention; 80%-coverage TDD mandate is a poor fit for a visual theming package; its tidyverse-patterns skill references functions that couldn't be verified to exist in released dplyr). Worth copying into CLAUDE.md instead:



\- Release-checklist extras: `urlchecker::url\_check()`, `spelling::spell\_check\_package()`.

\- testthat 3e deprecation mappings + file-organization conventions.

\- The rule "never modify tests to make them pass; snapshots update only for intentional changes."



\---



\## 3. Proposed next steps (on approval — nothing executed yet)



Work on a short-lived branch (e.g. `post-0.2.0-cleanup`); this is docs/tests/hygiene only, no behavior changes, so it can land as \*\*0.2.0.9000\*\* dev version or a quick 0.2.1 — Jonathan's call at commit time.



\*\*Step 1 — Documentation correctness (D1, D2, D3, P2)\*\*

Add `Roxygen: list(markdown = TRUE)`; fix `get\_logo()` `@return`; drop unused `@importFrom` tags; re-run `devtools::document()`; diff man/ to confirm formatting-only changes; `pkgdown::build\_site()`; drop the `tutorials` navbar entry (P1) in the same rebuild.



\*\*Step 2 — Packaging hygiene (R2, D5, O3, R4, D4)\*\*

Add `^plans$` to .Rbuildignore; move both plans docs to `plans/archive/` with completion headers; delete orphaned `vignettes/img/branded\_plot.png`; make `.onAttach` message conditional on registration; add missing exports to README features list. Decision item: delete `add\_google\_fonts()` alias (R3) — recommended yes.



\*\*Step 3 — Test gaps (T1, T2, T3, T4, T5)\*\*

New `test-fonts.R` per the release plan's Verification §6; publish\_plot HTML-branch + guard tests; multiple-`\_cv` warning test; hda/hfv adjust tests; strip stale red-baseline comments and unneeded `suppressWarnings()`.



\*\*Step 4 — Dev-workflow adoption (O4 + skill repos)\*\*

Create repo CLAUDE.md: R at `C:\\R\\R-4.6.0\\bin\\Rscript.exe` (not on PATH), temp-file Rscript convention, document→test→check→pkgdown loop, docs/ never hand-edited, release checklist (incl. urlchecker/spelling extras), never-modify-tests-to-pass rule. Vendor `create-release-checklist` into `.claude/skills/`. Install posit-dev `r-lib` plugin (marketplace add + plugin install — or vendor the two skill folders if plugin install is undesirable; vendoring is the lower-friction default).



\*\*Step 5 — Verify and ship\*\*

`devtools::document()` + `devtools::test()` + `devtools::check()` via Rscript temp files (target: 0 errors/0 warnings; accepted NOTE: non-standard license only — the plans/ NOTE should now be gone); `pkgdown::build\_site()`; spot-check docs/reference/add\_reliability.html renders bold/code instead of literal `\*\*`. Suggest commits at natural boundaries (one per step, roughly).



\*\*Explicitly deferred:\*\* \_pkgdown.yml Bootstrap 5 migration (visual change, P3); article refresh (O2); consumer add\_reliability swap + snapshot (other repos).



\## Verification



\- `devtools::check()` clean (see step 5) proves R2/D1/D3 fixes didn't break packaging.

\- man/ diff after step 1 must show only markdown→Rd-markup conversions; any signature change is a red flag.

\- Rebuilt docs/reference pages spot-checked for rendered formatting.

\- Full testthat run green, including the new font/publish\_plot tests, on R 4.6.0.

