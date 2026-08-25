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
    # Palette follows PHA's 2026 brand guidelines. The first four entries are
    # the guide's own colors, so any chart with four or fewer categories
    # renders only sanctioned PHA colors; the last two are tints derived from
    # Orange and Teal (same HCL hue, re-chroma'd and re-lightened) to reach a
    # six-color discrete palette. The guide dropped the old Red, Light Blue,
    # and Purple hue families outright.
    palette = c(
      "Orange"      = "#f78f49",  # official — primary orange   (H 32.4 / C 98.0 / L 69.4)
      "Teal"        = "#42a18d",  # official — primary teal     (H 168.6 / C 40.4 / L 60.4)
      "Blue"        = "#3990b1",  # official — secondary blue   (H 227.1 / C 48.9 / L 56.1)
      "Navy"        = "#0b242e",  # official — secondary navy   (H 227.1 / C 10.6 / L 12.8)
      "Orange Deep" = "#a4560c",  # derived  — Orange hue at C 76, L 45
      "Teal Light"  = "#a0d0c3"   # derived  — Teal hue at C 24.8, L 80
    ),
    gradient = NULL,
    na_color = "#e2e4e3",
    fonts = list(title = "Raleway", body = "Mulish"),
    base_size = 10,
    html_adjust = 0,
    pdf_adjust = 0,
    lineheight = 1,
    theme_fonts = list(
      title = "Raleway", subtitle = "Raleway", caption = "Mulish", strip = "Mulish"
    ),
    theme_margins = list(
      title = NULL,
      subtitle = ggplot2::margin(t = 5, b = 20, unit = "pt")
    ),
    # Re-anchored and re-tuned for the 2026 palette (plans/ramp-lab/REVIEW.md,
    # 2026-08-24 section). The old anchors read off Red (19.7) and Dark Blue
    # (243.4), hue families the new guide dropped. Sequential now anchors on
    # Orange (32.4); diverging pairs Blue/Navy (227.1, one shared hue) against
    # Orange. The protan inner-pair merge on the diverging ramp is the same
    # structural property of the shared cream center that HDA's diverging has.
    ramps = list(
      sequential = list(h1 = 32.4, c1 = 90, l1 = 25, l2 = 95, power = 0.95),
      diverging  = list(h1 = 227.1, h2 = 32.4, c1 = 89, l1 = 26, l2 = 95, power = 0.85)
    )
  ),

  vha = list(
    palette = c(
      "Dark Turq"   = "#0C4D4F",
      "Light Green" = "#A0D18E",
      "Yellow"      = "#ECC51E",
      "Light Turq"  = "#19787B",
      "Grey"        = "#2E3030",
      "Light Blue"  = "#E3F3F5"
    ),
    gradient = NULL,
    na_color = "#d6dbdb",
    fonts = list(title = "Montserrat", body = "Montserrat"),
    base_size = 13,
    html_adjust = 4,
    pdf_adjust = 7,
    lineheight = 0.9,
    theme_fonts = list(
      title = "Montserrat", subtitle = "Montserrat", caption = "Montserrat", strip = NULL
    ),
    theme_margins = list(
      title = ggplot2::margin(b = 10, unit = "pt"),
      subtitle = ggplot2::margin(t = -5, b = 10, unit = "pt")
    ),
    # Sequential anchors on Dark Turq (h1 = its own HCL hue, c1 near its own
    # chroma at that lightness). Diverging pairs Dark Turq against Yellow, the
    # palette's only true warm hue — Yellow's natural HCL lightness (~81) is
    # too high to survive as a dark, saturated anchor, so that arm renders
    # golden/olive rather than bright yellow at l1 (a sRGB gamut limit, not a
    # tuning slip; confirmed via swatch + CVD-sim render). Ships provisional,
    # same as HDA's diverging ramp — candidate for a follow-up Ramp Lab pass.
    ramps = list(
      sequential = list(h1 = 196.3, c1 = 22, l1 = 27, l2 = 95, power = 0.90),
      diverging  = list(h1 = 196.3, h2 = 67.6, c1 = 70, l1 = 40, l2 = 95, power = 0.90)
    )
  )

)
