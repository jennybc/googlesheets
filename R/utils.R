#' Extract sheet key from a URL
#'
#' Extract a sheet's unique key from a wide variety of URLs, i.e. a browser URL
#' for both old and new Sheets, the "worksheets feed", and other links returned
#' by the Sheets API.
#'
#' @param url character; a URL associated with a Google Sheet
#'
#' @examples
#' \dontrun{
#' GAP_URL <- gs_gap_url()
#' GAP_KEY <- extract_key_from_url(GAP_URL)
#' gap_ss <- gs_key(GAP_KEY)
#' gap_ss
#' }
#'
#' @export
extract_key_from_url <- function(url) {
  url_start_list <-
    c(ws_feed_start = "https://spreadsheets.google.com/feeds/worksheets/",
      self_link_start = "https://spreadsheets.google.com/feeds/spreadsheets/private/full/",
      url_start_new = "https://docs.google.com/spreadsheets/d/",
      url_start_google_apps_for_work = "https://docs.google.com/a/[[:print:]]+/spreadsheets/d/",
      url_start_old = "https://docs.google.com/spreadsheet/ccc\\?key=",
      url_start_old2 = "https://docs.google.com/spreadsheet/pub\\?key=",
      url_start_old3 = "https://spreadsheets.google.com/ccc\\?key=")
  url_start <- url_start_list %>% stringr::str_c(collapse = "|")
  url %>% stringr::str_replace(url_start, '') %>%
    stringr::str_split_fixed('[/&#]', n = 2) %>%
    `[`(, 1)
}

#' Construct a worksheets feed from a key
#'
#' @param key character, unique key for a spreadsheet
#' @param visibility character, either "private" (default) or "public",
#'   indicating whether further requests will be made with or without
#'   authorization, respectively
#'
#' @keywords internal
construct_ws_feed_from_key <- function(key, visibility = "private") {
  tmp <-
    "https://spreadsheets.google.com/feeds/worksheets/%s/%s/full"
  sprintf(tmp, key, visibility)
}

#' Construct a browser URL from a key
#'
#' @param key character, unique key for a spreadsheet
#'
#' @keywords internal
construct_url_from_key <- function(key) {
  tmp <- "https://docs.google.com/spreadsheets/d/%s/"
  sprintf(tmp, key)
}

isFALSE <- function(x) identical(FALSE, x)

is_toggle <- function(x) {
  is.null(x) || isTRUE(x) || isFALSE(x)
}

force_na_type <-
  function(x, type = c("logical", "integer", "double", "real",
                       "complex", "character")) {
    type <- match.arg(type)
    if(all(is.na(x))) {
      na <- switch(type,
                   logical = NA,
                   integer = NA_integer_,
                   double = NA_real_,
                   real = NA_real_,
                   complex = NA_complex_,
                   character = NA_character_,
                   NA)
      rep_len(na, length(x))
    } else {
      x
    }
  }

## good news: these are handy and call. = FALSE is built-in
##  bad news: 'fmt' must be exactly 1 string, i.e. you've got to paste, iff
##             you're counting on sprintf() substitution
cpf <- function(...) cat(paste0(sprintf(...), "\n"))
mpf <- function(...) message(sprintf(...))
wpf <- function(...) warning(sprintf(...), call. = FALSE)
spf <- function(...) stop(sprintf(...), call. = FALSE)

## spotted in various hadley packages
dropnulls <- function(x) Filter(Negate(is.null), x)

## do intake on `...` for all the read functions
parse_read_ddd <- function(..., verbose = FALSE) {
  ddd <- list(...)
  ddd <- list(
    ## pass straight through to readr::read_csv, readr::type_convert
    col_types = ddd$col_types,
    locale = ddd$locale,
    trim_ws = ddd$trim_ws,
    na = ddd$na,
    ## use to conditionally include httr::progress() in httr::GET() calls
    progress = ddd$progress %||% TRUE,
    ## work natively for gs_read_csv(), i.e. passed to readr::read_csv
    ## implemented internally in gs_reshape_feed() for list and cell feeds
    comment = ddd$comment,
    skip = ddd$skip,
    n_max = ddd$n_max,
    ## my very own fiddly problem to deal with
    col_names = ddd$col_names,
    check.names = ddd$check.names %||% FALSE
  )
  ddd$col_names <- ddd$col_names %||% TRUE
  stopifnot(is_toggle(ddd$col_names) || is.character(ddd$col_names))
  stopifnot(is_toggle(ddd$check.names))
  if (!is.null(ddd$comment)) {
    stopifnot(inherits(ddd$comment, "character"), length(ddd$comment) == 1L)
  }
  if (!is.null(ddd$skip)) {
    ddd$skip <- as.integer(ddd$skip)
    stopifnot(ddd$skip >= 0)
  }
  if (!is.null(ddd$n_max)) {
    ddd$n_max <- as.integer(ddd$n_max)
    stopifnot(ddd$n_max >= 1)
  }
  ddd
}

