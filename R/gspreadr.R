#' Get list of spreadsheets
#'
#' Retrieve the names of the user's spreadsheets in Google drive.
#'
#' @export
list_spreadsheets <- function() 
{
  ssfeed_to_df()$sheet_title
}


#' Add a new spreadsheet
#' 
#' Create a new (empty) spreadsheet with 1 worksheet titled "Sheet1" (default)
#' in your Google Drive.
#' 
#' @param title the title for the new spreadsheet
#' 
#' @export
add_spreadsheet <- function(title)
{
  the_body <- paste0('{ "title" : "', title ,'", 
                    "mimeType" : "application/vnd.google-apps.spreadsheet"}')
  
  gsheets_POST(url = "https://www.googleapis.com/drive/v2/files", the_body, 
               content_type = "json")
  
  message(paste0('Spreadsheet "', title, '" created in Google Drive.'))
}


#' Move spreadsheet to trash
#' 
#' Move a spreadsheet to trash in Google Drive.
#' 
#' @param title the title of the spreadsheet
#' 
#' @export
del_spreadsheet <- function(title)
{
  ss <-open_spreadsheet(title)
  
  the_url <- paste("https://www.googleapis.com/drive/v2/files", ss$sheet_id,
                   "trash", sep = "/")
  
  gsheets_POST(the_url, the_body = NULL)
  
  message(paste0('Spreadsheet "', title, '" moved to trash in Google Drive.'))
}

#' Open spreadsheet by title 
#'
#' Use the spreadsheet title (as it appears in Google Drive) to get a 
#' spreadsheet object, containing the spreadsheet id, title, time of last 
#' update, the titles of the worksheets contained, the number of worksheets 
#' contained, and a list of worksheet objects for every worksheet.
#'
#' @param title the title of the spreadsheet
#' 
#' @note The list of worksheet objects returned is missing the ncol, nrow and 
#' visibility components. Those are determined when \code{\link{open_worksheet}} 
#' or \code{\link{open_at_once}} is used to open a worksheet. It is time 
#' consuming to make a cellfeed request for every worksheet in the spreadsheet 
#' to determine the number of rows and columns. Use 
#' \code{\link{list_worksheet_objs}} to open all worksheets contained in the 
#' spreadsheet. 
#' 
#' @seealso \code{\link{list_worksheet_objs}}
#' 
#' @importFrom XML xmlToList getNodeSet
#' @export
open_spreadsheet <- function(title) 
{
  ssfeed_df <- ssfeed_to_df()
  
  index <- match(title, ssfeed_df$sheet_title)
  if(is.na(index)) stop("Spreadsheet not found.")
  sheet_key <- ssfeed_df[index, "sheet_key"]
  
  the_url <- build_req_url("worksheets", key = sheet_key)
  req <- gsheets_GET(the_url)
  wsfeed <- gsheets_parse(req)
  
  wsfeed_list <- xmlToList(wsfeed)
  
  ws_objs <- getNodeSet(wsfeed, "//ns:entry", c(ns = default_ns), 
                        function(x) make_ws_obj(x, sheet_key))
  
  names(ws_objs) <- lapply(ws_objs, function(x) x$title)
  
  ss <- spreadsheet()
  ss$sheet_id <- sheet_key
  ss$sheet_title <- wsfeed_list$title$text
  ss$updated <- wsfeed_list$updated
  ss$nsheets <- as.numeric(wsfeed_list$totalResults)
  ss$visibility <- "private"
  ss$ws_names <- names(ws_objs)
  ss$worksheets <- ws_objs
  
  ss
}


#' Get list of worksheets contained in spreadsheet
#'
#' Retrieve list of worksheet titles (order as they appear in spreadsheet). 
#'
#' @param ss a spreadsheet object returned by \code{\link{open_spreadsheet}}
#'
#' This is a mini wrapper around spreadsheet$ws_names.
#' @export
list_worksheets <- function(ss) 
{
  ss$ws_names
}

