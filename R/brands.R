# Internal brand registry. Single source of truth for the discrete palette,
# gradient stops, NA colour, font families, and theme parameters that differ
# per brand. Not exported; read via .brands$<brand>$<field>.
#
# Discrete `palette` vectors carry colour-label names; gradient/theme fields
# do not need them since nothing consumes the labels yet.

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
    lineheight = 0.9
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
    lineheight = 0.9
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
    lineheight = 1
  )

)
