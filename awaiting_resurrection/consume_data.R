 #' Get all values in a column.
#'
#' @param ws worksheet object
#' @param col column number or letter (case insensitive)
#' @return A data frame.
#' @seealso \code{\link{get_cols}}, \code{\link{get_row}}, 
#' \code{\link{get_rows}}, \code{\link{read_all}}, \code{\link{read_region}}, 
#' \code{\link{read_range}}
#' @export
get_col <- function(ws, col) 
{
  if(!is.numeric(col)) 
    col <- letter_to_num(col)
  
  if(col > ws$ncol)
    stop("Column exceeds current worksheet size")
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                           min_col = col, max_col = col, 
                           visibility = ws$visibility)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- get_lookup_tbl(feed)
  
  if(nrow(tbl) == 0) {
    message("Column contains no values.")
  } else {
    tbl_clean <- fill_missing_tbl(tbl, col_min = col)
    tbl_clean$val
  }
}


#' Get all values in a range of columns.
#'
#' Specify range of columns to get from worksheet.
#'
#' @param ws worksheet object
#' @param from,to start and end column indexes either integer or letter
#' @param header \code{logical} to indicate if the first row should be taken as 
#' the header
#' 
#' @return A data frame.
#'
#' @seealso \code{\link{get_col}}, \code{\link{get_row}}, 
#' \code{\link{get_rows}}, \code{\link{read_all}}, \code{\link{read_region}},
#' \code{\link{read_range}}
#' @importFrom plyr dlply rbind.fill
#' @export
get_cols <- function(ws, from, to, header = TRUE) 
{
  if(!is.numeric(from) & !is.numeric(to)) {
    from <- letter_to_num(from)
    to <- letter_to_num(to)
  }
  
  if(to > ws$ncol) 
    to <- ws$ncol
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                           min_col = from, max_col = to, 
                           visibility = ws$visibility)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- get_lookup_tbl(feed)
  
  tbl_clean <- fill_missing_tbl(tbl, col_min = from)
  
  list_of_df <- 
    dlply(tbl_clean, "row", 
          function(x) as.data.frame(t(x$val), stringsAsFactors = FALSE))
  
  my_df <- rbind.fill(list_of_df)
  
  if(header) 
    set_header(my_df)
  else 
    my_df
  
}

#' Get the value of a cell
#'
#' Get the value of a cell using label (A1) notation or coordinate (R1C1) 
#' notation.
#'
#' @param ws worksheet object
#' @param cell character string specifying cell position, 
#' either in label or coordinate notation
#' @return The value of the cell as a character string.
#' @export
get_cell <- function(ws, cell)
{
  if(grepl("[R][[:digit:]]+[C][[:digit:]]+", cell)) {
    cell
  } else {
    if(grepl("^[[:alpha:]]+[[:digit:]]+$", cell)) {
      cell <- label_to_coord(cell)
    } else {
      stop("Please check cell notation.")
    }
  }
  
  wks_links <- wks$links
  cell_url <- wks_links$href[grepl("cellsfeed", wks_links$rel)]
  new_url <- slaste(cell_url, cell)
  
  req <- gsheets_GET(new_url)
  
  ## I access cell content in this weird way because the structure of
  ## req$content$cell varies for cells that are populated vs. empty (and because
  ## I'm not using a list-oriented FP pkg yet)
  req$content$cell %>% unlist %>% `[`(grep("inputValue", names(.))) %>% unname
}