fix_names <- function(vnames, check.names = FALSE) {
  na_vnames <- is.na(vnames) | vnames == ""
  if (any(na_vnames)) {
    vnames[na_vnames] <- paste0("X", seq_along(vnames)[na_vnames])
  }
  if (check.names) {
    vnames <- make.names(vnames, unique = TRUE)
  }
  vnames
}

size_names <- function(vnames, n) {
  if (length(vnames) >= n) return(utils::head(vnames, n))
  nms <- paste0("X", seq_len(n))
  nms[seq_along(vnames)] <- vnames
  nms
}

reconcile_cell_contents <- function(x) {
  x <- x %>%
    dplyr::mutate_(literal_only = ~is.na(numeric_value),
                   putative_integer = ~ifelse(is.na(numeric_value), FALSE,
                                              gsub("\\.0$", "", numeric_value)
                                              == input_value),
                   ## a formula that evaluates to integer will almost certainly
                   ## look like a double, i.e. have trailing `.0`, but I'm not
                   ## sure I should strip it off
                   value = ~ifelse(literal_only,
                                   value,
                                   ifelse(putative_integer, input_value,
                                          numeric_value)))
  x %>%
    dplyr::select_(quote(-literal_only), quote(-putative_integer))
}

#' gs_prep_values
#' 
#' Preparing a data.frame to be passed as the values argument of a function call
#' 
#' @usage gsv4_prep_values(values, col_names=TRUE)
#' @param values \code{data.frame}; A data.frame to be passed as a values matrix typically
#' used with values operations write, update, or append.
#' @param col_names logical; indicates whether column names of input should be included in the edit, i.e. prepended to the input
#'   authorization, respectively
#' @return \code{data.frame} parsed from a values matrix returned by the Sheets V4 API
#' @examples
#' \dontrun{
#' my_values <- gsv4_prep_values(iris[5,], col_names=FALSE)
#' gsv4_values_update(spreadsheetId = this_spreadsheetId,
#'                    valueInputOption = 'RAW', 
#'                    range = "iris!A6", 
#'                    input = gsv4_ValueRange(values=my_values, 
#'                                            majorDimension = 'ROWS', 
#'                                            range="iris!A6"))
#' }
#' 
#' @export
gsv4_prep_values <- function(values, col_names=TRUE){
  header_row <- if(col_names) 1 else 0
  mat <- matrix(data = values %>% as_character_vector(col_names=col_names), 
                nrow=nrow(values) + header_row, 
                ncol=ncol(values), 
                byrow=TRUE)
  return(mat)
}

#' gs_parse_values
#' 
#' Parsing the values portion of a reply into a data.frame
#' 
#' @usage gsv4_parse_values(values, col_names=TRUE)
#' @importFrom plyr ldply
#' @param values \code{list}; a list parsed from the Sheets V4 API that represents an array
#' @param col_names logical; indicates whether column names of input should be parsed as part of the returne values matrix
#' @return \code{data.frame} parsed from a values matrix returned by the Sheets V4 API
#' @examples
#' \dontrun{
#' reply <- gsv4_values_get(spreadsheetId = this_spreadsheetId, range="Africa!A3:C5")
#' my_dat <- gsv4_parse_values(reply$values, col_names=FALSE)
#' head(my_dat)
#' }
#' 
#' @export
gsv4_parse_values <- function(values, col_names=TRUE){
  
  if(col_names){
    df_names <- unlist(values[[1]])
    values <- values[c(-1)]
  }
  
  df <- ldply(values, .fun=function(x){
    if(identical(x, list())){
      # this handles if a row or column is totally blank
      # other methods will completely drop the row, but
      # we should preserve the dimensions of the array observed
      # in the spreadsheet
      as.data.frame(matrix(character(0), nrow=1))
    } else {
      as.data.frame(t(unlist(x)))  
    }
    
  }, .id=NULL)
  
  # cannot use lappy and bind_rows because it will 
  # reorder rows if they are blank, weird behavior
  # this is documented in https://github.com/hadley/dplyr/issues/2175
  #   df <- lapply(values, FUN=function(x){
  #     if(identical(x, list())){
  #       # this handles if a row or column is totally blank
  #       # other methods will completely drop the row, but
  #       # we should preserve the dimensions of the array observed
  #       # in the spreadsheet
  #       as.data.frame(matrix(character(0), nrow=1))
  #     } else {
  #       as.data.frame(t(unlist(x)))  
  #     }
  #   })
  #   df <- bind_rows(df)
  
  if(col_names){
    colnames(df) <- df_names
  }
  
  return(df)
}


