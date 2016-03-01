## ----setup, echo = FALSE-------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN
)

## ----pre-clean, include = FALSE, eval = NOT_CRAN-------------------------
## in case a previous compilation of this document exited uncleanly, pre-clean 
## working directory and Google Drive first
#googlesheets::gs_vecdel(c("foo", "iris"), verbose = FALSE)
#file.remove(c("formatted-numbers-and-formulas.csv"))

## ----load-package--------------------------------------------------------
library(googlesheets)
#devtools::load_all()
suppressMessages(library(dplyr))

## ----auth, include = FALSE, eval = NOT_CRAN------------------------------
## I grab the token from the testing directory because that's where it is to be
## found on Travis
token_path <- file.path("..", "tests", "testthat", "googlesheets_token.rds")
suppressMessages(googlesheets::gs_auth(token = token_path, verbose = FALSE))

## ------------------------------------------------------------------------
## I can do this because I own the Sheet
## ffs <- gs_title("formula-formatting-sampler")
## but this should work for anyone
ffs <- gs_key("19lRTCJDf9BYz9JepHx7y6u8vcxGbFpVSfIuxXnWpsL0", lookup = FALSE)
(ffs_read_csv <- gs_read_csv(ffs))
(ffs_read_list <- gs_read_listfeed(ffs))
## interesting! reading the csv might require auth ... why?
(ffs_download_csv <- gs_download(ffs, to = "formatted-numbers-and-formulas.csv",
                                 overwrite = TRUE) %>% 
  readr::read_csv())
## a great opportunity to check the new readr ingest
identical(ffs_read_csv, ffs_read_list)
identical(ffs_read_csv, ffs_download_csv)
## YEESSSSSSS

## ------------------------------------------------------------------------
cf <- gs_read_cellfeed(ffs)
cf_printme <- cf %>%
  arrange(col, row) %>%
  select(cell, literal_value, input_value, numeric_value)

## ----echo = FALSE--------------------------------------------------------
knitr::kable(cf_printme)

## ------------------------------------------------------------------------
cf %>%
  filter(col == 2) %>%
  select(literal_value, numeric_value)

## ------------------------------------------------------------------------
cf %>%
  filter(col == 4) %>%
  select(input_value)

## ------------------------------------------------------------------------
cf %>%
  filter(col == 5) %>%
  select(literal_value, numeric_value, input_value)

## ------------------------------------------------------------------------
cf_aug <- cf %>%
  mutate(literal_only = is.na(numeric_value),
         putative_integer = ifelse(is.na(numeric_value), FALSE,
                                   gsub("\\.0$", "", numeric_value)
                                   == input_value),
         putative_content = ifelse(literal_only,
                                   literal_value,
                                   ifelse(putative_integer, input_value,
                                          numeric_value)))
cf_aug$literal_value <- cf_aug$putative_content
cf_aug <- cf_aug %>%
  select(-literal_only, -putative_integer, -putative_content)

## ------------------------------------------------------------------------
how_about_this <- cf_aug %>%
  gs_reshape_cellfeed()
how_about_this
ffs_read_csv

## ----include = FALSE-----------------------------------------------------
## super goofy computation of one formula
fla_row <- 3
fla_col <- 4
(fla <- cf$input_value[cf$row == fla_row & cf$col == fla_col])
(fla <- gsub("^=", "", fla))
## parse R[?]C[?] here!
how_about_this %>% 
  select(fla_col - 3) %>% 
  slice((fla_row - 1 - 1):(fla_row + 3 - 1)) %>% 
  purrr::map(sum, na.rm = TRUE)
cf$literal_value[cf$row == fla_row & cf$col == fla_col] %>% as.numeric()

