# Internal continuous-ramp construction. Builds sequential/diverging HCL hex
# vectors from each brand's `.brands[[brand]]$ramps` parameters (see
# R/brands.R). Ported from the Ramp Lab's plans/ramp-lab/generate_candidates.R
# build_sequential()/build_diverging(), which is the verified source of the
# parameters transcribed into the registry (plans/ramp-lab/REVIEW.md).
#
# Sequential is a single colorspace::sequential_hcl() call: dark anchor hue ->
# shared cream hue. Diverging is two sequential_hcl() arms (each dark anchor
# -> shared cream) stitched back-to-back, because colorspace::diverging_hcl()
# always collapses its center to achromatic and can't express a tinted
# (cream) center.
#
# Both return colorspace's raw dark -> light (or arm1 -> cream -> arm2) order,
# unreversed — this is what the pinned-hex tests in test-ramps.R check against
# REVIEW.md verbatim. R/scales.R's .scale_brand_continuous()/
# .scale_brand_binned() are responsible for reversing sequential ramps before
# use, so higher value = darker color without callers ever calling rev().

# Every ramp's light end (sequential) / neutral center (diverging) anchors to
# this shared cream instead of pure white or a same-hue tint, fixed across all
# brands and both variants.
.RAMP_CREAM_H <- 80
.RAMP_CREAM_C <- 10

# Stop count feeding the continuous scales' underlying scales::gradient_n_pal()
# interpolation. Matches generate_candidates.R's N_SMOOTH, already used and
# eyeballed for the Ramp Lab's smooth preview.
.RAMP_N_DENSE <- 32

.ramp_hex_sequential <- function(brand, n) {
  p <- .brands[[brand]]$ramps$sequential
  unname(colorspace::sequential_hcl(
    n,
    h = c(p$h1, .RAMP_CREAM_H),
    c = c(p$c1, .RAMP_CREAM_C),
    l = c(p$l1, p$l2),
    power = p$power
  ))
}

.ramp_hex_diverging <- function(brand, n) {
  p <- .brands[[brand]]$ramps$diverging
  n2 <- ceiling(n / 2)
  arm <- function(h) {
    colorspace::sequential_hcl(
      n2,
      h = c(h, .RAMP_CREAM_H),
      c = c(p$c1, .RAMP_CREAM_C),
      l = c(p$l1, p$l2),
      power = p$power
    )
  }
  out <- c(arm(p$h1), rev(arm(p$h2)))
  if (floor(n / 2) < n2) out <- out[-n2]
  unname(out)
}

.ramp_hex <- function(brand, palette, n) {
  if (palette == "sequential") {
    .ramp_hex_sequential(brand, n)
  } else {
    .ramp_hex_diverging(brand, n)
  }
}
