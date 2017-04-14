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

## ----options --------------------------------------------------
options(stringsAsFactors = FALSE) 
# setting as part of V4 that prints the JSON for easier debugging
options(googlesheets.print_json_request = TRUE)
# issues with package default client id and secret having enabled the V4 Sheets API
# using different client instead
options(googlesheets.client_id = '127208642922-0inefa6gok5hv9sl3hkaqtd72prmdtq2.apps.googleusercontent.com')
options(googlesheets.client_secret = 'yesQYnuvMSoRIr_0LJOhL51o')

## ----auth, include = FALSE-----------------------------------------------
## I grab the token from the testing directory because that's where it is to be
## found on Travis
token_path <- file.path("..", "tests", "testthat", "googlesheets_token.rds")
suppressMessages(gs_auth(token = token_path, verbose = FALSE))

## ----copy-gapminder, eval = TRUE, warning = FALSE----------------------------------------
ss <- gs_gap() %>%
  gs_copy(to = "Gapminder")

## ----get-sheet-object----------------------------------------
this_spreadsheetId <- ss$sheet_key
ssv4 <- gsv4_get(spreadsheetId = this_spreadsheetId)

## ----read-ws-metadata----------------------------------------
wsv4 <- bind_rows(lapply(ssv4$sheets, FUN=data.frame))
africa_ws_properties <- wsv4 %>% 
  filter(properties.title == 'Africa')
africa_ws_id <- africa_ws_properties$properties.sheetId
africa_ws_id
africa_ws_row_cnt <- africa_ws_properties$properties.gridProperties.rowCount
africa_ws_row_cnt
africa_ws_col_cnt <- africa_ws_properties$properties.gridProperties.columnCount
africa_ws_col_cnt

## ----reading-data--------------------------------------------------
# Get values from a spreadsheet - analogous to gs_read()
reply <- gsv4_values_get(spreadsheetId = this_spreadsheetId, range="Africa")
dat <- gsv4_parse_values(reply$values, col_names=TRUE)
head(dat, 3)

reply <- gsv4_values_get(spreadsheetId = this_spreadsheetId, range="Africa!A8:C10")
dat <- gsv4_parse_values(reply$values, col_names=FALSE)
dat

## ----rename-workshee--------------------------------------------------
#	Rename a worksheet - analogous to gs_ws_rename()
gsv4_batchUpdate(spreadsheetId = this_spreadsheetId,
                 input = gsv4_BatchUpdateSpreadsheetRequest(
                   requests=list(
                     gsv4_Request(
                       updateSheetProperties=gsv4_UpdateSheetPropertiesRequest(
                         fields='title', 
                         properties=gsv4_SheetProperties(sheetId=africa_ws_id, 
                                                         title='Africa2'))))))

## ----delete-worksheet--------------------------------------------------
#	Delete a worksheet - analogous to gs_ws_delete()
gsv4_batchUpdate(spreadsheetId = this_spreadsheetId,
                 input=gsv4_BatchUpdateSpreadsheetRequest(
                   requests=list(
                     gsv4_Request(
                       deleteSheet=gsv4_DeleteSheetRequest(sheetId=africa_ws_id)))))

## ----create-worksheet--------------------------------------------------
# Creates a worksheet - analogous to gs_ws_create()
# zero based indexes, user defined integer Id accepted (immutable)
create_id <- 12345678 
gsv4_batchUpdate(spreadsheetId = this_spreadsheetId,
                 input = gsv4_BatchUpdateSpreadsheetRequest(
                   requests=list(gsv4_Request(
                     addSheet=gsv4_AddSheetRequest(
                       properties=gsv4_SheetProperties(sheetId=create_id,
                                                       title="NewAfrica",
                                                       index=0,
                                                       gridProperties=
                                                         gsv4_GridProperties(rowCount=africa_ws_row_cnt,
                                                                             columnCount=africa_ws_col_cnt)))))))

## ----write-data--------------------------------------------------
# Write Data - analogous to gs_edit_cells()
gsv4_values_update(spreadsheetId=this_spreadsheetId, 
                            valueInputOption = 'RAW', 
                            range = "NewAfrica!A1", 
                            input = gsv4_ValueRange(majorDimension = 'ROWS', 
                                                    range="NewAfrica!A1",
                                                    values=gsv4_prep_values(head(iris))))

## ----bold-and-highlight-cells--------------------------------------------------
# Bold and Highlight the first row - no analogous googlesheets function currently
# zero based indexes and start is inclusive and end is exclusive
gsv4_batchUpdate(spreadsheetId = this_spreadsheetId,
                          input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                            gsv4_Request(repeatCell=gsv4_RepeatCellRequest(
                              cell=gsv4_CellData(
                                userEnteredFormat=gsv4_CellFormat(
                                  backgroundColor=gsv4_Color(120,10,100),
                                  textFormat=gsv4_TextFormat(bold=TRUE))),
                              fields="userEnteredFormat(backgroundColor,textFormat)", 
                              range=gsv4_GridRange(sheetId=create_id, 
                                                   startColumnIndex = 0, 
                                                   endRowIndex = 1))))))

## ----merge-cells--------------------------------------------------
# Merge cells A1:B2 - no analogous googlesheets function currently
# zero based indexes and start is inclusive and end is exclusive
gsv4_batchUpdate(spreadsheetId = this_spreadsheetId,
                          input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                            gsv4_Request(mergeCells=gsv4_MergeCellsRequest(
                              mergeType = 'MERGE_ALL',
                              range = gsv4_GridRange(sheetId=create_id, 
                                                     startColumnIndex=0, 
                                                     endColumnIndex=2, 
                                                     startRowIndex=0, 
                                                     endRowIndex=2))))))

## ----delete-columns--------------------------------------------------
# Delete 2 columns - no analogous googlesheets function currently
# zero based indexes and start is inclusive and end is exclusive
gsv4_batchUpdate(spreadsheetId = this_spreadsheetId,
                 input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                   gsv4_Request(deleteDimension=gsv4_DeleteDimensionRequest(
                     range=gsv4_DimensionRange(sheetId=create_id, 
                                               start=2, 
                                               end=4, 
                                               dimension = 'COLUMNS'))))))

## ----insert-rows--------------------------------------------------
# Insert blank row 3 - no analogous googlesheets function currently
gsv4_batchUpdate(spreadsheetId = this_spreadsheetId,
                 input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                   gsv4_Request(insertDimension=gsv4_InsertDimensionRequest(
                     range=gsv4_DimensionRange(sheetId=create_id, 
                                               start=2, 
                                               end=3, 
                                               dimension = 'ROWS'))))))

## ----write-to-blank-row--------------------------------------------------
# Populate values back - analogous to gs_edit_cells()
gsv4_values_update(spreadsheetId = this_spreadsheetId,
                   valueInputOption = 'RAW', 
                   range = "NewAfrica!A3", 
                   input = gsv4_ValueRange(values=gsv4_prep_values(iris[5,], 
                                                                   col_names=FALSE), 
                                           majorDimension = 'ROWS', 
                                           range="NewAfrica!A3"))
