#' gsv4_batchUpdate
#' 
#' Applies one or more updates to the spreadsheet.
#' 
#' Each request is validated before
#' being applied. If any request is not valid then the entire request will
#' fail and nothing will be applied.
#' 
#' Some requests have replies to
#' give you some information about how
#' they are applied. The replies will mirror the requests.  For example,
#' if you applied 4 updates and the 3rd one had a reply, then the
#' response will have 2 empty replies, the actual reply, and another empty
#' reply, in that order.
#' 
#' Due to the collaborative nature of spreadsheets, it is not guaranteed that
#' the spreadsheet will reflect exactly your changes after this completes,
#' however it is guaranteed that the updates in the request will be
#' applied together atomically. Your changes may be altered with respect to
#' collaborator changes. If there are no collaborators, the spreadsheet
#' should reflect your changes.
#' 
#' @importFrom httr POST content add_headers status_code
#' @importFrom jsonlite toJSON
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets/batchUpdate}{Google's Documentation for batchUpdate}
#' @param spreadsheetId string (required). The spreadsheet to apply the updates to.
#' @param input \code{\link{gsv4_BatchUpdateSpreadsheetRequest}}. The request for updating any aspect of a spreadsheet.
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return BatchUpdateSpreadsheetResponse
#' @export
gsv4_batchUpdate <- function(spreadsheetId, input, standard_params = list(...), ...){
  if(getOption("googlesheets.print_json_request")){
    cat(jsonlite::toJSON(input, pretty = TRUE, force = TRUE))
  }
  call_url <- sprintf("%s/v4/spreadsheets/%s:batchUpdate", getOption("googlesheets.service_url"), spreadsheetId)
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
#' gsv4_create
#' 
#' Creates a spreadsheet, returning the newly created spreadsheet.
#' 
#' @importFrom httr POST content add_headers status_code
#' @importFrom jsonlite toJSON
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets/create}{Google's Documentation for create}
#' @param input \code{\link{gsv4_Spreadsheet}}. Resource that represents a spreadsheet.
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return Spreadsheet
#' @export
gsv4_create <- function(input, standard_params = list(...), ...){
  if(getOption("googlesheets.print_json_request")){
    cat(jsonlite::toJSON(input, pretty = TRUE, force = TRUE))
  }
  call_url <- sprintf("%s/v4/spreadsheets", getOption("googlesheets.service_url"))
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
#' gsv4_get
#' 
#' Returns the spreadsheet at the given ID.
#' The caller must specify the spreadsheet ID.
#' 
#' By default, data within grids will not be returned.
#' You can include grid data one of two ways:
#' 
#' * Specify a field mask listing your desired fields using the `fields` URL
#' parameter in HTTP
#' 
#' * Set the includeGridData
#' URL parameter to TRUE.  If a field mask is set, the `includeGridData`
#' parameter is ignored
#' 
#' For large spreadsheets, it is recommended to retrieve only the specific
#' fields of the spreadsheet that you want.
#' 
#' To retrieve only subsets of the spreadsheet, use the
#' ranges URL parameter.
#' Multiple ranges can be specified.  Limiting the range will
#' return only the portions of the spreadsheet that intersect the requested
#' ranges. Ranges are specified using A1 notation.
#' 
#' @importFrom httr GET content add_headers status_code
#' @importFrom jsonlite toJSON
#' @seealso \href{https://developers.google.com/sheets/reference/rest/v4/spreadsheets/get}{Google's Documentation for get}
#' @param spreadsheetId string (required). The spreadsheet to request.
#' @param includeGridData logical. TRUE if grid data should be returned.
#' This parameter is ignored if a field mask was set in the request.
#' @param ranges string (repeated). The ranges to retrieve from the spreadsheet.
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return Spreadsheet
#' @export
gsv4_get <- function(spreadsheetId, includeGridData=NULL, ranges=NULL, standard_params = list(...), ...){
  call_url <- sprintf("%s/v4/spreadsheets/%s", getOption("googlesheets.service_url"), spreadsheetId)
  query_string <- gsv4_form_query_string(standard_params, includeGridData=includeGridData, ranges=ranges)
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
