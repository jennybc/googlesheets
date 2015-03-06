#' Update a cell or range of cells
#' 
#' Modify the contents of a cell or a range of cells by specifying a range or a 
#' reference cell. If a reference cell is given, the range occupied by the input 
#' will be calculated and updated correspondingly. Input can be a character
#' vector or a data frame.
#' 
#' Cells are updated by rows, hence specifying a reference cell and a vector of 
#' values for input will result in the specified row being updated. 
#' 
#' @param ss a registered Google sheet
#' 
#' @param ws positive integer or character string specifying index or title, 
#' respectively, of the worksheet to consume
#' 
#' @param range single character string specifying which cell or range of cells 
#' to update; positioning notation can be either "A1" or "R1C1"; a single cell 
#' can be updated, e.g. "B4" or "R4C2" or a rectangular range can be updated, 
#' e.g. "B2:D4" or "R2C2:R4C4"
#' 
#' @param input either a vector of a data frame of values to update cells with
#' 
#' @param verbose logical; do you want informative message?
#' 
#' @note Data frame row names are ignored.
#' 
#' @export
update_cells <- function(ss, ws, range, input, verbose = TRUE) {
  
  this_ws <- get_ws(ss, ws, verbose = FALSE)
  
  # finds the min/max row/col
  limits <- convert_range_to_limit_list(range)
  
  # is the input a dataframe?
  if(is.data.frame(input)) {
    # turn it into a vector
    value_vector <- input %>% dplyr::rowwise() %>% t() %>% unlist() %>% 
      unname() %>% c(names(input), .)
  } else {
    value_vector <- input
  }
  
  # do some checks on the input
  
  # reference cell given
  if(!stringr::str_detect(range, ":")) {
    # update 1 cell
    if(length(value_vector) == 1L) {
      message(sprintf("Updating cell \"%s\" to \"%s\".", range, input))
      new_limits <- limits
      
    } else {
      # update >1 cell, what is the range taken up by the input?
      new_range <- build_range(limits, input) # "A1" -> "A1:B3" or "R1C1" -> "A1:B3" 
      message(sprintf("Reference cell: \"%s\".\nThe range occupied by the update input is: \"%s\". ", 
                      range, new_range))
      
      new_limits <- convert_range_to_limit_list(new_range)
    } 
  } else { 
    # range is given, how many cells in the range?
    ncells <- (abs(limits[["max-col"]] - limits[["min-col"]]) + 1) * 
      (abs(limits[["max-row"]] - limits[["min-row"]]) + 1)
    
    # do number of cells in range match length of input given?
    if(length(value_vector) != ncells) {
      stop(sprintf("Number of cells in %s: %d does not match number of cells to update: %d", 
                   range, ncells, length(value_vector)))
    } else {
      message(sprintf("Number of cells to update in %s: %d.", range, ncells))
      new_limits <- limits
    } 
  }
  
  # are the cells to update within the current ws dimensions?
  new_row_extent <- max(this_ws$row_extent, new_limits[["max-row"]])
  new_col_extent <- max(this_ws$col_extent, new_limits[["max-col"]])
  
  same_extents_as_before <- all(c(new_row_extent, new_col_extent) == 
                                  c(this_ws$row_extent, this_ws$col_extent))
  
  if(same_extents_as_before) {        
    message("The worksheet does not need to be resized.")
  } else {
    ss <- resize_ws(ss, this_ws$ws_title, new_row_extent, new_col_extent)
  }
  
  # hold all cell info (get_via_cf() + edit links, cell ids)
  cells_info_df <- get_via_cf(ss, ws, limits = new_limits, return_empty = TRUE) %>% 
    dplyr::mutate_(update_value = ~ value_vector)
  
  update_entries <- 
    plyr::dlply(
      cells_info_df, "cell_alt", 
      .fun = function(x) {
        XML::xmlNode("entry", 
                     XML::xmlNode("batch:id", x$cell),
                     XML::xmlNode("batch:operation", attrs = c("type" = "update")),
                     XML::xmlNode("id", x$cell_id),
                     XML::xmlNode("link", 
                                  attrs = c("rel" = "edit", 
                                            "type" = "application/atom+xml",
                                            "href" = x$edit_link)),
                     XML::xmlNode("gs:cell", 
                                  attrs = c("row" = x$row, 
                                            "col" = x$col, 
                                            "inputValue" = x$update_value)))})
  update_feed <- 
    XML::xmlNode("feed", 
                 namespaceDefinitions = 
                   c("http://www.w3.org/2005/Atom",
                     batch = "http://schemas.google.com/gdata/batch",
                     gs = "http://schemas.google.com/spreadsheets/2006"),
                 .children = list(XML::xmlNode("id", this_ws$cellsfeed))) %>%
    XML::addChildren( kids = update_entries) %>% XML::toString.XMLNode()
  
  gsheets_POST(paste(this_ws$cellsfeed, "batch", sep = "/"), update_feed)
  
  if(verbose) {
    message(sprintf("Worksheet titled \"%s\" successfully updated with %d new value(s).", 
                    this_ws$ws_title, length(value_vector)))
  }
  
  ss_refresh <- ss %>% register_ss(verbose = FALSE)
  ss_refresh
}


