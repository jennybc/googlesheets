#' Extract sheet key from a URL
#'
#' Extract a sheet's unique key from a wide variety of URLs, i.e. a browser URL
#' for both old and new Sheets, the "worksheets feed", and other links returned
#' by the Sheets API.
#'
#' @param url character; a URL associated with a Google Sheet
#'
#' @examples
#' \dontrun{
#' GAP_URL <- gs_gap_url()
#' GAP_KEY <- extract_key_from_url(GAP_URL)
#' gap_ss <- gs_key(GAP_KEY)
#' gap_ss
#' }
#'
#' @export
extract_key_from_url <- function(url) {
  url_start_list <-
    c(ws_feed_start = "https://spreadsheets.google.com/feeds/worksheets/",
      self_link_start = "https://spreadsheets.google.com/feeds/spreadsheets/private/full/",
      url_start_new = "https://docs.google.com/spreadsheets/d/",
      url_start_google_apps_for_work = "https://docs.google.com/a/[[:print:]]+/spreadsheets/d/",
      url_start_old = "https://docs.google.com/spreadsheet/ccc\\?key=",
      url_start_old2 = "https://docs.google.com/spreadsheet/pub\\?key=",
      url_start_old3 = "https://spreadsheets.google.com/ccc\\?key=")
  url_start <- url_start_list %>% stringr::str_c(collapse = "|")
  url %>% stringr::str_replace(url_start, '') %>%
    stringr::str_split_fixed('[/&#]', n = 2) %>%
    `[`(, 1)
}

#' Construct a worksheets feed from a key
#'
#' @param key character, unique key for a spreadsheet
#' @param visibility character, either "private" (default) or "public",
#'   indicating whether further requests will be made with or without
#'   authorization, respectively
#'
#' @keywords internal
construct_ws_feed_from_key <- function(key, visibility = "private") {
  tmp <-
    "https://spreadsheets.google.com/feeds/worksheets/%s/%s/full"
  sprintf(tmp, key, visibility)
}

#' Construct a browser URL from a key
#'
#' @param key character, unique key for a spreadsheet
#'
#' @keywords internal
construct_url_from_key <- function(key) {
  tmp <- "https://docs.google.com/spreadsheets/d/%s/"
  sprintf(tmp, key)
}

isFALSE <- function(x) identical(FALSE, x)

is_toggle <- function(x) {
  is.null(x) || isTRUE(x) || isFALSE(x)
}

force_na_type <-
  function(x, type = c("logical", "integer", "double", "real",
                       "complex", "character")) {
    type <- match.arg(type)
    if(all(is.na(x))) {
      na <- switch(type,
                   logical = NA,
                   integer = NA_integer_,
                   double = NA_real_,
                   real = NA_real_,
                   complex = NA_complex_,
                   character = NA_character_,
                   NA)
      rep_len(na, length(x))
    } else {
      x
    }
  }

## good news: these are handy and call. = FALSE is built-in
##  bad news: 'fmt' must be exactly 1 string, i.e. you've got to paste, iff
##             you're counting on sprintf() substitution
mpf <- function(...) message(sprintf(...))
wpf <- function(...) warning(sprintf(...), call. = FALSE)
spf <- function(...) stop(sprintf(...), call. = FALSE)

## spotted in various hadley packages
dropnulls <- function(x) Filter(Negate(is.null), x)

## do intake on `...` for all the read functions
parse_read_ddd <- function(..., feed = c("csv", "list", "cell"),
                           verbose = FALSE) {
  feed <- match.arg(feed)
  ddd <- list(...)
  ddd <- list(
    ## pass straight through to readr::read_csv, readr::type_convert
    col_types = ddd$col_types,
    locale = ddd$locale,
    trim_ws = ddd$trim_ws,
    na = ddd$na,
    ## use to conditionally include httr::progress() in httr::GET() calls
    progress = ddd$progress %||% TRUE,
    ## only sensible for readr::read_csv and, therefore, gs_read_csv()
    comment = ddd$comment,
    skip = ddd$skip,
    n_max = ddd$n_max,
    ## my very own fiddly problem to deal with
    col_names = ddd$col_names,
    check.names = ddd$check.names %||% FALSE
  )
  if (feed != "csv") {
    nope <- c("comment", "skip", "n_max")
    oops <- intersect(names(dropnulls(ddd)), nope)
    if (length(oops) > 0 && verbose) {
      mpf(paste0("Ignoring these arguments that don't work with this ",
                 "read function:\n%s"), paste(oops, collapse = ", "))
    }
    ddd <- ddd[setdiff(names(ddd), nope)]
  }
  if (is.null(ddd$col_names)) {
    ddd$col_names <- TRUE
  } else {
    stopifnot(is_toggle(ddd$col_names) || is.character(ddd$col_names))
  }
  stopifnot(is_toggle(ddd$check.names))
  ddd
}

