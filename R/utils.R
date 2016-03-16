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
parse_read_ddd <- function(..., verbose = FALSE) {
  ddd <- list(...)
  ddd <- list(
    ## pass straight through to readr::read_csv, readr::type_convert
    col_types = ddd$col_types,
    locale = ddd$locale,
    trim_ws = ddd$trim_ws,
    na = ddd$na,
    ## use to conditionally include httr::progress() in httr::GET() calls
    progress = ddd$progress %||% TRUE,
    ## work natively for gs_read_csv(), i.e. passed to readr::read_csv
    ## implemented internally in gs_reshape_feed() for list and cell feeds
    comment = ddd$comment,
    skip = ddd$skip,
    n_max = ddd$n_max,
    ## my very own fiddly problem to deal with
    col_names = ddd$col_names,
    check.names = ddd$check.names %||% FALSE
  )
  ddd$col_names <- ddd$col_names %||% TRUE
  stopifnot(is_toggle(ddd$col_names) || is.character(ddd$col_names))
  stopifnot(is_toggle(ddd$check.names))
  if (!is.null(ddd$comment)) {
    stopifnot(inherits(ddd$comment, "character"), length(ddd$comment) == 1L)
  }
  if (!is.null(ddd$skip)) {
    ddd$skip <- as.integer(ddd$skip)
    stopifnot(ddd$skip >= 0)
  }
  if (!is.null(ddd$n_max)) {
    ddd$n_max <- as.integer(ddd$n_max)
    stopifnot(ddd$n_max >= 1)
  }
  ddd
}

fix_names <- function(vnames, check.names = FALSE) {
  na_vnames <- is.na(vnames) | vnames == ""
  if (any(na_vnames)) {
    vnames[na_vnames] <- paste0("X", seq_along(vnames)[na_vnames])
  }
  if (check.names) {
    vnames <- make.names(vnames, unique = TRUE)
  }
  vnames
}

size_names <- function(vnames, n) {
  if (length(vnames) >= n) return(utils::head(vnames, n))
  nms <- paste0("X", seq_len(n))
  nms[seq_along(vnames)] <- vnames
  nms
}

reconcile_cell_contents <- function(x) {
  x <- x %>%
    dplyr::mutate_(literal_only = ~is.na(numeric_value),
                   putative_integer = ~ifelse(is.na(numeric_value), FALSE,
                                              gsub("\\.0$", "", numeric_value)
                                              == input_value),
                   ## a formula that evaluates to integer will almost certainly
                   ## look like a double, i.e. have trailing `.0`, but I'm not
                   ## sure I should strip it off
                   value = ~ifelse(literal_only,
                                   value,
                                   ifelse(putative_integer, input_value,
                                          numeric_value)))
  x %>%
    dplyr::select_(quote(-literal_only), quote(-putative_integer))
}