#' Get a list of worksheet objects
#'
#' The returned list of worksheet objects enables \code{plyr} functions to 
#' operate on mutiple worksheets at once.
#' 
#' @param ss a spreadsheet object returned by \code{\link{open_spreadsheet}}
#' 
#' @importFrom plyr llply
#' @export
list_worksheet_objs <- function(ss) 
{
  llply(ss$worksheets, function(x) open_worksheet(ss, x$title))
}

#' Open worksheet by title or index
#'
#' Use the title or index of a worksheet to retrieve the worksheet object.
#'
#' @param ss a spreadsheet object containing the worksheet
#' @param value a character string for the title of worksheet or numeric for 
#' index of worksheet
#' 
#' @return A worksheet object with number of rows and cols component.
#' 
#' @examples
#' ws <- open_worksheet(ss, "Sheet1")
#' ws <- open_worksheet(ss, 1)
#' @export
open_worksheet <- function(ss, value) 
{
  if(is.character(value)) {
    index <- match(value, names(ss$worksheets))
    
    if(is.na(index))
      stop("Worksheet not found.")
    
  } else {
    index <- value
  }
  
  ws <- ss$worksheets[[index]]
  ws$visibility <- ss$visibility
  worksheet_dim(ws, visibility = ss$visibility)
}


#' Open a worksheet from a spreadsheet in one go
#' 
#' @param ss_title spreadsheet title
#' @param ws_value title or numeric index of worksheet
#' 
#' @examples
#' open_at_once("Temperature", "Sheet1")
#' open_at_once("Temperature", 1)
#' @export
open_at_once <- function(ss_title, ws_value) 
{
  sheet <- open_spreadsheet(ss_title)
  open_worksheet(sheet, ws_value)
}


#' Add a new (empty) worksheet to spreadsheet
#'
#' Add a new (empty) worksheet to spreadsheet, specify title, number of rows 
#' and columns. The title should not be the names of exisiting worksheets else 
#' a bad request error is returned.
#'
#' @param ss spreadsheet object
#' @param title character string for title of new worksheet 
#' @param nrow number of rows
#' @param ncol number of columns
#' @param token Google token obtained from \code{\link{login}} or 
#' \code{\link{authorize}}
#' 
#' @importFrom XML xmlNode toString.XMLNode
#' @export
add_worksheet <- function(ss, title, nrow, ncol) 
{   
  the_body <- 
    xmlNode("entry", 
            namespaceDefinitions = 
              c(default_ns,
                gs = "http://schemas.google.com/spreadsheets/2006"),
            xmlNode("title", title),
            xmlNode("gs:rowCount", nrow),
            xmlNode("gs:colCount", ncol))
  
  the_body <- toString.XMLNode(the_body)
  
  the_url <- build_req_url("worksheets", key = ss$sheet_id)
  
  gsheets_POST(the_url, the_body)
}


#' Delete a worksheet from spreadsheet
#'
#' The worksheet and all of its data will be removed from spreadsheet.
#'
#' @param ws worksheet object
#' @export
del_worksheet<- function(ws) 
{
  the_url <- build_req_url("worksheets", key = ws$sheet_id, ws_id = ws$id)
  gsheets_DELETE(the_url) 
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
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_row = row, max_row = row, 
                           visibility = ws$visibility)
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- get_lookup_tbl(feed)
  
  if(nrow(tbl) == 0) {
    message("Row contains no values.")
  } else {
    tbl_clean <- fill_missing_tbl(tbl, row_min = row)
    data.frame(t(tbl_clean$val))
  }
}


