## TO DO: gs_gs

#' Register a Google Sheet
#'
#' The \code{googlesheets} package must gather information on a Google Sheet
#' from \href{https://developers.google.com/google-apps/spreadsheets/}{the API}
#' prior to any requests to read or write data. We call this
#' \strong{registering} the sheet and store the result in a \code{googlesheet}
#' object. Note this object does not contain any sheet data, but rather contains
#' metadata about the sheet. We populate a \code{googlesheet}
#' object with information from the
#' \href{https://developers.google.com/google-apps/spreadsheets/#working_with_worksheets}{worksheets
#' feed} and, if available, also from the
#' \href{https://developers.google.com/google-apps/spreadsheets/#retrieving_a_list_of_spreadsheets}{spreadsheets
#' feed}. Choose from the functions below depending on the type of
#' sheet-identifying input you will provide. Is it a sheet title, key,
#' browser URL, or worksheets feed (another URL, mostly used internally)?
#'
#' A registered \code{googlesheet} will contain information on:
#'
#' \itemize{
#'   \item \code{sheet_key} the key of the spreadsheet
#'   \item \code{sheet_title} the title of the spreadsheet
#'   \item \code{n_ws} the number of worksheets contained in the spreadsheet
#'   \item \code{ws_feed} the "worksheets feed" of the spreadsheet
#'   \item \code{updated} the time of last update (at time of registration)
#'   \item \code{reg_date} the time of registration
#'   \item \code{visibility} visibility of spreadsheet (Google's confusing
#'     vocabulary); actually, does not describe a property of spreadsheet
#'     itself but rather whether requests will be made with or without
#'     authentication
#'   \item \code{is_public} logical indicating visibility is "public" (meaning
#'     unauthenticated requests will be sent), as opposed to "private" (meaning
#'     authenticated requests will be sent)
#'   \item \code{author} the name of the owner
#'   \item \code{email} the email of the owner
#'   \item \code{links} data.frame of links specific to the spreadsheet
#'   \item \code{ws} a data.frame about the worksheets contained in the
#'   spreadsheet
#' }
#'
#' A \code{googlesheet} object will contain this information from the
#' spreadsheets feed if it was available at the time of registration:
#'
#' \itemize{
#'   \item \code{alt_key} alternate key; applies only to "old" sheets
#' }
#'
#' Since the spreadsheets feed contains private user data, \code{googlesheets}
#' must use authentication to access it. So a \code{googlesheet} object will
#' only contain info from the spreadsheets feed if \code{lookup = TRUE}, which
#' directs us to look up sheet-identifying information in the spreadsheets feed.
#'
#' @name googlesheet
#'
#' @param x sheet-identifying information; a character vector of length one
#'   holding sheet title, key, browser URL or worksheets feed
#' @param lookup logical, optional. Controls whether \code{googlesheets} will
#'   place authenticated API requests during registration. If unspecified, will
#'   be set to \code{TRUE} if authentication has previously been used in this R
#'   session or if working directory contains a file named \code{.httr-oauth}.
#' @template visibility
#' @template verbose
#'
#' @return a \code{googlesheet} object
#'
#' @export
gs_title <- function(x, verbose = TRUE) {

  stopifnot(length(x) == 1L, is.character(x))

  ssf <- x %>%
    gs_lookup("sheet_title", verbose)

  x <- structure(ssf$ws_feed, class = "ws_feed")
  x %>%
    as.googlesheet(ssf, verbose)

}

#' @rdname googlesheet
#' @export
gs_key <- function(x, lookup = NULL, visibility = NULL, verbose = TRUE) {

  stopifnot(length(x) == 1L, is.character(x))

  lookup <- set_lookup(lookup, verbose)
  visibility <- set_visibility(visibility, lookup)

  if(lookup) {
    ssf <- x %>%
      gs_lookup("sheet_key", verbose)
    x <- ssf$ws_feed
  } else {
    x <- x %>% construct_ws_feed_from_key(visibility)
    if(verbose) {
      sprintf("Worksheets feed constructed with %s visibility", visibility) %>%
        message()
    }
    ssf <- NULL
  }

  x <- structure(x, class = "ws_feed")
  x %>%
    as.googlesheet(ssf, verbose)

}

#' @rdname googlesheet
#' @export
gs_url <- function(x, lookup = NULL, visibility = NULL, verbose = TRUE) {

  stopifnot(length(x) == 1L, is.character(x),
            stringr::str_detect(x, "^https://"))

  lookup <- set_lookup(lookup, verbose)
  visibility <- set_visibility(visibility, lookup)

  if(verbose) {
    paste0("Sheet-identifying info appears to be a browser URL.\n",
           "googlesheets will attempt to extract sheet key from the URL.") %>%
      message()
  }

  x <- extract_key_from_url(x)
  if(verbose) {
    sprintf("Putative key: %s", x) %>% message()
  }

  x %>%
    gs_key(lookup, visibility, verbose)

}

#' @rdname googlesheet
#' @export
gs_ws_feed <- function(x, lookup = NULL, verbose = TRUE) {

  ws_feed_regex <- "https://spreadsheets.google.com/feeds/worksheets"
  stopifnot(length(x) == 1L, is.character(x),
            stringr::str_detect(x, ws_feed_regex))

  lookup <- set_lookup(lookup, verbose)

  if(lookup) {
    ssf <- x %>%
      gs_lookup("ws_feed", verbose)
  } else {
    ssf <- NULL
  }

  x <- structure(x, class = "ws_feed")
  x %>%
    as.googlesheet(ssf, verbose)

}

## TO DO: decide how to handle googlesheets as input
# as.googlesheet.googlesheet <- function(x, ssf = NULL, verbose = TRUE, ...) {
#
#   x <- structure(x$ws_feed, class = "ws_feed")
#   x %>%
#     as.googlesheet()
#
# }

set_lookup <- function(lookup = NULL, verbose = TRUE) {

  if(is.null(lookup)) {
    lookup <- !is.null(.state$token) || file.exists(".httr-oauth")
  } else {
    stopifnot(is.logical(lookup))
  }
  if(verbose) {
    sprintf("Authentication will %sbe used.", if(lookup) "" else "not ") %>%
      message()
  }

  lookup

}

set_visibility <- function(visibility = NULL, lookup = TRUE) {

  if(is.null(visibility)) {
    if(lookup) {
      visibility <- "private"
    } else {
      visibility <- "public"
    }
  } else {
    stopifnot(visibility %in% c("public", "private"))
  }

  visibility

}

## for internal use only x = character holding title | key | ws_feed
##
## x will be sought in the variable named 'lvar' in the tbl_df returned by
## gs_ls(), which wraps the spreadsheets feed
##
## return value = return of gs_ls() limited to the row where x matched
gs_lookup <- function(x, lvar = "sheet_title", verbose = TRUE) {

  ssf <- gs_ls()

  i <- which(ssf[[lvar]] == x)

  if(length(i) < 1) {
    mess <-
      sprintf(paste("\"%s\" doesn't match %s of any sheet returned by gs_ls()",
                    "(which should reflect user's Google Sheets home screen)."),
              x, lvar)
    stop(mess)
  } else if(length(i) > 1) {
    mess <-
      sprintf(paste("\"%s\" matches %s for multiple sheets returned by gs_ls()",
                    "(which should reflect user's Google Sheets home screen).",
                    "Suggest you identify this sheet by unique key instead."),
              x, lvar)
    stop(mess)
  }

  if(verbose) {
    sprintf("Sheet successfully identifed: \"%s\"", ssf$sheet_title[i]) %>%
      message()
  }

  ssf[i, ]

}
