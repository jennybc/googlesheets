#' ---
#' output: md_document
#' ---

## NOTE 2015-04-25 The file created here is no longer used for testing. All
## testing of "published to the web" is done via files owned by rpackagetest. A
## version of this script and its output file does, however, live on. It is now
## used to test the exact opposite: working with a file that has NOT been
## published to the web and is owned by gspreadr.

library("googlesheets")
suppressPackageStartupMessages(library("dplyr"))

## damn you render and your hard-wiring of wd = dir where file lives!
## if I don't commit this abomination, existing .httr-oauth cannot be found :(
if (getwd() %>% basename == "data-for-demo") {
  setwd("..")
}

## "make clean"
delete_ss(regex = "^iris_public$")

iris_ss <- new_ss("iris_public")
iris_ss

iris_ss <- iris_ss %>%
  edit_cells(input = head(iris), header = TRUE, trim = TRUE)
iris_ss

iris_ss %>% get_via_lf()
iris_ss %>% get_via_csv()

## via browser, publish this sheet to the web
## in sheets, File > Publish to the web ...
## in future, do programmatically w/ googlesheets or driver
## https://github.com/jennybc/googlesheets/issues/62
## https://docs.google.com/spreadsheets/d/1cAYN-a089TSw8GF0RadQNdZiWo2RzekT-8swZeYME4A/pubhtml

iris_key <- "1cAYN-a089TSw8GF0RadQNdZiWo2RzekT-8swZeYME4A"
iris_public <- register_ss(key = iris_key, visibility = "public")
iris_public
iris_public %>% get_via_csv()