#' Get all values in range of rows
#'
#' Specify range of rows to get from worksheet.
#'
#' @param ws worksheet object
#' @param from,to start and end row indexes
#' @param header logical indicating whether first row should be taken as header
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
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
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
#' @param vis either "private" or "public", "public" for public worksheet
#' @return A data frame.
#' @seealso \code{\link{get_cols}}, \code{\link{get_row}}, 
#' \code{\link{get_rows}}, \code{\link{read_all}}, \code{\link{read_region}}, 
#' \code{\link{read_range}}
#' @export
get_col <- function(ws, col, vis = "private") 
{
  if(!is.numeric(col)) 
    col <- letter_to_num(col)
  
  if(col > ws$ncol)
    stop("Column exceeds current worksheet size")
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
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
#' @return A data frame.
#' @examples
#' get_cols(ws, 1, 2)
#' get_cols(ws, 30, 40)
#' 
#' get_cols(ws, "A", "B")
#' get_cols(ws, "c", "f")
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
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
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
#' @examples
#' get_cell(ws, "A1")
#' get_cell(ws, "R1C1")
#' get_cell(ws, "AB1")
#' get_cell(ws, "R1C27")
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
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id)
  new_url <- paste(the_url, cell, sep = "/")
  
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
#' @param header logical value indicating whether the first line contains the 
#' names of the variables
#' @param vis either "private" or "public" indicating whether the worksheet is 
#' private or public
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
#' @param vis either \code{private} or \code{public}
#' @return A data frame.
#' @seealso \code{\link{read_all}}, \code{\link{get_row}}, \code{\link{get_rows}},
#' \code{\link{get_col}}, \code{\link{get_cols}}, \code{\link{read_range}}
#' @importFrom plyr ddply
#' @export
read_region <- function(ws, from_row, to_row, from_col, to_col, header = TRUE)
{
  if(to_row > ws$nrow)
    to_row <- ws$nrow
  
  if(to_col > ws$ncol)
    to_col <- ws$ncol
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_row = from_row, max_row = to_row,
                           min_col = from_col, max_col = to_col, 
                           visibility = ws$visibility)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- get_lookup_tbl(feed)
  
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
#' @param header \code{logical} for whether or not first row should be taken as 
#' header
#' @param vis either "private" (default) or "public" for public spreadsheets
#' @examples
#' read_range("A1:B10")
#' read_range("C10:D20")
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


#' Find first cell matching string value
#' 
#' Get the cell location of the first occurence of a cell value.
#' 
#' @param ws worksheet object
#' @param x a character string
#' 
#' @export
find_cell <- function(ws, x)
{
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_col = 1, max_col = ws$ncol, visibility = "private")
  
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
#' @importFrom dplyr filter mutate select
#' 
#' @export
find_all <- function(ws, x)
{
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_col = 1, max_col = ws$ncol, visibility = "private")
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  tbl <- get_lookup_tbl(feed)
  vals <- filter(tbl, val == x)
  
  if(nrow(vals) == 0) {
    message("Cell not found")
  } else {
    dat <- mutate(vals, Coord = paste0("R", row, "C", col),
                  Label = paste0(vnum_to_letter(col), row),
                  Val = val)
    select(dat, Label, Coord, Val)
  }
}


#' Update a cell's value
#' 
#' Modify the contents of cells (those already with values) in worksheet. 
#' To empty a cell, update it with an empty string. 
#' 
#' @param ws worksheet object
#' @param pos cell position in label (ex. "A1") or coordinate (ex. "R1C1") 
#' format
#' @param value character string for new value
#'
#' @importFrom XML getNodeSet xmlNode
#' @export
update_cell <- function(ws, pos, value)
{
  if(grepl("^[[:alpha:]]+[0-9]+$", pos)) {
    pos <- label_to_coord(pos)
  }
  
  row_num <- sub("R([0-9]+)C([0-9]+)", "\\1", pos)
  col_num <- sub("R([0-9]+)C([0-9]+)", "\\2", pos)
  coord <- paste0("R", row_num, "C", col_num)
  
  # get cell feed to get cell version (needed in put request)
  url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id)
  the_url <- paste(url, coord, sep = "/")
  
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


