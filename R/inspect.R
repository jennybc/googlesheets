#' Get list of spreadsheets
#'
#' Retrieve the names of the user's spreadsheets in Google drive. All 
#' private, public, and shared spreadsheets will be listed in order of most
#' recently updated. 
#' 
#' @param show_key \code{logical} to indicate whether spreadsheet keys are shown
#' 
#' @importFrom dplyr select_
#' @export
list_spreadsheets <- function(show_key = FALSE) 
{
  sheets_df <- ssfeed_to_df()
  
  if(show_key) {
    sheets_df
  } else {
    select_(sheets_df, quote(-sheet_key))
  }
  
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
  the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                           min_col = 1, max_col = ws$ncol,
                           visibility = ws$visibility)
  check_empty(ws)
  
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
  ws_objs <- open_worksheets(ss)
  
  dat_tbl <- 
    ldply(ws_objs, 
          function(ws)  {
            
            if(ws$ncol == 0) {
              col = 0
            } else {
              col = 1
            }
            
            the_url <- build_req_url("cells", key = ws$sheet_id, ws_id = ws$ws_id, 
                                     min_col = col, max_col = ws$ncol,
                                     visibility = ws$visibility)
            
            req <- gsheets_GET(the_url)
            
            feed <- gsheets_parse(req)
            get_lookup_tbl(feed, include_sheet_title = TRUE)
          })
  
  p1 <- make_plot(dat_tbl)
  
  p2 <- ggplot(dat_tbl, aes(x = col, y = row, group = ~ Sheet)) +
    geom_tile(fill = "steelblue2", aes(x = col, y = row), alpha = 0.4) +
    scale_x_continuous(breaks = seq(1, max(dat_tbl$col), 1), expand = c(0, 0)) +
    annotate("text", x = seq(1, max(dat_tbl$col), 1), y = (-0.05) * max(dat_tbl$row), 
             label = LETTERS[1:max(dat_tbl$col)], colour = "steelblue4",
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


#' Display the structure of a worksheet
#' 
#' Show the structure of a worksheet. Display the title, number of rows and 
#' columns, and summary of what patterns each column contains (ie. the number 
#' of missing cells before cells with values). 
#' 
#' @param object worksheet object
#' @param ... potential further arguments (required for Method/Generic reasons)
#' 
#' @return Does not return anything, prints to the console.
#' 
#' @importFrom dplyr summarise_ group_by_ select_ arrange_
#' @importFrom plyr ddply join rename
#' 
#' @export
str.worksheet <- function(object, ...)
{
  item1 <- paste(object$title, ":", object$nrow, "rows and", 
                 object$ncol, "columns")
  
  if(object$nrow == 0)
    return(item1)
  
  the_url <- build_req_url("cells", key = object$sheet_id, ws_id = object$ws_id, 
                           min_col = 1, max_col = object$ncol, 
                           visibility = object$visibility)
  
  req <- gsheets_GET(the_url)
  
  feed <- gsheets_parse(req)
  tbl <- get_lookup_tbl(feed)
  
  tbl_clean <- fill_missing_tbl(tbl, row_only = TRUE)
  tbl_bycol <- group_by_(tbl_clean, ~col)
  
  a1 <- summarise_(tbl_bycol, 
                   Label = ~num_to_letter(mean(col)),
                   nrow = ~max(row),
                   Empty.Cells = ~length(which(is.na(val))),
                   Missing = ~round(Empty.Cells/nrow, 2))
  
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
  
  item2 <- rename_(a3, "Column" = "col", "Rows" = "nrow", "Runs" = "V1")
  
  cat("Worksheet", item1, sep = "\n")
  print(item2)
}


#' Get the structure for a spreadsheet
#' 
#' Display the structure of a spreadsheet: the name of the spreadsheet, the 
#' number of worksheets contained and the corresponding worksheet dimensions.
#' 
#' @param object spreadsheet object
#' @param ... potential further arguments (required for Method/Generic reasons)
#' 
#' @importFrom dplyr summarise group_by select
#' @importFrom plyr llply
#' 
#' @export
str.spreadsheet <- function(object, ...)
{
  item1 <- paste0(object$sheet_title, ": ", object$nsheets, " worksheets")
  
  list_ws <- open_worksheets(object)
  
  item2 <- llply(list_ws, function(x) paste(x$title, ":", x$nrow, 
                                            "rows and", x$ncol, "columns"))
  
  cat("Spreadsheet:", item1, "\nWorksheets:", paste(item2, sep = "\n"), 
      sep = "\n")
}


#' Print method for a spreadsheet object
#' 
#' @param x spreadsheet object
#' @param ... potential further arguments
#' 
#' 
#' @export
print.spreadsheet <- function(x, ...)
{
  dat <- llply(x$worksheets, function(x) paste(x$title, ":", x$row_extent, "rows and", x$col_extent, "columns"))
  
  cat("Spreadsheet:", x$sheet_title)
  cat("\n")
  cat("Spreadsheet id:", x$sheet_id)
  cat("\n")
  cat("Last updated:", x$updated)
  cat("\n")
  cat("\n")
  cat("Contains", x$nsheets, "worksheets:")
  cat("\n")
  cat("(Title) : (Worksheet dimensions)")
  cat("\n")
  cat(paste(dat, sep = "\n"), sep = "\n")
  cat("\n")
  
  invisible(x)
}


#' Print method for a worksheet object
#' 
#' @param x worksheet object
#' @param ... potential further arguments
#' 
#' @export
print.worksheet <- function(x, ...)
{
  cat("Worksheet:", x$title)
  cat("\n")
  cat("Worksheet id:", x$ws_id)
  cat("\n")
  cat("Dimensions:", x$row_extent, "rows and", x$col_extent, "columns")
  cat("\n")
  cat("With data:", x$nrow, "rows and", x$ncol, "columns")
  cat("\n")
  
  invisible(x)
}

