# default namespace for querying xml feed returned by gsheets_GET
default_ns = "http://www.w3.org/2005/Atom"

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

#' Create worksheet objects from worksheets feed
#' 
#' Extract worksheet info (spreadsheet id, worksheet id, worksheet title) 
#' from entry nodes in worksheets feed as worksheet objects.
#' 
#' @param node entry node for worksheet
#' @param sheet_id spreadsheet id housing worksheet
#' 
#' @importFrom XML xmlToList
make_ws_obj <- function(node, sheet_id)
{
  attr_list <- xmlToList(node)
  
  ws <- worksheet()
  ws$sheet_id <- sheet_id
  ws$id <- unlist(strsplit(attr_list$id, "/"))[[9]]
  ws$title <- (attr_list$title)$text
  ws
}


#' Get information from spreadsheets feed 
#'
#' Get spreadsheets titles, keys, and date/time of last update.
#'
#' @importFrom XML xmlValue
#' @importFrom XML xmlGetAttr
#' @importFrom XML getNodeSet
ssfeed_to_df <- function() 
{
  the_url <- build_req_url("spreadsheets")
  req <- gsheets_GET(the_url)
  ssfeed <- gsheets_parse(req)
  
  ss_titles <- getNodeSet(ssfeed, "//ns:entry//ns:title", c("ns" = default_ns),
                          xmlValue)
  
  ss_updated <- getNodeSet(ssfeed, "//ns:entry//ns:updated", 
                           c("ns" = default_ns), xmlValue)
  
  ss_wsfeed <- 
    getNodeSet(ssfeed, '//ns:entry//ns:link[@rel="self"]', c("ns" = default_ns),
               function(x) xmlGetAttr(x, "href"))
  
  ss_key <- sub(".*full/", "", unlist(ss_wsfeed)) # extract spreadsheet key
  
  ssdata_df <- data.frame(sheet_title = unlist(ss_titles),
                          last_updated = unlist(ss_updated),
                          sheet_key = ss_key,
                          stringsAsFactors = FALSE)
  ssdata_df
}


#' Find number of rows and columns of worksheet

#' Get the rows and columns of worksheet by making a request for cellfeed

#' @param ws Worksheet object
#' @param auth Google token
#' @param visibility set to \code{public} for public sheets
#' @importFrom XML getNodeSet
#' @importFrom XML xmlApply
#' @importFrom XML xmlGetAttr
#' @export
worksheet_dim <- function(ws, auth = get_google_token(), visibility = "private")
{
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           visibility = visibility)
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  tbl <- create_lookup_tbl(feed)
  
  cell_nodes <- getNodeSet(feed, "//ns:feed//ns:entry", c("ns" = default_ns)) 
  
  if(length(cell_nodes) == 0) {
    dims <- getNodeSet(feed, "//ns:feed//gs:*", c("ns" = default_ns, "gs"), xmlValue)
    ws$nrow <- as.numeric(dims[[1]])
    ws$ncol <- as.numeric(dims[[2]])
  } else {
    cell_col_num <- getNodeSet(feed, "//ns:entry//gs:*", c("ns" = default_ns, "gs"),
                               function(x) c(as.numeric(xmlGetAttr(x, "col")), 
                                             as.numeric(xmlGetAttr(x, "row"))))
    
    ws$nrow <- max(sapply(cell_col_num, "[[", 2))
    ws$ncol <- max(sapply(cell_col_num, "[[", 1))
  }
  ws
}

# #' Find number of rows and columns of worksheet
# #' 
# #' Get the rows and columns of worksheet by making a request for cellfeed
# #' 
# #' dparam ws Worksheet object
# #' param auth Google token
# #' param visibility set to \code{public} for public sheets
# #'  
# #' The is faster but with a trade-off. For listfeeds, data will stop before an 
# #' entire blank row. For example if row 2 is entirely blank, no data will be 
# #' returned. Blank columns are also ignored. The number of columns will be the 
# #' maximum number of cells in a row that contain a value, regardless
# #' of spacing.
# #' 
# #' importFrom XML getNodeSet
# #' importFrom XML xmlChildren
# worksheet_dim <- function(ws, auth = get_google_token(), visibility = "private")
# {
#   the_url <- build_req_url("list", key = ws$sheet_id, ws_id = ws$id, 
#                            visibility = visibility)
#   
#   req <- gsheets_GET(the_url)
#   feed <- gsheets_parse(req)
# 
#   cell_nodes <- getNodeSet(feed, "//ns:feed//ns:entry", c("ns" = default_ns),
#                            function(x) length(xmlChildren(x)) - 7)
#   
#   ws$ncol <- max(unlist(cell_nodes))
#   ws$nrow <- length(cell_nodes) + 1 # to include header row
#   ws
# }

