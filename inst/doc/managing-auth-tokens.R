## ---- echo = FALSE-------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

## ----token-path, include = FALSE, eval = NOT_CRAN------------------------
## I grab the token from the testing directory because that's where it is to be
## found on Travis
## does not work
## token_path <- testthat::test_path("googlesheets_token.rds")
token_path <- file.path("..", "tests", "testthat","googlesheets_token.rds")
suppressMessages(googlesheets::gs_auth(token = token_path, verbose = FALSE))

## ----make-clean, include = FALSE, eval = NOT_CRAN------------------------
## if previous compilation errored out, intended clean up may be incomplete
googlesheets::gs_grepdel("^iris_bit$", verbose = FALSE)

## ------------------------------------------------------------------------
library(googlesheets)
suppressPackageStartupMessages(library(dplyr))
gs_gap_key() %>%
  gs_key(lookup = FALSE) %>% 
  gs_read() %>% 
  head(3)

## ------------------------------------------------------------------------
iris_ss <- gs_new("iris_bit", input = head(iris, 3), trim = TRUE, verbose = FALSE)
iris_ss %>% 
  gs_read()

## ----include = FALSE-----------------------------------------------------
gs_grepdel("^iris_bit$")

## ------------------------------------------------------------------------
gs_user()

## ----eval = FALSE--------------------------------------------------------
#  library(googlesheets)
#  token <- gs_auth(cache = FALSE)
#  gd_token()
#  saveRDS(token, file = "googlesheets_token.rds")

## ----eval = FALSE--------------------------------------------------------
#  library(googlesheets)
#  gs_auth(token = "googlesheets_token.rds")
#  ## and you're back in business, using the same old token
#  ## if you want silence re: token loading, use this instead
#  suppressMessages(gs_auth(token = "googlesheets_token.rds", verbose = FALSE))

## ----eval = FALSE--------------------------------------------------------
#  library(googlesheets)
#  token <- gs_auth()
#  saveRDS(token, file = "tests/testthat/googlesheets_token.rds")

## ----eval = FALSE--------------------------------------------------------
#  suppressMessages(gs_auth(token = "googlesheets_token.rds", verbose = FALSE))

## ----eval = FALSE--------------------------------------------------------
#  gs_deauth(verbose = FALSE)

## ----eval = FALSE--------------------------------------------------------
#  library(testthat)
#  library(googlesheets)
#  
#  if (identical(tolower(Sys.getenv("NOT_CRAN")), "true")) {
#    test_check("googlesheets")
#  }

## ----eval = FALSE--------------------------------------------------------
#  NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")

## ----eval = FALSE--------------------------------------------------------
#  knitr::opts_chunk$set(
#    collapse = TRUE,
#    comment = "#>",
#    purl = NOT_CRAN,
#    eval = NOT_CRAN
#  )

