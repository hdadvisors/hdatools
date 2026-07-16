# hdatools 2026 design review — investigation & recommendations

> **Status:** approved 2026-07-16; awaiting implementation. Work proceeds in
> future sessions, item by item — Tier 1 first (release sequencing at the end of
> §4). No package code has been changed yet.

## Context

`hdatools` (0.2.0.9000) provides branded ggplot2 themes and color scales for three
brands (HDA, HFV, PHA), consumed by Quarto/R projects rendering to HTML and PNG (PDF
routes exist downstream but are all commented out or deferred today). The 0.2.0
release already handled ggplot2 4.0 deprecations, font bundling, and namespace
hygiene. What remains is structural: ~730 lines of R that should be ~250, no single
source of truth for the palettes, half-finished continuous scales, no accessibility
story, and a font stack (showtext) the tidyverse now explicitly recommends against.

**Evidence base.** Full read of `R/*.R`, tests, DESCRIPTION, NEWS, `_pkgdown.yml`;
usage survey of four consumer repos (faar, fhfh, vhtf, fed-workforce); web research
with citations (ggplot2 4.0 release notes, scales 1.4.0, afcharts, urbnthemes,
brand.yml, tidyverse font guidance, cols4all). `pha-update-2026` (named in CLAUDE.md
as a pinned consumer) was **not** surveyed — PHA blast-radius calls below are
inferred from faar's archive (PHA usage is near-dead there) and should be confirmed
against that repo before touching PHA functions.

**Consumer reality that constrains everything:**

| Repo | Pin | Heaviest usage |
|---|---|---|
| faar | renv @ 0.1.7 | `theme_hda` ~95 sites, `scale_fill_hda` ~50 (incl. positional `scale_fill_hda(-1)`), `add_zero_line` ~50, local `hda_pal[n]` indexing ~40 |
| fhfh | renv @ 0.1.7 (same SHA) | `theme_hda` ~45, `add_zero_line` ~30; bans `add_reliability()` in its CLAUDE.md |
| vhtf | **unpinned, floats on main** | Cloned the entire system (`theme_vha`, `vha_pal_discrete`, `scale_fill_vha`) to fake a VHA brand |
| fed-workforce | **unpinned, floats on main** | `theme_hfv` ×7; hardcodes `hfv_blue <- "#334a66"` etc.; forces `ggsave(bg = "white")` |

Every repo hardcodes brand hexes locally because the package exports no color
vectors.

**Compatibility contract (per Jonathan): fhfh is the only consumer that matters
for breaking changes.** faar and the others are done/archived or small enough to
update to new conventions. So the binding surface is fhfh's: `theme_hda()`
(~45 sites, incl. the `...` → `theme()` passthrough and `flip_gridlines = TRUE`),
`add_zero_line("x"/"y")` (~30), `scale_fill_hda()` (~5). Everything outside that
set — positional `scale_fill_hda(-1)`, the gradient scales, `publish_plot()`,
`*_pal_discrete()` — can change more freely, though cheap `lifecycle`
soft-deprecations are still preferred over silent breaks since unpinned repos
(vhtf, fed-workforce) install from `main`.

**Design goal (per Jonathan): adding a client brand palette must be easy.** PHA
and VHA are the precedent — HDA regularly produces plots in a client's own
colors. The architecture below treats brands as data (one registry entry:
colors + fonts + theme spec), not as code to copy.

---

## 1. Key inefficiencies / issues, with recommended solutions

Ordered by leverage.