#' Get a region of a worksheet by min/max row and column
#'
#' Extract cells of a worksheet by specifying the minimum and maximum rows and 
#' columns. If the specified range is beyond the dimensions of the worksheet, 
#' the boundaries of the worksheet will be used instead.
#'
#' @param ws worksheet object
#' @param from_row,to_row range of rows to extract
#' @param from_col,to_col range of cols to extract
#' @param header \code{logical} to indicate if the first row should be taken as 
#' the header
#' 
#' @return A data frame.
#' @seealso \code{\link{read_all}}, \code{\link{get_row}}, \code{\link{get_rows}},
#' \code{\link{get_col}}, \code{\link{get_cols}}, \code{\link{read_range}}
#' @importFrom plyr ddply
#' @export
read_region <- function(ws, from_row, to_row, from_col, to_col, header = TRUE)
{
  check_empty(ws)
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                           min_row = from_row, max_row = to_row,
                           min_col = from_col, max_col = to_col, 
                           visibility = ws$visibility)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- get_lookup_tbl(feed)
  
  if(nrow(tbl) == 0)
    stop("Range is empty")
  
  tbl_clean <- fill_missing_tbl(tbl, row_min = from_row, col_min = from_col)
  
  list_of_df <- 
    dlply(tbl_clean, "row", 
          function(x) as.data.frame(t(x$val), stringsAsFactors = FALSE))
  
  my_df <- rbind.fill(list_of_df)
  
  if(header) {
    if(nrow(my_df) == 1) {
      my_df
    } else {
      set_header(my_df)
    }
  } else { 
    my_df
  }
}


#' Get a region of a worksheet by range
#'
#' Extract cells of a worksheet by specifying the minimum and maximum rows and 
#' columns. If the specified range is beyond the dimensions of the worksheet, 
#' the boundaries of the worksheet will be used instead.
#'
#' @param ws worksheet object
#' @param x character string for range separated by ":"
#' @param header \code{logical} to indicate if the first row should be taken as the
#' header
#' @examples
#' \dontrun{
#' worksheet <- open_at_once("My Spreadsheet", "Sheet1")
#' 
#' read_range(worksheet, "A1:B10")
#' read_range(worksheet, "C10:D20")
#' }
#' 
#' @seealso \code{\link{read_region}}, \code{\link{get_row}}, 
#' \code{\link{get_rows}}, \code{\link{get_col}}, \code{\link{get_cols}}, 
#' \code{\link{read_all}}
#' 
#' @export
read_range <- function(ws, x, header = TRUE) 
{
  if(!grepl("[[:alpha:]]+[[:digit:]]+:[[:alpha:]]+[[:digit:]]+", x)) 
    stop("Please check cell notation.")
  
  bounds <- unlist(strsplit(x, split = ":"))
  rows <- as.numeric(gsub("[^0-9]", "", bounds))  
  cols <- unname(sapply(gsub("[^A-Z]", "", bounds), letter_to_num))
  
  read_region(ws, rows[1], rows[2], cols[1], cols[2], header)
}

#' Get rows or columns from a worksheet
#'
#' Get row(s) or column(s) from a worksheet by specifying the desired row/column
#' number. 
#'
#' @param ws worksheet object
#' @param type either "row" or "col"
#' @param values a vector of length 1 or 2 depending on if a single or a range 
#' of rows or columns is to be returned
#' @param header indicating if the first row should be taken as header row
#' 
get_data <- function(ws, type, values, header = FALSE) {
  min_row <- NULL
  max_row <- NULL
  min_col <- NULL
  max_col <- NULL
  
  if(length(values) == 1)
    values <- rep(values, 2)
  
  if(grepl("row", type)) {
    min_row <- values[1]
    max_row <- values[2]
  } else {
    min_col <- values[1]
    max_col <- values[2]
  }
  
  #old way
  url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id,
                       visibility = ws$visibility)
  
  # get the cells feed link
  #x <- parse_url("https://spreadsheets.google.com/feeds/cells/1WpFeaRU_9bBEuK8fI21e5TcbCjQZy90dQYgXF_0JvyQ/od6/private/full")
  
  x <- parse_url(url)
  # enter query params
  x$query <- list("min-row" = min_row, "max-row" = max_row, 
                  "min-col" = min_col, "max-col" = max_col)
  
  the_url <- build_url(x)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  tbl <- get_lookup_tbl(feed)
  
  if(nrow(tbl) == 0) { 
    stop("No data found in current selection")
  }
  
  row_min <- 1
  col_min <- 1
  
  if(is.null(min_row)) {
    col_min <- min_col
  } else {
    row_min <- min_row
  }
  
  tbl_clean <- fill_missing_tbl(tbl, row_min, col_min)
  
  list_of_df <- 
    dlply(tbl_clean, "row", 
          function(x) as.data.frame(t(x$val), stringsAsFactors = FALSE))
  
  my_df <- rbind.fill(list_of_df)
  
  if(header) {
    set_header(my_df)
  } else {
    my_df
  }
}

