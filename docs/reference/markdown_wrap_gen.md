# Generate a function to wrap and format facet labels with markdown

This function creates a labeller function for use with ggplot2 facets.
It wraps long labels to a specified width and formats them as markdown,
which allows them to be rendered correctly when using
ggtext::element_markdown() in themes.

## Usage

``` r
markdown_wrap_gen(width = 25)
```

## Arguments

- width:

  An integer specifying the maximum number of characters before wrapping
  the text. Default is 25.

## Value

A function that takes a vector of labels and returns a list of wrapped
and formatted labels.

## Examples

``` r
if (FALSE) { # \dontrun{
library(ggplot2)
library(hdatools)

ggplot(mtcars, aes(mpg, wt)) +
  geom_point() +
  facet_wrap(~vs, labeller = markdown_wrap_gen(width = 20)) +
  theme_hda()
} # }
```
