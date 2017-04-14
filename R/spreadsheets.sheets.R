#' gsv4_sheets_copyTo
#' 
#' Copies a single sheet from a spreadsheet to another spreadsheet.
#' Returns the properties of the newly created sheet.
#' 
#' @importFrom httr POST content add_headers status_code
#' @importFrom jsonlite toJSON
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets.sheets/copyTo}{Google's Documentation for copyTo}
#' @param spreadsheetId string (required). The ID of the spreadsheet containing the sheet to copy.
#' @param sheetId integer (required). The ID of the sheet to copy.
#' @param input \code{\link{gsv4_CopySheetToAnotherSpreadsheetRequest}}. The request to copy a sheet across spreadsheets.
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return SheetProperties
#' @export
gsv4_sheets_copyTo <- function(spreadsheetId, sheetId, input, standard_params = list(...), ...){
  if(getOption("googlesheets.print_json_request")){
    cat(jsonlite::toJSON(input, pretty = TRUE, force = TRUE))
  }
  call_url <- sprintf("%s/v4/spreadsheets/%s/sheets/%s:copyTo", getOption("googlesheets.service_url"), spreadsheetId, sheetId)
  query_string <- gsv4_form_query_string(standard_params)
  call_url <- paste0(call_url, query_string)
  req <- POST(call_url, google_token(),
              body = jsonlite::toJSON(input, force=TRUE),
              add_headers(`Content-Type` = 'application/json'))
  parsed_req <- content(req, "parsed")
  if(status_code(req) != 200){
    warning(parsed_req)
  }
  return(parsed_req)
}
#' 
