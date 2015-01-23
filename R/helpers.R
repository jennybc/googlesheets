#' Convert column letter to number
#'
#' @param x column letter (case insensitive)
letter_to_num <- function(x)
{
  x <- toupper(x)
  ascii_tbl <- data.frame(alpha = LETTERS, num = 65:90)
  
  m <- c()
  for(i in 1:nchar(x)) {
    k <- unlist(strsplit(x, "")) # list of characters
    ind <- grep(k[i], ascii_tbl$alpha)
    y <- (ascii_tbl[ind, "num"] - 64) * (26 ^ (nchar(x) - i))
    m <- c(m, y)
  }
  sum(m)
}


#' Convert column number to letter
#'
#' @param x column number
num_to_letter <- function(x)
{
  ascii_tbl <- data.frame(alpha = LETTERS, num = 65:90)
  letter <- ""
  
  while(x > 0)
  {
    temp <- (x - 1) %% 26
    ind <-  grep(temp + 65, ascii_tbl$num)
    letter <- paste0(ascii_tbl$alpha[ind], letter)
    x <- (x - temp - 1) / 26
  }
  letter
}

vnum_to_letter <- Vectorize(num_to_letter)

#' Convert label (A1) notation to coordinate (R1C1) notation
#'
#' A1 and R1C1 are equivalent addresses for position of cells.
#'
#' @param x label notation for position of cell
label_to_coord <- function(x)
{
  letter <- unlist(strsplit(x, "[0-9]+"))
  col_num <- letter_to_num(letter)
  row_num <- gsub("[[:alpha:]]", "", x)
  paste0("R", row_num, "C", col_num)
}


#' Convert coordinate (R1C1) notation to label (A1) notation
#'
#' A1 and R1C1 are equivalent addresses for position of cells.
#'
#' @param x coord notation for position of cell
coord_to_label <- function(x)
{
  row_num <- sub("R([0-9]+)C([0-9]+)", "\\1", x)
  col_num <- sub("R([0-9]+)C([0-9]+)", "\\2", x)
  
  letter <- num_to_letter(as.numeric(col_num))
  
  paste0(letter, row_num)
}


#' Set header for data frame 
#'
#' Take first row of data frame and make it the header. Rownames are also reset.
#'
#' @param x a data frame.
set_header <- function(x)
{
  names(x) <- x[1, ]
  x <- x[2:nrow(x), ]
  rownames(x) <- NULL
  x
}


#' Determine the number of cells in the range
#' 
#' @param range character string for range value
#'
#' @return numeric value for count of cells in range.
ncells <- function(range)
{
  bounds <- unlist(strsplit(range, split = ":"))
  rows <- as.numeric(gsub("[^0-9]", "", bounds))  
  cols <- unname(sapply(gsub("[^A-Z]", "", bounds), letter_to_num))
  
  i <- seq(rows[1], rows[2])
  j <- seq(cols[1], cols[2])
  cells_in_range <- expand.grid(i, j)
  nrow(cells_in_range)
}


#' Determine the range occupied by a data frame
#' 
#' @param dat a data frame
#' @param anchor position of cell used as an "anchor"
#' @param header \code{logical} indicating whether the header of the data should 
#' be included in the range
#'
#' @return character string for the range taken up by a data frame
build_range <- function(dat, anchor, header) {
  
  if(!is.data.frame(dat)) {
    row <- 0
    col <- length(dat) - 1
  } else {
    
    if(header) {
      row <- nrow(dat)
    } else { 
      row <- nrow(dat) - 1 
    }
    col <- ncol(dat) - 1
  }
  
  letter <- unlist(strsplit(anchor, "[0-9]+"))
  
  right_col_num <- letter_to_num(letter) + col
  right_col_letter <- num_to_letter(right_col_num)
  
  row_num <- gsub("[[:alpha:]]", "", anchor)
  bottom_row <- as.numeric(row_num) + row
  
  paste0(anchor, ":", right_col_letter, bottom_row)
}


