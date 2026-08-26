# CVD regression tests — pairwise delta-E (CIE76) in Lab space
#
# These tests assert that the first 4 colors of each brand palette maintain a
# minimum pairwise perceptual distance under full-severity CVD simulation
# (colorspace::protan/deutan/tritan, sev = 1). They guard against future edits
# that make palette colors more similar under CVD — they do NOT change or
# reorder any palette (per Q7, plans/DECISIONS.md, 2026-07-18).
#
# Thresholds are set conservatively below each brand's observed minimum:
#   HDA first-4: min observed ~22.7 (deutan) → threshold 20
#   HFV first-4: min observed ~12.1 (deutan) → threshold 10
#   PHA first-4: min observed ~27.3 (deutan) → threshold 22, but tritan is
#     handled separately: Teal vs Blue collapses there (see the flagged-pair
#     test at the bottom of this file)
#   VHA first-4: min observed ~16.5 (deutan) → threshold 12

# ── Helpers ──────────────────────────────────────────────────────────────────

.hex_to_lab <- function(hex) {
  colorspace::coords(
    methods::as(colorspace::hex2RGB(hex), "LAB")
  )
}

.pairwise_min_delta_e <- function(hex_vec) {
  labs <- .hex_to_lab(unname(hex_vec))
  n    <- length(hex_vec)
  pairs <- combn(seq_len(n), 2)
  dEs <- apply(pairs, 2, function(p) {
    sqrt(sum((.hex_to_lab(hex_vec[p[1L]]) - .hex_to_lab(hex_vec[p[2L]]))^2))
  })
  min(dEs)
}

.sim_min_delta_e <- function(hex_vec, cvd_fn) {
  sim <- cvd_fn(hex_vec, sev = 1)
  structure(sim, names = names(hex_vec))
  .pairwise_min_delta_e(sim)
}

# Same as .sim_min_delta_e(), minus one named pair. Used where a palette has a
# single documented CVD collapse that would otherwise mask every other pair's
# separation, so the rest still gets a real regression guard.
.sim_min_delta_e_excluding <- function(hex_vec, cvd_fn, exclude) {
  sim   <- cvd_fn(unname(hex_vec), sev = 1)
  pairs <- combn(seq_along(sim), 2)
  keep  <- !apply(pairs, 2, function(p) setequal(names(hex_vec)[p], exclude))
  dEs <- apply(pairs[, keep, drop = FALSE], 2, function(p) {
    sqrt(sum((.hex_to_lab(sim[p[1L]]) - .hex_to_lab(sim[p[2L]]))^2))
  })
  min(dEs)
}

# ── HDA first-4 (Blue / Green / Yellow / Coral) ──────────────────────────────

test_that("HDA first-4 colors maintain min delta-E >= 20 under CVD", {
  pal4 <- hdatools:::`.brands`$hda$palette[1:4]
  expect_gte(.sim_min_delta_e(pal4, colorspace::protan), 20)
  expect_gte(.sim_min_delta_e(pal4, colorspace::deutan), 20)
  expect_gte(.sim_min_delta_e(pal4, colorspace::tritan), 20)
})

# ── HFV first-4 (Shadow / Sky / Lilac / Grass) ───────────────────────────────
# Sky vs Grass is structurally risky (~12 delta-E under all CVD types).
# Threshold is 10 — sufficient to catch a regression without false fragility.

test_that("HFV first-4 colors maintain min delta-E >= 10 under CVD", {
  pal4 <- hdatools:::`.brands`$hfv$palette[1:4]
  expect_gte(.sim_min_delta_e(pal4, colorspace::protan), 10)
  expect_gte(.sim_min_delta_e(pal4, colorspace::deutan), 10)
  expect_gte(.sim_min_delta_e(pal4, colorspace::tritan), 10)
})

# ── PHA first-4 (Orange / Teal / Blue / Navy) ────────────────────────────────
# All four are PHA's own 2026 guide colors. Protan and deutan are strong
# across every pair (min observed 29.0 and 27.3). Tritan is strong too — 52.9
# — for every pair EXCEPT Teal vs Blue, which collapses to 6.6; that pair gets
# its own test below and is excluded here so this one still guards the other
# five pairs under tritanopia instead of pinning to the collapse.

test_that("PHA first-4 colors maintain min delta-E >= 22 under protan and deutan", {
  pal4 <- hdatools:::`.brands`$pha$palette[1:4]
  expect_gte(.sim_min_delta_e(pal4, colorspace::protan), 22)
  expect_gte(.sim_min_delta_e(pal4, colorspace::deutan), 22)
})

test_that("PHA first-4 colors hold up under tritan apart from Teal/Blue", {
  pal4 <- hdatools:::`.brands`$pha$palette[1:4]
  expect_gte(
    .sim_min_delta_e_excluding(pal4, colorspace::tritan, c("Teal", "Blue")),
    40
  )
})

# ── VHA first-4 (Dark Turq / Light Green / Yellow / Light Turq) ──────────────
# Dark Turq vs Light Turq is the tightest pair (~16–18 delta-E under CVD).

test_that("VHA first-4 colors maintain min delta-E >= 12 under CVD", {
  pal4 <- hdatools:::`.brands`$vha$palette[1:4]
  expect_gte(.sim_min_delta_e(pal4, colorspace::protan), 12)
  expect_gte(.sim_min_delta_e(pal4, colorspace::deutan), 12)
  expect_gte(.sim_min_delta_e(pal4, colorspace::tritan), 12)
})

# ── Flagged pair: HDA Green vs Sea Green ─────────────────────────────────────
# These are positions 2 and 6 in the HDA palette (outside first-4 audit above).
# Under TRITANOPIA this pair collapses to delta-E ≈ 5.97 — a documented
# limitation (see vignettes/articles/cvd-audit.Rmd). Protan and deutan are
# acceptably distinct (≥ 19); the tritan failure is NOT tested here since any
# threshold below 10 would not guard a real regression.
# Guard only the passing CVD types so a regression toward protan/deutan failure
# is caught.

test_that("HDA Green/Sea Green pair passes protan and deutan (tritan documented failure)", {
  pair <- c(
    hdatools:::`.brands`$hda$palette["Green"],
    hdatools:::`.brands`$hda$palette["Sea Green"]
  )
  expect_gte(.sim_min_delta_e(pair, colorspace::protan), 15)
  expect_gte(.sim_min_delta_e(pair, colorspace::deutan), 15)
})

# ── Flagged pair: PHA Teal vs Blue ───────────────────────────────────────────
# Positions 2 and 3 in the PHA palette, both official 2026 guide colors.
# Under TRITANOPIA this pair collapses to delta-E 6.6 — a documented
# limitation (see vignettes/articles/cvd-audit.Rmd). The guide's two cool hues
# sit at 168.6 and 227.1, which a tritan simulation maps close together; no
# fix exists that does not invent an unsanctioned hue, so this is documented
# rather than worked around (per Q7, plans/DECISIONS.md, 2026-07-18).
# Protan and deutan are strong (29.0 and 27.3); the tritan failure is NOT
# tested here since any threshold below 7 would not guard a real regression.

test_that("PHA Teal/Blue pair passes protan and deutan (tritan documented failure)", {
  pair <- c(
    hdatools:::`.brands`$pha$palette["Teal"],
    hdatools:::`.brands`$pha$palette["Blue"]
  )
  expect_gte(.sim_min_delta_e(pair, colorspace::protan), 22)
  expect_gte(.sim_min_delta_e(pair, colorspace::deutan), 22)
})
