#' Get data from a rectangular worksheet as a tbl_df
#' 
#' @param ss a registered Google spreadsheet
#' @param ws positive integer or character string specifying index or title, 
#'   respectively, of the worksheet to consume
#'   
#'   Gets data via the listfeed, which assumes populated cells form a neat
#'   rectangle. First row regarded as header row of variable or column names. If
#'   data is neatly rectangular and you want all of it, this is the fastest way
#'   to get it. Anecdotally, ~3x faster than using methods based on the
#'   cellfeed.
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
#'   
#' @export
get_via_cf <- function(ss, ws = 1, min_row = NULL, max_row = NULL,
                       min_col = NULL, max_col = NULL) {
  
  this_ws <- get_ws(ss, ws)
  
  limits <- list(min_row = min_row, max_row = max_row,
                 min_col = min_col, max_col = max_col)
  limits <- limits %>%
    validate_limits(this_ws$row_extent, this_ws$col_extent)
  limits <- limits[!plyr::laply(limits, is.null)]
  if(length(limits) > 0) {
    query_string <- 
      stringr::str_c(names(limits), unlist(limits),
                     sep = "=", collapse = "&") %>%
      stringr::str_replace("_", "-")
  } else {
    query_string <- NULL
  }
  
  get_url <- this_ws$cellsfeed %>%
    httr::modify_url(query = query_string)
  req <- gsheets_GET(get_url)
  
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

#' Reshape cell-level data and convert to data.frame
#' 
#' This will not be exported long-term. Will write wrappers. Temporary export.
#' 
#' @param x a data.frame returned by \code{get_via_cf()}
#' @param header logical indicating whether first row should be taken as
#'   variable names
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
      dplyr::filter_(~ row == 1L)
    var_names <- ifelse(is.na(row_one$cell_text),
                        stringr::str_c("C", row_one$col),
                        row_one$cell_text) %>% make.names
    x_augmented <- x_augmented %>%
      dplyr::filter_(~ row > 1)
  } else {
    var_names <- limits$col_min:limits$col_max %>% make.names
  }

  x_augmented %>%
    dplyr::select_(~ row, ~ col, ~ cell_text) %>%
    tidyr::spread_("col", "cell_text", convert = TRUE) %>% 
    dplyr::select_(~ -row) %>%
    setNames(var_names)

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
    
    jfun(limits$min_row, limits$max_row)
    jfun(limits$min_row, ws_row_extent)
    jfun(limits$max_row, ws_row_extent)
    jfun(limits$min_col, limits$max_col)
    jfun(limits$min_col, ws_col_extent)
    jfun(limits$max_col, ws_col_extent)
    
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
