#' Get all data from a rectangular worksheet as a tbl_df or data.frame
#'
#' This function consumes data using the \code{exportcsv} links found in the
#' worksheets feed. Don't be spooked by the "csv" thing -- the data is NOT
#' actually written to file during this process. In fact, this is much, much
#' faster than consumption via the list feed. Unlike using the list feed, this
#' method does not assume that the populated cells form a neat rectangle. All
#' cells within the "data rectangle", i.e. spanned by the maximal row and column
#' extent of the data, are returned. Empty cells will be assigned NA. Also, the
#' header row, potentially containing column or variable names, is not
#' transformed/mangled, as it is via the list feed. If you want all of your
#' data, this is the fastest way to get it.
#'
#' @inheritParams get_via_lf
#' @param ... further arguments to be passed to \code{\link{read.csv}} or,
#'   ultimately, \code{\link{read.table}}; note that \code{\link{read.csv}} is
#'   called with \code{stringsAsFactors = FALSE}, which is the blanket policy
#'   within \code{googlesheets} re: NOT converting character data to factor
#'   
#' @family data consumption functions
#'
#' @return a tbl_df
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "gap_copy")
#' oceania_csv <- get_via_csv(gap_ss, ws = "Oceania")
#' str(oceania_csv)
#' oceania_csv
#' }
#' @export
get_via_csv <- function(ss, ws = 1, ...) {

  stopifnot(ss %>% inherits("googlesheet"))
  
  this_ws <- get_ws(ss, ws)

  ## since gsheets_GET expects xml back, just using GET for now
  if(ss$is_public) {
    req <- httr::GET(this_ws$exportcsv)
  } else { 
    req <- httr::GET(this_ws$exportcsv, get_google_token())
  }
  
  if(is.null(httr::content(req))) {
    stop("Worksheet is empty. There are no cells that contain data.")
  }

  ## content() will process with read.csv, because req$headers$content-type is
  ## "text/csv"
  ## for empty cells, numeric columns returned as NA vs "" for chr
  #columns so set all "" to NA
  req %>%
    httr::content(na.strings = c("", "NA"), ...) %>%
    dplyr::as_data_frame()
}

#' Get data from a rectangular worksheet as a tbl_df or data.frame
#'
#' Gets data via the list feed, which assumes populated cells form a neat
#' rectangle. The list feed consumes data row by row. First row regarded as
#' header row of variable or column names. If data is neatly rectangular and you
#' want all of it, this is the fastest way to get it. Anecdotally, ~3x faster
#' than using methods based on the cellfeed.
#'
#' @note When you use the listfeed, the Sheets API transforms the variable or
#'   column names like so: 'The column names are the header values of the
#'   worksheet lowercased and with all non-alpha-numeric characters removed. For
#'   example, if the cell A1 contains the value "Time 2 Eat!" the column name
#'   would be "time2eat".' If this is intolerable to you, consume the data via
#'   the cell feed or csv download. Or, at least, consume the first row via the
#'   cell feed and manually restore the variable names post hoc.
#'
#' @param ss a registered Google spreadsheet
#' @param ws positive integer or character string specifying index or title,
#'   respectively, of the worksheet to consume
#'
#' @family data consumption functions
#'
#' @return a tbl_df
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "gap_copy")
#' oceania_lf <- get_via_lf(gap_ss, ws = "Oceania")
#' str(oceania_lf)
#' oceania_lf
#' }
#'
#' @export
get_via_lf <- function(ss, ws = 1) {

  stopifnot(ss %>% inherits("googlesheet"))
  
  this_ws <- get_ws(ss, ws)
  req <- gsheets_GET(this_ws$listfeed)
  row_data <- req$content %>% lfilt("entry")
  component_names <- row_data[[1]] %>% names()
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
  row_data %>%
    ## get just the data, as named character vector
    ## because empty cells emerge from the XML as NULL values
    ## these need to be trapped and converted to NA before unlisting
    ## otherwise the list gets truncated
      ## - subset to variables
	    plyr::llply(function(x) x[var_names] ) %>%
	    ## - replace NULLs 
		  plyr::llply(function(x) {x[sapply(x, is.null)] <- NA; return(x)}) %>%
		  ## - convert to vector
		  plyr::llply(unlist) %>%
      ## rowbind to produce character matrix
      do.call("rbind", .) %>%
      ## drop stupid repetitive "entry" rownames
      `rownames<-`(NULL) %>%
      ## convert to integer, numeric, etc. but w/ stringsAsFactors = FALSE
      plyr::alply(2, type.convert, as.is = TRUE, .dims = TRUE) %>%
      ## get rid of attributes that are non-standard for tbl_dfs or data.frames
      ## and that are an artefact of the above (specifically, I think, the use of
      ## alply?); if I don't do this, the output is fugly when you str() it
      `attr<-`("split_type", NULL) %>%
      `attr<-`("split_labels", NULL) %>%
      `attr<-`("dim", NULL) %>%
      ## for some reason removing the non-standard dim attributes clobbers the
      ## variable names, so those must be restored
      `names<-`(var_names) %>%
      ## convert to data.frame (tbl_df, actually)
      dplyr::as_data_frame()
}

