## ---- echo = FALSE-------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  fig.path = "README-"
)

## ----auth, include = FALSE-----------------------------------------------
## I grab the token from the testing directory because that's where it is to be
## found on Travis
token_path <- file.path("..", "tests", "testthat", "googlesheets_token.rds")
suppressMessages(googlesheets::gs_auth(token = token_path, verbose = FALSE))

## ----pre-clean, include = FALSE------------------------------------------
## if a previous compilation of this document leaves anything behind, i.e. if it
## aborts, clean up Google Drive first
googlesheets::gs_vecdel("hi I am new here", verbose = FALSE)

## ----load package--------------------------------------------------------
library(googlesheets)
suppressMessages(library(dplyr))

## ----list-sheets---------------------------------------------------------
(my_sheets <- gs_ls())
# (expect a prompt to authenticate with Google interactively HERE)
my_sheets %>% glimpse()

## ----copy-gapminder, eval = FALSE----------------------------------------
#  gs_gap() %>%
#    gs_copy(to = "Gapminder")

## ----register-sheet------------------------------------------------------
gap <- gs_title("Gapminder")
gap

# Need to access a sheet you do not own?
# Access it by key if you know it!
(GAP_KEY <- gs_gap_key())
third_party_gap <- GAP_KEY %>%
  gs_key()

# Need to access a sheet you do not own but you have a sharing link?
# Access it by URL!
(GAP_URL <- gs_gap_url())
third_party_gap <- GAP_URL %>%
  gs_url()
# note: registration via URL may not work for "old" sheets

# Worried that a spreadsheet's registration is out-of-date?
# Re-register it!
gap <- gap %>% gs_gs()

## ------------------------------------------------------------------------
oceania <- gap %>% gs_read(ws = "Oceania")
oceania
str(oceania)
glimpse(oceania)

## ------------------------------------------------------------------------
gap %>% gs_read(ws = 2, range = "A1:D8")
gap %>% gs_read(ws = "Europe", range = cell_rows(1:4))
gap %>% gs_read(ws = "Europe", range = cell_rows(100:103), col_names = FALSE)
gap %>% gs_read(ws = "Africa", range = cell_cols(1:4))
gap %>% gs_read(ws = "Asia", range = cell_limits(c(1, 4), c(5, NA)))

## ----csv-list-and-cell-feed----------------------------------------------
# Get the data for worksheet "Oceania": the super-fast csv way
oceania_csv <- gap %>% gs_read_csv(ws = "Oceania")
str(oceania_csv)
oceania_csv

# Get the data for worksheet "Oceania": the less-fast tabular way ("list feed")
oceania_list_feed <- gap %>% gs_read_listfeed(ws = "Oceania") 
str(oceania_list_feed)
oceania_list_feed

# Get the data for worksheet "Oceania": the slow cell-by-cell way ("cell feed")
oceania_cell_feed <- gap %>% gs_read_cellfeed(ws = "Oceania") 
str(oceania_cell_feed)
oceania_cell_feed

## ------------------------------------------------------------------------
jfun <- function(readfun)
  system.time(do.call(readfun, list(gs_gap(), ws = "Africa", verbose = FALSE)))
readfuns <- c("gs_read_csv", "gs_read_listfeed", "gs_read_cellfeed")
readfuns <- sapply(readfuns, get, USE.NAMES = TRUE)
sapply(readfuns, jfun)

## ----post-processing-----------------------------------------------------
# Reshape: instead of one row per cell, make a nice rectangular data.frame
australia_cell_feed <- gap %>%
  gs_read_cellfeed(ws = "Oceania", range = "A1:F13") 
str(australia_cell_feed)
oceania_cell_feed
australia_reshaped <- australia_cell_feed %>% gs_reshape_cellfeed()
str(australia_reshaped)
australia_reshaped

# Example: first 3 rows
gap_3rows <- gap %>% gs_read_cellfeed("Europe", range = cell_rows(1:3))
gap_3rows %>% head()

# convert to a data.frame (by default, column names found in first row)
gap_3rows %>% gs_reshape_cellfeed()

# arbitrary cell range, column names no longer available in first row
gap %>%
  gs_read_cellfeed("Oceania", range = "D12:F15") %>%
  gs_reshape_cellfeed(col_names = FALSE)

# arbitrary cell range, direct specification of column names
gap %>%
  gs_read_cellfeed("Oceania", range = cell_limits(c(2, 1), c(5, 3))) %>%
  gs_reshape_cellfeed(col_names = paste("thing", c("one", "two", "three"),
                                        sep = "_"))

## ------------------------------------------------------------------------
# Example: first row only
gap_1row <- gap %>% gs_read_cellfeed("Europe", range = cell_rows(1))
gap_1row

# convert to a named character vector
gap_1row %>% gs_simplify_cellfeed()

# Example: single column
gap_1col <- gap %>% gs_read_cellfeed("Europe", range = cell_cols(3))
gap_1col

# convert to a un-named character vector and drop the variable name
gap_1col %>% gs_simplify_cellfeed(notation = "none", col_names = TRUE)

## ----new-sheet-----------------------------------------------------------
foo <- gs_new("foo")
foo

## ----edit-cells----------------------------------------------------------
## foo <- gs_new("foo")
## initialize the worksheets
foo <- foo %>% gs_ws_new("edit_cells")
foo <- foo %>% gs_ws_new("add_row")

## add first six rows of iris data (and var names) into a blank sheet
foo <- foo %>% gs_edit_cells(ws = "edit_cells", input = head(iris), trim = TRUE)

## initialize sheet with column headers and one row of data
## the list feed is picky about this
foo <- foo %>% gs_edit_cells(ws = "add_row", input = head(iris, 1), trim = TRUE)
## add the next 5 rows of data
for(i in 2:6) {
  foo <- foo %>% gs_add_row(ws = "add_row", input = iris[i, ])
}

## let's inspect out work
foo %>% gs_read(ws = "edit_cells")
foo %>% gs_read(ws = "add_row")

## ----delete-sheet--------------------------------------------------------
gs_delete(foo)

## ----new-sheet-from-file-------------------------------------------------
iris %>%
  head(5) %>%
  write.csv("iris.csv", row.names = FALSE)
iris_ss <- gs_upload("iris.csv")
iris_ss
iris_ss %>% gs_read()
file.remove("iris.csv")

## ----new-sheet-from-xlsx-------------------------------------------------
gap_xlsx <- gs_upload(system.file("mini-gap.xlsx", package = "googlesheets"))
gap_xlsx
gap_xlsx %>% gs_read(ws = "Asia")

## ----delete-moar-sheets--------------------------------------------------
gs_vecdel(c("iris", "mini-gap"))
## achieves same as:
## gs_delete(iris_ss)
## gs_delete(gap_xlsx)

## ----export-sheet-as-csv-------------------------------------------------
gs_title("Gapminder") %>%
  gs_download(ws = "Africa", to = "~/tmp/gapminder-africa.csv")
## is it there? yes!
read.csv("~/tmp/gapminder-africa.csv") %>% head()

## ----export-sheet-as-xlsx------------------------------------------------
gs_title("Gapminder") %>% 
  gs_download(to = "~/tmp/gapminder.xlsx")

## ----clean-exported-files------------------------------------------------
file.remove(file.path("~/tmp", c("gapminder.xlsx", "gapminder-africa.csv")))

## ----gs_auth, eval = FALSE-----------------------------------------------
#  # Give googlesheets permission to access your spreadsheets and google drive
#  gs_auth()

## ----gs_user-------------------------------------------------------------
user_session_info <- gs_user()
user_session_info

