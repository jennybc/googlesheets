#' Add a new worksheet within a spreadsheet
#'
#' Add a new worksheet to an existing spreadsheet. By default, it will [1] have
#' 1000 rows and 26 columns, [2] contain no data, and [3] be titled "Sheet1".
#' Use the \code{ws_title}, \code{row_extent}, \code{col_extent}, and \code{...}
#' arguments to give the worksheet a different title or extent or to populate it
#' with some data. This function calls the
#' \href{https://developers.google.com/drive/v2/reference/}{Google Drive API} to
#' create the worksheet and edit its title or extent. If you provide data for
#' the sheet, then this function also calls the
#' \href{https://developers.google.com/google-apps/spreadsheets/}{Google Sheets
#' API}. The title of the new worksheet can not be the same as any existing
#' worksheet in the sheet.
#'
#' We anticipate that \strong{if} the user wants to control the extent of the
#' new worksheet, it will be by providing input data and specifying `trim =
#' TRUE` (see \code{\link{gs_edit_cells}}) or by specifying \code{row_extent}
#' and \code{col_extent} directly. But not both ... although we won't stop you.
#' In that case, note that explicit worksheet sizing occurs before data
#' insertion. If data insertion triggers any worksheet resizing, that will
#' override any usage of \code{row_extent} or \code{col_extent}.
#'
#' @template ss
#' @inheritParams gs_new
#' @template verbose
#'
#' @template return-googlesheet
#'
#' @examples
#' \dontrun{
#' # get a copy of the Gapminder spreadsheet
#' gap_ss <- gs_copy(gs_gap(), to = "Gapminder_copy")
#' gap_ss <- gs_ws_new(gap_ss)
#' gap_ss <- gs_ws_delete(gap_ss, ws = "Sheet1")
#' gap_ss <-
#'   gs_ws_new(gap_ss, ws_title = "Atlantis", input = head(iris), trim = TRUE)
#' gap_ss
#' gs_delete(gap_ss)
#' }
#'
#' @export
gs_ws_new <- function(ss, ws_title = "Sheet1",
                      row_extent = 1000, col_extent = 26, ..., verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  ws_title_exist <- ws_title %in% gs_ws_ls(ss)

  if(ws_title_exist) {
    spf(paste("A worksheet titled \"%s\" already exists, please",
              "choose a different name."), ws_title)
  }

  the_body <-
    XML::xmlNode("entry",
                 namespaceDefinitions =
                   c("http://www.w3.org/2005/Atom",
                     gs = "http://schemas.google.com/spreadsheets/2006"),
                 XML::xmlNode("title", ws_title),
                 XML::xmlNode("gs:rowCount", row_extent),
                 XML::xmlNode("gs:colCount", col_extent))

  the_body <- XML::toString.XMLNode(the_body)

  req <- httr::POST(
    ss$ws_feed,
    google_token(),
    httr::add_headers("Content-Type" = "application/atom+xml"),
    body = the_body
  ) %>%
    httr::stop_for_status()

  ss <- req$url %>%
    extract_key_from_url() %>%
    gs_key(verbose = FALSE)

  ws_title_exist <- ws_title %in% gs_ws_ls(ss)

  if (ws_title_exist) {
    this_ws <- ss %>% gs_ws(ws_title, verbose = FALSE)
    if(verbose) {
      mpf("Worksheet \"%s\" added to sheet \"%s\".",
          this_ws$ws_title, ss$sheet_title)
    }
  } else {
    mpf(paste("Cannot verify whether worksheet \"%s\" was added",
              "to sheet \"%s\"."), ws_title, ss$sheet_title)
    return(invisible(NULL))
  }

  dotdotdot <- list(...)
  if (length(dotdotdot)) {
    gs_edit_cells_arg_list <-
      c(list(ss = ss), list(ws = this_ws$ws_title),
        dotdotdot, list(verbose = verbose))
    ss <- do.call(gs_edit_cells, gs_edit_cells_arg_list)
  }

  if (verbose) {
    this_ws <- ss %>% gs_ws(ws_title, verbose = FALSE)
    mpf("Worksheet dimensions: %d x %d.",
        this_ws$row_extent, this_ws$col_extent)
  }

  invisible(ss)

}

#' Delete a worksheet from a spreadsheet
#'
#' The worksheet and all of its contents will be removed from the spreadsheet.
#'
#' @template ss
#' @template ws
#' @template verbose
#'
#' @template return-googlesheet
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_copy(gs_gap(), to = "gap_copy")
#' gs_ws_ls(gap_ss)
#' gap_ss <- gs_ws_new(gap_ss, "new_stuff")
#' gap_ss <- gs_edit_cells(gap_ss, "new_stuff", input = head(iris), trim = TRUE)
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

  req <- httr::DELETE(this_ws$ws_id, google_token()) %>%
    httr::stop_for_status()

  ss_refresh <- ss$sheet_key %>% gs_key(verbose = FALSE)

  ws_title_exist <- this_ws$ws_title %in% gs_ws_ls(ss_refresh)

  if(verbose) {
    if(ws_title_exist) {
      mpf(paste("Cannot verify whether worksheet \"%s\" was",
                "deleted from sheet \"%s\"."),
          this_ws$ws_title, ss_refresh$sheet_title)
    } else {
      mpf("Worksheet \"%s\" deleted from sheet \"%s\".",
          this_ws$ws_title, ss$sheet_title)
    }
  }

  if(ws_title_exist) {
    NULL
  } else {
    ss_refresh %>% invisible()
  }

}