#' Find the dimensions of a worksheet
#'
#' Get the rows and columns of a worksheet by making a request for cellfeed.
#'
#' @param ws a worksheet object
worksheet_dim <- function(ws)
{
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                           visibility = ws$visibility)
  
  req <- gsheets_GET(the_url)
  
  feed <- gsheets_parse(req)
  
  row_count <- unlist(getNodeSet(feed, "//gs:rowCount", 
                                     c("ns" = default_ns, "gs"), xmlValue))
  
  col_count <- unlist(getNodeSet(feed, "//gs:colCount", 
                                     c("ns" = default_ns, "gs"), xmlValue))
  
  ws$row_extent <- as.numeric(row_count)
  ws$col_extent <- as.numeric(col_count)
  
  tbl <- get_lookup_tbl(feed)
  
  if(nrow(tbl) == 0) {
  ws$nrow <- 0
  ws$ncol <- 0
  } else {
    ws$nrow <- max(tbl$row)
    ws$ncol <- max(tbl$col)
  }
  ws
}


#' Create worksheet objects from worksheets feed
#' 
#' Extract worksheet info (spreadsheet id, worksheet id, worksheet title, 
#' row count and col count) from entry nodes in worksheets feed as worksheet 
#' objects.
#' 
#' @param node entry node for worksheet
#' @param sheet_id spreadsheet id housing worksheet
#' 
make_ws_obj <- function(node, sheet_id)
{
  attr_list <- XML::xmlToList(node)
  
  ws <- worksheet()
  ws$sheet_id <- sheet_id
  ws$ws_id <- unlist(strsplit(attr_list$id, "/"))[[9]]
  ws$title <- (attr_list$title)$text
  ws$row_extent <- as.numeric(attr_list$rowCount)
  ws$col_extent <- as.numeric(attr_list$colCount)
  ws
}


#' Get lookup table 
#'
#' Create lookup table from cellfeed.
#' 
#' @param feed cellfeed from GET request
#' @param include_sheet_title include column with worksheet title in lookup 
#' table
#' 
#' @importFrom XML xmlValue xmlAttrs
#'
get_lookup_tbl <- function(feed, include_sheet_title = FALSE)
{
  val <- getNodeSet(feed, "//ns:entry//gs:cell", 
                    c("ns" = default_ns, "gs"), xmlValue)
  
  row_num <- getNodeSet(feed, "//ns:entry//gs:cell", 
                        c("ns" = default_ns, "gs"),
                        function(x) as.numeric(xmlAttrs(x)["row"]))
  
  col_num <-  getNodeSet(feed, "//ns:entry//gs:cell", 
                         c("ns" = default_ns, "gs"),
                         function(x) as.numeric(xmlAttrs(x)["col"]))
  
  rows <- unlist(row_num)
  cols <- unlist(col_num)
  
  lookup_tbl <- data.frame(row = rows, col = cols, val = unlist(val),
                           stringsAsFactors = FALSE)
  
  if(nrow(lookup_tbl) != 0 & include_sheet_title) {
    title <- getNodeSet(feed, "//ns:title", c("ns" = default_ns), xmlValue)[1]
    lookup_tbl$Sheet <- unlist(title)
  }
  
  lookup_tbl
}


#' Fill in missing tuples for lookup table
#' 
#' The lookup table returned by get_lookup_tbl may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every row down to the bottom-most row of every column or every column 
#' up to the right-most column of every row. 
#' 
#' @param lookup_tbl data frame returned by \code{\link{get_lookup_tbl}}
#' @param row_min top-most row to start 
#' @param col_min left-most column to start
#' @param row_only \code{logical}, set to \code{TRUE} to fill missing rows only 
#' 
#' @importFrom dplyr arrange mutate
#' @importFrom plyr ddply
fill_missing_tbl <- function(lookup_tbl, row_min = 1, col_min = 1, 
                             row_only = FALSE) 
{
  if(row_only) {
    lookup_tbl_clean1 <- ddply(lookup_tbl, "col", 
                               function(x) fill_missing_row(x, row_min))
  } else {
    lookup_tbl_clean <- ddply(lookup_tbl, "row", 
                              function(x) fill_missing_col(x, col_min))
    lookup_tbl_clean1 <- ddply(lookup_tbl_clean, "col", 
                               function(x) fill_missing_row(x, row_min))
    
    lookup_tbl_clean1$row <- as.numeric(lookup_tbl_clean1$row)
  }
  
  lookup_tbl_clean1$col <- as.numeric(lookup_tbl_clean1$col)
  arrange(lookup_tbl_clean1, row, col) 
}

