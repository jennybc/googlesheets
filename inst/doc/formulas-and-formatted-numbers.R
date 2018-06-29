## ----setup, echo = FALSE-------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)

## ----load-package--------------------------------------------------------
library(googlesheets)
suppressMessages(library(dplyr))

## ----eval = FALSE--------------------------------------------------------
#  gs_read(..., literal = FALSE)

## ------------------------------------------------------------------------
gs_ff() %>% 
  gs_read(range = cell_cols("B:C"))

## ------------------------------------------------------------------------
gs_ff() %>% 
  gs_read(literal = FALSE, range = cell_cols("B:C"))

## ----results = "asis"----------------------------------------------------
gs_ff() %>% 
  gs_read_cellfeed(range = cell_cols("E")) %>% 
  select(-cell_alt, -row, -col) %>% 
  knitr::kable()

## ------------------------------------------------------------------------
gs_ff() %>% 
  gs_read() %>% 
  select(-integer)

## ------------------------------------------------------------------------
cf <- gs_read_cellfeed(gs_ff())

## ----echo = FALSE, results = "asis"--------------------------------------
cf_printme <- cf %>%
  arrange(col, row) %>%
  select(cell, value, input_value, numeric_value)
## work with purrr v0.2.2 but avoid deprecation warning with v0.2.2.1
## modify_if() is ideal but not in v0.2.2
cf_printme[] <- cf_printme %>%
  purrr::map(~ if(purrr::is_character(.x)) {
    gsub('$', '\\$', .x, fixed = TRUE)
  } else .x)
knitr::kable(cf_printme)

## ------------------------------------------------------------------------
cf %>%
  filter(row > 1, col == 2) %>%
  select(value, input_value, numeric_value) %>% 
  readr::type_convert()

## ------------------------------------------------------------------------
cf %>%
  filter(row > 1, col == 3) %>%
  select(value, input_value, numeric_value) %>% 
  readr::type_convert()

## ------------------------------------------------------------------------
cf %>%
  filter(row > 1, col == 5) %>%
  select(value, input_value, numeric_value) %>% 
  mutate(input_value = substr(input_value, 1, 43)) %>% 
  readr::type_convert()

## ------------------------------------------------------------------------
cf %>%
  filter(row > 1, col == 6) %>%
  select(value, input_value, numeric_value) %>% 
  readr::type_convert()

