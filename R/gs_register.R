#' Register a Google Sheet
#'
#' The \code{googlesheets} package must gather information on a Google Sheet
#' from \href{https://developers.google.com/google-apps/spreadsheets/}{the API}
#' prior to any requests to read or write data. We call this
#' \strong{registering} the sheet and store the result in a \code{googlesheet}
#' object. Note this object does not contain any sheet data, but rather contains
#' metadata about the sheet. We populate a \code{googlesheet}
#' object with information from the
#' \href{https://developers.google.com/google-apps/spreadsheets/worksheets}{worksheets
#' feed} and, if available, also from the
#' \href{https://developers.google.com/google-apps/spreadsheets/worksheets#retrieve_a_list_of_spreadsheets}{spreadsheets
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
#'     authorization
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
#' must be properly authorized to access it. So a \code{googlesheet} object will
#' only contain info from the spreadsheets feed if \code{lookup = TRUE}, which
#' directs us to look up sheet-identifying information in the spreadsheets feed.
#'
#' @name googlesheet
#'
#' @param x sheet-identifying information; a character vector of length one
#'   holding sheet title, key, browser URL or worksheets feed OR, in the case of
#'   \code{gs_gs} only, a \code{googlesheet} object
#' @param lookup logical, optional. Controls whether \code{googlesheets} will
#'   place authorized API requests during registration. If unspecified, will
#'   be set to \code{TRUE} if authorization has previously been used in this R
#'   session, if working directory contains a file named \code{.httr-oauth}, or
#'   if \code{x} is a worksheets feed or \code{googlesheet} object that
#'   specifies "public" visibility.
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
    as.googlesheet(ssf, lookup = TRUE, verbose)

}

#' @rdname googlesheet
#' @export
gs_key <- function(x, lookup = NULL, visibility = NULL, verbose = TRUE) {

  stopifnot(length(x) == 1L, is.character(x))

  lookup <- set_lookup(lookup, visibility, verbose)
  visibility <- set_visibility(visibility, lookup)

  if (lookup) {
    ssf <- x %>%
      gs_lookup("sheet_key", verbose)
    x <- ssf$ws_feed
  } else {
    x <- x %>%
      construct_ws_feed_from_key(visibility)
    if (verbose) {
      mpf("Worksheets feed constructed with %s visibility", visibility)
    }
    ssf <- NULL
  }

  x <- structure(x, class = "ws_feed")
  x %>%
    as.googlesheet(ssf, lookup, verbose)

}

#' @rdname googlesheet
#' @export
gs_url <- function(x, lookup = NULL, visibility = NULL, verbose = TRUE) {

  stopifnot(length(x) == 1L, is.character(x),
            stringr::str_detect(x, "^https://"))

  if(verbose) {
    message("Sheet-identifying info appears to be a browser URL.\n",
            "googlesheets will attempt to extract sheet key from the URL.")
  }

  x <- extract_key_from_url(x)

  if(verbose) mpf("Putative key: %s", x)

  x %>%
    gs_key(lookup, visibility, verbose)

}

#' @rdname googlesheet
#' @export
gs_ws_feed <- function(x, lookup = NULL, verbose = TRUE) {

  ws_feed_regex <- "https://spreadsheets.google.com/feeds/worksheets"
  stopifnot(length(x) == 1L, is.character(x),
            stringr::str_detect(x, ws_feed_regex))

  visibility <- if(grepl("public", x)) "public" else "private"
  lookup <- set_lookup(lookup, visibility, verbose)

  if(lookup) {
    ssf <- x %>%
      gs_lookup("ws_feed", verbose)
  } else {
    ssf <- NULL
  }

  x <- structure(x, class = "ws_feed")
  x %>%
    as.googlesheet(ssf, lookup, verbose)

}

#' @rdname googlesheet
#' @export
gs_gs <- function(x, visibility = NULL, verbose = TRUE) {

  stopifnot(inherits(x, "googlesheet"))

  if(is.null(visibility)) {
    visibility <- x$visibility
  } else {
    stopifnot(identical(visibility, "public") ||
                identical(visibility, "private"))
  }

  key <- extract_key_from_url(x$ws_feed)
  key %>%
    gs_key(lookup = x$lookup, visibility = visibility, verbose = verbose)

}

set_lookup <- function(lookup = NULL, visibility = NULL, verbose = TRUE) {

  stopifnot(is_toggle(lookup))

  auth_seems_possible <- !is.null(.state$token) || file.exists(".httr-oauth")

  if(is.null(lookup)) {
    if(is.null(visibility)) {
      lookup <- auth_seems_possible
    } else {
      lookup <- switch(visibility,
                       public = FALSE,
                       private = TRUE,
                       auth_seems_possible)
    }
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
    stopifnot(identical(visibility, "public") ||
                identical(visibility, "private"))
  }

  visibility

}

## for internal use only
## x = character holding title | key | ws_feed
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
    mpf("Sheet successfully identified: \"%s\"", ssf$sheet_title[i])
  }

  ssf[i, ]

}
