# strip.text diagnostic — theme_pha parity (Verification §2)

Run **before** editing `R/themes.R` for commit 4 (theme_pha parity + strip.text),
under the release target stack. This reproduces the ggplot2 4.0 "class clash"
between S7 `element_text()` and the S3-based `ggtext::element_markdown()` used for
strip/title/caption elements, and confirms the supported override idioms.

## Environment

- R 4.6.0 (2026-04-24 ucrt)
- ggplot2 **4.0.3**
- ggtext **0.1.2** (still the latest on CRAN as of 2026-07-15; no S7 release yet —
  CRAN issue #135 remains open, so the plan's `ggtext (>= 0.1.2)` floor is unchanged)

## Method

Faceted plot exercised via `ggplotGrob()` (forces full theme merge + grob build):

```r
d <- data.frame(x = letters[1:4], y = 1:4, f = rep(c("Group one", "Group two"), 2))
base <- ggplot(d, aes(x, y)) + geom_col() + facet_wrap(~f)
```

Four cases, each on the **current (pre-commit-4) package source**.

## Results

### Case A — `base + theme_pha() + theme(strip.text = element_text(...))`

**RESULT: clean build (no error).**

The *current* `theme_pha()` does not set `strip.text`, so it inherits
`theme_minimal()`'s S7 `element_text`. Overriding it with another S7
`element_text()` merges class-for-class and succeeds. This is precisely the gap
commit 4 closes — and note that once `theme_pha()` sets
`strip.text = element_markdown(...)`, Case A will begin to error exactly like
Case B (hence the roxygen/README guidance to override strips with
`ggtext::element_markdown()`, never raw `element_text()`).

### Case B — `base + theme_hda() + theme(strip.text = element_text(...))`

**RESULT: ERROR** — `class: rlang_error/error/condition`

```
Can't merge the `strip.text` theme element.
Caused by error in `method(merge_element, list(ggplot2::element, class_any))`:
! Only elements of the same class can be merged.
```

`theme_hda()` sets `strip.text = ggtext::element_markdown()` (S3). Overriding with
an S7 `element_text()` trips ggplot2 4.0's class-compatibility check in
`merge_element`. This is the documented clash.

### Case C — `base + theme_hda() + theme(strip.text = ggtext::element_markdown(...))`

**RESULT: clean build (no error).**

Overriding an `element_markdown` strip with another `element_markdown` merges
class-for-class. This is the supported override idiom.

### Case D — `base + theme_pha(strip.text = ggtext::element_markdown(...))` (passthrough)

**RESULT: ERROR** — `class: simpleError/error/condition`

```
unused argument (strip.text = ggtext::element_markdown(size = 8, colour = "red"))
```

Expected: the current `theme_pha()` has no `...` passthrough. Commit 4 adds
`...`, after which this case builds cleanly.

## Conclusion

All four cases match the plan's assumptions. Proceeding with commit 4:

- `theme_pha()` gains `strip.text = ggtext::element_markdown(...)` at parity with
  `theme_hda()`/`theme_hfv()` (hda metrics — see metrics-guard note below), plus a
  `...` passthrough so Case D works.
- Override guidance (override strips with `ggtext::element_markdown()`, never raw
  `element_text()`, under ggplot2 >= 4.0) is documented in roxygen on all three
  themes and in the README (README text is deferred to the docs commit).

### Metrics guard (plan #8)

The plan's guard: *if* any consumer currently renders a **faceted `theme_pha()`
chart**, use theme_minimal-inherited strip metrics (`size = adjusted_base_size *
0.8`, no margin) for visual parity; otherwise use the hda metrics. The plan notes
consumers currently **de-facet** theme_pha charts (the workaround this feature
removes), so the guard condition is expected to be false → hda metrics.

**Consumer grep (this session):** the only file where `theme_pha()` co-occurs
with `facet_*` is `faar/archive/needs-current-temp.qmd` — an archived, not
currently-rendered doc, and faar stays pinned to the old hdatools. No
currently-rendered doc in pha-update-2026 or fhfh renders a faceted `theme_pha()`
chart. Guard condition is false → **hda strip metrics used** (the plan default).

## Post-commit-4 confirmation

Re-run after adding `strip.text = element_markdown()` and the `...` passthrough to
`theme_pha()`:

| Case | Before | After |
|---|---|---|
| A `theme_pha() + theme(strip.text = element_text())` | clean | **ERROR** (now clashes, at parity with theme_hda) |
| C `theme_pha() + theme(strip.text = element_markdown())` | clean | clean |
| D `theme_pha(strip.text = element_markdown())` passthrough | ERROR (unused arg) | clean |

Case A flipping from clean to a class-merge error is the expected, intended
consequence of giving `theme_pha()` a markdown strip element — and the reason the
override guidance now ships in the roxygen for all three themes.
