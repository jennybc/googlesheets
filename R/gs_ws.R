#' Add a new worksheet to spreadsheet
#'
#' Add a new (empty) worksheet to spreadsheet: specify title and worksheet
#' extent (number of rows and columns). The title of the new worksheet can not
#' be the same as any existing worksheets in the sheet.
#'
#' @param ss a \code{\link{googlesheet}} object, i.e. a registered Google
#'   sheet
#' @param ws_title character string for title of new worksheet
#' @param nrow number of rows (default is 1000)
#' @param ncol number of columns (default is 26)
#' @param verbose logical; do you want informative message?
#'
#' @return a \code{\link{googlesheet}} object
#'
#' @examples
#' \dontrun{
#' # get a copy of the Gapminder spreadsheet
#' gap_ss <- gs_copy(gs_gap(), to = "Gapminder_copy")
#' gap_ss <- gs_ws_new(gap_ss, ws_title = "Atlantis")
#' gap_ss
#' gs_delete(gap_ss)
#' }
#'
#' @export
gs_ws_new <- function(ss, ws_title = "Sheet1",
                      nrow = 1000, ncol = 26, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  ws_title_exist <- ws_title %in% gs_ws_ls(ss)

  if(ws_title_exist) {
    stop(sprintf(paste("A worksheet titled \"%s\" already exists, please",
                       "choose a different name."), ws_title))
  }

  the_body <-
    XML::xmlNode("entry",
                 namespaceDefinitions =
                   c("http://www.w3.org/2005/Atom",
                     gs = "http://schemas.google.com/spreadsheets/2006"),
                 XML::xmlNode("title", ws_title),
                 XML::xmlNode("gs:rowCount", nrow),
                 XML::xmlNode("gs:colCount", ncol))

  the_body <- XML::toString.XMLNode(the_body)

  req <- gsheets_POST(ss$ws_feed, the_body)

  ss_refresh <- ss$sheet_key %>% gs_key(verbose = FALSE)

  ws_title_exist <- ws_title %in% gs_ws_ls(ss_refresh)

  if(verbose) {
    if(ws_title_exist) {
      message(sprintf("Worksheet \"%s\" added to sheet \"%s\".",
                      ws_title, ss_refresh$sheet_title))
    } else {
      message(sprintf(paste("Cannot verify whether worksheet \"%s\" was added",
                            "to sheet \"%s\"."), ws_title,
                      ss_refresh$sheet_title))
    }
  }

  if(ws_title_exist) {
    ss_refresh %>% invisible()
  } else {
    NULL
  }

}

#' Delete a worksheet from a spreadsheet
#'
#' The worksheet and all of its contents will be removed from the spreadsheet.
#'
#' @inheritParams get_via_lf
#' @param verbose logical; do you want informative message?
#'
#' @return a \code{\link{googlesheet}} object
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_copy(gs_gap(), to = "gap_copy")
#' gs_ws_ls(gap_ss)
#' gap_ss <- gs_ws_new(gap_ss, "new_stuff")
#' gap_ss <- edit_cells(gap_ss, "new_stuff", input = head(iris), header = TRUE,
#'                      trim = TRUE)
#' gap_ss
#' gap_ss <- gs_ws_delete(gap_ss, "new_stuff")
#' gs_ws_ls(gap_ss)
#' gap_ss <- gs_ws_delete(gap_ss, ws = 3)
#' gs_ws_ls(gap_ss)
#' gs_delete(gap_ss)
#' }
#'
#' @export
gs_ws_delete <- function(ss, ws = 1, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  this_ws <- ss %>% gs_ws(ws)

  req <- gsheets_DELETE(this_ws$ws_id)

  ss_refresh <- ss$sheet_key %>% gs_key(verbose = FALSE)

  ws_title_exist <- this_ws$ws_title %in% gs_ws_ls(ss_refresh)

  if(verbose) {
    if(ws_title_exist) {
      message(sprintf(paste("Cannot verify whether worksheet \"%s\" was",
                            "deleted from sheet \"%s\"."),
                      this_ws$ws_title, ss_refresh$sheet_title))
    } else {
      message(sprintf("Worksheet \"%s\" deleted from sheet \"%s\".",
                      this_ws$ws_title, ss$sheet_title))
    }
  }

  if(ws_title_exist) {
    NULL
  } else {
    ss_refresh %>% invisible()
  }

}

