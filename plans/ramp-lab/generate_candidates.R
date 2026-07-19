# Ramp Lab — Stage 1: candidate generator
#
# Standalone dev tool for Session 2 (item 2.2, Q6) of phase-2-features-0.4.0.md.
# Generates sequential/diverging HCL ramp candidates per brand from
# hdatools:::.brands's live named palettes, and writes plans/ramp-lab/candidates.js
# for the Stage 2 dashboard (dashboard.html) to load via <script src>.
#
# Never run inline (-e); always `Rscript plans/ramp-lab/generate_candidates.R`.

setwd("R:/hda/hdatools")
devtools::load_all(".", quiet = TRUE)
library(colorspace)

if (!requireNamespace("jsonlite", quietly = TRUE)) {
  stop("jsonlite is required to emit candidates.js (dev-only dependency for this tool).")
}

brands <- hdatools:::.brands

# Experimental HFV-only secondary colors (explicit hex from Jonathan, not part
# of hdatools:::.brands — used in lieu of a weaker existing anchor where they
# read as a better fit; see anchor_specs$hfv below for which ones they replaced).
experimental_colors <- list(
  hfv = c(Cerulean = "#7fc7e0", Leaf = "#6fb547")
)

# Every ramp's light end (sequential) / neutral center (diverging) anchors to
# a shared, brand-wide hint of cream instead of pure white or a same-hue tint —
# keeps light classes visible against a white page/basemap. Fixed across all
# brands and both variants; only the cream's LIGHTNESS varies with the
# "wide-contrast" variant, matching how the dark end already varies.
CREAM_H <- 80
CREAM_C <- 10

# ---- HCL helpers -------------------------------------------------------

get_hcl <- function(hex) {
  coords <- as(hex2RGB(hex), "polarLUV")@coords
  c(H = unname(coords[1, "H"]), C = unname(coords[1, "C"]), L = unname(coords[1, "L"]))
}

clamp <- function(x, lo, hi) pmin(pmax(x, lo), hi)

hue_dist <- function(h1, h2) {
  d <- abs(h1 - h2) %% 360
  pmin(d, 360 - d)
}

resolve_source <- function(brand, name) {
  pal <- brands[[brand]]$palette
  if (name %in% names(pal)) {
    return(list(hex = unname(pal[name]), label = name))
  }
  exp_colors <- experimental_colors[[brand]]
  if (!is.null(exp_colors) && name %in% names(exp_colors)) {
    return(list(hex = unname(exp_colors[name]), label = sprintf("%s (experimental %s secondary)", name, toupper(brand))))
  }
  stop(sprintf("Unknown source color '%s' for brand '%s'", name, brand))
}

# ---- Ramp builders -------------------------------------------------------
# Sequential: a single real colorspace::sequential_hcl() call, hue-shifting
# from the anchor's own hue (dark end) to the shared cream hue (light end).
#
# Diverging: colorspace::diverging_hcl() always collapses its center to
# ACHROMATIC (chroma 0) by construction — it has no way to express a tinted
# center. So a cream center is built from two real sequential_hcl() calls
# (one per arm, each dark-anchor -> cream), stitched with the exact same
# n/n2/parity logic diverging_hcl() itself uses internally. This is still
# "programmatic from brand anchors via colorspace HCL" (Q6) — just composed
# from two sequential_hcl() calls instead of one diverging_hcl() call.

build_sequential <- function(params, n) {
  colorspace::sequential_hcl(
    n, h = c(params$h1, CREAM_H), c = c(params$c1, CREAM_C),
    l = c(params$l1, params$l2), power = params$power
  )
}

build_diverging <- function(params, n) {
  n2 <- ceiling(n / 2)
  arm <- function(h) {
    colorspace::sequential_hcl(
      n2, h = c(h, CREAM_H), c = c(params$c1, CREAM_C),
      l = c(params$l1, params$l2), power = params$power
    )
  }
  out <- c(arm(params$h1), rev(arm(params$h2)))
  if (floor(n / 2) < n2) out <- out[-n2]
  out
}

# ---- Guardrail checks ---------------------------------------------------
# These flag problems as visible warnings on each candidate; nothing here
# silently drops or "fixes" a candidate.

hex_L <- function(hex) {
  vapply(hex, function(h) as(hex2RGB(h), "polarLUV")@coords[1, "L"], numeric(1))
}

