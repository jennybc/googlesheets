## ----load package--------------------------------------------------------
library(gspreadr)
suppressMessages(library(dplyr))

## ----authorize, include = FALSE------------------------------------------

## look for .httr-oauth in pwd (assuming pwd is gspreadr) or two levels up
## (assuming pwd is gspreadr/tests/testthat)
pwd <- getwd()
one_up <- pwd %>% dirname()
two_up <- pwd %>% dirname() %>% dirname()
HTTR_OAUTH <- c(two_up, one_up, pwd) %>% file.path(".httr-oauth")
HTTR_OAUTH <- HTTR_OAUTH[HTTR_OAUTH %>% file.exists()]

if(length(HTTR_OAUTH) > 0) {
  HTTR_OAUTH <- HTTR_OAUTH[1]
  file.copy(from = HTTR_OAUTH, to = ".httr-oauth", overwrite = TRUE)
}


## ----copy-gapminder, eval = FALSE----------------------------------------
#  gap_key <- "1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE"
#  copy_ss(key = gap_key, to = "Gapminder")

## ----list-sheets---------------------------------------------------------
my_sheets <- list_sheets()

## ----view-my-sheets, echo = FALSE----------------------------------------
my_sheets %>% 
  head %>% 
  mutate(sheet_title = substr(sheet_title, 1, 10),
         sheet_key = sheet_key %>% substr(1, 7) %>% stringr::str_c("...")) %>% 
  select(-ws_feed)

## ------------------------------------------------------------------------
gap <- register_ss("Gapminder")
str(gap)

## ------------------------------------------------------------------------
(gap_key <- my_sheets$sheet_key[my_sheets$sheet_title == "Gapminder"])
ss2 <- register_ss(gap_key)
str(ss2)

## ------------------------------------------------------------------------
str(gap)
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

## ----create and delete spreadsheet---------------------------------------
# Create a new empty spreadsheet by title
new_ss("hi I am new here")
list_sheets() %>% filter(sheet_title == "hi I am new here")

# Move spreadsheet to trash
delete_ss("hi I am new here")
list_sheets() %>% filter(sheet_title == "hi I am new here")

## ----new-sheet-new-ws-delete-ws------------------------------------------
new_ss("hi I am new here")
x <- register_ss("hi I am new here")
str(x)
add_ws(x, ws_title = "foo", nrow = 10, ncol = 10)
x <- register_ss("hi I am new here")
str(x)
delete_ws(x, ws_title = "foo")
x <- register_ss("hi I am new here")
str(x)

## ----new-ws-rename-ws-delete-ws, eval = FALSE----------------------------
#  ## oops this function not resurrected yet!
#  rename_worksheet(ssheet, "Sheet1", "First Sheet")

## ----delete-sheet--------------------------------------------------------
delete_ss("hi I am new here")

## ----, fig.width=7, fig.height=7, eval = FALSE---------------------------
#  
#  view(ws)
#  
#  view_all(ssheet)

## ----update cell, eval = FALSE-------------------------------------------
#  
#  update_cell(ws, "A1", "Oops")
#  
#  get_cell(ws, "A1")
#  
#  update_cell(ws, "R1C1", "country")
#  
#  get_cell(ws, "R1C1")
#  

## ----update cells, eval = FALSE------------------------------------------
#  
#  update_cells(ws, "C1:E1", c("A", "B", "C"))
#  
#  read_range(ws, "A1:F3")
#  
#  update_cells(ws, "G1", head(iris))
#  
#  read_range(ws, "G1:K7")

## ----return to orig, include = FALSE, eval = FALSE, eval = FALSE---------
#  
#  update_cells(ws, "C1:E1", c("pop", "continent", "lifeExp"))
#  update_cells(ws, "G1:K7", ncol(head(iris) * (nrow(iris) + 1)))

