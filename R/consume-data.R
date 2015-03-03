#' Get data from a rectangular worksheet as a tbl_df
#' 
#' Gets data via the listfeed, which assumes populated cells form a neat 
#' rectangle. First row regarded as header row of variable or column names. If 
#' data is neatly rectangular and you want all of it, this is the fastest way to
#' get it. Anecdotally, ~3x faster than using methods based on the cellfeed.
#' 
#' @param ss a registered Google spreadsheet
#' @param ws positive integer or character string specifying index or title, 
#'   respectively, of the worksheet to consume
#'   
#' @family data consumption functions
#'   
#' @export
get_via_lf <- function(ss, ws = 1) {
  
  this_ws <- get_ws(ss, ws)
  req <- gsheets_GET(this_ws$listfeed)
  row_data <- req$content %>% lfilt("entry")
  component_names <- row_data[[1]] %>% names
  boilerplate_names <- ## what if spreadsheet header row contains these names??
    ## safer to get via ... numeric index? or by parsing entry$title and
    ## entry$content$text?
    ## sigh: if I were still using XML, use of gsx namespace would disambiguate
    ## this
    ## TO DO: experiment with empty header cells, header cells with
    ## space or other non-alphanumeric characters
    ## https://developers.google.com/google-apps/spreadsheets/#working_with_list-based_feeds
    c("id", "updated", "category", "title", "content", "link")
  var_names <- component_names %>% dplyr::setdiff(boilerplate_names)
  dat <- row_data %>%
    ## get just the data, as named character vector
    plyr::llply(function(x) x[var_names] %>% unlist) %>%
    ## rowbind to produce character matrix
    do.call("rbind", .) %>%
    ## drop stupid repetitive "entry" rownames
    `rownames<-`(NULL) %>%
    ## convert to integer, numeric, etc. but w/ stringsAsFactors = FALSE
    plyr::alply(2, type.convert, as.is = TRUE, .dims = TRUE) %>%
    ## convert to data.frame (tbl_df, actually)
    dplyr::as_data_frame()
  
}

#' Create a data.frame of the non-empty cells in a rectangular region of a 
#' worksheet
#' 
#' No attempt to shape the returned data! Data.frame will have one row per cell.
#' 
#' Use the limits, e.g. min_row or max_col, to delineate the rectangular region 
#' of interest. You can specify any subset of the limits or none at all. If 
#' limits are provided, validity will be checked as well as internal consistency
#' and compliance with known extent of the worksheet. If no limits are provided,
#' all cells will be returned but user should realize that access via the list 
#' feed is potentially a much faster to consume data from a rectangular 
#' worksheet.
#' 
#' Empty cells, even if "embedded" in a rectangular region of populated cells, 
#' are not returned by the API and will not appear in the returned data.frame.
#' 
#' @param ss a registered Google spreadsheet
#' @param ws positive integer or character specifying index or title, 
#'   respectively, of the worksheet to consume; defaults to 1, i.e. the first 
#'   worksheet
#' @param min_row positive integer, optional
#' @param max_row positive integer, optional
#' @param min_col positive integer, optional
#' @param max_col positive integer, optional
#' @param limits list, with named components holding the min and max for rows
#'   and columns; intended primarily for internal use
#'   
#' @family data consumption functions
#'   
#' @export
get_via_cf <- function(ss, ws = 1, min_row = NULL, max_row = NULL,
                       min_col = NULL, max_col = NULL, limits = NULL) {
  
  this_ws <- get_ws(ss, ws)
  
  if(is.null(limits)) {
    limits <- list("min-row" = min_row, "max-row" = max_row,
                   "min-col" = min_col, "max-col" = max_col)
  } else{
    ## since direct input of limits is mostly for internal use, I'm not doing
    ## much validity checking here ...
    names(limits) <- names(limits) %>% stringr::str_replace("_", "-")
  }
  limits <- limits %>%
    validate_limits(this_ws$row_extent, this_ws$col_extent)

  req <- gsheets_GET(this_ws$cellsfeed, query = limits)
  
  x <- req$content %>% lfilt("entry") %>%
    lapply(FUN = function(x) {
      dplyr::data_frame(cell = x$title$text,
                        cell_alt = x$id %>% basename,
                        row = x$cell$.attrs["row"] %>% as.integer,
                        col = x$cell$.attr["col"] %>% as.integer,
                        # see issue #19 about all the places cell data is
                        # (mostly redundantly) stored in the XML
                        #content_text = x$content$text,
                        #cell_inputValue = x$cell$.attrs["inputValue"],
                        #cell_numericValue = x$cell$.attrs["numericValue"],
                        cell_text = x$cell$text)
    }) %>%
    dplyr::bind_rows()
  attr(x, "ws_title") <- this_ws$ws_title
  x
}

