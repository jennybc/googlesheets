## set up at build time

## create an environment to hold registration info for example sheets
.gs_exsheets <- new.env(parent = emptyenv())

## persistent browser URL for gapminder example sheet
## (owned by rpackagetest) PLUS fall back key
assign("gap_purl",
       "https://w3id.org/people/jennybc/googlesheets_gap_url",
       envir = .gs_exsheets)
assign("gap_fallback_key",
       "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ",
       envir = .gs_exsheets)

## persistent browser URL for mini gapminder example sheet
## (owned by rpackagetest) PLUS fall back key
assign("mini_gap_purl",
       "https://w3id.org/people/jennybc/googlesheets_mini_gap_url",
       envir = .gs_exsheets)
assign("ff_fallback_key", "1BMtx1V2pk2KG2HGANvvBOaZM4Jx1DUdRrFdEx-OJIGY",
       envir = .gs_exsheets)

## persistent browser URL for formula and formatting example sheet
## (owned by rpackagetest) PLUS fall back key
assign("ff_purl",
       "https://w3id.org/people/jennybc/googlesheets_ff_url",
       envir = .gs_exsheets)
assign("ff_fallback_key", "132Ij_8ggTKVLnLqCOM3ima6mV9F8rmY7HEcR-5hjWoQ",
       envir = .gs_exsheets)

#' Examples of Google Sheets
#'
#' These functions return information on some Google Sheets we've published to
#' the web for use in examples and testing. For example, function names that
#' start with \code{gs_gap_} refer to a spreadsheet based on the Gapminder data,
#' which you can visit it in the browser:
#'
#' \itemize{
#'
#' \item \href{https://w3id.org/people/jennybc/googlesheets_gap_url}{Gapminder
#' sheet}
#' \item \href{https://w3id.org/people/jennybc/googlesheets_mini_gap_url}{mini
#' Gapminder sheet}
#' \item \href{https://w3id.org/people/jennybc/googlesheets_ff_url}{Sheet with
#' numeric formatting and formulas}
#'
#' }
#'
#' @return the key, browser URL, worksheets feed or \code{\link{googlesheet}}
#'   object corresponding to one of the example sheets
#'
#' @examples
#' \dontrun{
#' gs_gap_key()
#' gs_gap_url()
#' browseURL(gs_gap_url())
#' gs_gap_ws_feed() # not so interesting to a user!
#' gs_gap()
#'
#' gs_ff_key()
#' gs_ff_url()
#' gs_ff()
#' gs_browse(gs_ff())
#' }
#'
#' @name example-sheets
NULL

#' @describeIn example-sheets Gapminder sheet key
#' @export
gs_gap_key <- function() {
  if (is.null(get0("gap_key", .gs_exsheets))) gs_example_resolve("gap")
  get("gap_key", envir = .gs_exsheets)
}

#' @describeIn example-sheets Gapminder sheet URL
#' @export
gs_gap_url <- function() gs_gap_key() %>% construct_url_from_key()

#' @describeIn example-sheets Gapminder sheet worksheets feed
#' @export
gs_gap_ws_feed <- function() {
  gs_gap_key() %>%
    construct_ws_feed_from_key(visibility = "public")
}

#' @describeIn example-sheets Gapminder sheet as registered googlesheet
#' @export
gs_gap <- function() {
  gs_gap_key() %>%
    gs_key(lookup = FALSE, verbose = FALSE)
}

#' @describeIn example-sheets mini Gapminder sheet key
#' @export
gs_mini_gap_key <- function() {
  if (is.null(get0("mini_gap_key", .gs_exsheets))) gs_example_resolve("mini_gap")
  get("mini_gap_key", envir = .gs_exsheets)
}

#' @describeIn example-sheets mini Gapminder sheet URL
#' @export
gs_mini_gap_url <- function() gs_mini_gap_key() %>% construct_url_from_key()

#' @describeIn example-sheets mini Gapminder sheet worksheets feed
#' @export
gs_mini_gap_ws_feed <- function() {
  gs_mini_gap_key() %>%
    construct_ws_feed_from_key(visibility = "public")
}

#' @describeIn example-sheets mini Gapminder sheet as registered googlesheet
#' @export
gs_mini_gap <- function() {
  gs_mini_gap_key() %>%
    gs_key(lookup = FALSE, verbose = FALSE)
}

#' @describeIn example-sheets Key to a sheet with numeric formatting and
#' formulas
#' @export
gs_ff_key <- function() {
  if (is.null(get0("ff_key", .gs_exsheets))) gs_example_resolve("ff")
  get("ff_key", envir = .gs_exsheets)
}

#' @describeIn example-sheets URL for a sheet with numeric formatting and
#' formulas
#' @export
gs_ff_url <- function() gs_ff_key() %>% construct_url_from_key()

#' @describeIn example-sheets Worksheets feed for a sheet with numeric
#' formatting and formulas
#' @export
gs_ff_ws_feed <- function() {
  gs_ff_key() %>%
    construct_ws_feed_from_key(visibility = "public")
}

#' @describeIn example-sheets Registered googlesheet for a sheet with numeric
#' formatting and formulas
#' @export
gs_ff <- function() {
  gs_ff_key() %>%
    gs_key(lookup = FALSE, verbose = FALSE)
}

## not exported
## attempt to resolve the persistent URL of an example sheet
gs_example_resolve <- function(ex) {

  ex_purl <- paste(ex, "purl", sep = "_")
  ex_key <- paste(ex, "key", sep = "_")
  ex_fallback_key <- paste(ex, "fallback_key", sep = "_")
  req <- try(httr::GET(get(ex_purl, envir = .gs_exsheets)), silent = TRUE)
  if (inherits(req, "response") && httr::status_code(req) == 200) {
    assign(ex_key, extract_key_from_url(req$url), envir = .gs_exsheets)
    return(invisible(TRUE))
  } else {
    mpf(paste("googlesheets: can't resolve persistent URL for example sheet",
              "\"%s\" online; falling back to static default."), ex)
    assign(ex_key, get(ex_fallback_key, envir = .gs_exsheets),
           envir = .gs_exsheets)
    return(invisible(FALSE))
  }
}
