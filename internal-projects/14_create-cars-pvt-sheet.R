#' ---
#' output: md_document
#' ---

library("googlesheets")
suppressPackageStartupMessages(library("dplyr"))

## damn you render and your hard-wiring of wd = dir where file lives!
## if I don't commit this abomination, existing .httr-oauth cannot be found :(
if ((getwd() %>% basename) == "data-for-demo") {
  setwd("..")
}

cars_ss <- gs_new("test-gs-cars-private", ws_title = "cars",
                  input = head(mtcars), header = TRUE, trim = TRUE)
cars_ss