### 1.1 No single source of truth for palettes — and no named color access
Hexes live inside three closure factories ([scales.R:10-17, 49-56, 88-95](R/scales.R#L10)),
are repeated in the gradient defaults ([scales.R:212, 236, 260](R/scales.R#L212)), and are
re-typed by hand in every consumer (faar/fhfh both maintain a local `hda_pal`
vector; fed-workforce comments *"HFV palette colors for manual two-series
assignments"*). This is the root cause of most downstream friction.

**Fix:** one internal registry (a named list of per-brand specs — colors, font
families, theme parameters — defined once in `R/brands.R`) that every factory,
scale, and theme reads from. **Adding a client brand = adding one registry entry
plus optional bundled fonts; palettes, discrete/continuous scales, and a theme
all fall out of it** (this is the direct answer to vhtf's 200-line clone and to
future client work). On top of the registry:
- Exported named vectors per brand — `hda_colors`, `hfv_colors`, `pha_colors`
  (e.g. `hda_colors[["sky"]]`), the afcharts `af_colour_values` pattern
  ([afcharts](https://github.com/best-practice-and-impact/afcharts)). scales' own
  palette-package guidance says to export the naked colour vector so
  `as_discrete_pal()`/`as_continuous_pal()` work on it
  ([scales palette-recommendations](https://scales.r-lib.org/reference/palette-recommendations.html)).
- An accessor `hda_color("sky", "coral", brand = "hda")` for the manual-two-series
  and ggtext-`<span style='color:…'>` use cases all four repos hand-roll today.

### 1.2 Triplicated palette factories + 9 copy-pasted scale wrappers
`hda/hfv/pha_pal_discrete()` are byte-identical except the hex vector; the 6
discrete + 3 gradient wrappers are pure copy-paste ([scales.R](R/scales.R), 273 lines).

**Fix:** one internal factory and one internal scale constructor:
```r
pal_hda_discrete <- function(brand, direction = 1, repeat_pal = FALSE) { ... }  # internal
scale_brand_d    <- function(aesthetics, brand, direction = 1, repeat_pal = FALSE, ...) { ... }
```
The nine exported names become one-line wrappers — zero API change, zero behavior
change, existing tests must pass untouched. Build the factory on
`scales::pal_manual()` / wrap with `scales::new_discrete_palette(type = "colour",
nlevels = 6)` so the palettes carry metadata and interop with ggplot2 4.x
([scales 1.4.0](https://tidyverse.org/blog/2025/04/scales-1-4-0/)). `repeat_pal`
folds into the factory once. Keep `direction` as first parameter — faar calls
`scale_fill_hda(-1)` positionally dozens of times.

### 1.3 Continuous scales: incomplete matrix, undesigned ramps, leaky API
Three problems in one ([scales.R:211-272](R/scales.R#L211)):
- **Coverage holes:** HDA has color but no fill; HFV has nothing; PHA has both.
  faar consequently hand-rolls `scale_fill_steps(low = hda_pal[3], high = hda_pal[5])`
  at ~8 choropleth sites.
- **The "gradient" is the categorical palette strung end-to-end**
  (blue → sage → yellow → coral). That is not a perceptually monotonic ramp; it is
  unreadable as magnitude and fails every CVD simulation style of check. Modern
  practice is designed sequential/diverging ramps (viridis/scico or HCL-derived)
  ([ggplot2 book, scales-colour](https://ggplot2-book.org/scales-colour)).
- **API smell:** a *branded* scale exposing `colors`, `values`, `space` as user
  arguments isn't branded at all — it's `scale_color_gradientn()` with extra steps.

**Fix:** design one sequential and one diverging ramp per brand, anchored on brand
colors but built with `colorspace::sequential_hcl()`/`diverging_hcl()` calibration
and CVD-checked (§1.6). Expose a complete, consistent matrix:
`scale_colour|color|fill_{hda,hfv,pha}_c(palette = c("sequential","diverging"),
direction, na.value, ...)` (afcharts' `scale_*_continuous_af()` shape). Soft-deprecate
`scale_color_gradient_hda/pha` and `scale_fill_gradient_pha` with
`lifecycle::deprecate_warn()`; usage downstream is zero active sites, so risk ≈ nil.

### 1.4 Three ~150-line themes that differ by a config row
[themes.R](R/themes.R) (459 lines). Actual per-brand deltas: base/header font
families, base_size default (14/14/10), html/pdf adjust defaults (4/7 vs 0/0),
lineheight (0.9 vs 1), and two PHA margin quirks. Everything else is identical,
including the fragile `%+replace%` + `+ if (flip_gridlines) {...} else {...}`
construct.

**Fix:** one internal builder + a per-brand config list:
```r
.brand_theme <- function(spec, base_size, flip_gridlines, output_format, ...) { ... }
theme_hda <- function(...) .brand_theme(.brands$hda, ...)
```
Build the element list in plain code (an `if` assigning gridline elements, not an
`if` glued on with `+`), and construct with `complete = TRUE` rather than
`%+replace%` onto `theme_minimal()` — the canonical complete-theme pattern, and
safer under ggplot2 4.x's stricter S7 element validation
([tidyverse 4.0.0 post](https://tidyverse.org/blog/2025/09/ggplot2-4-0-0/)).
Preserve the `...` → `theme()` passthrough exactly (load-bearing in fhfh's ~45
sites). Adding a brand then = adding one registry entry (§1.1) — new-client
theming stops being a copy-paste job (§2, Tier 2).

### 1.5 Not using the ggplot2 4.x theme-palette system (the headline modernization)
Since 4.0, default scales carry `palette = NULL` and resolve palettes from the
theme: `theme(palette.colour.discrete = ..., palette.fill.discrete = ...)`
([release post](https://tidyverse.org/blog/2025/09/ggplot2-4-0-0/)). afcharts has
already moved to 4.0.1-compatible behavior
([afcharts NEWS](https://cran.ma.imperial.ac.uk/web/packages/afcharts/news/news.html)).

**Fix:** have `theme_hda()` et al. set `palette.colour.discrete`,
`palette.fill.discrete`, and `palette.*.continuous` to the brand palettes. Result:
`ggplot(...) + theme_hfv()` is fully branded with **no scale call at all**; the
~65 downstream `scale_fill_hda()` sites keep working but become optional. This is
additive and is the single biggest usability win available. Also adopt the 4.x
`ink`/`paper` arguments and `theme(geom = element_geom(...))` so branded geom
defaults (e.g. default column fill = first brand color) travel with the theme
instead of requiring `update_geom_defaults()` hacks (urbnthemes' current approach).
Requires raising the ggplot2 floor to >= 4.0 (see Open Question Q4).

### 1.6 No colour-blind-safety or contrast checking, anywhere
Never validated. Several brand pairs look risky by inspection (HDA `#8baeaa` sage
vs `#8abc8e` sea-green; PHA `#f39152` orange vs `#be451c` red), but **I have not
run a simulation — treat specific pairs as unverified until checked.**

**Fix:** audit all three palettes with cols4all (`c4a_data()` + its
colorblindcheck-based CVD scoring and WCAG contrast metrics —
[cols4all](https://cols4all.github.io/cols4all-R/)); add a cheap regression test
asserting a minimum pairwise distance under `colorspace::simulate_cvd()` for the
first 4 colors of each palette. Where a palette fails: reorder so the first 3–4
draws are safe (most plots use ≤4 series), and document the safe subset. Don't
silently change hexes — that's a visual output change for every consumer chart.

### 1.7 `colour` vs `color` inconsistency
Discrete scales pass `aesthetics = "colour"`, continuous pass `"color"`
([scales.R:126 vs 218](R/scales.R#L126)). ggplot2 standardises both, so it works,
but it's the kind of inconsistency that breeds copy-paste bugs.
**Fix:** standardise on `"colour"` internally (ggplot2's canonical spelling);
export `scale_colour_hda()` etc. as aliases of the `color` spellings — ggplot2
itself ships both spellings for every scale.

### 1.8 Font stack: showtext at `.onLoad`, against current guidance
[zzz.R](R/zzz.R) + `register_hda_fonts()` run sysfonts/`showtext_auto()` and set
`knitr::opts_chunk$set(fig.showtext = TRUE)` as load-time global side effects.
Current tidyverse guidance is explicit: systemfonts + textshaping + ragg;
*"do not use showtext or extrafont for new workflows"*
([Fonts in R, May 2025](https://tidyverse.org/blog/2025/05/fonts-in-r/)). showtext
also outlines text in PDF/SVG (inaccessible, no text selection, large files) and
couples output to DPI — a real problem the day fhfh/faar turn their PDF routes on.

**Fix (staged, Tier 3):** register the bundled TTFs with
`systemfonts::add_font()`/`register_variant()`, render via ragg
(`dev: ragg_png` in consumer Quarto YAML — Quarto does *not* default to ragg,
[ragg](https://ragg.r-lib.org/)), and drop showtext/sysfonts from Imports. This
changes text metrics in every rendered chart, so it ships in its own minor
release, verified consumer-by-consumer. Keep the `hdatools.fonts` opt-out.

### 1.9 Smaller issues (worth fixing while in there)
| Issue | Fix |
|---|---|
| `flip_gridlines` exists as both a theme arg and an exported helper with its own hardcoded grays | Keep both (both are used downstream) but implement the arg via the helper's element logic; single definition of the grid color |
| fed-workforce forces `ggsave(bg = "white")`, comment blames transparent theme background | Current code sets `rect` fill white ([themes.R:38-43](R/themes.R#L38)) — likely already fixed post-0.1.7; **verify at rollout**, and confirm `plot.background` is explicit under `complete = TRUE` |
| `get_output_format()` maps every non-HTML knitr format (typst, docx, gfm) to `"pdf"`; `"studio"` is an odd name | Recognize typst/docx explicitly; treat `"studio"`→`"interactive"` with the old value kept working |
| `publish_plot()` hardcodes `height_svg = 4`; usage is 2 archive sites | Expose `...` passthrough to `girafe()`; don't invest further (near-dead) |
| Heavy Imports: dplyr, stringr, glue, knitr each justify one call | Optional slimming: `strwrap()` for stringr, `sprintf()` for glue. dplyr/rlang stay (add_reliability). knitr stays (format detection). Low priority |
| `_pkgdown.yml` uses BS3-era `template: params: bootswatch:` | `template: bootstrap: 5`; add reference index grouping |
| pkgdown article needs tidycensus + API key + network | Keep, but add a network-free quick-start article generated from bundled data so the site rebuilds offline |
| `scale_color_gradient_*` docs say "depreciated" | Typo; goes away with §1.3 |

---

## 2. Tiered improvements

Effort: S (<½ day), M (1–2 days), L (3+ days). Blast radius = faar / fhfh / vhtf / fed-workforce (+ pha-update-2026 unverified).

### Tier 1 — consolidation, zero user-facing change (do first, safe)
| # | Item | Effort | Blast radius | API break |
|---|---|---|---|---|
| 1.1 | Internal palette registry; factories/gradients read from it | S | none (identical output; existing tests must pass unmodified) | no |
| 1.2 | One internal discrete factory + scale constructor; 9 exports become thin wrappers | S | none | no |
| 1.3 | One internal theme builder + per-brand spec; 3 themes become wrappers; `complete = TRUE` | M | none intended — verify with structural tests that every computed element is identical pre/post | no |
| 1.4 | Standardise `aesthetics = "colour"`; add `scale_colour_*` aliases | S | none (additive) | no |
| 1.5 | pkgdown → Bootstrap 5; reference grouping; fix "depreciated" typos | S | none | no |
| 1.6 | Structural test expansion: element-identity snapshot of each theme (guards 1.3) | S | none | no |

### Tier 2 — new features, additive (the value release)
| # | Item | Effort | Blast radius | API break |
|---|---|---|---|---|
| 2.1 | Export `hda_colors`/`hfv_colors`/`pha_colors` named vectors + `hda_color()` accessor | S | Positive: lets faar/fhfh/fed-workforce delete local hex vectors | no |
| 2.2 | Designed sequential + diverging ramps per brand; complete `scale_*_{brand}_c()` matrix; soft-deprecate `scale_*_gradient_*` | M | ~0 active gradient call sites; faar can replace 8 hand-rolled `scale_fill_steps()` | deprecation only |
| 2.3 | ggplot2 4.x theme-carried palettes (`palette.colour.discrete` etc.) + `ink`/`paper` + `element_geom()` defaults in themes | M | Additive; existing explicit `scale_*` calls override the theme palette, so ~65 sites unaffected. Needs ggplot2 >= 4.0 floor (Q4) | no |
| 2.4 | **Brand extensibility, proven with VHA as the fourth brand** (`theme_vha`, palettes, scales from one registry entry + bundled Montserrat), plus a short "adding a new client brand" howto in the repo docs | S–M (after T1) | Retires vhtf's ~200-line clone; makes future client palettes a one-entry job | no |
| 2.5 | CVD audit (cols4all) + documented safe-subset ordering + simulate_cvd regression test | M | Reordering changes color assignment in existing charts → do at a consumer re-render boundary, or document-only first | behavior change if reordered (opt-in) |
| 2.6 | ggtext span helper (e.g. `hda_span("text", "sky")`) for the hand-pasted `<span style='color:#…'>` pattern in fhfh/fed-workforce subtitles | S | Positive only | no |
| 2.7 | Focus/emphasis palette (one brand color + grays) — afcharts pattern, fits "highlight one series" housing-report idiom | S | Additive | no |

### Tier 3 — ambitious modernization (each is its own release)
| # | Item | Effort | Blast radius | API break |
|---|---|---|---|---|
| 3.1 | **systemfonts/ragg migration**, drop showtext/sysfonts; consumers add `dev: ragg_png` | L | Text metrics shift in every chart in all repos; unpinned vhtf/fed-workforce hit immediately on install → coordinate | rendering change, not API |
| 3.2 | Emit/ship a `_brand.yml` per brand (colors, typography, logos) so Quarto docs and hdatools charts share one spec; optionally read palettes *from* it | M–L | None until consumers adopt in their `_quarto.yml` | no |
| 3.3 | vdiffr visual-regression suite (SVG snapshots, font-independent hardcoded metrics — [vdiffr](https://vdiffr.r-lib.org/)) | M | none; expect snapshot churn on ggplot2 bumps | no |
| 3.4 | `use_hdatools(brand)` global setter (theme_set + geom/knitr defaults), afcharts/urbnthemes pattern | S–M | Additive | no |
| 3.5 | Split analysis utils (`add_reliability`, `fct_case_when`) into a separate package | M | All four repos touch at least one | yes — **recommend against** for now |

---

## 3. Open questions / decisions (recommended default first)

**Q1 — Palette single source of truth?**
→ **Plain named character vectors in `R/palettes.R` (internal registry + exported
vectors).** Not `data/` objects (can't be used at build time by the package's own
functions without `LazyData` gymnastics), not brand.yml-driven yet (adds a runtime
dependency and YAML parsing for zero current benefit). Revisit brand.yml as the
*source* only if item 3.2 proves out.

**Q2 — Adopt `_brand.yml`?**
→ **Yes, but as an output, not an input** (Tier 3.2): generate one per brand from
the registry so Quarto 1.6+ document theming matches chart theming
([brand.yml](https://posit-dev.github.io/brand-yml/)). Don't make the package
parse it at runtime.

**Q3 — Deprecate old names or break them?**
→ **fhfh's surface is inviolable; everything else may change with cheap
`lifecycle` soft-deprecations.** Must keep exact behavior: `theme_hda()` signature
+ `...` passthrough, `add_zero_line()`, `scale_fill_hda()` named args. Free to
deprecate now, remove in 0.5+: `scale_*_gradient_*` (0 active sites),
`*_pal_discrete()` exports (1 site, in faar). Positional `direction` support is
cheap to keep, so keep it, but it is no longer a binding constraint.

**Q4 — Raise ggplot2 floor to >= 4.0?**
→ **Yes, at the Tier 2 release.** The theme-palette feature (2.3) needs it, faar and
fhfh upgrade via deliberate `renv::snapshot()` anyway, and dual-pathing 3.5/4.0
inside the themes costs more than it buys. The floating repos already resolve
current ggplot2 on fresh installs.

**Q5 — Fonts: keep showtext or migrate to systemfonts/ragg?**
→ **Migrate (Tier 3.1), in a dedicated release with side-by-side render comparison
in one consumer before tagging.** Sequence: Tier 1+2 first (pure R refactors),
fonts last, so rendering diffs are attributable. Until then, keep the current
bundled-TTF showtext path — it works offline, which was the 0.2.0 win.

**Q6 — Continuous ramp design: programmatic or hand-designed?**
→ **Programmatic from brand anchors via `colorspace` HCL tooling, then eyeballed
and CVD-checked.** Hand-designing three brands' worth of ramps is designer work
the team doesn't need; HCL interpolation with a fixed luminance sweep is the
defensible default.

**Q7 — Reorder palettes for CVD safety?**
→ **Audit and document now; reorder only with sign-off** (it silently recolors
every existing multi-series chart on next render). If a palette fails badly,
prefer adding a `cvd_safe = TRUE` argument or an explicitly-named safe palette
over changing defaults.

**Q8 — Add VHA as a first-class brand?**
→ **Yes** (2.4) — vhtf maintains a full parallel clone today. Confirm brand
ownership of the hex set and bundle Montserrat (OFL) alongside the other fonts.

**Q9 — Keep house-style theme defaults (`legend.position = "none"`, blank axis
titles)?**
→ **Keep.** ~150 downstream call sites are built around them; consumers who want
legends already pass `legend.position =` through `...`.

**Q10 — `add_reliability()`: anything more needed?**
→ **Verify, then communicate.** The 0.2.0 `cv_col`/`scale` rework appears to cover
exactly fhfh's percent-scale case, but fhfh still bans the function in its
CLAUDE.md/README. Confirm with fhfh's actual data shape during that repo's next
session and retire the ban there — not as a drive-by from this package.

---

## 4. Everything else for 2026 / Quarto streamlining

- **Quarto render defaults**: document (README + article) the recommended consumer
  `_quarto.yml` block — `knitr: opts_chunk: dev: "ragg_png"` (post-3.1),
  `fig-dpi`, and `bg` handling. Quarto does not use ragg by default.
- **HTML+PDF parity**: all PDF routes downstream are currently dormant, but fhfh
  has typst on its roadmap. Add `"typst"` awareness to `get_output_format()` now
  (cheap), and treat the systemfonts migration (3.1) as the prerequisite for
  selectable, accessible text in PDF — showtext outlines all text.
- **`use_hdatools(brand)`** (3.4): one call in `_common.R` sets theme, geom
  defaults, and knitr options — collapses the per-chunk boilerplate the books
  repeat today.
- **Logo/caption helper**: `get_logo()` returns a raw `<img>` glue string; add a
  `caption_source()`-style helper (urbnthemes has `urbn_source()`) only if
  consumers ask — not speculatively.
- **Testing**: keep the font-free `ggplot_build()`/`calc_element()` structural
  approach (works, per CLAUDE.md); add (a) theme element-identity tests before the
  Tier 1 refactor, (b) CVD distance tests (2.5), (c) vdiffr snapshots (3.3) last,
  after fonts stabilize.
- **CI**: no visible CI config — add GitHub Actions `R-CMD-check` (windows +
  ubuntu, ggplot2 release + devel) before the refactor lands, so consumer-facing
  regressions surface pre-tag. (Verify: repo has no `.github/workflows/` — worth a
  double check, none was found.)
- **pkgdown**: Bootstrap 5 template, grouped reference index (Themes / Palettes &
  scales / Helpers / Analysis utils), a network-free quick-start article; keep the
  tidycensus article as the long-form demo.
- **Consumer hygiene (out of package scope, worth scheduling)**: vhtf and
  fed-workforce should pin hdatools (renv or a tagged ref) before any of this
  ships; faar/fhfh re-snapshot deliberately per the existing rollout convention.
- **Release sequencing**: Tier 1 → `0.3.0` (pure refactor, output-identical);
  Tier 2 → `0.4.0` (features + ggplot2 4.0 floor); fonts/brand.yml/vdiffr → `0.5.0`.
  Each follows the CLAUDE.md release checklist; consumer bumps happen in their own
  sessions, never drive-by.

---

## If you only do three things

1. **Tier 1 consolidation into a brand registry** (one factory + one theme
   builder reading per-brand specs; output provably identical) — everything else
   builds on it, and adding a client brand becomes a one-entry job.
2. **Export named brand colors + designed continuous scales** (2.1 + 2.2) — kills
   the hardcoded-hex copies in every consumer repo.
3. **ggplot2 4.x theme-carried palettes** (2.3) — `+ theme_hfv()` becomes the whole
   branding story; scale calls become optional.
