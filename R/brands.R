# Internal brand registry. Single source of truth for the discrete palette,
# gradient stops, NA colour, font families, theme parameters, and continuous
# ramp anchors that differ per brand. Not exported; read via
# .brands$<brand>$<field>.
#
# Discrete `palette` vectors carry colour-label names; gradient/theme fields
# do not need them since nothing consumes the labels yet.
#
# `theme_fonts` gives the family used for plot.title/subtitle/caption/strip.text
# in .brand_theme(); a NULL entry means that element tracks the caller's
# base_family instead of a brand-fixed family. `theme_margins` gives the
# plot.title/subtitle margins (which vary by brand); caption and strip margins
# are identical across brands and live directly in .brand_theme().
#
# `ramps` holds colorspace::sequential_hcl() parameters for the sequential and
# diverging continuous scales (R/ramps.R builds the hex vectors; R/scales.R
# exposes them as scale_*_<brand>_c()/scale_*_<brand>_b()). The shared cream
# light-end/center hue and chroma are fixed design constants, not brand data —
# see .RAMP_CREAM_H/.RAMP_CREAM_C in R/ramps.R.

.brands <- list(

  hda = list(
    palette = c(
      "Blue"      = "#445ca9",
      "Green"     = "#8baeaa",
      "Yellow"    = "#e9ab3f",
      "Coral"     = "#e76f52",
      "Lavender"  = "#a97a92",
      "Sea Green" = "#8abc8e"
    ),
    gradient = c("#445ca9", "#8baeaa", "#e9ab3f", "#e76f52"),
    na_color = "#cfcfd0",
    fonts = list(title = "Roboto Slab", body = "Lato"),
    base_size = 14,
    html_adjust = 4,
    pdf_adjust = 7,
    lineheight = 0.9,
    # NULL means "track the caller's base_family" rather than a fixed family.
    theme_fonts = list(
      title = "Roboto Slab", subtitle = "Roboto Slab", caption = "Lato", strip = "Lato"
    ),
    theme_margins = list(
      title = ggplot2::margin(b = 10, unit = "pt"),
      subtitle = ggplot2::margin(t = -5, b = 10, unit = "pt")
    ),
    # Sequential/diverging HCL ramp anchors (colorspace::sequential_hcl()
    # parameters), tuned and CVD-verified in the Ramp Lab review
    # (plans/ramp-lab/REVIEW.md, signed off 2026-07-18). h/c/l1 are the dark
    # (or arm) end; l2 is the light end/cream-center luminance shared with the
    # fixed cream hue/chroma constants in R/ramps.R. HDA's diverging ramp is
    # provisional pending a follow-up pass to differentiate it from PHA's
    # (see plans/DECISIONS.md, 2026-07-18 row).
    ramps = list(
      sequential = list(h1 = 259.2, c1 = 64, l1 = 26, l2 = 95, power = 0.85),
      diverging  = list(h1 = 259.2, h2 = 20.4, c1 = 76, l1 = 26, l2 = 95, power = 0.90)
    )
  ),

  hfv = list(
    palette = c(
      "Shadow"   = "#334a66",
      "Sky"      = "#66cccc",
      "Lilac"    = "#a29dd4",
      "Grass"    = "#50aaa7",
      "Berry"    = "#c0327e",
      "Desert"   = "#ec7c53",
      "Leaf"     = "#6fb547",
      "Cerulean" = "#7fc7e0"
    ),
    gradient = NULL,
    na_color = "#d6dadd",
    fonts = list(title = "Open Sans", body = "Open Sans"),
    base_size = 14,
    html_adjust = 4,
    pdf_adjust = 7,
    lineheight = 0.9,
    theme_fonts = list(title = NULL, subtitle = NULL, caption = NULL, strip = NULL),
    theme_margins = list(
      title = ggplot2::margin(b = 10, unit = "pt"),
      subtitle = ggplot2::margin(t = -5, b = 10, unit = "pt")
    ),
    ramps = list(
      sequential = list(h1 = 118.5, c1 = 65, l1 = 28, l2 = 95, power = 1.00),
      diverging  = list(h1 = 118.5, h2 = 344.0, c1 = 68, l1 = 26, l2 = 95, power = 0.95)
    )
  ),

  pha = list(
    palette = c(
      "Green"      = "#5bab8e",
      "Light Blue" = "#a6cccc",
      "Orange"     = "#f39152",
      "Red"        = "#be451c",
      "Purple"     = "#a5add0",
      "Dark Blue"  = "#2b6b9c"
    ),
    gradient = c("#5bab8e", "#a6cccc", "#f39152", "#be451c"),
    na_color = "#e2e4e3",
    fonts = list(title = "Noto Sans", body = "Noto Sans"),
    base_size = 10,
    html_adjust = 0,
    pdf_adjust = 0,
    lineheight = 1,
    theme_fonts = list(
      title = "Noto Sans", subtitle = "Noto Sans", caption = "Noto Sans", strip = NULL
    ),
    theme_margins = list(
      title = NULL,
      subtitle = ggplot2::margin(t = 5, b = 20, unit = "pt")
    ),
    ramps = list(
      sequential = list(h1 = 19.7, c1 = 84, l1 = 28, l2 = 95, power = 0.95),
      diverging  = list(h1 = 243.4, h2 = 19.7, c1 = 72, l1 = 26, l2 = 95, power = 0.90)
    )
  )

)
