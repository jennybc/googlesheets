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
knitr::kable(cf_printme %>%
               purrr::dmap_if(purrr::is_character,
                              ~gsub('$', '\\$', .x, fixed = TRUE)))

## ------------------------------------------------------------------------
cf %>%
  filter(col == 2) %>%
  select(value, input_value, numeric_value)

## ------------------------------------------------------------------------
cf %>%
  filter(col == 3) %>%
  select(value, input_value, numeric_value)

## ------------------------------------------------------------------------
cf %>%
  filter(col == 5) %>%
  select(value, input_value, numeric_value) %>% 
  mutate(input_value = substr(input_value, 1, 43))

## ------------------------------------------------------------------------
cf %>%
  filter(col == 6) %>%
  select(value, input_value, numeric_value)