#' Update multiple cells' values
#' 
#' Modify a range of cells by specifiying the range and values to update with. 
#' The range should not include empty cells because those cells will not be 
#' captured in the response of the request.
#' 
#' @param ws worksheet object
#' @param range character string for range of cells (ie. "A1:A2", "A1:B6") 
#' @param new_values vector of new values to update cells
#' 
#' @importFrom plyr rename
#' @export 
update_cells <- function(ws, range, new_values)
{
  if(!grepl("[[:alpha:]]+[[:digit:]]+:[[:alpha:]]+[[:digit:]]+", range)) 
    stop("Please check cell notation.")
  
  bounds <- unlist(strsplit(range, split = ":"))
  rows <- as.numeric(gsub("[^0-9]", "", bounds))  
  cols <- unname(sapply(gsub("[^A-Z]", "", bounds), letter_to_num))
  
  if(max(rows) * max(cols) != length(new_values))
    stop("Length of new values do not match number of cells to update")
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_row = rows[1], max_row = rows[2],
                           min_col = cols[1], max_col = cols[2])
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  the_body <- create_update_feed(feed, new_values)
  
  req_url <- paste("https://spreadsheets.google.com/feeds/cells",
                   ws$sheet_id, ws$id, "private/full/batch", sep = "/")
  
  gsheets_POST(req_url, the_body)
}


#' View worksheet
#'
#' Get an idea of what your worksheet looks like.
#'
#' @param ws worksheet object
#' @return ggplot
#'
#' @import ggplot2
#' @export 
view <- function(ws)
{
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_col = 1, max_col = ws$ncol,
                           visibility = ws$visibility)
  
  if(ws$nrow == 0)
    stop("Worksheet is empty!")
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  tbl <- get_lookup_tbl(feed, include_sheet_title = TRUE)
  make_plot(tbl)
}

#' View all your worksheets
#'
#' Get a view of all the worksheets contained in the spreadsheet. This function
#' returns a list of two ggplot objects, first is a gallery of all the 
#' worksheets and the second is an overlay of all the worksheets.
#' 
#' @param ss spreadsheet object
#' @param show_overlay \code{logical} set to \code{TRUE} if want to also 
#' display the overlay of all the worksheets
#'
#' @importFrom plyr ldply
#' @importFrom gridExtra arrangeGrob grid.arrange
#' @export
view_all <- function(ss, show_overlay = FALSE)
{
  ws_objs <- list_worksheet_objs(ss)
  
  tbl <- 
    ldply(ws_objs, 
          function(ws)  {
            the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                                     min_col = 1, max_col = ws$ncol,
                                     visibility = ws$visibility)
            req <- gsheets_GET(the_url)
            feed <- gsheets_parse(req)
            get_lookup_tbl(feed, include_sheet_title = TRUE)
          })
  
  p1 <- make_plot(tbl)
  
  p2 <- ggplot(tbl, aes(x = col, y = row, group = Sheet)) +
    geom_tile(fill = "steelblue2", aes(x = col, y = row), alpha = 0.4) +
    scale_x_continuous(breaks = seq(1, max(tbl$col), 1), expand = c(0, 0)) +
    annotate("text", x = seq(1, max(tbl$col) ,1), y = (-0.05) * max(tbl$row), 
             label = LETTERS[1:max(tbl$col)], colour = "steelblue4",
             fontface = "bold") +
    scale_y_reverse() +
    ylab("Row") +
    ggtitle(paste(length(ws_objs), "worksheets")) +
    theme(panel.grid.major.x = element_blank(),
          plot.title = element_text(face = "bold"),
          axis.text.x = element_blank(),
          axis.title.x = element_blank(),
          axis.ticks.x = element_blank())
  
  if(show_overlay) {
    p3 <- arrangeGrob(p1, p2)
    p3
  }else {
    p1
  }
}