#' Rename a worksheet within a spreadsheet
#'
#' Give a worksheet a new title that does not duplicate the title of any
#' existing worksheet within the spreadsheet.
#'
#' @template ss
#' @template ws_from
#' @param to character string for new title of worksheet
#' @template verbose
#'
#' @template return-googlesheet
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
      mpf("Worksheet \"%s\" renamed to \"%s\".", from_title, to)
    } else {
      mpf(paste("Cannot verify whether worksheet \"%s\" was",
                "renamed to \"%s\"."), from_title, to)
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
#' @template ss
#' @template ws
#' @template row_extent
#' @template col_extent
#' @template verbose
#'
#' @note Setting rows and columns to less than the current worksheet dimensions
#'   will delete contents without warning!
#'
#' @examples
#' \dontrun{
#' yo <- gs_new("yo")
#' yo <- gs_edit_cells(yo, input = head(iris), trim = TRUE)
#' gs_read_csv(yo)
#' yo <- gs_ws_resize(yo, ws = "Sheet1", row_extent = 5, col_extent = 4)
#' gs_read_csv(yo)
#' yo <- gs_ws_resize(yo, ws = 1, row_extent = 3, col_extent = 3)
#' gs_read_csv(yo)
#' yo <- gs_ws_resize(yo, row_extent = 2, col_extent = 2)
#' gs_read_csv(yo)
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
    mpf("Worksheet \"%s\" dimensions changed to %d x %d.",
        this_ws$ws_title, new_row_extent, new_col_extent)
  }

  ss_refresh %>%
    invisible()

}

#' Modify a worksheet's title or size
#'
#' @template ss
#' @template ws_from
#' @param to character string for new title of worksheet
#' @param new_dim list of length 2 specifying the row and column extent of the
#'   worksheet
#' @template verbose
#'
#' @template return-googlesheet
#'
#' @keywords internal
gs_ws_modify <- function(ss, from = NULL, to = NULL,
                         new_dim = NULL, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  this_ws <- ss %>% gs_ws(from, verbose = FALSE)

  req <- httr::GET(this_ws$ws_id, google_token()) %>%
    httr::stop_for_status()
  stop_for_content_type(req, expected = "application/atom+xml; charset=UTF-8")
  ## yes, that's right
  ## the content MUST be xml but I'm about to parse it as text
  ## this nuttiness will go away when we can use xml2 to write xml
  ## below I edit the xml using regex to avoid XML package pain
  the_body <- req %>% httr::content(as = "text", encoding = "UTF-8")

  if (!is.null(to)) { # rename a worksheet

    stopifnot(is.character(to), length(to) == 1L)

    if (to %in% gs_ws_ls(ss)) {
      spf(paste("A worksheet titled \"%s\" already exists in sheet",
                "\"%s\".\nPlease choose another worksheet title."),
          to, ss$sheet_title)
    }

    ## TO DO: we should probably be doing something more XML-y here, instead
    ## of doing XML --> string --> regex based subsitution --> XML
    title_replacement <- paste0("\\1", to, "\\3")
    the_body <-
      sub("(<title type=\'text\'>)(.*)(</title>)", title_replacement, the_body)
  }

  if (!is.null(new_dim)) { # resize a worksheet

    stopifnot(is.numeric(new_dim),
              identical(names(new_dim), c("row_extent", "col_extent")))

    row_replacement <- paste0("\\1", new_dim["row_extent"], "\\3")
    col_replacement <- paste0("\\1", new_dim["col_extent"], "\\3")

    the_body <- the_body %>%
      sub("(<gs:rowCount>)(.*)(</gs:rowCount>)", row_replacement, .) %>%
      sub("(<gs:colCount>)(.*)(</gs:colCount>)", col_replacement, .)
  }

  req <-
    httr::PUT(this_ws$edit,
              google_token(),
              httr::add_headers("Content-Type" = "application/atom+xml"),
              body = the_body) %>%
    httr::stop_for_status()

  req$url %>%
    extract_key_from_url() %>%
    gs_key(verbose = verbose)

}

#' Retrieve a worksheet-describing list from a \code{googlesheet}
#'
#' From a \code{\link{googlesheet}}, retrieve a list (actually a row of a
#' data.frame) giving everything we know about a specific worksheet.
#'
#' @template ss
#' @template ws
#' @template verbose
#'
#' @keywords internal
gs_ws <- function(ss, ws, verbose = TRUE) {

  stopifnot(inherits(ss, "googlesheet"),
            length(ws) == 1L,
            is.character(ws) || (is.numeric(ws) && ws > 0))

  if(is.character(ws)) {
    index <- match(ws, ss$ws$ws_title)
    if(is.na(index)) {
      spf("Worksheet %s not found.", ws)
    } else {
      ws <- index
    }
  }
  ws <- ws %>% as.integer()
  if(ws > ss$n_ws) {
    spf("Spreadsheet only contains %d worksheets.", ss$n_ws)
  }
  if(verbose) {
    mpf("Accessing worksheet titled '%s'.", ss$ws$ws_title[ws])
  }
  ss$ws[ws, ]
}

#' List the worksheets in a spreadsheet
#'
#' Retrieve the titles of all the worksheets in a \code{\link{googlesheet}}.
#'
#' @template ss
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