#' Create a data.frame of the non-empty cells in a rectangular region of a
#' worksheet
#'
#' This function consumes data via the cell feed, which, as the name suggests,
#' retrieves data cell by cell. No attempt is made here to shape the returned
#' data, but you can do that with \code{\link{reshape_cf}} and
#' \code{\link{simplify_cf}}). The output data.frame of \code{get_via_cf} will
#' have one row per cell.
#'
#' Use the limits, e.g. min_row or max_col, to delineate the rectangular region
#' of interest. You can specify any subset of the limits or none at all. If
#' limits are provided, validity will be checked as well as internal consistency
#' and compliance with known extent of the worksheet. If no limits are provided,
#' all cells will be returned but realize that \code{\link{get_via_csv}} and
#' \code{\link{get_via_lf}} are much faster ways to consume data from a
#' rectangular worksheet.
#'
#' Empty cells, even if "embedded" in a rectangular region of populated cells,
#' are not normally returned by the cell feed This function won't return them
#' either when \code{return_empty = FALSE} (default), but will if you set
#' \code{return_empty = TRUE}. If you don't specify any limits AND you set
#' \code{return_empty = TRUE}, you could be in for several minutes wait, as the
#' feed will return all cells, which defaults to 1000 rows and 26 columns.
#'
#' @inheritParams get_via_lf
#' @param min_row positive integer, optional
#' @param max_row positive integer, optional
#' @param min_col positive integer, optional
#' @param max_col positive integer, optional
#' @param limits list, with named components holding the min and max for rows
#'   and columns; intended primarily for internal use
#' @param return_empty logical; indicates whether to return empty cells
#' @param return_links logical; indicates whether to return the edit and self
#'   links (used internally in cell editing workflow)
#' @param verbose logical; do you want informative messages?
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "gap_copy")
#' get_via_cf(gap_ss, "Asia", max_row = 4)
#' reshape_cf(get_via_cf(gap_ss, "Asia", max_row = 4))
#' reshape_cf(get_via_cf(gap_ss, "Asia",
#'                       limits = list(max_row = 4, min_col = 3)))
#' }
#' @family data consumption functions
#'
#' @export
get_via_cf <-
  function(ss, ws = 1,
           min_row = NULL, max_row = NULL, min_col = NULL, max_col = NULL,
           limits = NULL, return_empty = FALSE, return_links = FALSE,
           verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))
    
  this_ws <- get_ws(ss, ws, verbose)

  if(is.null(limits)) {
    limits <- list("min-row" = min_row, "max-row" = max_row,
                   "min-col" = min_col, "max-col" = max_col)
  } else{
    names(limits) <- names(limits) %>%
      stringr::str_replace("_", "-")
  }
  limits <- limits %>%
    validate_limits(this_ws$row_extent, this_ws$col_extent)

  query <- limits
  if(return_empty) {
    ## the return-empty parameter is not documented in current sheets API, but
    ## is discussed in older internet threads re: the older gdata API; so if
    ## this stops working, consider that they finally stopped supporting this
    ## query parameter
    query <- query %>% c(list("return-empty" = "true"))
  }
  req <- gsheets_GET(this_ws$cellsfeed, query = query)
  x <- req$content %>%
    lfilt("entry") %>%
    lapply(FUN = function(x) {

      # filled cells: "row" "col" "inputValue" stored in x$cell$.attr
      # empty cells:  "row" "col" "inputValue" stored in x$cell
      # revisit this when/if we switch to xml2 ... these gymnastics may just be
      # an unsavory consequence of our use of XML::xmlToList
      if(is.null(x$cell[["row"]])) { # cell is not empty
        row_num <- x$cell$.attrs["row"]
        col_num <- x$cell$.attrs["col"]
        text <- x$cell$text
      } else { # cell is empty
        row_num <- x$cell["row"]
        col_num <- x$cell["col"]
        text <- x$cell["inputValue"]
      }

      links <- x %>% lfilt("^link$") %>% do.call("rbind", .) %>%
        `rownames<-`(NULL) %>%
        as.data.frame(stringsAsFactors = FALSE)
      # edit link looks like so: "path/R1C1/version"
      edit_link <- links$href[grepl("edit", links$rel)]

      dplyr::data_frame(cell = x$title$text,
                        cell_alt = x$id %>% basename,
                        row = row_num %>% as.integer(),
                        col = col_num %>% as.integer(),
                        cell_text = text,
                        edit_link = edit_link,
                        cell_id = x$id) # full URL to cell to be updated
    }) %>%
    dplyr::bind_rows()

  attr(x, "ws_title") <- this_ws$ws_title

  # the pros outweighed the cons re: setting up a zero row data.frame that, at
  # least, has the correct variables
  if(nrow(x) == 0L) {
    x <- dplyr::data_frame(cell = character(),
                           cell_alt = character(),
                           row = integer(),
                           col = integer(),
                           cell_text = character(),
                           edit_link = character(),
                           cell_id = character())
  }

  if(return_links) {
    x
  } else {
    x %>%
      dplyr::select_(~ -edit_link, ~ -cell_id)
  }
  # see issue #19 about all the places cell data is (mostly redundantly) stored
  # in the XML, such as:
  # content_text = x$content$text,
  # cell_inputValue = x$cell$.attrs["inputValue"],
  # cell_numericValue = x$cell$.attrs["numericValue"],
  # when/if we think about formulas explicitly, we will want to come back and
  # distinguish between inputValue and numericValue
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
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "gap_copy")
#' get_row(gap_ss, "Europe", row = 1)
#' simplify_cf(get_row(gap_ss, "Europe", row = 1))
#' }
#'
#' @export
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
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "gap_copy")
#' get_col(gap_ss, "Oceania", col = 1:2)
#' reshape_cf(get_col(gap_ss, "Oceania", col = 1:2))
#' }
#'
#' @export
get_col <- function(ss, ws = 1, col) {
  get_via_cf(ss, ws, min_col = min(col), max_col = max(col))
}

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
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "gap_copy")
#' get_cells(gap_ss, "Europe", range = "B3:D7")
#' simplify_cf(get_cells(gap_ss, "Europe", range = "A1:F1"))
#' }
#'
#' @export
get_cells <- function(ss, ws = 1, range) {

  limits <- convert_range_to_limit_list(range)
  get_via_cf(ss, ws, limits = limits)
}