#' gsv4_limits_to_grid_range
#' 
#' Converting a \code{cell_limits} object to a gridRange object as specified in the Sheets V4 API.
#' 
#' @param lim \code{cell_limits}; a list of three components representing upper-left, 
#' lower-right limits of the range, plus the sheet component
#' @template ss
#' @details The sheet component of the limits must be an integer that refers to 
#' a specific sheetId that exists in the spreadsheet.
#' @examples
#' \dontrun{
#' gsv4_limits_to_grid_range(lim=cell_limits(c(1, 3), c(1, 5)))
#' }
#' 
#' @export
gsv4_limits_to_grid_range <- function(lim, ss=NULL){
  
  if(is.na(lim$sheet) | is.character(lim$sheet)){
    
    if(is.null(ss)){
      stop('The ss argument must be supplied if the sheetId is not provided as part of the limits.')
    }
    
    # pull out details on the sheet and find corresponding sheetId
    # assume it's the first sheet if not specified
    ws <- if(is.na(lim$sheet)) 1 else lim$sheet
    this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
    this_ws_id <- as.integer(this_ws$gid)
    lim$sheet <- this_ws_id
  }
  
  non_na_args <- list(sheetId = lim$sheet)
  
  # check the range limits individually because NA values 
  # actually mean unbounded ranges that need to be omitted 
  # from the call to gsv4_GridRange
  if(is.finite(lim$ul[1] - 1)){
    non_na_args[['startRowIndex']] <- lim$ul[1] - 1
  }
  if(is.finite(lim$ul[2] - 1)){
    non_na_args[['startColumnIndex']] <- lim$ul[2] - 1
  }
  if(is.finite(lim$lr[1] - 1)){
    non_na_args[['endRowIndex']] <- lim$lr[1]
  }
  if(is.finite(lim$lr[2] - 1)){
    non_na_args[['endColumnIndex']] <- lim$lr[2]
  }
  
  do.call(gsv4_GridRange, non_na_args)
}

#' gsv4_anchor_to_grid_coordinate
#' 
#' Converting an anchor reference to a gridCoordinate object as specified in the Sheets V4 API.
#' 
#' @template ss
#' @template ws
#' @template anchor
#' @examples
#' \dontrun{
#' gsv4_anchor_to_grid_coordinate(gap_ss, anchor="A1")
#' gsv4_anchor_to_grid_coordinate(gap_ss, ws=1, anchor="A1")
#' gsv4_anchor_to_grid_coordinate(gap_ss, ws="Americas", anchor="A1")
#' gsv4_anchor_to_grid_coordinate(gap_ss, anchor="Americas!A1")
#' }
#' 
#' @export
gsv4_anchor_to_grid_coordinate <- function(anchor, ss, ws=1){
  
  lim <- cellranger::as.cell_limits(anchor)
  
  if(is.na(lim$sheet) & missing(ws)){
    message("The sheet was not specified in the anchor. Assuming the first sheet.")
  }
  
  ws <- if(!is.na(lim$sheet)) lim$sheet else ws
  anchor_row <- lim$ul[1] - 1
  anchor_col <- lim$ul[2] - 1
  
  this_ws <- googlesheets:::gs_ws(ss, ws, verbose = FALSE)
  this_ws_id <- as.integer(this_ws$gid)

  gsv4_GridCoordinate(sheetId = this_ws_id,
                      rowIndex = anchor_row,
                      columnIndex = anchor_col)
}

#' gsv4_form_query_string
#' 
#' A convenience function for constructing a query string to tack onto URL
#' based on a named list of arguments. The function assumes the standard
#' query parameters as defined by the Sheets API v4.
#' 
#' @param standard_params a list of parameters for controlling the HTTP request and its response.
#' Refer to \code{\link{gsv4_standard_parameters}} for details on its arguments
#' @param ... arguments to be used to form standard_params argument if it is not supplied directly.
#' @return character; a string that represents query parameters of a URL
#' @seealso \href{https://developers.google.com/sheets/api/query-parameters}{Google's Documentation of Standard Query Parameters}
#' @examples 
#' \dontrun{
#' gsv4_form_query_string(standard_params=list(fields='sheets.properties'), other='o')
#' gsv4_form_query_string(a=1, b=TRUE, x='x')
#' gsv4_form_query_string()
#' }
#' @export
gsv4_form_query_string <- function(standard_params=list(), ...){
  
  stopifnot(is.list(standard_params))
  other_params <- list(...)
  all_params <- c(standard_params, other_params)
  
  # convert everything to a string since it will be later
  # when pasted at the end of the URL
  all_params <- lapply(all_params, 
                            FUN=function(x){
                              if(is.logical(x)){
                                  if(x) 'true' else 'false'
                                } else {
                                  as.character(x)
                                }
                            })
  
  named_query_parms <- unlist(all_params, use.names=T)
  
  if(length(named_query_parms) > 0){
    query_string <- paste0('?', paste0(paste(names(named_query_parms), named_query_parms, sep='='), collapse='&'))
  } else {
    query_string <- ''
  }
  
  return(query_string)
}
