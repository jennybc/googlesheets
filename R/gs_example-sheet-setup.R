## set up at build time

## create an environment to hold registration info for example sheets
.gs_exsheets <- new.env(parent = emptyenv())

## persistent browser URL for gapminder example sheet
## (owned by rpackagetest) PLUS fall back key
assign("gap_purl",
       "https://w3id.org/people/jennybc/googlesheets_gap_url",
       envir = .gs_exsheets)
assign("gap_fallback_key", "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ",
       envir = .gs_exsheets)

#' Examples of Google Sheets
#'
#' These functions return information on some Google Sheets we've published to
#' the web for use in examples and testing. For example, function names that
#' start with \code{gap_} refer to a spreadsheet based on the Gapminder data,
#' which you can visit it in the browser:
#'
#' \itemize{
#'
#' \item \href{https://w3id.org/people/jennybc/googlesheets_gap_url}{Gapminder
#' sheet}
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
gs_gap_key <- function() {

  if(is.null(get0("gap_key", .gs_exsheets))) gs_example_resolve("gap")
  get("gap_key", envir = .gs_exsheets)

}

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

## not exported
## attempt to resolve the persistent URL of an example sheet
gs_example_resolve <- function(ex) {

  ex_purl <- paste(ex, "purl", sep = "_")
  ex_key <- paste(ex, "key", sep = "_")
  ex_fallback_key <- paste(ex, "fallback_key", sep = "_")
  req <- try(httr::GET(get(ex_purl, envir = .gs_exsheets)), silent = TRUE)
  if(inherits(req, "response") && httr::status_code(req) == 200) {
    assign(ex_key, extract_key_from_url(req$url), envir = .gs_exsheets)
    return(invisible(TRUE))
  } else {
    paste("googlesheets: can't resolve persistent URL for example sheet",
          "\"%s\" online; falling back to static default.") %>%
      sprintf(ex) %>%
      message()
    assign(ex_key, ex_fallback_key, envir = .gs_exsheets)
    return(invisible(FALSE))
  }
}
