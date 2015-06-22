## ----load package--------------------------------------------------------
library(googlesheets)
suppressMessages(library(dplyr))

## ----auth, include = FALSE-----------------------------------------------
suppressMessages(gs_auth(token = "googlesheets_token.rds", verbose = FALSE))

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
oceania_list_feed <- gs_read_listfeed(gap, ws = "Oceania") 
str(oceania_list_feed)
oceania_list_feed

## ------------------------------------------------------------------------
oceania_cell_feed <- gs_read_cellfeed(gap, ws = "Oceania") 
str(oceania_cell_feed)
head(oceania_cell_feed, 10)
oceania_reshaped <- gs_reshape_cellfeed(oceania_cell_feed)
str(oceania_reshaped)
head(oceania_reshaped, 10)

## ----createspreadsheet---------------------------------------------------
# Create a new empty spreadsheet by title
gs_new("hi I am new here")
gs_ls("hi I am new here")

## ----delete spreadsheet--------------------------------------------------
# Move spreadsheet to trash
gs_grepdel("hi I am new here")
gs_ls("hi I am new here")

## ----new-sheet-new-ws-delete-ws------------------------------------------
gs_new("hi I am new here")
x <- gs_title("hi I am new here")
x
x <- gs_ws_new(x, ws_title = "foo", row_extent = 10, col_extent = 10)
x
x <- gs_ws_delete(x, ws = "foo")
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