#' Create lookup table for cell indices and its values 
#'
#' Convert cell row and col attributes stored in entry nodes, along with 
#' input values into a single data frame and serve as a lookup table for 
#' further processing.
#'
#' @param cellsfeed Cell based feed parsed with \code{\link{gsheets_parse}} 
#' @return A data frame with cell row and col number and corresponding input value.
#' @importFrom XML getNodeSet
#' @importFrom XML xmlAttrs
#' @importFrom XML xmlValue
create_lookup_tbl <- function(cellsfeed) {
  val <- getNodeSet(cellsfeed, "//ns:entry//gs:cell", 
                    c("ns" = default_ns, "gs"), xmlValue)
  
  row_num <- getNodeSet(cellsfeed, "//ns:entry//gs:cell", 
                        c("ns" = default_ns, "gs"),
                        function(x) as.numeric(xmlAttrs(x)["row"]))
  
  col_num <-  getNodeSet(cellsfeed, "//ns:entry//gs:cell", 
                         c("ns" = default_ns, "gs"),
                         function(x) as.numeric(xmlAttrs(x)["col"]))
  
  rows <- unlist(row_num)
  cols <- unlist(col_num)
  
  lookup_tbl <- data.frame(row = rows, col = cols, val = unlist(val),
                           stringsAsFactors = FALSE)
  
  lookup_tbl
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


#' Convert column letter to column number
#'
#' @param x column letter (case insensitive)
#' @examples
#' letter_to_num("A")
#' letter_to_num("AB")
#' letter_to_num("a")
#' letter_to_num("ab")
letter_to_num <- function(x)
{
  ascii_tbl <- data.frame(alpha = LETTERS, num = 65:90)
  x <- toupper(x)
  
  m <- c()
  for(i in 1:nchar(x)) {
    k <- unlist(strsplit(x, "")) # list of characters
    ind <- grep(k[i], ascii_tbl$alpha)
    y <- (ascii_tbl[ind, "num"] - 64) * (26 ^ (nchar(x) - i))
    m <- c(m, y)
  }
  sum(m)
}


#' Convert column number to column letter
#'
#' @param x column number
#' @examples
#' num_to_letter(1)
#' num_to_letter(26)
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
#' A1 and R1C1 are equivalent addresses for position of cells, but R1C1 
#' notation is used in queries. 
#'
#' @param x label notation for position of cell
#' @examples
#' label_to_coord("A1")
#' label_to_coord("AB23")
label_to_coord <- function(x)
{
  letter <- unlist(strsplit(x, "[0-9]+"))
  col_num <- letter_to_num(letter)
  row_num <- gsub("[[:alpha:]]", "", x)
  paste0("R", row_num, "C", col_num)
}


#' Fill in missing columns in row
#' 
#' The lookup table returned by create_lookup_tbl may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every column up to the right-most column of the row.
#' 
#' @param x data frame returned by \code{\link{create_look_tbl}}
#' 
#' This function operates on the lookup table grouped by row.
#'
fill_missing_col <- function(x) 
{
  r <- as.numeric(x$col_adj)
  
  for(i in 1: max(r)) {
    if(is.na(match(i, r))) {
      new_tuple <- c("-", "-", NA, unique(x$row_adj), i)
      x <- rbind(x, new_tuple)
    }
  }
  x
} 


#' Fill in missing rows in column
#' 
#' The lookup table returned by create_lookup_tbl may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every row down to the bottom-most row of the column.
#' 
#' @param x data frame returned by \code{\link{create_look_tbl}}
#' 
#' This function operates on the lookup table grouped by column.
#'
fill_missing_row <- function(x) 
{
  r <- as.numeric(x$row_adj)
  
  for(i in 1: max(r)) {
    if(is.na(match(i, r))) {
      new_tuple <- c("-", "-", NA, i, unique(x$col_adj))
      x <- rbind(x, new_tuple)
    }
  }
  x
}


#' Fill in missing tuples for lookup table
#' 
#' The lookup table returned by create_lookup_tbl may contain missing tuples 
#' for empty cells. This function fills in the table so that there is a tuple 
#' for every row down to the bottom-most row of every column or every column 
#' up to the right-most column of every row. 
#' 
#' @param lookup_tbl data frame returned by \code{\link{create_look_tbl}}
#' 
#' @importFrom dplyr arrange
#' @importFrom dplyr mutate
#' @importFrom plyr ddply
fill_missing_tbl <- function(lookup_tbl) 
{
  
  # create adjusted row/col indices
  row_diff <- min(lookup_tbl$row) - 1
  col_diff <- min(lookup_tbl$col) - 1
  
  lookup_tbl <- mutate(lookup_tbl, row_adj = row - row_diff, 
                       col_adj = col - col_diff)
  
  lookup_tbl_clean1 <- ddply(lookup_tbl, "row_adj", fill_missing_col)
  lookup_tbl_clean2 <- ddply(lookup_tbl_clean1, "col_adj", fill_missing_row)
  
  lookup_tbl_clean2$row_adj <- as.numeric(lookup_tbl_clean2$row_adj)
  lookup_tbl_clean2$col_adj <- as.numeric(lookup_tbl_clean2$col_adj)
  
  arrange(lookup_tbl_clean2, row_adj, col_adj)
  
}

#' Get lookup table for entire worksheet
#'
#' Create lookup table for all the values in the worksheet.
#' 
#' @param ws worksheet object
#'
get_lookup_tbl <- function(ws)
{
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$id, 
                           min_col = 1, max_col = ws$ncol, visibility = "private")
  
  req <- gsheets_GET(the_url)
  feed <- gsheets_parse(req)
  
  dat <- create_lookup_tbl(feed)
  dat$Sheet <- ws$title
  dat
}


