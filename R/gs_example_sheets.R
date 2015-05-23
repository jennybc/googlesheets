## set up at build time

## create an environment to hold registration info for example sheets
.gs_exsheets <- new.env(parent = emptyenv())

## persistent browser URL for gapminder example sheet
## (owned by rpackagetest) PLUS fall back key
assign("gap_purl",
       "https://w3id.org/people/jennybc/googlesheets_gap_url",
       envir = .gs_exsheets)
assign("gap_key", "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ",
       envir = .gs_exsheets)
## see .onAttach() in zzz.R for how the persistent URLs above are used to
## determine current sheet keys at session start or, failing that, the fallback
## keys above will be used

#' Examples of Google Sheets
#'
#' These functions return information on some public Google Sheets we've made
#' available for examples and testing. For example, function names that include
#' \code{gap} refer to a spreadsheet based on the Gapminder data. This sheet is
#' "published to the web" and you can visit it in the browser:
#'
#' \itemize{
#'
#'   \item \href{https://w3id.org/people/jennybc/googlesheets_gap_url}{Gapminder sheet}
#'
#' }
#'
#' @param visibility either "public" (the default) or "private"; used when
#'   producing a worksheets feed
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
#' }
#'
#' @name example-sheets
NULL

#' @rdname example-sheets
#' @export
gs_gap_key <- function() get("gap_key", envir = .gs_exsheets)

#' @rdname example-sheets
#' @export
gs_gap_url <- function() gs_gap_key() %>% construct_url_from_key()

#' @rdname example-sheets
#' @export
gs_gap_ws_feed <- function(visibility = "public") {
  gs_gap_key() %>%
    construct_ws_feed_from_key(visibility)
}

#' @rdname example-sheets
#' @export
gs_gap <- function() {
  gs_gap_key() %>%
    gs_key(lookup = FALSE, verbose = FALSE)
}
