## ---- echo = FALSE-------------------------------------------------------
NOT_CRAN <- identical(tolower(Sys.getenv("NOT_CRAN")), "true")
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  purl = NOT_CRAN,
  eval = NOT_CRAN
)
## this is nice during development = on github
## this is not so nice for preparing vignettes for CRAN
#options(knitr.table.format = 'markdown')

## ----load-package--------------------------------------------------------
library(googlesheets)
suppressMessages(library(dplyr))

## ----auth, include = FALSE-----------------------------------------------
## I grab the token from the testing directory because that's where it is to be
## found on Travis
token_path <- rprojroot::find_package_root_file(
  "tests", "testthat", "googlesheets_token.rds"
)
suppressMessages(googlesheets::gs_auth(token = token_path, verbose = FALSE))

## ----pre-clean, include = FALSE------------------------------------------
## in case a previous compilation of this document exited uncleanly, pre-clean 
## working directory and Google Drive first
googlesheets::gs_vecdel(c("foo", "iris", "data-ingest-practice", "boring"),
                        verbose = FALSE)
file.remove(c("gapminder.xlsx", "gapminder-africa.csv", "iris"))

## ----list-sheets---------------------------------------------------------
(my_sheets <- gs_ls())
# (expect a prompt to authenticate with Google interactively HERE)
my_sheets %>% glimpse()

## ----copy-gapminder, eval = FALSE----------------------------------------
#  gs_gap() %>%
#    gs_copy(to = "Gapminder")

## ----ls-gapminder--------------------------------------------------------
gs_ls("Gapminder")

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

# Want to dig the key out of a URL?
# registration by key is the safest, long-run strategy
extract_key_from_url(GAP_URL)

# Worried that a spreadsheet's registration is out-of-date?
# Re-register it!
gap <- gap %>% gs_gs()

## ----register-sheet-cran-only, include = FALSE---------------------------
gap <- gs_gap()

## ----eval = FALSE--------------------------------------------------------
#  gap %>% gs_browse()
#  gap %>% gs_browse(ws = 2)
#  gap %>% gs_browse(ws = "Europe")

## ----include = FALSE-----------------------------------------------------
Sys.sleep(20)

## ------------------------------------------------------------------------
gap
gs_ws_ls(gap)

## ------------------------------------------------------------------------
oceania <- gap %>%
  gs_read(ws = "Oceania")
oceania
str(oceania)
glimpse(oceania)

## ------------------------------------------------------------------------
gap %>% gs_read(ws = 2, range = "A1:D8")
gap %>% gs_read(ws = "Europe", range = cell_rows(1:4))
gap %>% gs_read(ws = "Europe", range = cell_rows(100:103), col_names = FALSE)
gap %>% gs_read(ws = "Africa", range = cell_cols(1:4))
gap %>% gs_read(ws = "Asia", range = cell_limits(c(1, 4), c(5, NA)))

## ----new-sheet, warning = FALSE------------------------------------------
boring_ss <- gs_new("boring", ws_title = "iris-gs_new", input = head(iris),
                    trim = TRUE, verbose = FALSE)
boring_ss %>% 
  gs_read()

## ----new-worksheet, warning = FALSE--------------------------------------
boring_ss <- boring_ss %>% 
  gs_ws_new(ws_title = "mtcars-gs_ws_new", input = head(mtcars),
                    trim = TRUE, verbose = FALSE)
boring_ss %>% 
  gs_read(ws = 2)

## ----delete-rename-worksheet---------------------------------------------
boring_ss <- boring_ss %>% 
  gs_ws_delete(ws = 2) %>% 
  gs_ws_rename(to = "iris")
boring_ss

## ----edit-cells----------------------------------------------------------
foo <- gs_new("foo") %>% 
  gs_ws_rename(from = "Sheet1", to = "edit_cells") %>% 
  gs_ws_new("add_row")
foo