#' Get report for a worksheet
#' 
#' Generate a report for a worksheet.
#' 
#' @param ws worksheet object
#' 
#' @return A list of 2.
#' 
#' @importFrom dplyr summarise group_by select arrange
#' @importFrom plyr ddply join rename
#' 
#' @export
str.worksheet <- function(ws)
{
  item1 <- paste(ws$title, ":", ws$nrow, "rows and", ws$ncol, "columns")
  
  if(ws$nrow == 0)
    return(item1)
  
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_col = 1, max_col = ws$ncol, 
                           visibility = ws$visibility)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  tbl <- get_lookup_tbl(feed)
  
  tbl_clean <- fill_missing_tbl(tbl, row_only = TRUE)
  tbl_bycol <- group_by(tbl_clean, col)
  
  a1 <- summarise(tbl_bycol, 
                  Label = num_to_letter(col[1]),
                  nrow = max(row),
                  Empty.Cells = length(which(is.na(val))),
                  Missing = round(Empty.Cells/nrow, 2))
  
  # Find the cell pattern for each column
  runs <- function(x) 
  {
    x_ordered <- arrange(x, row)
    a <- rle(is.na(x_ordered$val))
    dat <- data.frame(length = a$lengths, value = a$values)
    dat$string <- ifelse(a$values, "NA", "V")
    dat$summary <- paste0(dat$length, dat$string)
    paste(dat$summary, collapse = ", ")
  }
  
  a2 <- ddply(tbl_clean, "col", runs)
  a3 <- join(a1, a2, by = "col")
  
  item2 <- rename(a3, c("V1" = "Runs", "nrow" = "Rows", "col" = "Column"))
  
  cat("Worksheet", item1, sep = "\n")
  print(item2)
}


#' Get the structure for a spreadsheet
#' 
#' Display the structure of a spreadsheet: the name of the spreadsheet, the 
#' number of worksheets contained and the corresponding worksheet dimensions.
#' 
#' @param ss spreadsheet object
#' 
#' @importFrom dplyr summarise group_by select
#' @importFrom plyr llply
#' 
#' @export
str.spreadsheet <- function(ss)
{
  item1 <- paste0(ss$sheet_title, ": ", ss$nsheets, " worksheets")
  
  list_ws <- list_worksheet_objs(ss)
  
  item2 <- llply(list_ws, function(x) paste(x$title, ":", x$nrow, 
                                            "rows and", x$ncol, "columns"))
  
  cat("Spreadsheet:", item1, "\nWorksheets:", paste(item2, sep = "\n"), 
      sep = "\n")
}

# Public spreadsheets only -----

#' Open spreadsheet by key 
#'
#' Use key found in browser URL and return an object of class spreadsheet.
#'
#' @param spreadsheet_key A key of a spreadsheet as it appears in browser URL.
#' @return Object of class spreadsheet.
#'
#' This function only works for keys of public spreadsheets.
#' @importFrom XML xmlToList getNodeSet
#' @export
open_by_key <- function(key, visibility = "public") 
{
  if(visibility == "public") {
    the_url <- build_req_url("worksheets", key = key, visibility = "public")
  } else {
    the_url <- build_req_url("worksheets", key = key, visibility = "private")
  }
  
  req <- gsheets_GET(the_url)
  wsfeed <- gsheets_parse(req)
  wsfeed_list <- xmlToList(wsfeed)
  
  ss <- spreadsheet()
  ss$sheet_id <- key
  ss$updated <- wsfeed_list$updated
  ss$sheet_title <- wsfeed_list$title$text
  ss$nsheets <- as.numeric(wsfeed_list$totalResults)
  ss$visibility <- visibility
  
  # return list of worksheet objs
  ws_objs<- getNodeSet(wsfeed, "//ns:entry", c("ns" = default_ns),
                       function(x) make_ws_obj(x, ss$sheet_id))
  
  names(ws_objs) <- lapply(ws_objs, function(x) x$title)
  ss$ws_names <- names(ws_objs)
  ss$worksheets <- ws_objs
  ss
}


#' Open spreadsheet by url
#'
#' Use url of spreadsheet and return an object of class spreadsheet.
#'
#' @param url URL of spreadsheet as it appears in browser
#' @return Object of class spreadsheet.
#'
#' This function currently only works for public spreadsheets.
#' This function extracts the key from the url and calls on 
#' \code{\link{open_by_key}}.
#' @export
open_by_url <- function(url, visibility = "public") 
{
  key <- unlist(strsplit(url, "/"))[6] 
  open_by_key(key, visibility)
}