check_seq_monotonic <- function(hex) {
  L <- hex_L(hex)
  d <- diff(L)
  # allow tiny float noise; a real reversal is what we care about
  if (any(d < -0.3) && any(d > 0.3)) {
    "Luminance is not monotonic end to end — the ramp reverses direction somewhere in the middle."
  } else {
    NULL
  }
}

check_diverging_arms <- function(params) {
  d <- hue_dist(params$h1, params$h2)
  if (d < 60) {
    sprintf(
      "Anchor hues are only %.0f%s apart — too close to read as a genuine diverging scheme (aim for >=60-90%s).",
      d, "°", "°"
    )
  } else {
    NULL
  }
}

check_endpoint_contrast <- function(hex, is_diverging) {
  # A diverging ramp's "light end" is its cream CENTER (both true endpoints
  # are the dark arm tips) — a pale center is normal/expected there, so it
  # only warrants a warning near pure white. A sequential ramp's light end is
  # a real choropleth class that must still read against white, so that gets
  # the stricter threshold.
  L <- hex_L(hex)
  msgs <- character(0)
  light_end_L <- if (is_diverging) max(L) else L[length(L)]
  light_threshold <- if (is_diverging) 98.5 else 96.5
  dark_end_L <- if (is_diverging) min(L) else L[1]
  if (light_end_L > light_threshold) {
    msgs <- c(msgs, sprintf(
      "Light end (L=%.1f) nearly disappears against a white background.", light_end_L
    ))
  }
  if (dark_end_L < 14) {
    msgs <- c(msgs, sprintf(
      "Dark end (L=%.1f) is close enough to black to fight with text/gridlines.", dark_end_L
    ))
  }
  if (length(msgs)) paste(msgs, collapse = " ") else NULL
}

check_nudge_cap <- function(hue_delta, chroma_delta, label) {
  # Only ever evaluated against the DARK/anchor end's true palette source —
  # the cream light end/center is a fixed design constant, not a "nudge" of
  # any brand color, so it never participates in this check.
  msgs <- character(0)
  if (abs(hue_delta) > 20) {
    msgs <- c(msgs, sprintf(
      "%s: hue nudged %+.0f%s — past the modest cap, risks reading as a different hue family.",
      label, hue_delta, "°"
    ))
  }
  if (abs(chroma_delta) > 30) {
    msgs <- c(msgs, sprintf(
      "%s: chroma nudged %+.0f — larger than the modest-nudge guideline.", label, chroma_delta
    ))
  }
  if (length(msgs)) paste(msgs, collapse = " ") else NULL
}

# ---- Anchor design ------------------------------------------------------
# Each sequential anchor is inspired by ONE named palette color (or, for HFV,
# one of the two experimental secondary colors): the dark/saturated end
# nudges that color's own HCL coordinates (chroma up for punch on muted
# colors, luminance down for ramp depth). The light end is NOT a further tint
# of that same hue — it always resolves to the shared brand-wide cream anchor
# (CREAM_H/CREAM_C, see above), independent of the anchor's own hue.
#
# Each diverging anchor pairs TWO source colors on opposite sides of the hue
# wheel, sharing one chroma target and luminance range, converging on the
# same shared cream point at the center (see build_diverging()).

seq_anchor <- function(brand, source_name, h_nudge, c1, l1, l2 = 95) {
  src_info <- resolve_source(brand, source_name)
  src <- get_hcl(src_info$hex)
  h <- src["H"] + h_nudge
  list(
    sourceNames = list(dark = src_info$label, light = sprintf("shared cream (H~%d, C~%d)", CREAM_H, CREAM_C)),
    nudgeNote = sprintf(
      "Off %s: hue %s%.0f%s (source %.0f%s -> final %.0f%s), chroma %.0f -> %.0f (dark end), luminance %.0f -> %.0f (dark end); light end anchors to a shared cream tone (H~%d, C~%d) at L~%.0f, not this color's own hue.",
      src_info$label,
      ifelse(h_nudge >= 0, "+", ""), h_nudge, "°", src["H"], "°", h, "°",
      src["C"], c1, src["L"], l1, CREAM_H, CREAM_C, l2
    ),
    hueDelta = h_nudge,
    chromaDelta = c1 - src["C"],
    base = list(h1 = unname(h), c1 = c1, l1 = l1, l2 = l2)
  )
}

