# Get a logo for use in a ggplot2 plot

Get a logo for use in a ggplot2 plot

## Usage

``` r
get_logo(type = c("hda", "hfv"), width = 100)
```

## Arguments

- type:

  one of "hda" or "hfv"

- width:

  Image width in pixels; defaults to 100

## Value

A length-one character (glue) string containing an HTML `<img>` tag that
points at the installed logo file, sized to `width`. Intended for use in
ggtext-rendered plot elements such as a markdown title or caption.
