


```r
library(googlesheets)
suppressMessages(library(dplyr))
```

```r
options(stringsAsFactors = FALSE) 
# setting as part of V4 that prints the JSON for easier debugging
options(googlesheets.print_json_request = TRUE)
# issues with package default client id and secret having enabled the V4 Sheets API
# using different client instead
options(googlesheets.client_id = '127208642922-0inefa6gok5hv9sl3hkaqtd72prmdtq2.apps.googleusercontent.com')
options(googlesheets.client_secret = 'yesQYnuvMSoRIr_0LJOhL51o')
```


```r
ss <- gs_gap() %>%
  gs_copy(to = "Gapminder")
#> Successful copy! New sheet is titled "Gapminder".
```

```r
this_spreadsheetId <- ss$sheet_key
ssv4 <- gsv4_get(spreadsheetId = this_spreadsheetId)
```

```r
wsv4 <- bind_rows(lapply(ssv4$sheets, FUN=data.frame))
africa_ws_properties <- wsv4 %>% 
  filter(properties.title == 'Africa')
africa_ws_id <- africa_ws_properties$properties.sheetId
africa_ws_id
#> [1] 1150108545
africa_ws_row_cnt <- africa_ws_properties$properties.gridProperties.rowCount
africa_ws_row_cnt
#> [1] 625
africa_ws_col_cnt <- africa_ws_properties$properties.gridProperties.columnCount
africa_ws_col_cnt
#> [1] 6
```

```r
# Get values from a spreadsheet - analogous to gs_read()
reply <- gsv4_values_get(spreadsheetId = this_spreadsheetId, range="Africa")
dat <- gsv4_parse_values(reply$values, col_names=TRUE)
head(dat, 3)
#>   country continent year lifeExp      pop gdpPercap
#> 1 Algeria    Africa 1952  43.077  9279525 2449.0082
#> 2 Algeria    Africa 1957  45.685 10270856  3013.976
#> 3 Algeria    Africa 1962  48.303 11000948 2550.8169

reply <- gsv4_values_get(spreadsheetId = this_spreadsheetId, range="Africa!A8:C10")
dat <- gsv4_parse_values(reply$values, col_names=FALSE)
dat
#>        V1     V2   V3
#> 1 Algeria Africa 1982
#> 2 Algeria Africa 1987
#> 3 Algeria Africa 1992
```

```r
#	Rename a worksheet - analogous to gs_ws_rename()
gsv4_batchUpdate(spreadsheetId = this_spreadsheetId,
                 input = gsv4_BatchUpdateSpreadsheetRequest(
                   requests=list(
                     gsv4_Request(
                       updateSheetProperties=gsv4_UpdateSheetPropertiesRequest(
                         fields='title', 
                         properties=gsv4_SheetProperties(sheetId=africa_ws_id, 
                                                         title='Africa2'))))))
#> {
#>   "requests": [
#>     {
#>       "updateSheetProperties": {
#>         "fields": "title",
#>         "properties": {
#>           "sheetId": 1150108545,
#>           "title": "Africa2"
#>         }
#>       }
#>     }
#>   ]
#> }
#> $spreadsheetId
#> [1] "1t2Bh2veSbkY4tcuYLqaWwCg-UXw-DAY2uzM5T9VJC5Y"
#> 
#> $replies
#> $replies[[1]]
#> named list()
```

```r
#	Delete a worksheet - analogous to gs_ws_delete()
gsv4_batchUpdate(spreadsheetId = this_spreadsheetId,
                 input=gsv4_BatchUpdateSpreadsheetRequest(
                   requests=list(
                     gsv4_Request(
                       deleteSheet=gsv4_DeleteSheetRequest(sheetId=africa_ws_id)))))
#> {
#>   "requests": [
#>     {
#>       "deleteSheet": {
#>         "sheetId": 1150108545
#>       }
#>     }
#>   ]
#> }
#> $spreadsheetId
#> [1] "1t2Bh2veSbkY4tcuYLqaWwCg-UXw-DAY2uzM5T9VJC5Y"
#> 
#> $replies
#> $replies[[1]]
#> named list()
```