## add first six rows of iris data (and var names) into a blank sheet
foo <- foo %>%
  gs_edit_cells(ws = "edit_cells", input = head(iris), trim = TRUE)

## initialize sheet with column headers and one row of data
## the list feed is picky about this
foo <- foo %>% 
  gs_edit_cells(ws = "add_row", input = head(iris, 1), trim = TRUE)
## add the next 5 rows of data ... careful not to go too fast
for (i in 2:6) {
  foo <- foo %>% gs_add_row(ws = "add_row", input = iris[i, ])
  Sys.sleep(0.3)
}

## gs_add_row() will actually handle multiple rows at once
foo <- foo %>% 
  gs_add_row(ws = "add_row", input = tail(iris))

## let's inspect our work
foo %>% gs_read(ws = "edit_cells")
foo %>% gs_read(ws = "add_row")

## ----eval = FALSE--------------------------------------------------------
#  gs_browse(foo, ws = "edit_cells")
#  gs_browse(foo, ws = "add_row")

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
gap_xlsx <- gs_upload(system.file("mini-gap", "mini-gap.xlsx",
                                  package = "googlesheets"))
gap_xlsx
gap_xlsx %>% gs_read(ws = "Asia")

## ----delete-moar-sheets--------------------------------------------------
gs_vecdel(c("iris", "mini-gap"))
## achieves same as:
## gs_delete(iris_ss)
## gs_delete(gap_xlsx)

## ----export-sheet-as-csv-------------------------------------------------
gs_title("Gapminder") %>%
  gs_download(ws = "Africa", to = "gapminder-africa.csv")
## is it there? yes!
read.csv("gapminder-africa.csv") %>% head()

## ----export-sheet-as-xlsx------------------------------------------------
gs_title("Gapminder") %>% 
  gs_download(to = "gapminder.xlsx")

## ----clean-exported-files------------------------------------------------
file.remove(c("gapminder.xlsx", "gapminder-africa.csv"))

## ----csv-list-and-cell-feed----------------------------------------------
# Get the data for worksheet "Oceania": the super-fast csv way
oceania_csv <- gap %>% gs_read_csv(ws = "Oceania")
oceania_csv
glimpse(oceania_csv)

# Get the data for worksheet "Oceania": the less-fast tabular way ("list feed")
oceania_list_feed <- gap %>% gs_read_listfeed(ws = "Oceania") 
oceania_list_feed
glimpse(oceania_list_feed)

# Get the data for worksheet "Oceania": the slow cell-by-cell way ("cell feed")
oceania_cell_feed <- gap %>% gs_read_cellfeed(ws = "Oceania") 
oceania_cell_feed
glimpse(oceania_cell_feed)

## ----include = FALSE-----------------------------------------------------
readfuns <- c("gs_read_csv", "gs_read_listfeed", "gs_read_cellfeed")
readfuns <- sapply(readfuns, get, USE.NAMES = TRUE)
jfun <- function(readfun)
  system.time(do.call(readfun, list(gs_gap(), ws = "Africa", verbose = FALSE)))
tmat <- sapply(readfuns, jfun)
tmat <- tmat[c("user.self", "sys.self", "elapsed"), ]
tmat_show <- sweep(tmat, 1, tmat[ , "gs_read_csv", drop = FALSE], "/")
tmat_show <- sapply(seq_len(ncol(tmat_show)), function(i) {
  paste0(format(round(tmat[ , i, drop = FALSE], 2), nsmall = 3), " (",
         format(round(tmat_show[ , i, drop = FALSE], 2), nsmall = 2), ")")
})
tmat_show <- as.data.frame(tmat_show, row.names = row.names(tmat))
colnames(tmat_show) <- colnames(tmat)

## ----echo = FALSE, results = "asis"--------------------------------------
knitr::kable(tmat_show, row.names = TRUE)

## ----post-processing-----------------------------------------------------
## reshape into 2D data frame
gap_3rows <- gap %>% gs_read_cellfeed("Europe", range = cell_rows(1:3))
gap_3rows %>% head()
gap_3rows %>% gs_reshape_cellfeed()

