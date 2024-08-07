% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/fct_case_when.R
\name{fct_case_when}
\alias{fct_case_when}
\title{Create a factor with case_when logic and automatic level ordering}
\usage{
fct_case_when(..., dir = 1)
}
\arguments{
\item{...}{A series of two-sided formulas. The left hand side (LHS) determines
which values match this case. The right hand side (RHS) provides the value
to use for the output.}

\item{dir}{Direction of factor levels. Use 1 for the same order as input (default),
or -1 to reverse the order.}
}
\value{
A factor with levels ordered according to their appearance in the
  case_when conditions, and the specified direction.
}
\description{
This function combines the functionality of \code{dplyr::case_when()} with
automatic factor level ordering. It creates a factor where the levels are
ordered according to the sequence they appear in the case_when conditions.
}
\note{
This function was adapted from an answer provided to StackOverflow post #69333730 (\url{https://stackoverflow.com/a/69333730})
}
\examples{
library(dplyr)
library(tibble)

# Create a sample dataset of cost burden percent values
set.seed(123)
cost_burden <- tibble(
  pct = runif(100, min = 0, max = 1)
)

# Apply fct_case_when to create labels
cost_burden_label <- cost_burden |>
  mutate(
    cb = fct_case_when(
      pct < 0.30 ~ "Not cost-burdened",
      pct < 0.50 ~ "Cost-burdened",
      pct >= 0.50 ~ "Severely cost-burdened"
    )
  )

# Check the levels of the new factor column
levels(cost_burden_label$cb)

}