#' Rename a worksheet
#'
#' Give a worksheet a new title that does not duplicate the title of any
#' existing worksheet within the spreadsheet.
#'
#' @param ss a \code{\link{googlesheet}} object, i.e. a registered Google
#'   sheet
#' @param from positive integer or character string specifying index or title,
#' respectively, of the worksheet
#' @param to character string for new title of worksheet
#' @param verbose logical; do you want informative message?
#'
#' @return a \code{\link{googlesheet}} object
#'
#' @note Since the edit link is used in the PUT request, the version path in the
#'   url changes everytime changes are made to the worksheet, hence consecutive
#'   function calls using the same edit link from the same sheet object without
#'   'refreshing' it by re-registering results in a HTTP 409 Conflict.
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_copy(gs_gap(), to = "gap_copy")
#' gs_ws_ls(gap_ss)
#' gap_ss <- gs_ws_rename(gap_ss, from = "Oceania", to = "ANZ")
#' gs_ws_ls(gap_ss)
#' gap_ss <- gs_ws_rename(gap_ss, from = 1, to = "I am the first sheet!")
#' gs_ws_ls(gap_ss)
#' gs_delete(gap_ss)
#' }
#'
#' @export
gs_ws_rename <- function(ss, from = 1, to, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"),
            from %>% is.numeric() || from %>% is.character(),
            length(from) == 1L,
            to %>% is.character(),
            length(to) == 1L)

  this_ws <- ss %>% gs_ws(from, verbose)
  from_title <- this_ws$ws_title

  ss_refresh <- gs_ws_modify(ss, from = from, to = to, verbose = verbose)

  from_is_gone <- !(from_title %in% gs_ws_ls(ss_refresh))
  to_is_there <- to %in% gs_ws_ls(ss_refresh)

  if(verbose) {
    if(from_is_gone && to_is_there) {
      message(sprintf("Worksheet \"%s\" renamed to \"%s\".", from_title, to))
    } else {
      message(sprintf(paste("Cannot verify whether worksheet \"%s\" was",
                            "renamed to \"%s\"."), from_title, to))
    }
  }

  ss_refresh %>% invisible()

}

#' Resize a worksheet
#'
#' Set the number of rows and columns of a worksheet. We use this function
#' internally during cell updates, if the data would exceed the current
#' worksheet extent, and to trim worksheet down to fit the data exactly. Is it
#' possible a user might want to use this directly?
#'
#' @inheritParams get_via_lf
#' @param row_extent integer for new row extent
#' @param col_extent integer for new column extent
#' @param verbose logical; do you want informative message?
#'
#' @note Setting rows and columns to less than the current worksheet dimensions
#'   will delete contents without warning!
#'
#' @examples
#' \dontrun{
#' yo <- gs_new("yo")
#' yo <- edit_cells(yo, input = head(iris), header = TRUE, trim = TRUE)
#' get_via_csv(yo)
#' yo <- gs_ws_resize(yo, ws = "Sheet1", row_extent = 5, col_extent = 4)
#' get_via_csv(yo)
#' yo <- gs_ws_resize(yo, ws = 1, row_extent = 3, col_extent = 3)
#' get_via_csv(yo)
#' yo <- gs_ws_resize(yo, row_extent = 2, col_extent = 2)
#' get_via_csv(yo)
#' gs_delete(yo)
#' }
#'
#' @keywords internal
gs_ws_resize <- function(ss, ws = 1,
                         row_extent = NULL, col_extent = NULL, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"),
            ws %>% is.numeric() || ws %>% is.character(),
            length(ws) == 1L)

  this_ws <- ss %>% gs_ws(ws, verbose)

  # if row or col extent not specified, make it the same as before
  if(is.null(row_extent)) {
    row_extent <- this_ws$row_extent
  }
  if(is.null(col_extent)) {
    col_extent <- this_ws$col_extent
  }

  stopifnot(row_extent %>% is.numeric(), length(row_extent) == 1L,
            col_extent %>% is.numeric(), length(col_extent) == 1L)

  ss_refresh <-
    gs_ws_modify(ss, ws,
                 new_dim = c(row_extent = row_extent, col_extent = col_extent),
                 verbose = verbose)
  this_ws <- ss_refresh  %>% gs_ws(ws, verbose)

  new_row_extent <- this_ws$row_extent %>% as.integer()
  new_col_extent <- this_ws$col_extent %>% as.integer()

  success <- all.equal(c(new_row_extent, new_col_extent),
                       c(row_extent, col_extent))

  if(verbose && success) {
    message(sprintf("Worksheet \"%s\" dimensions changed to %d x %d.",
                    this_ws$ws_title, new_row_extent, new_col_extent))
  }

  ss_refresh %>%
    invisible()

}

