# Element-class check that is agnostic to ggplot2's S3/S7 split:
# S7 (>= 4.0) reports "ggplot2::element_line"; S3 (<= 3.5) reports "element_line".
# ggtext elements remain S3 in 0.1.2, so "element_markdown" matches either way.
has_element_class <- function(x, cls) {
  any(grepl(paste0("(^|::)", cls, "$"), class(x)))
}