#' Plot worksheet
#'
#' @param tbl data frame returned by \code{\link{get_lookup_tbl}}
make_plot <- function(tbl)
{
  ggplot(tbl, aes(x = col, y = row)) +
    geom_tile(fill = "steelblue2", aes(x = col, y = row), alpha = 0.4) +
    facet_wrap(~ Sheet) +
    scale_x_continuous(breaks = seq(1, max(tbl$col), 1), expand = c(0, 0)) +
    annotate("text", x = seq(1, max(tbl$col) ,1), y = (-0.05) * max(tbl$row), 
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


#' @importFrom XML xmlNode getNodeSet
#' @importFrom dplyr mutate
#' @importFrom plyr dlply
create_update_feed <- function(feed, new_values)
{
  tbl <- create_lookup_tbl(feed)
  
  self_link <- getNodeSet(feed, '//ns:entry//ns:link[@rel="self"]', 
                          c("ns" = default_ns),
                          function(x) xmlGetAttr(x, "href"))  
  
  edit_link <- getNodeSet(feed, '//ns:entry//ns:link[@rel="edit"]', 
                          c("ns" = default_ns),
                          function(x) xmlGetAttr(x, "href"))
  
  dat_tbl <- mutate(tbl, self_link = unlist(self_link), 
                    edit_link = unlist(edit_link), 
                    new_vals = new_values, row_id = 1:nrow(tbl))
  
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
  
  new_body <- gsub("</feed>", paste(nodes, "</feed>", sep = "\n"), toString.XMLNode(the_body))
  new_body
}


#' @importFrom XML xmlNode toString.XMLNode
make_entry_node <- function(x)
{
  node <- xmlNode("entry",
                  xmlNode("batch:id", paste0("R", x$row, "C", x$col)),
                  xmlNode("batch:operation", attrs = c(type = "update")),
                  xmlNode("id", x$self_link),
                  xmlNode("link", 
                          attrs = c("rel" = "edit", "type" = "application/atom+xml",
                                    "href" = x$edit_link)),
                  xmlNode("gs:cell", attrs = c("row" = x$row, "col" = x$col, "inputValue" = x$new_vals)))
  toString.XMLNode(node)
}  

