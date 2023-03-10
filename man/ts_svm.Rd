% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ts_svm.R
\name{ts_svm}
\alias{ts_svm}
\title{Time Series Support Vector Machine}
\usage{
ts_svm(
  preprocess = NA,
  input_size = NA,
  kernel = "radial",
  epsilon = 0,
  cost = 10
)
}
\value{
a \code{ts_svm} object.
}
\description{
Transform data into vectors of features. The algorithm then
identifies the support vectors that define the hyperplane that best separates
the data into different classes based on temporal proximity. The hyperplane
can then be used to make predictions about future values of the time series.
}
