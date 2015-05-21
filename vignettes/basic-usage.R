## ----load package--------------------------------------------------------
library(googlesheets)
suppressMessages(library(dplyr))

## ----auth, include = FALSE-----------------------------------------------

## look for .httr-oauth in pwd (assuming pwd is googlesheets) or two levels up
## (assuming pwd is googlesheets/tests/testthat)
pwd <- getwd()
one_up <- pwd %>% dirname()
two_up <- pwd %>% dirname() %>% dirname()
HTTR_OAUTH <- c(two_up, one_up, pwd) %>% file.path(".httr-oauth")
HTTR_OAUTH <- HTTR_OAUTH[HTTR_OAUTH %>% file.exists()]

if(length(HTTR_OAUTH) > 0) {
  HTTR_OAUTH <- HTTR_OAUTH[1]
  file.copy(from = HTTR_OAUTH, to = ".httr-oauth", overwrite = TRUE)
}


## ----pre-clean, include = FALSE------------------------------------------
## if a previous compilation of this document leaves anything behind, i.e. if it
## aborts, clean up Google Drive first
gs_vecdel("hi I am new here", verbose = FALSE)

## ----copy-gapminder, eval = FALSE----------------------------------------
#  gs_gap() %>%
#    gs_copy(to = "Gapminder")

## ----list-sheets---------------------------------------------------------
my_sheets <- gs_ls()
my_sheets

## ------------------------------------------------------------------------
gap <- gs_title("Gapminder")
gap

## ------------------------------------------------------------------------
just_gap <- gs_ls("^Gapminder$")
just_gap$sheet_key
ss2 <- just_gap$sheet_key %>%
  gs_key()
ss2

## ------------------------------------------------------------------------
gap
oceania_list_feed <- get_via_lf(gap, ws = "Oceania") 
str(oceania_list_feed)
oceania_list_feed

## ------------------------------------------------------------------------
oceania_cell_feed <- get_via_cf(gap, ws = "Oceania") 
str(oceania_cell_feed)
head(oceania_cell_feed, 10)
oceania_reshaped <- reshape_cf(oceania_cell_feed)
str(oceania_reshaped)
head(oceania_reshaped, 10)

## ----createspreadsheet---------------------------------------------------
# Create a new empty spreadsheet by title
gs_new("hi I am new here")
gs_ls() %>% filter(sheet_title == "hi I am new here")

## ----delete spreadsheet--------------------------------------------------
# Move spreadsheet to trash
gs_delete(gs_title("hi I am new here"))
gs_ls() %>% filter(sheet_title == "hi I am new here")

## ----new-sheet-new-ws-delete-ws------------------------------------------
gs_new("hi I am new here")
x <- gs_title("hi I am new here")
x
x <- gs_ws_new(x, ws_title = "foo", nrow = 10, ncol = 10)
x
gs_ws_delete(x, ws = "foo")
x <- gs_title("hi I am new here")
x

## ----new-ws-rename-ws-delete-ws------------------------------------------
gs_ws_rename(x, "Sheet1", "First Sheet")

## ----delete-sheet--------------------------------------------------------
gs_delete(gs_title("hi I am new here"))

## ---- fig.width=7, fig.height=7, eval = FALSE----------------------------
#  
#  view(ws)
#  
#  view_all(ssheet)