#' Fill in missing columns in a row
#' 
#' The lookup table returned by \code{\link{get_lookup_tbl}} may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every column up to the right-most column of the row.
#' 
#' @param x data frame returned by \code{\link{get_lookup_tbl}}
#' @param col_min leftmost column that row begins at
#' 
#' @note This function operates on the lookup table grouped by row.
#'
fill_missing_col <- function(x, col_min) 
{
  r <- as.numeric(x$col)
  
  for(i in col_min: max(r)) {
    if(is.na(match(i, r))) {
      new_tuple <- c(unique(x$row), i, NA)
      x <- rbind(x, new_tuple)
    }
  }
  x
} 


#' Fill in missing rows in column
#' 
#' The lookup table returned by \code{\link{get_lookup_tbl}} may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every row down to the bottom-most row of the column.
#' 
#' @param x data frame returned by \code{\link{get_lookup_tbl}}
#' @param row_min top-most row that column begins at
#' 
#' @note This function operates on the lookup table grouped by column.
#'
fill_missing_row <- function(x, row_min) 
{
  r <- as.numeric(x$row)
  
  for(i in row_min: max(r)) {
    if(is.na(match(i, r))) {
      new_tuple <- c(i, unique(x$col), NA)
      x <- rbind(x, new_tuple)
    }
  }
  x
}


#' Check if worksheet is empty
#'
#' Throw an error if worksheet is empty
#'
#' @param ws worksheet object
check_empty <- function(ws) {
  if(ws$nrow == 0)
    stop("Worksheet does not contain any values.")
}


#' Wrapper around xmlInternalTreeParse
#'
#' Simply for code neatness.
#'
#' @param req response from \code{\link{gsheets_GET}} request
#' @importFrom XML xmlInternalTreeParse
gsheets_parse <- function(req) 
{
  xmlInternalTreeParse(req)
}


#' Plot worksheet
#'
#' @param tbl data frame returned by \code{\link{get_lookup_tbl}}
make_plot <- function(tbl)
{
  ggplot(data = tbl, aes(x = col, y = row)) +
    geom_tile(width = 1, height = 1, fill = "steelblue2", alpha = 0.4) +
    facet_wrap(~ Sheet) +
    scale_x_continuous(breaks = seq(1, max(tbl$col), 1), expand = c(0, 0),
                       limits = c(1 - 0.5, max(tbl$col) + 0.5)) +
    annotate("text", x = seq(1, max(tbl$col), 1), y = (-0.05) * max(tbl$row), 
             label = LETTERS[1:max(tbl$col)], colour = "blue",
             fontface = "bold") +
    scale_y_reverse() +
    ylab("Row") +
    theme(panel.grid.major.x = element_blank(),
          plot.title = element_text(face = "bold"),
          axis.text.x = element_blank(),
          axis.title.x = element_blank(),
          axis.ticks.x = element_blank())
}