#' Get data from a row or range of rows
#' 
#' Get data via the cell feed for one row or for a range of rows.
#' 
#' @inheritParams get_via_lf
#' @param row vector of positive integers, possibly of length one, specifying
#'   which rows to retrieve; only contiguous ranges of rows are supported, i.e.
#'   if \code{row = c(2, 8)}, you will get rows 2 through 8
#'   
#' @family data consumption functions
#' @seealso \code{\link{reshape_cf}} to reshape the retrieved data into a more 
#'   usable data.frame
get_row <- function(ss, ws = 1, row)
  get_via_cf(ss, ws, min_row = min(row), max_row = max(row))

#' Get data from a column or range of columns
#' 
#' Get data via the cell feed for one column or for a range of columns.
#' 
#' @inheritParams get_via_lf
#' @param col vector of positive integers, possibly of length one, specifying 
#'   which columns to retrieve; only contiguous ranges of columns are supported,
#'   i.e. if \code{col = c(2, 8)}, you will get columns 2 through 8
#'   
#' @family data consumption functions
#' @seealso \code{\link{reshape_cf}} to reshape the retrieved data into a more 
#'   usable data.frame
get_col <- function(ss, ws = 1, col)
  get_via_cf(ss, ws, min_col = min(col), max_row = max(col))

#' Get data from a cell or range of cells
#' 
#' Get data via the cell feed for a rectangular range of cells
#' 
#' @inheritParams get_via_lf
#' @param range single character string specifying which cell or range of cells
#'   to retrieve; positioning notation can be either "A1" or "R1C1"; a single
#'   cell can be requested, e.g. "B4" or "R4C2" or a rectangular range can be
#'   requested, e.g. "B2:D4" or "R2C2:R4C4"
#'   
#' @family data consumption functions
#' @seealso \code{\link{reshape_cf}} to reshape the retrieved data into a more 
#'   usable data.frame
get_cells <- function(ss, ws = 1, range) {
  
  limits <- convert_range_to_limit_list(range) 
  get_via_cf(ss, ws, limits = limits)
  
}

#' Reshape cell-level data and convert to data.frame
#' 
#' This will not be exported long-term. Will write wrappers. Temporary export.
#' 
#' @param x a data.frame returned by \code{get_via_cf()}
#' @param header logical indicating whether first row should be taken as
#'   variable names
#' 
#' @family data consumption functions
#'   
#' @export
reshape_cf <- function(x, header = TRUE) {
  
  limits <- x %>%
    dplyr::summarise_each_(dplyr::funs(min, max), list(~ row, ~ col))
  all_possible_cells <-
    with(limits,
         expand.grid(row = row_min:row_max, col = col_min:col_max))
  suppressMessages(
    x_augmented <- all_possible_cells %>% dplyr::left_join(x)
    ## tidyr::spread(), used below, could do something similar as this join, but
    ## it would handle completely missing rows and columns differently; still
    ## thinking about this
  )
  
  if(header) {
    row_one <- x_augmented %>% 
      dplyr::filter_(~ row == min(row))
    var_names <- ifelse(is.na(row_one$cell_text),
                        stringr::str_c("C", row_one$col),
                        row_one$cell_text) %>% make.names()
    x_augmented <- x_augmented %>%
      dplyr::filter_(~ row > min(row))
  } else {
    var_names <- limits$col_min:limits$col_max %>% make.names()
  }
  
  x_augmented %>%
    dplyr::select_(~ row, ~ col, ~ cell_text) %>%
    tidyr::spread_("col", "cell_text", convert = TRUE) %>% 
    dplyr::select_(~ -row) %>%
    setNames(var_names)
  
}