fix_names <- function(vnames, check.names = FALSE) {
  na_vnames <- is.na(vnames) | vnames == ""
  n_na_vnames <- sum(na_vnames)
  if (n_na_vnames > 0) {
    vnames[na_vnames] <- paste0("X", seq_len(n_na_vnames))
  }
  if (check.names) {
    vnames <- make.names(vnames, unique = TRUE)
  }
  vnames
}

vet_names <- function(col_names, vnames,
                      check.names = FALSE, n_cols = length(vnames),
                      verbose = FALSE) {
  if (is.character(col_names)) {
    vnames <- fix_names(col_names, check.names)
    if (length(vnames) >= n_cols) {
      vnames <- head(vnames, n_cols)
    } else {
      if (verbose) mpf("'col_names' too short ... taking them from Sheet.")
      vnames <- TRUE
    }
  }
  vnames
}

## spotted in various hadley packages
dropnulls <- function(x) Filter(Negate(is.null), x)

## do intake on `...` for all the read functions
parse_read_ddd <- function(..., feed = c("csv", "list", "cell"),
                           verbose = FALSE) {
  feed <- match.arg(feed)
  ddd <- list(...)
  ddd <- list(
    ## pass straight through to readr::read_csv, readr::type_convert
    col_types = ddd$col_types,
    locale = ddd$locale,
    trim_ws = ddd$trim_ws,
    na = ddd$na,
    ## use to conditionally include httr::progress() in httr::GET() calls
    progress = ddd$progress %||% TRUE,
    ## only sensible for readr::read_csv and, therefore, gs_read_csv()
    comment = ddd$comment,
    skip = ddd$skip,
    n_max = ddd$n_max,
    ## my very own fiddly problem to deal with
    col_names = ddd$col_names,
    check.names = ddd$check.names %||% FALSE
  )
  if (feed != "csv") {
    nope <- c("comment", "skip", "n_max")
    oops <- intersect(names(dropnulls(ddd)), nope)
    if (length(oops) > 0 && verbose) {
      mpf(paste0("Ignoring these arguments that don't work with this ",
                 "read function:\n%s"), paste(oops, collapse = ", "))
    }
    ddd <- ddd[setdiff(names(ddd), nope)]
  }
  if (is.null(ddd$col_names)) {
    ddd$col_names <- TRUE
  } else {
    stopifnot(is_toggle(ddd$col_names) || is.character(ddd$col_names))
  }
  stopifnot(is_toggle(ddd$check.names))
  ddd
}

fix_names <- function(vnames, check.names = FALSE) {
  na_vnames <- is.na(vnames) | vnames == ""
  n_na_vnames <- sum(na_vnames)
  if (n_na_vnames > 0) {
    vnames[na_vnames] <- paste0("X", seq_len(n_na_vnames))
  }
  if (check.names) {
    vnames <- make.names(vnames, unique = TRUE)
  }
  vnames
}

vet_names <- function(col_names, vnames,
                      check.names = FALSE, n_cols = length(vnames),
                      verbose = FALSE) {
  if (is.character(col_names)) {
    vnames <- fix_names(col_names, check.names)
    if (length(vnames) >= n_cols) {
      vnames <- head(vnames, n_cols)
    } else {
      if (verbose) mpf("'col_names' too short ... taking them from Sheet.")
      vnames <- TRUE
    }
  }
  vnames
}
