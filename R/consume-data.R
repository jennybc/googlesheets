#' Find first cell matching string value
#' 
#' Get the cell location of the first occurence of a cell value.
#' 
#' @param ws worksheet object
#' @param x a character string (case sensitive)
#' 
#' @export
find_cell <- function(ws, x)
{
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                           min_col = 1, max_col = ws$ncol, 
                           visibility = ws$visibility)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- get_lookup_tbl(feed)
  ind <- match(x, tbl$val)
  
  if(is.na(ind)) {
    message("Cell not found")
  } else {
    letter <- num_to_letter(tbl[ind, "col"])
    paste0("Cell R", tbl[ind, "row"], "C", tbl[ind, "col"], 
           ", ", letter, tbl[ind, "row"])
  }
}


#' Find all cells with string value
#' 
#' Get all the cell locations for a string value
#' 
#' @param ws worksheet object
#' @param x a character string
#' 
#' @return a data frame listing the cell locations in label and coordinate 
#' format
#' @importFrom dplyr filter_ mutate_ select_
#' 
#' @export
find_all <- function(ws, x)
{
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                           min_col = 1, max_col = ws$ncol, 
                           visibility = ws$visibility)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  tbl <- get_lookup_tbl(feed)
  vals <- filter_(tbl, ~ val == x)
  
  if(nrow(vals) == 0) {
    message("Cell not found")
  } else {
    dat <- mutate_(vals, 
                   Coord = ~paste0("R", row, "C", col),
                   Label = ~paste0(vnum_to_letter(col), row),
                   Val = ~val)
    select_(dat, ~Label, ~Coord, ~Val)
  }
}


#' Get all values in a row
#'
#' Specify row of values to get from worksheet.
#'
#' @param ws worksheet object
#' @param row row number
#' @return A data frame.
#' @seealso \code{\link{get_rows}}, \code{\link{get_col}}, 
#' \code{\link{get_cols}}, \code{\link{read_all}}, \code{\link{read_region}}, 
#' \code{\link{read_range}}
#' @export
get_row <- function(ws, row) 
{
  if(row > ws$nrow)
    stop("Specified row exceeds the number of rows contained in the worksheet.")
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                           min_row = row, max_row = row, 
                           visibility = ws$visibility)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- get_lookup_tbl(feed)
  
  if(nrow(tbl) == 0) {
    message("Row contains no values.")
  } else {
    tbl_clean <- fill_missing_tbl(tbl, row_min = row)
    tbl_clean$val
  }
}


#' Get all values in range of rows
#'
#' Specify range of rows to get from worksheet.
#'
#' @param ws worksheet object
#' @param from,to start and end row indexes
#' @param header \code{logical} to indicate if the first row should be taken as the
#' header
#' 
#' @return A data frame.
#' @seealso \code{\link{get_row}}, \code{\link{get_col}}, 
#' \code{\link{get_cols}}, \code{\link{read_all}}, \code{\link{read_region}}, 
#' \code{\link{read_range}}
#' @importFrom plyr dlply rbind.fill
#' @export
get_rows <- function(ws, from, to, header = FALSE)
{
  if(to > ws$nrow)
    to <- ws$nrow
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                           min_row = from, max_row = to, 
                           visibility = ws$visibility)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- get_lookup_tbl(feed)
  tbl_clean <- fill_missing_tbl(tbl, row_min = from)
  
  list_of_df <- 
    dlply(tbl_clean, "row", 
          function(x) as.data.frame(t(x$val), stringsAsFactors = FALSE))
  
  my_df <- rbind.fill(list_of_df)
  
  if(header) 
    set_header(my_df)
  else 
    my_df
}


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
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                           visibility = ws$visibility)
  new_url <- slaste(the_url, cell)
  
  req <- gsheets_GET(new_url)
  feed <- gsheets_parse(req)
  
  cell_val <- 
    getNodeSet(feed, "//ns:entry//gs:cell", c("ns" = default_ns, "gs"),
               xmlValue)
  unlist(cell_val)
}


#' Get all values in a worksheet.
#'
#' Extract the entire worksheet and turn it into a data frame. This function
#' uses the rightmost cell with a value as the maximum number of columns and 
#' bottom-most cell as the maximum row.
#'
#' @param ws worksheet object 
#' @param header \code{logical} to indicate if the first row should be taken as the
#' header
#' 
#' @return A dataframe. 
#' 
#' This function calls on \code{\link{get_cols}} with \code{to} set as the 
#' number of columns of the worksheet.
#' @seealso \code{\link{read_region}}, \code{\link{read_range}}, 
#' \code{\link{get_row}}, \code{\link{get_rows}}, \code{\link{get_col}}, 
#' \code{\link{get_cols}}
#' 
#' @export
read_all <- function(ws, header = TRUE) 
{
  get_cols(ws, 1, ws$ncol, header)
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