#' Simplify data from the cell feed
#' 
#' In some cases, you might not want to convert the data retrieved from the cell
#' feed into a data.frame via \code{\link{reshape_cf}}. You might prefer it as 
#' an atomic vector. That's what this function does. Note that, unlike 
#' \code{\link{reshape_cf}}, empty cells will NOT appear in this result. The API
#' does not transmit data for these cells; \code{gspreadr} inserts these cells 
#' in \code{\link{reshape_cf}} because it is necessary to give the data 
#' rectangular shape. But it is not necessary when returning the data as a 
#' vector and therefore it is not done by \code{simplify_cf}.
#' 
#' @inheritParams reshape_cf
#' @param convert logical, indicating whether to attempt to convert the result
#'   vector from character to something more appropriate, such as logical,
#'   integer, or numeric; if TRUE, result is passed through \code{type.convert};
#'   if FALSE, result will be character
#' @param as.is logical, passed through to the \code{as.is} argument of 
#'   \code{type.convert}
#' @param notation character; the result vector will have names that reflect 
#'   which cell the data came from; this argument controls notation style, i.e. 
#'   "A1" vs. "R1C1"
#'   
#' @return a named vector
#'   
#' @family data consumption functions
#'   
#' @export
simplify_cf <- function(x, convert = TRUE, as.is = TRUE,
                        notation = c("A1", "R1C1")) {
  notation <- match.arg(notation)
  y <- x$cell_text
  names(y) <- switch(notation,
                     A1 = x$cell,
                     R1C1 = x$cell_alt)
  if(convert) {
    y %>% type.convert(as.is = as.is)
  } else {
    y
  }
  
}

## argument validity checks and transformation

## re: min_row, max_row, min_col, max_col = query params for cell feed
validate_limits <-
  function(limits, ws_row_extent = NULL, ws_col_extent = NULL) {
    
    ## limits must be length one vector, holding a positive integer
    
    ## why do I proceed this way?
    ## [1] want to preserve original invalid limits for use in error message
    ## [2] want to be able to say which element(s) of limits is/are invalid
    tmp_limits <- limits %>% plyr::llply(affirm_not_factor)
    tmp_limits <- tmp_limits %>% plyr::llply(make_integer)
    tmp_limits <- tmp_limits %>% plyr::llply(affirm_length_one)
    tmp_limits <- tmp_limits %>% plyr::llply(affirm_positive)
    if(any(oops <- is.na(tmp_limits))) {
      mess <- sprintf("A row or column limit must be a single positive integer (or not given at all).\nInvalid input:\n%s",
                      paste(capture.output(limits[oops]), collapse = "\n"))
      stop(mess)
    } else {
      limits <- tmp_limits
    }
    
    ## min must be <= max, min and max must be <= nominal worksheet extent
    jfun <- function(x, upper_bound) {
      x_name <- deparse(substitute(x))
      ub_name <- deparse(substitute(upper_bound))
      if(!is.null(x) && !is.null(upper_bound) && x > upper_bound) {
        mess <-
          sprintf("%s must be less than or equal to %s\n%s = %d, %s = %d\n",
                  x_name, ub_name, x_name, x, ub_name, upper_bound)
        stop(mess)
      }
    }
    
    jfun(limits[["min-row"]], limits[["max-row"]])
    jfun(limits[["min-row"]], ws_row_extent)
    jfun(limits[["max-row"]], ws_row_extent)
    jfun(limits[["min-col"]], limits[["max-col"]])
    jfun(limits[["min-col"]], ws_col_extent)
    jfun(limits[["max-col"]], ws_col_extent)
    
    limits
    
  }

affirm_not_factor <- function(x) {
  if(is.null(x) || !inherits(x, "factor")) {
    x
  } else {
    NA
  }
}

make_integer <- function(x) {
  suppressWarnings(try({
    if(!is.null(x)) {
      storage.mode(x) <- "integer"
      ## why not use as.integer? because names are lost :(
      ## must use this method based on storage.mode
      ## if coercion fails, x is NA
      ## note this will "succeed" and coerce, eg, 4.7 to 4L
    }
    x
  }, silent = FALSE))
}

affirm_length_one <- function(x) {
  if(is.null(x) || length(x) == 1L || is.na(x)) {
    x
  } else {
    NA
  }
}

affirm_positive <- function(x) {
  if(is.null(x) || x > 0 || is.na(x)) {
    x
  } else {
    NA
  }
}