div_anchor <- function(brand, name1, name2, c1, l1 = 28, l2 = 95) {
  s1_info <- resolve_source(brand, name1)
  s2_info <- resolve_source(brand, name2)
  s1 <- get_hcl(s1_info$hex)
  s2 <- get_hcl(s2_info$hex)
  list(
    sourceNames = list(arm1 = s1_info$label, arm2 = s2_info$label),
    nudgeNote = sprintf(
      "Off %s (arm 1, hue %.0f%s) and %s (arm 2, hue %.0f%s): shared chroma target %.0f (arm1 source C=%.0f, arm2 source C=%.0f), luminance sweep %.0f -> %.0f into a shared cream center (H~%d, C~%d), not a fully neutral one.",
      s1_info$label, s1["H"], "°", s2_info$label, s2["H"], "°", c1, s1["C"], s2["C"], l1, l2, CREAM_H, CREAM_C
    ),
    hueDelta = 0,
    chromaDelta = c1 - mean(c(s1["C"], s2["C"])),
    base = list(h1 = unname(s1["H"]), h2 = unname(s2["H"]), c1 = c1, l1 = l1, l2 = l2)
  )
}

anchor_specs <- list(
  hda = list(
    sequential = list(
      seq_anchor("hda", "Blue", h_nudge = 0, c1 = 60, l1 = 26),
      seq_anchor("hda", "Coral", h_nudge = 0, c1 = 85, l1 = 30),
      seq_anchor("hda", "Sea Green", h_nudge = 2, c1 = 55, l1 = 28)
    ),
    diverging = list(
      div_anchor("hda", "Blue", "Coral", c1 = 70),
      div_anchor("hda", "Blue", "Yellow", c1 = 65),
      div_anchor("hda", "Lavender", "Sea Green", c1 = 45)
    )
  ),
  hfv = list(
    # "Grass" (teal, H~189) sat too close to "Sky" (H~192) to earn its own
    # anchor once a genuine green option existed — swapped for the
    # experimental "Leaf" color, a true green far from every other HFV hue
    # and already near full native chroma (little nudging needed). "Lilac vs
    # Desert" gave the narrowest hue separation (116 degrees) of HFV's three
    # original diverging pairs — swapped for "Cerulean vs Desert" (165
    # degrees separation, a cleaner diverging read).
    sequential = list(
      seq_anchor("hfv", "Shadow", h_nudge = 0, c1 = 45, l1 = 24),
      seq_anchor("hfv", "Leaf", h_nudge = 0, c1 = 65, l1 = 28),
      seq_anchor("hfv", "Berry", h_nudge = 0, c1 = 80, l1 = 30)
    ),
    diverging = list(
      div_anchor("hfv", "Shadow", "Desert", c1 = 55),
      div_anchor("hfv", "Leaf", "Berry", c1 = 62),
      div_anchor("hfv", "Cerulean", "Desert", c1 = 55)
    )
  ),
  pha = list(
    sequential = list(
      seq_anchor("pha", "Dark Blue", h_nudge = 0, c1 = 58, l1 = 26),
      seq_anchor("pha", "Red", h_nudge = 0, c1 = 90, l1 = 28),
      seq_anchor("pha", "Green", h_nudge = 0, c1 = 52, l1 = 26)
    ),
    diverging = list(
      div_anchor("pha", "Dark Blue", "Red", c1 = 65),
      div_anchor("pha", "Dark Blue", "Orange", c1 = 60),
      div_anchor("pha", "Purple", "Green", c1 = 45)
    )
  )
)

# ---- Grid variants -------------------------------------------------------
# Two variants per anchor (keeps each brand x ramp-type slot at 6 candidates,
# within the "3-6, not dozens" bound): a "standard" linear sweep, and a
# "wide-contrast" sweep with a deeper dark end, brighter cream end, punchier
# dark-end chroma, and an eased power curve. The cream hue/chroma itself
# (CREAM_H/CREAM_C) stays fixed across variants — only its lightness moves.

make_seq_variants <- function(base) {
  list(
    standard = list(
      h1 = base$h1, c1 = base$c1, l1 = base$l1, l2 = base$l2, power = 1
    ),
    wide_contrast = list(
      h1 = base$h1,
      c1 = clamp(base$c1 + 12, 0, 100),
      l1 = clamp(base$l1 - 6, 12, 95),
      l2 = clamp(base$l2 + 1, 5, 98),
      power = 1.2
    )
  )
}

