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

## "make clean"
## uncomment if you are genuinely starting to recreate this!
#delete_ss(regex = "^test-gs-iris-private$")

iris_ss <- new_ss("test-gs-iris-private")
iris_ss

iris_ss <- iris_ss %>%
  edit_cells(input = head(iris), header = TRUE, trim = TRUE)
iris_ss

iris_ss %>% get_via_lf()
iris_ss %>% get_via_csv()

iris_key <- "1UXr4-haIQsmJfyjkEhlkNt2PXduBkB97e15jez9ogRo"
iris_public <- register_ss(key = iris_key, visibility = "public")
## this should NOT work! we should have a better error message! I note the
## returned stats us 200 but API sends back HTML which appears to correspond to
## a "maybe you need to sign in?" type of form
iris_public