#' Put information from spreadsheets feed into data frame 
#'
#' Get spreadsheets' titles, owner, access type, date/time of last update and 
#' its unique key, and organize into a data frame for easy post-processing.
#'
#' @importFrom XML xmlValue xmlGetAttr
ssfeed_to_df <- function() 
{
  the_url <- build_req_url("spreadsheets")
  
  req <- gsheets_GET(the_url)
  ssfeed <- gsheets_parse(req)
  
  ss_titles <- getNodeSet(ssfeed, "//ns:entry//ns:title", c("ns" = default_ns),
                          xmlValue)
  
  ss_updated <- getNodeSet(ssfeed, "//ns:entry//ns:updated", 
                           c("ns" = default_ns), xmlValue)
  
  ss_access <- 
    getNodeSet(ssfeed, '//ns:entry//ns:link[@rel="http://schemas.google.com/spreadsheets/2006#worksheetsfeed"]', 
               c("ns" = default_ns),
               function(x) xmlGetAttr(x, "href"))
  
  ss_access_log <- grepl("values", unlist(ss_access))
  
  ss_access_log[grep(TRUE, ss_access_log)] <- "read only"
  ss_access_log[grep(FALSE, ss_access_log)] <- "read/write"
  
  
  ss_wsfeed <- 
    getNodeSet(ssfeed, '//ns:entry//ns:link[@rel="self"]', c("ns" = default_ns),
               function(x) xmlGetAttr(x, "href"))
  
  ss_key <- sub(".*full/", "", unlist(ss_wsfeed)) # extract spreadsheet key
  
  ss_owner <- getNodeSet(ssfeed, "//ns:entry//ns:author//ns:name", 
                         c("ns" = default_ns), xmlValue)
  
  ssdata_df <- data.frame(sheet_title = unlist(ss_titles),
                          sheet_key = ss_key,
                          owner = unlist(ss_owner),
                          access_type = ss_access_log,
                          last_updated = unlist(ss_updated),
                          stringsAsFactors = FALSE)
  ssdata_df
}


#' Generate a cells feed to update cell values
#' 
#' Create an update feed for the new values.
#' 
#' @param feed cell feed returned and parsed from GET request
#' @param new_values vector of new values to update cells 
#' 
#' @importFrom XML xmlNode
#' @importFrom dplyr mutate
#' @importFrom plyr dlply
create_update_feed <- function(feed, new_values)
{
  tbl <- get_lookup_tbl(feed)
  
  self_link <- getNodeSet(feed, '//ns:entry//ns:link[@rel="self"]', 
                          c("ns" = default_ns),
                          function(x) xmlGetAttr(x, "href"))  
  
  edit_link <- getNodeSet(feed, '//ns:entry//ns:link[@rel="edit"]', 
                          c("ns" = default_ns),
                          function(x) xmlGetAttr(x, "href"))
  
  dat_tbl <- mutate(tbl, self_link = unlist(self_link), 
                    edit_link = unlist(edit_link), 
                    new_vals = new_values,
                    row_id = 1:nrow(tbl))
  
  req_url <- unlist(getNodeSet(feed, '//ns:id', 
                               c("ns" = default_ns), xmlValue))[1]
  
  listt <- dlply(dat_tbl, "row_id", make_entry_node)
  new_list <- unlist(listt, use.names = FALSE)
  nodes <- paste(new_list, collapse = "\n" )
  
  # create entry element 
  the_body <- 
    xmlNode("feed", 
            namespaceDefinitions = 
              c(default_ns, 
                batch = "http://schemas.google.com/gdata/batch",
                gs = "http://schemas.google.com/spreadsheets/2006"),
            xmlNode("id", req_url)
    )
  
  new_body <- gsub("</feed>", paste(nodes, "</feed>", sep = "\n"), 
                   toString.XMLNode(the_body))
  new_body
}


#' Make entry element
#' 
#' Make the new value into an entry element required by the update feed. 
#' 
#' @param x a character string or numeric 
#' @importFrom XML xmlNode toString.XMLNode
make_entry_node <- function(x)
{
  node <- xmlNode("entry",
                  xmlNode("batch:id", paste0("R", x$row, "C", x$col)),
                  xmlNode("batch:operation", attrs = c(type = "update")),
                  xmlNode("id", x$self_link),
                  xmlNode("link", 
                          attrs = c("rel" = "edit", 
                                    "type" = "application/atom+xml",
                                    "href" = x$edit_link)),
                  xmlNode("gs:cell", attrs = c("row" = x$row, "col" = x$col, 
                                               "inputValue" = x$new_vals)))
  toString.XMLNode(node)
}  

