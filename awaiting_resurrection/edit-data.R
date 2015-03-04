##' Add rows to a worksheet
#'
#' @param ws worksheet object
#' @param n \code{numeric} the number of rows to add
#' 
#' @export
add_rows <- function(ws, n) {
  resize_worksheet(ws, nrow = n, ncol = NULL)
}

#' Add columns to a worksheet
#'
#' @param ws worksheet object
#' @param n \code{numeric} the number of columns to add
#' 
#' @export
add_cols <- function(ws, n) {
  resize_worksheet(ws, nrow = NULL, ncol = n)
}


#' Update a cell's value
#' 
#' Modify the contents of a cell in a worksheet. Formulas can be set on a cell 
#' by starting with an = character. The calculated value will be the cell's
#' actual value. To empty a cell, update it with an empty string. 
#' 
#' @param ws worksheet object
#' @param pos cell position in label (ex. "A1") or coordinate (ex. "R1C1") 
#' format
#' @param value character string for new value
#'
#' @note If the cell to update is beyond the extent of the worksheet, the
#' worksheet will be resized.
#' 
#' @examples
#' \dontrun{
#' update_cell(worksheet, "A1", "First Cell")
#' update_cell(worksheet, "C1", "=A1+B1")
#' }
#' @importFrom XML xmlNode
#' @export
update_cell <- function(ws, pos, value)
{
  if(grepl("^[[:alpha:]]+[0-9]+$", pos)) {
    pos <- label_to_coord(pos)
  }
  
  row_num <- as.numeric(sub("R([0-9]+)C([0-9]+)", "\\1", pos))
  col_num <- as.numeric(sub("R([0-9]+)C([0-9]+)", "\\2", pos))
  
  if(ws$row_extent < row_num) {
    new_row <- row_num
  } else {
    new_row <- NULL
  }
  
  if(ws$col_extent < col_num) {
    new_col <- col_num
  } else {
    new_col <- NULL
  }
  
  if(any(c(!is.null(new_row), !is.null(new_col)))) {
    resize_worksheet(ws, nrow = new_row, ncol = new_col )
  }
  
  # use "private" for visibility because "public" will not allow for writing to
  # public sheet since does not return edit url in the response feed,
  # if dont have permission then error will be thrown
  url <- build_req_url("cells", key = ws$sheet_id, ws_id =  ws$ws_id, 
                       visibility = "private") 
  
  the_url <- slaste(url, pos)
  
  req <- gsheets_GET(the_url)
  
  feed <- gsheets_parse(req)
  
  nodes <- getNodeSet(feed, '//ns:link[@rel="edit"]', c("ns" = default_ns),
                      function(x) xmlGetAttr(x, "href"))
  
  req_url <- unlist(nodes)
  
  # create entry element 
  the_body <- 
    xmlNode("entry", 
            namespaceDefinitions = 
              c(default_ns, gs = "http://schemas.google.com/spreadsheets/2006"),
            xmlNode("id", req_url),
            xmlNode("link", attrs = c("rel" = "edit", 
                                      "type" = "application/atom+xml", 
                                      "href" = req_url)),
            xmlNode("gs:cell", attrs = c("row" = row_num, "col" = col_num, 
                                         "inputValue" = value)))
  
  gsheets_PUT(req_url, the_body)
}


#' Update multiple cells at once
#' 
#' Modify a range of cells by specifiying the range and values to update to.
#' Values will be updated by row. 
#' 
#' @param ws worksheet object
#' @param range character string for range of cells (ie. "A1:A2", "A1:B6") or a
#' single cell to represent an "anchor" cell
#' @param dat character vector or data frame of new values to update cells
#' @param header \code{logical} inidicating if data contains header row
#' 
#' @note If the cells to update are beyond the extent of the worksheet, the
#' worksheet will be resized.
#' 
#' @importFrom dplyr mutate_ rename_
#' @export 
update_cells <- function(ws, range, dat, header = TRUE)
{
  if(grepl("^[[:alpha:]]+[[:digit:]]+$", range)) {
    range <- build_range(dat, range, header)
  } else {
    if(!grepl("[[:alpha:]]+[[:digit:]]+:[[:alpha:]]+[[:digit:]]+", range))
      stop("Please check cell notation.")
  }
  
  if(!header) {
    head_vals <- NULL
  } else {
    head_vals <- names(dat)
  }
  
  new_values <- c(head_vals, as.vector(t(dat))) # dframe to vector by row
  
  if(ncells(range) != length(new_values))
    stop("Length of new values do not match number of cells to update")
  
  bounds <- unlist(strsplit(range, split = ":"))
  rows <- as.numeric(gsub("[^0-9]", "", bounds))  
  cols <- unname(sapply(gsub("[^A-Z]", "", bounds), letter_to_num))
  
  if(ws$row_extent < max(rows)) {
    new_row <- max(rows)
  } else {
    new_row <- NULL
  }
  
  if(ws$col_extent < max(cols)) {
    new_col <- max(cols)
  } else {
    new_col <- NULL
  }
  
  if(any(c(!is.null(new_row), !is.null(new_col)))) {
    resize_worksheet(ws, nrow = new_row, ncol = new_col )
  }
  
  # use "private" for visibility because "public" will not allow for writing to
  # public sheet, if dont have permission then error will be thrown
  the_url0 <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                            visibility = "private")
  
  the_url <- paste0(the_url0, "?range=", range, "&return-empty=true")
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  the_body <- create_update_feed(feed, new_values)
  
  req_url <- slaste("https://spreadsheets.google.com/feeds/cells",
                    ws$sheet_id, ws$ws_id, "private/full/batch")
  
  gsheets_POST(req_url, the_body)
}
