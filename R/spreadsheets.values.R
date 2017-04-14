#' gsv4_values_append
#' 
#' Appends values to a spreadsheet. The input range is used to search for
#' existing data and find a "table" within that range. Values will be
#' appended to the next row of the table, starting with the first column of
#' the table. See the
#' \href{https://developers.google.com/sheets/api/guides/values#appending_values}{guide}
#' and
#' \href{https://developers.google.com/sheets/api/samples/writing#append_values}{sample code}
#' for specific details of how tables are detected and data is appended.
#' 
#' The caller must specify the spreadsheet ID, range, and
#' a valueInputOption.  The `valueInputOption` only
#' controls how the input data will be added to the sheet (column-wise or
#' row-wise), it does not influence what cell the data starts being written
#' to.
#' 
#' @importFrom httr POST content add_headers status_code
#' @importFrom jsonlite toJSON
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets.values/append}{Google's Documentation for append}
#' @usage gsv4_values_append(spreadsheetId, range, valueInputOption, includeValuesInResponse=NULL, insertDataOption=NULL, responseDateTimeRenderOption=NULL, responseValueRenderOption=NULL, input, standard_params = list(...), ...)
#' @param spreadsheetId string (required). The ID of the spreadsheet to update.
#' @param range string (required). The A1 notation of a range to search for a logical table of data.
#' Values will be appended after the last row of the table.
#' @param valueInputOption string (required). How the input data should be interpreted.
#' @param includeValuesInResponse logical. Determines if the update response should include the values
#' of the cells that were appended. By default, responses
#' do not include the updated values.
#' @param insertDataOption string. How the input data should be inserted.
#' @param responseDateTimeRenderOption string. Determines how dates, times, and durations in the response should be
#' rendered. This is ignored if response_value_render_option is
#' FORMATTED_VALUE.
#' The default dateTime render option is [DateTimeRenderOption.SERIAL_NUMBER].
#' @param responseValueRenderOption string. Determines how values in the response should be rendered.
#' The default render option is ValueRenderOption.FORMATTED_VALUE.
#' @param input \code{\link{gsv4_ValueRange}}. Data within a range of the spreadsheet.
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return AppendValuesResponse
#' @export
gsv4_values_append <- function(spreadsheetId, range, valueInputOption, includeValuesInResponse=NULL, insertDataOption=NULL, responseDateTimeRenderOption=NULL, responseValueRenderOption=NULL, input, standard_params = list(...), ...){
  if(getOption("googlesheets.print_json_request")){
    cat(jsonlite::toJSON(input, pretty = TRUE, force = TRUE))
  }
  call_url <- sprintf("%s/v4/spreadsheets/%s/values/%s:append", getOption("googlesheets.service_url"), spreadsheetId, range)
  query_string <- gsv4_form_query_string(standard_params, valueInputOption, includeValuesInResponse, insertDataOption, responseDateTimeRenderOption, responseValueRenderOption)
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
#' gsv4_values_batchClear
#' 
#' Clears one or more ranges of values from a spreadsheet.
#' The caller must specify the spreadsheet ID and one or more ranges.
#' Only values are cleared -- all other properties of the cell (such as
#' formatting, data validation, etc..) are kept.
#' 
#' @importFrom httr POST content add_headers status_code
#' @importFrom jsonlite toJSON
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets.values/batchClear}{Google's Documentation for batchClear}
#' @usage gsv4_values_batchClear(spreadsheetId, input, standard_params = list(...), ...)
#' @param spreadsheetId string (required). The ID of the spreadsheet to update.
#' @param input \code{\link{gsv4_BatchClearValuesRequest}}. The request for clearing more than one range of values in a spreadsheet.
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return BatchClearValuesResponse
#' @export
gsv4_values_batchClear <- function(spreadsheetId, input, standard_params = list(...), ...){
  if(getOption("googlesheets.print_json_request")){
    cat(jsonlite::toJSON(input, pretty = TRUE, force = TRUE))
  }
  call_url <- sprintf("%s/v4/spreadsheets/%s/values:batchClear", getOption("googlesheets.service_url"), spreadsheetId)
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
#' gsv4_values_batchGet
#' 
#' Returns one or more ranges of values from a spreadsheet.
#' The caller must specify the spreadsheet ID and one or more ranges.
#' 
#' @importFrom httr GET content add_headers status_code
#' @importFrom jsonlite toJSON
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets.values/batchGet}{Google's Documentation for batchGet}
#' @usage gsv4_values_batchGet(spreadsheetId, dateTimeRenderOption=NULL, majorDimension=NULL, ranges=NULL, valueRenderOption=NULL, standard_params = list(...), ...)
#' @param spreadsheetId string (required). The ID of the spreadsheet to retrieve data from.
#' @param dateTimeRenderOption string. How dates, times, and durations should be represented in the output.
#' This is ignored if value_render_option is
#' FORMATTED_VALUE.
#' The default dateTime render option is [DateTimeRenderOption.SERIAL_NUMBER].
#' @param majorDimension string. The major dimension that results should use.
#' 
#' For example, if the spreadsheet data is: `A1=1,B1=2,A2=3,B2=4`,
#' then requesting `range=A1:B2,majorDimension=ROWS` will return
#' `[[1,2],[3,4]]`,
#' whereas requesting `range=A1:B2,majorDimension=COLUMNS` will return
#' `[[1,3],[2,4]]`.
#' @param ranges string (repeated). The A1 notation of the values to retrieve.
#' @param valueRenderOption string. How values should be represented in the output.
#' The default render option is ValueRenderOption.FORMATTED_VALUE.
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return BatchGetValuesResponse
#' @export
gsv4_values_batchGet <- function(spreadsheetId, dateTimeRenderOption=NULL, majorDimension=NULL, ranges=NULL, valueRenderOption=NULL, standard_params = list(...), ...){
  call_url <- sprintf("%s/v4/spreadsheets/%s/values:batchGet", getOption("googlesheets.service_url"), spreadsheetId)
  query_string <- gsv4_form_query_string(standard_params, dateTimeRenderOption, majorDimension, ranges, valueRenderOption)
  call_url <- paste0(call_url, query_string)
  req <- GET(call_url, google_token(),
              add_headers(`Content-Type` = 'application/json'))
  parsed_req <- content(req, "parsed")
  if(status_code(req) != 200){
    warning(parsed_req)
  }
  return(parsed_req)
}
#' 
#' gsv4_values_batchUpdate
#' 
#' Sets values in one or more ranges of a spreadsheet.
#' The caller must specify the spreadsheet ID,
#' a valueInputOption, and one or more
#' ValueRanges.
#' 
#' @importFrom httr POST content add_headers status_code
#' @importFrom jsonlite toJSON
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets.values/batchUpdate}{Google's Documentation for batchUpdate}
#' @usage gsv4_values_batchUpdate(spreadsheetId, input, standard_params = list(...), ...)
#' @param spreadsheetId string (required). The ID of the spreadsheet to update.
#' @param input \code{\link{gsv4_BatchUpdateValuesRequest}}. The request for updating more than one range of values in a spreadsheet.
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return BatchUpdateValuesResponse
#' @export
gsv4_values_batchUpdate <- function(spreadsheetId, input, standard_params = list(...), ...){
  if(getOption("googlesheets.print_json_request")){
    cat(jsonlite::toJSON(input, pretty = TRUE, force = TRUE))
  }
  call_url <- sprintf("%s/v4/spreadsheets/%s/values:batchUpdate", getOption("googlesheets.service_url"), spreadsheetId)
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
#' gsv4_values_clear
#' 
#' Clears values from a spreadsheet.
#' The caller must specify the spreadsheet ID and range.
#' Only values are cleared -- all other properties of the cell (such as
#' formatting, data validation, etc..) are kept.
#' 
#' @importFrom httr POST content add_headers status_code
#' @importFrom jsonlite toJSON
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets.values/clear}{Google's Documentation for clear}
#' @usage gsv4_values_clear(spreadsheetId, range, input, standard_params = list(...), ...)
#' @param spreadsheetId string (required). The ID of the spreadsheet to update.
#' @param range string (required). The A1 notation of the values to clear.
#' @param input \code{\link{gsv4_ClearValuesRequest}}. The request for clearing a range of values in a spreadsheet.
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return ClearValuesResponse
#' @export
gsv4_values_clear <- function(spreadsheetId, range, input, standard_params = list(...), ...){
  if(getOption("googlesheets.print_json_request")){
    cat(jsonlite::toJSON(input, pretty = TRUE, force = TRUE))
  }
  call_url <- sprintf("%s/v4/spreadsheets/%s/values/%s:clear", getOption("googlesheets.service_url"), spreadsheetId, range)
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
#' gsv4_values_get
#' 
#' Returns a range of values from a spreadsheet.
#' The caller must specify the spreadsheet ID and a range.
#' 
#' @importFrom httr GET content add_headers status_code
#' @importFrom jsonlite toJSON
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets.values/get}{Google's Documentation for get}
#' @usage gsv4_values_get(spreadsheetId, range, dateTimeRenderOption=NULL, majorDimension=NULL, valueRenderOption=NULL, standard_params = list(...), ...)
#' @param spreadsheetId string (required). The ID of the spreadsheet to retrieve data from.
#' @param range string (required). The A1 notation of the values to retrieve.
#' @param dateTimeRenderOption string. How dates, times, and durations should be represented in the output.
#' This is ignored if value_render_option is
#' FORMATTED_VALUE.
#' The default dateTime render option is [DateTimeRenderOption.SERIAL_NUMBER].
#' @param majorDimension string. The major dimension that results should use.
#' 
#' For example, if the spreadsheet data is: `A1=1,B1=2,A2=3,B2=4`,
#' then requesting `range=A1:B2,majorDimension=ROWS` will return
#' `[[1,2],[3,4]]`,
#' whereas requesting `range=A1:B2,majorDimension=COLUMNS` will return
#' `[[1,3],[2,4]]`.
#' @param valueRenderOption string. How values should be represented in the output.
#' The default render option is ValueRenderOption.FORMATTED_VALUE.
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return ValueRange
#' @export
gsv4_values_get <- function(spreadsheetId, range, dateTimeRenderOption=NULL, majorDimension=NULL, valueRenderOption=NULL, standard_params = list(...), ...){
  call_url <- sprintf("%s/v4/spreadsheets/%s/values/%s", getOption("googlesheets.service_url"), spreadsheetId, range)
  query_string <- gsv4_form_query_string(standard_params, dateTimeRenderOption, majorDimension, valueRenderOption)
  call_url <- paste0(call_url, query_string)
  req <- GET(call_url, google_token(),
              add_headers(`Content-Type` = 'application/json'))
  parsed_req <- content(req, "parsed")
  if(status_code(req) != 200){
    warning(parsed_req)
  }
  return(parsed_req)
}
#' 
#' gsv4_values_update
#' 
#' Sets values in a range of a spreadsheet.
#' The caller must specify the spreadsheet ID, range, and
#' a valueInputOption.
#' 
#' @importFrom httr PUT content add_headers status_code
#' @importFrom jsonlite toJSON
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets.values/update}{Google's Documentation for update}
#' @usage gsv4_values_update(spreadsheetId, range, valueInputOption, includeValuesInResponse=NULL, responseDateTimeRenderOption=NULL, responseValueRenderOption=NULL, input, standard_params = list(...), ...)
#' @param spreadsheetId string (required). The ID of the spreadsheet to update.
#' @param range string (required). The A1 notation of the values to update.
#' @param valueInputOption string (required). How the input data should be interpreted.
#' @param includeValuesInResponse logical. Determines if the update response should include the values
#' of the cells that were updated. By default, responses
#' do not include the updated values.
#' If the range to write was larger than than the range actually written,
#' the response will include all values in the requested range (excluding
#' trailing empty rows and columns).
#' @param responseDateTimeRenderOption string. Determines how dates, times, and durations in the response should be
#' rendered. This is ignored if response_value_render_option is
#' FORMATTED_VALUE.
#' The default dateTime render option is [DateTimeRenderOption.SERIAL_NUMBER].
#' @param responseValueRenderOption string. Determines how values in the response should be rendered.
#' The default render option is ValueRenderOption.FORMATTED_VALUE.
#' @param input \code{\link{gsv4_ValueRange}}. Data within a range of the spreadsheet.
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return UpdateValuesResponse
#' @export
gsv4_values_update <- function(spreadsheetId, range, valueInputOption, includeValuesInResponse=NULL, responseDateTimeRenderOption=NULL, responseValueRenderOption=NULL, input, standard_params = list(...), ...){
  if(getOption("googlesheets.print_json_request")){
    cat(jsonlite::toJSON(input, pretty = TRUE, force = TRUE))
  }
  call_url <- sprintf("%s/v4/spreadsheets/%s/values/%s", getOption("googlesheets.service_url"), spreadsheetId, range)
  query_string <- gsv4_form_query_string(standard_params, valueInputOption, includeValuesInResponse, responseDateTimeRenderOption, responseValueRenderOption)
  call_url <- paste0(call_url, query_string)
  req <- PUT(call_url, google_token(),
              body = jsonlite::toJSON(input, force=TRUE),
              add_headers(`Content-Type` = 'application/json'))
  parsed_req <- content(req, "parsed")
  if(status_code(req) != 200){
    warning(parsed_req)
  }
  return(parsed_req)
}
#' 
