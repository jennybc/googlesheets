library(testthat)
library(googlesheets)

if (identical(tolower(Sys.getenv("NOT_CRAN")), "true")) {
  test_check("googlesheets")
}