```r
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
#> {
#>   "requests": [
#>     {
#>       "addSheet": {
#>         "properties": {
#>           "sheetId": 12345678,
#>           "gridProperties": {
#>             "columnCount": 6,
#>             "rowCount": 625
#>           },
#>           "index": 0,
#>           "title": "NewAfrica"
#>         }
#>       }
#>     }
#>   ]
#> }
#> $spreadsheetId
#> [1] "1t2Bh2veSbkY4tcuYLqaWwCg-UXw-DAY2uzM5T9VJC5Y"
#> 
#> $replies
#> $replies[[1]]
#> $replies[[1]]$addSheet
#> $replies[[1]]$addSheet$properties
#> $replies[[1]]$addSheet$properties$sheetId
#> [1] 12345678
#> 
#> $replies[[1]]$addSheet$properties$title
#> [1] "NewAfrica"
#> 
#> $replies[[1]]$addSheet$properties$index
#> [1] 0
#> 
#> $replies[[1]]$addSheet$properties$sheetType
#> [1] "GRID"
#> 
#> $replies[[1]]$addSheet$properties$gridProperties
#> $replies[[1]]$addSheet$properties$gridProperties$rowCount
#> [1] 625
#> 
#> $replies[[1]]$addSheet$properties$gridProperties$columnCount
#> [1] 6
```

```r
# Write Data - analogous to gs_edit_cells()
gsv4_values_update(spreadsheetId=this_spreadsheetId, 
                            valueInputOption = 'RAW', 
                            range = "NewAfrica!A1", 
                            input = gsv4_ValueRange(majorDimension = 'ROWS', 
                                                    range="NewAfrica!A1",
                                                    values=gsv4_prep_values(head(iris))))
#> {
#>   "range": "NewAfrica!A1",
#>   "majorDimension": "ROWS",
#>   "values": [
#>     ["Sepal.Length", "Sepal.Width", "Petal.Length", "Petal.Width", "Species"],
#>     ["5.1", "3.5", "1.4", "0.2", "setosa"],
#>     ["4.9", "3.0", "1.4", "0.2", "setosa"],
#>     ["4.7", "3.2", "1.3", "0.2", "setosa"],
#>     ["4.6", "3.1", "1.5", "0.2", "setosa"],
#>     ["5.0", "3.6", "1.4", "0.2", "setosa"],
#>     ["5.4", "3.9", "1.7", "0.4", "setosa"]
#>   ]
#> }
#> Warning in gsv4_values_update(spreadsheetId = this_spreadsheetId,
#> valueInputOption = "RAW", : list(code = 400, message = "Invalid query
#> parameters. Empty query parameter names are not allowed.", status =
#> "INVALID_ARGUMENT")
#> $error
#> $error$code
#> [1] 400
#> 
#> $error$message
#> [1] "Invalid query parameters. Empty query parameter names are not allowed."
#> 
#> $error$status
#> [1] "INVALID_ARGUMENT"
```

```r
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
#> {
#>   "requests": [
#>     {
#>       "repeatCell": {
#>         "range": {
#>           "sheetId": 12345678,
#>           "endRowIndex": 1,
#>           "startColumnIndex": 0
#>         },
#>         "fields": "userEnteredFormat(backgroundColor,textFormat)",
#>         "cell": {
#>           "userEnteredFormat": {
#>             "backgroundColor": {
#>               "alpha": 120,
#>               "blue": 10,
#>               "green": 100
#>             },
#>             "textFormat": {
#>               "bold": true
#>             }
#>           }
#>         }
#>       }
#>     }
#>   ]
#> }
#> $spreadsheetId
#> [1] "1t2Bh2veSbkY4tcuYLqaWwCg-UXw-DAY2uzM5T9VJC5Y"
#> 
#> $replies
#> $replies[[1]]
#> named list()
```