# Example: first row only
gap_1row <- gap %>% gs_read_cellfeed("Europe", range = cell_rows(1))
gap_1row

# convert to a named (character) vector
gap_1row %>% gs_simplify_cellfeed()

# Example: single column
gap_1col <- gap %>% gs_read_cellfeed("Europe", range = cell_cols(3))
gap_1col

# drop the `year` variable name, convert to integer, return un-named vector
yr <- gap_1col %>% gs_simplify_cellfeed(notation = "none")
str(yr)

## ----include = FALSE-----------------------------------------------------
Sys.sleep(20)

## ------------------------------------------------------------------------
df <- data_frame(thing1 = paste0("A", 2:5),
                 thing2 = paste0("B", 2:5),
                 thing3 = paste0("C", 2:5))
df$thing1[2] <- paste0("#", df$thing1[2])
df$thing2[1] <- "*"
df

ss <- gs_new("data-ingest-practice", ws_title = "simple",
             input = df, trim = TRUE) %>% 
  gs_ws_new("one-blank-row", input = df, trim = TRUE, anchor = "A2") %>% 
  gs_ws_new("two-blank-rows", input = df, trim = TRUE, anchor = "A3")

## ------------------------------------------------------------------------
## will use gs_read_csv
ss %>% gs_read(col_names = FALSE, skip = 1)
ss %>% gs_read(col_names = letters[1:3], skip = 1)

## explicitly use gs_read_listfeed
ss %>% gs_read_listfeed(col_names = FALSE, skip = 1)

## use range to force use of gs_read_cellfeed
ss %>% gs_read_listfeed(col_names = FALSE, skip = 1, range = cell_cols("A:Z"))

## ----include = FALSE-----------------------------------------------------
Sys.sleep(20)

## ------------------------------------------------------------------------
## blank row causes variable names to show up in the data frame :(
ss %>% gs_read(ws = "one-blank-row")

## skip = 1 fixes it :)
ss %>% gs_read(ws = "one-blank-row", skip = 1)

## more arguments, more better
ss %>% gs_read(ws = "one-blank-row", skip = 2,
               col_names = paste0("yo ?!*", 1:3), check.names = TRUE,
               na = "*", comment = "#", n_max = 2)

## also works on list feed
ss %>% gs_read_listfeed(ws = "one-blank-row", skip = 2,
                        col_names = paste0("yo ?!*", 1:3), check.names = TRUE,
                        na = "*", comment = "#", n_max = 2)

## also works on the cell feed
ss %>% gs_read_listfeed(ws = "one-blank-row", range = cell_cols("A:Z"), skip = 2,
                        col_names = paste0("yo ?!*", 1:3), check.names = TRUE,
                        na = "*", comment = "#", n_max = 2)

## ------------------------------------------------------------------------
## use skip to get correct result via gs_read() --> gs_read_csv()
ss %>% gs_read(ws = "two-blank-rows", skip = 2)

## or use range in gs_read() --> gs_read_cellfeed() + gs_reshape_cellfeed()
ss %>% gs_read(ws = "two-blank-rows", range = cell_limits(c(3, NA), c(NA, NA)))
ss %>% gs_read(ws = "two-blank-rows", range = cell_cols("A:C"))

## list feed can't cope because the 1st data row is empty
ss %>% gs_read_listfeed(ws = "two-blank-rows")
ss %>% gs_read_listfeed(ws = "two-blank-rows", skip = 2)

## ----delete-ingest-sheet-------------------------------------------------
gs_delete(ss)

## ----include = FALSE-----------------------------------------------------
Sys.sleep(20)

## ----gs_auth, eval = FALSE-----------------------------------------------
#  # Give googlesheets permission to access your spreadsheets and google drive
#  gs_auth()

## ----gs_user-------------------------------------------------------------
user_session_info <- gs_user()
user_session_info

