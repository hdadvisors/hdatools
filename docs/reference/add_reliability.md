# Add reliability labels based on coefficient of variation

Adds a `reliability` column that classifies each row by its coefficient
of variation (CV). There are two ways to call it:

## Usage

``` r
add_reliability(data, cv_col = NULL, scale = c("percent", "proportion"))
```

## Arguments

- data:

  A data frame or tibble.

- cv_col:

  The column of CV values to classify. If `NULL` (the default), the
  legacy `_cv` auto-detection path is used.

- scale:

  Whether `cv_col` is on a `"percent"` (0-100, the default) or
  `"proportion"` (0-1) scale. Ignored on the legacy path.

## Value

The input data frame with an additional `reliability` character column.

## Details

- **Supply `cv_col` (recommended).** The named column is classified with
  `<=` boundaries on the chosen `scale`. With `scale = "percent"` (the
  default) a CV of exactly 15 is "High" and exactly 30 is "Medium".

- **Omit `cv_col` (legacy).** The single column ending in `_cv` is
  auto-detected and treated as a 0-1 proportion with strict `<`
  boundaries (High: CV \< 0.15; Medium: 0.15 \<= CV \< 0.30; Low: CV \>=
  0.30).

Missing CV values yield `NA`. The result is a character column (not a
factor).

## Examples

``` r
# Recommended: name the CV column (percent scale)
df <- data.frame(location = c("A", "B", "C", "D"), cv = c(5, 15, 30, NA))
add_reliability(df, cv_col = cv)
#>   location cv reliability
#> 1        A  5        High
#> 2        B 15        High
#> 3        C 30      Medium
#> 4        D NA        <NA>

# Legacy: auto-detect a _cv column on the 0-1 proportion scale
df2 <- data.frame(location = c("A", "B", "C"), value_cv = c(0.05, 0.20, 0.35))
add_reliability(df2)
#>   location value_cv reliability
#> 1        A     0.05        High
#> 2        B     0.20      Medium
#> 3        C     0.35         Low
```
