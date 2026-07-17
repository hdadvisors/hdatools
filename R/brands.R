# Internal brand registry. Single source of truth for the discrete palette,
# gradient stops, NA colour, font families, and theme parameters that differ
# per brand. Not exported; read via .brands$<brand>$<field>.
#
# Discrete `palette` vectors carry colour-label names; gradient/theme fields
# do not need them since nothing consumes the labels yet.
#
# `theme_fonts` gives the family used for plot.title/subtitle/caption/strip.text
# in .brand_theme(); a NULL entry means that element tracks the caller's
# base_family instead of a brand-fixed family. `theme_margins` gives the
# plot.title/subtitle margins (which vary by brand); caption and strip margins
# are identical across brands and live directly in .brand_theme().

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
    )
  ),

  hfv = list(
    palette = c(
      "Shadow" = "#334a66",
      "Sky"    = "#66cccc",
      "Lilac"  = "#a29dd4",
      "Grass"  = "#50aaa7",
      "Berry"  = "#c0327e",
      "Desert" = "#ec7c53"
    ),
    gradient = NULL,
    na_color = NULL,
    fonts = list(title = "Open Sans", body = "Open Sans"),
    base_size = 14,
    html_adjust = 4,
    pdf_adjust = 7,
    lineheight = 0.9,
    theme_fonts = list(title = NULL, subtitle = NULL, caption = NULL, strip = NULL),
    theme_margins = list(
      title = ggplot2::margin(b = 10, unit = "pt"),
      subtitle = ggplot2::margin(t = -5, b = 10, unit = "pt")
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
    )
  )

)