#' Modify a worksheet's title or size
#'
#' @inheritParams get_via_lf

#' @param ss a \code{\link{googlesheet}} object, i.e. a registered Google
#'   sheet
#' @param from positive integer or character string specifying index or title,
#' respectively, of the worksheet
#' @param to character string for new title of worksheet
#' @param new_dim list of length 2 specifying the row and column extent of the
#'   worksheet
#'
#' @return a \code{\link{googlesheet}} object
#'
#' @keywords internal
gs_ws_modify <- function(ss, from = NULL, to = NULL,
                         new_dim = NULL, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  this_ws <- ss %>% gs_ws(from, verbose = FALSE)

  req <- gsheets_GET(this_ws$ws_id, to_xml = FALSE)
  the_body <- req %>% httr::content(as = "text", encoding = "UTF-8")

  if(!is.null(to)) { # rename a worksheet

    stopifnot(to %>% is.character(), length(to) == 1L)

    if(to %in% gs_ws_ls(ss)) {
      stop(sprintf(paste("A worksheet titled \"%s\" already exists in sheet",
                         "\"%s\". Please choose another worksheet title."),
                   to, ss$sheet_title))
    }

    ## TO DO: we should probably be doing something more XML-y here, instead
    ## of doing XML --> string --> regex based subsitution --> XML
    title_replacement <- paste0("\\1", to, "\\3")
    the_body <- the_body %>%
      sub("(<title type=\'text\'>)(.*)(</title>)", title_replacement, .)
  }

  if(!is.null(new_dim)) { # resize a worksheet

    stopifnot(new_dim %>% is.numeric(),
              identical(new_dim %>% names(), c("row_extent", "col_extent")))

    row_replacement <- paste0("\\1", new_dim["row_extent"], "\\3")
    col_replacement <- paste0("\\1", new_dim["col_extent"], "\\3")

    the_body <- the_body %>%
      sub("(<gs:rowCount>)(.*)(</gs:rowCount>)", row_replacement, .) %>%
      sub("(<gs:colCount>)(.*)(</gs:colCount>)", col_replacement, .)
  }

  req <- gsheets_PUT(this_ws$edit, the_body)
  ## TO DO (?): inspect req
  req$url %>%
    extract_key_from_url() %>%
    gs_key(verbose = verbose)

}

#' Retrieve a worksheet-describing list from a googlesheet
#'
#' From a \code{\link{googlesheet}}, retrieve a list (actually a row of a
#' data.frame) giving everything we know about a specific worksheet.
#'
#' @inheritParams get_via_lf
#' @param verbose logical, indicating whether to give a message re: title of the
#'   worksheet being accessed
#'
#' @keywords internal
gs_ws <- function(ss, ws, verbose = TRUE) {

  stopifnot(inherits(ss, "googlesheet"),
            length(ws) == 1L,
            is.character(ws) || (is.numeric(ws) && ws > 0))

  if(is.character(ws)) {
    index <- match(ws, ss$ws$ws_title)
    if(is.na(index)) {
      stop(sprintf("Worksheet %s not found.", ws))
    } else {
      ws <- index
    }
  }
  ws <- ws %>% as.integer()
  if(ws > ss$n_ws) {
    stop(sprintf("Spreadsheet only contains %d worksheets.", ss$n_ws))
  }
  if(verbose) {
    message(sprintf("Accessing worksheet titled \"%s\"", ss$ws$ws_title[ws]))
  }
  ss$ws[ws, ]
}

#' List the worksheets in a Google Sheet
#'
#' Retrieve the titles of all the worksheets in a \code{\link{googlesheet}}.
#'
#' @inheritParams get_via_lf
#'
#' @examples
#' \dontrun{
#' gs_ws_ls(gs_gap())
#' }
#' @export
gs_ws_ls <- function(ss) {

  stopifnot(inherits(ss, "googlesheet"))

  ss$ws$ws_title
}