#' Reshape cell-level data and convert to data.frame
#'
#' @param x a data.frame returned by \code{get_via_cf()}
#' @param header logical indicating whether first row should be taken as
#'   variable names
#'
#' @family data consumption functions
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "gap_copy")
#' get_via_cf(gap_ss, "Asia", max_row = 4)
#' reshape_cf(get_via_cf(gap_ss, "Asia", max_row = 4))
#' }
#' @export
reshape_cf <- function(x, header = TRUE) {

  limits <- x %>%
    dplyr::summarise_each_(dplyr::funs(min, max), list(~ row, ~ col))
  all_possible_cells <-
    with(limits,
         expand.grid(row = row_min:row_max, col = col_min:col_max))
  suppressMessages(
    x_augmented <- all_possible_cells %>% dplyr::left_join(x)
  )
  ## tidyr::spread(), used below, could do something similar as this join, but
  ## it would handle completely missing rows and columns differently; still
  ## thinking about this

  if(header) {

    if(x_augmented$row %>% dplyr::n_distinct() < 2) {
      message("No data to reshape!")
      if(header) {
        message("Perhaps retry with `header = FALSE`?")
      }
      return(NULL)
    }

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
#' \code{\link{reshape_cf}}, empty cells will NOT necessarily appear in this 
#' result. By default, the API does not transmit data for these cells; 
#' \code{googlesheets} inserts these cells in \code{\link{reshape_cf}} because
#' it is necessary to give the data rectangular shape. In contrast, empty cells
#' will only appear in the output of \code{simplify_cf} if they were already
#' present in the data from the cell feed, i.e. if the original call to 
#' \code{\link{get_via_cf}} had argument \code{return_empty} set to \code{TRUE}.
#' 
#' @inheritParams reshape_cf
#' @param convert logical, indicating whether to attempt to convert the result 
#'   vector from character to something more appropriate, such as logical, 
#'   integer, or numeric; if TRUE, result is passed through \code{type.convert};
#'   if FALSE, result will be character
#' @param as.is logical, passed through to the \code{as.is} argument of 
#'   \code{type.convert}
#' @param notation character; the result vector will have names that reflect 
#'   which cell the data came from; this argument selects the positioning 
#'   notation, i.e. "A1" vs. "R1C1"
#'
#' @return a named vector
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- register_ss(gap_key)
#' get_row(gap_ss, row = 1)
#' simplify_cf(get_row(gap_ss, row = 1))
#' simplify_cf(get_row(gap_ss, row = 1), notation = "R1C1")
#' }
#'
#' @family data consumption functions
#'
#' @export
simplify_cf <- function(x, convert = TRUE, as.is = TRUE,
                        notation = c("A1", "R1C1"), header = NULL) {

  ## TO DO: If the input contains empty cells, maybe this function should have a
  ## way to request that cell entry "" be converted to NA?

  notation <- match.arg(notation)

  if(is.null(header) &&
     x$row %>% min() == 1 &&
     x$col %>% dplyr::n_distinct() == 1) {
    header <-  TRUE
  } else {
    header <- FALSE
  }

  if(header) {
    x <- x %>%
      dplyr::filter_(~ row > min(row))
  }

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
      mess <- sprintf(paste0("A row or column limit must be a single positive",
                             "integer (or not given at all).\nInvalid input:\n",
                             "%s"),
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