make_div_variants <- function(base) {
  list(
    standard = list(
      h1 = base$h1, h2 = base$h2, c1 = base$c1, l1 = base$l1, l2 = base$l2, power = 1
    ),
    wide_contrast = list(
      h1 = base$h1, h2 = base$h2,
      c1 = clamp(base$c1 + 12, 0, 100),
      l1 = clamp(base$l1 - 6, 12, 95),
      l2 = clamp(base$l2 + 1, 5, 99),
      power = 1.2
    )
  )
}

variant_label <- list(
  standard = "Standard (linear HCL sweep)",
  wide_contrast = "Wide-contrast (deeper dark end, punchier chroma, eased curve)"
)

# ---- Assemble candidates --------------------------------------------------

N_SMOOTH <- 32
N_BINNED <- 7

slugify <- function(x) tolower(gsub("[^a-z0-9]+", "-", tolower(x)))

build_candidate <- function(brand, type, anchor, variant_name, variant_params, idx) {
  is_div <- type == "diverging"
  hex_smooth <- if (is_div) build_diverging(variant_params, N_SMOOTH) else build_sequential(variant_params, N_SMOOTH)
  hex_binned <- if (is_div) build_diverging(variant_params, N_BINNED) else build_sequential(variant_params, N_BINNED)

  warnings <- Filter(Negate(is.null), list(
    if (is_div) NULL else check_seq_monotonic(hex_smooth),
    if (is_div) check_diverging_arms(variant_params) else NULL,
    check_endpoint_contrast(hex_smooth, is_div),
    check_nudge_cap(anchor$hueDelta, anchor$chromaDelta, anchor$nudgeNote)
  ))

  anchor_label <- if (is_div) {
    sprintf("%s vs %s", anchor$sourceNames$arm1, anchor$sourceNames$arm2)
  } else {
    sprintf("%s -> cream", anchor$sourceNames$dark)
  }

  list(
    id = sprintf("%s-%s-%s-%s", brand, substr(type, 1, 3), slugify(anchor_label), variant_name),
    brand = brand,
    type = type,
    anchorLabel = anchor_label,
    inspiration = anchor$sourceNames,
    nudgeNote = anchor$nudgeNote,
    variant = variant_name,
    variantLabel = variant_label[[variant_name]],
    params = c(variant_params, list(hc = CREAM_H, cc = CREAM_C)),
    sourceHueDelta = unname(anchor$hueDelta),
    sourceChromaDelta = unname(anchor$chromaDelta),
    hexSmooth = unname(hex_smooth),
    hexBinned = unname(hex_binned),
    warnings = warnings
  )
}

candidates <- list()
for (brand in names(anchor_specs)) {
  for (type in c("sequential", "diverging")) {
    anchors <- anchor_specs[[brand]][[type]]
    slot <- list()
    for (anchor in anchors) {
      variants <- if (type == "sequential") make_seq_variants(anchor$base) else make_div_variants(anchor$base)
      for (variant_name in names(variants)) {
        slot[[length(slot) + 1]] <- build_candidate(
          brand, type, anchor, variant_name, variants[[variant_name]]
        )
      }
    }
    candidates[[brand]][[type]] <- slot
  }
}

# ---- Emit candidates.js ---------------------------------------------------

json <- jsonlite::toJSON(candidates, auto_unbox = TRUE, pretty = TRUE, digits = 4)
out_path <- file.path("plans", "ramp-lab", "candidates.js")
writeLines(c("// Generated by generate_candidates.R — do not hand-edit.", "const CANDIDATES = ", paste0(json, ";")), out_path)

cat(sprintf("Wrote %s\n", out_path))
n_total <- sum(vapply(candidates, function(b) sum(vapply(b, length, integer(1))), integer(1)))
cat(sprintf("Total candidates: %d\n", n_total))
for (brand in names(candidates)) {
  for (type in names(candidates[[brand]])) {
    n <- length(candidates[[brand]][[type]])
    n_warn <- sum(vapply(candidates[[brand]][[type]], function(c) length(c$warnings) > 0, logical(1)))
    cat(sprintf("  %s / %s: %d candidates (%d with warnings)\n", brand, type, n, n_warn))
  }
}
