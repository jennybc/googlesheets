#' Add a new (empty) worksheet to spreadsheet
#'
#' Add a new (empty) worksheet to spreadsheet: specify title and worksheet
#' extent (number of rows and columns). The title of the new worksheet can not
#' be the same as any existing worksheets in the sheet.
#'
#' @param ss a registered Google sheet
#' @param ws_title character string for title of new worksheet
#' @param nrow number of rows (default is 1000)
#' @param ncol number of columns (default is 26)
#' @param verbose logical; do you want informative message?
#'
#' @return a googlesheet object, resulting from re-registering the host
#'   spreadsheet after adding the new worksheet
#'
#' @examples
#' \dontrun{
#' # get a copy of the Gapminder spreadsheet
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- gs_copy(gs_key(gap_key), to = "Gapminder_copy")
#' gap_ss <- add_ws(gap_ss, ws_title = "Atlantis")
#' gap_ss
#' }
#'
#' @export
add_ws <- function(ss, ws_title = "Sheet1",
                   nrow = 1000, ncol = 26, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  ws_title_exist <- ws_title %in% list_ws(ss)

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

  ws_title_exist <- ws_title %in% list_ws(ss_refresh)

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
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- gap_key %>%
#'   gs_key() %>%
#'   gs_copy(to = "gap_copy")
#' # non-pipe equivalent: gap_ss <- gs_copy(gs_key(gap_key), to = "gap_copy")
#' list_ws(gap_ss)
#' gap_ss <- add_ws(gap_ss, "new_stuff")
#' gap_ss <- edit_cells(gap_ss, "new_stuff", input = head(iris), header = TRUE,
#'                      trim = TRUE)
#' gap_ss
#' gap_ss <- delete_ws(gap_ss, "new_stuff")
#' list_ws(gap_ss)
#' gap_ss <- delete_ws(gap_ss, ws = 3)
#' list_ws(gap_ss)
#' gs_delete(gap_ss)
#' }
#'
#' @export
delete_ws <- function(ss, ws = 1, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  this_ws <- ss %>% get_ws(ws)

  req <- gsheets_DELETE(this_ws$ws_id)

  ss_refresh <- ss$sheet_key %>% gs_key(verbose = FALSE)

  ws_title_exist <- this_ws$ws_title %in% list_ws(ss_refresh)

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
#' @param ss a registered Google sheet
#' @param from positive integer or character string specifying index or title,
#' respectively, of the worksheet
#' @param to character string for new title of worksheet
#' @param verbose logical; do you want informative message?
#'
#' @note Since the edit link is used in the PUT request, the version path in the
#'   url changes everytime changes are made to the worksheet, hence consecutive
#'   function calls using the same edit link from the same sheet object without
#'   'refreshing' it by re-registering results in a HTTP 409 Conflict.
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- gs_copy(gs_key(gap_key), to = "gap_copy")
#' list_ws(gap_ss)
#' gap_ss <- rename_ws(gap_ss, from = "Oceania", to = "ANZ")
#' list_ws(gap_ss)
#' gap_ss <- rename_ws(gap_ss, from = 1, to = "I am the first sheet!")
#' list_ws(gap_ss)
#' gs_delete(gap_ss)
#' }
#'
#' @export
rename_ws <- function(ss, from = 1, to, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  this_ws <- ss %>% get_ws(from)
  from_title <- this_ws$ws_title

  req <- modify_ws(ss, from = from, to = to)
  ## req carries updated info about the affected worksheet ... but I find it
  ## easier to just re-register the spreadsheet

  Sys.sleep(1)
  ss_refresh <- ss$sheet_key %>% gs_key(verbose = FALSE)

  from_is_gone <- !(from_title %in% list_ws(ss_refresh))
  to_is_there <- to %in% list_ws(ss_refresh)

  if(verbose) {
    if(from_is_gone && to_is_there) {
      message(sprintf("Worksheet \"%s\" renamed to \"%s\".", from_title, to))
    } else {
      message(sprintf(paste("Cannot verify whether worksheet \"%s\" was",
                            "renamed to \"%s\"."), from_title, to))
    }
  }

  if(from_is_gone && to_is_there) {
    ss_refresh %>% invisible()
  } else {
    NULL
  }

}

#' Resize a worksheet
#'
#' Set the number of rows and columns of a worksheet. We use this function
#' internally during cell updates, if the data would exceed the current
#' worksheet extent. It is possible a user might want to use this directly?
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
#' yo <- resize_ws(yo, ws = "Sheet1", row_extent = 5, col_extent = 4)
#' get_via_csv(yo)
#' yo <- resize_ws(yo, ws = 1, row_extent = 3, col_extent = 3)
#' get_via_csv(yo)
#' yo <- resize_ws(yo, row_extent = 2, col_extent = 2)
#' get_via_csv(yo)
#' gs_delete(yo)
#' }
#'
#' @keywords internal
resize_ws <- function(ss, ws = 1,
                      row_extent = NULL, col_extent = NULL, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  this_ws <- ss %>% get_ws(ws, verbose)

  # if row or col extent not specified, make it the same as before
  if(is.null(row_extent)) {
    row_extent <- this_ws$row_extent
  }
  if(is.null(col_extent)) {
    col_extent <- this_ws$col_extent
  }

  req <-
    modify_ws(ss, ws,
              new_dim = c(row_extent = row_extent, col_extent = col_extent))

  new_row_extent <- req$content$rowCount %>% as.integer()
  new_col_extent <- req$content$colCount %>% as.integer()

  success <- all.equal(c(new_row_extent, new_col_extent),
                       c(row_extent, col_extent))

  if(verbose && success) {
    message(sprintf("Worksheet \"%s\" dimensions changed to %d x %d.",
                    this_ws$ws_title, new_row_extent, new_col_extent))
  }

  if(success) {
    ss$sheet_key %>%
      gs_key(verbose = FALSE) %>%
      invisible()
  } else{
    NULL
  }
}

#' Modify a worksheet's title or size
#'
#' @inheritParams get_via_lf

#' @param ss a registered Google sheet
#' @param from positive integer or character string specifying index or title,
#' respectively, of the worksheet
#' @param to character string for new title of worksheet
#' @param new_dim list of length 2 specifying the row and column extent of the
#'   worksheet
#'
#' @keywords internal
modify_ws <- function(ss, from, to = NULL, new_dim = NULL) {

    stopifnot(ss %>% inherits("googlesheet"))

    this_ws <- ss %>% get_ws(from, verbose = FALSE)

    req <- gsheets_GET(this_ws$ws_id, to_xml = FALSE)
    contents <- req$content

    if(!is.null(to)) { # our purpose is to rename a worksheet

      if(to %in% list_ws(ss)) {
        stop(sprintf(paste("A worksheet titled \"%s\" already exists in sheet",
                           "\"%s\". Please choose another worksheet title."),
                     to, ss$sheet_title))
      }

      ## TO DO: we should probably be doing something more XML-y here, instead
      ## of doing XML --> string --> regex based subsitution --> XML
      title_replacement <- paste0("\\1", to, "\\3")
      the_body <- contents %>%
        sub("(<title type=\'text\'>)(.*)(</title>)", title_replacement, .)
    }

    if(!is.null(new_dim)) { # our purpose is to resize a worksheet

      row_replacement <- paste0("\\1", new_dim["row_extent"], "\\3")
      col_replacement <- paste0("\\1", new_dim["col_extent"], "\\3")

      the_body <- contents %>%
        sub("(<gs:rowCount>)(.*)(</gs:rowCount>)", row_replacement, .) %>%
        sub("(<gs:colCount>)(.*)(</gs:colCount>)", col_replacement, .)
    }

  gsheets_PUT(this_ws$edit, the_body)

}