```r
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
#> {
#>   "requests": [
#>     {
#>       "mergeCells": {
#>         "range": {
#>           "sheetId": 12345678,
#>           "endColumnIndex": 2,
#>           "endRowIndex": 2,
#>           "startColumnIndex": 0,
#>           "startRowIndex": 0
#>         },
#>         "mergeType": "MERGE_ALL"
#>       }
#>     }
#>   ]
#> }
#> $spreadsheetId
#> [1] "1t2Bh2veSbkY4tcuYLqaWwCg-UXw-DAY2uzM5T9VJC5Y"
#> 
#> $replies
#> $replies[[1]]
#> named list()
```

```r
# Delete 2 columns - no analogous googlesheets function currently
# zero based indexes and start is inclusive and end is exclusive
gsv4_batchUpdate(spreadsheetId = this_spreadsheetId,
                 input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                   gsv4_Request(deleteDimension=gsv4_DeleteDimensionRequest(
                     range=gsv4_DimensionRange(sheetId=create_id, 
                                               start=2, 
                                               end=4, 
                                               dimension = 'COLUMNS'))))))
#> {
#>   "requests": [
#>     {
#>       "deleteDimension": {
#>         "range": {
#>           "sheetId": 12345678,
#>           "dimension": "COLUMNS",
#>           "endIndex": 4,
#>           "startIndex": 2
#>         }
#>       }
#>     }
#>   ]
#> }
#> $spreadsheetId
#> [1] "1t2Bh2veSbkY4tcuYLqaWwCg-UXw-DAY2uzM5T9VJC5Y"
#> 
#> $replies
#> $replies[[1]]
#> named list()
```

```r
# Insert blank row 3 - no analogous googlesheets function currently
gsv4_batchUpdate(spreadsheetId = this_spreadsheetId,
                 input=gsv4_BatchUpdateSpreadsheetRequest(requests=list(
                   gsv4_Request(insertDimension=gsv4_InsertDimensionRequest(
                     range=gsv4_DimensionRange(sheetId=create_id, 
                                               start=2, 
                                               end=3, 
                                               dimension = 'ROWS'))))))
#> {
#>   "requests": [
#>     {
#>       "insertDimension": {
#>         "range": {
#>           "sheetId": 12345678,
#>           "dimension": "ROWS",
#>           "endIndex": 3,
#>           "startIndex": 2
#>         }
#>       }
#>     }
#>   ]
#> }
#> $spreadsheetId
#> [1] "1t2Bh2veSbkY4tcuYLqaWwCg-UXw-DAY2uzM5T9VJC5Y"
#> 
#> $replies
#> $replies[[1]]
#> named list()
```

```r
# Populate values back - analogous to gs_edit_cells()
gsv4_values_update(spreadsheetId = this_spreadsheetId,
                   valueInputOption = 'RAW', 
                   range = "NewAfrica!A3", 
                   input = gsv4_ValueRange(values=gsv4_prep_values(iris[5,], 
                                                                   col_names=FALSE), 
                                           majorDimension = 'ROWS', 
                                           range="NewAfrica!A3"))
#> {
#>   "range": "NewAfrica!A3",
#>   "majorDimension": "ROWS",
#>   "values": [
#>     ["5", "3.6", "1.4", "0.2", "setosa"]
#>   ]
#> }
#> Warning in gsv4_values_update(spreadsheetId = this_spreadsheetId,
#> valueInputOption = "RAW", : list(code = 400, message = "Invalid query
#> parameters. Empty query parameter names are not allowed.", status =
#> "INVALID_ARGUMENT")
#> $error
#> $error$code
#> [1] 400
#> 
#> $error$message
#> [1] "Invalid query parameters. Empty query parameter names are not allowed."
#> 
#> $error$status
#> [1] "INVALID_ARGUMENT"
```

