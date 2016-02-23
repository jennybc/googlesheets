#' List sheets a la Google Sheets home screen
#'
#' Lists spreadsheets that the user would see in the Google Sheets home screen:
#' \url{https://docs.google.com/spreadsheets/}. This function returns the
#' information available from the
#' \href{https://developers.google.com/google-apps/spreadsheets/#retrieving_a_list_of_spreadsheets}{spreadsheets
#' feed} of the Google Sheets API. Since this is non-public user data, use of
#' \code{gs_ls} will require authorization
#'
#' This listing gives a \emph{partial} view of the sheets available for access
#' (why just partial? see below). For these sheets, we retrieve sheet title,
#' sheet key, author, user's permission, date-time of last update, version (old
#' vs new sheet?), various links, and an alternate key (only relevant to old
#' sheets).
#'
#' The resulting table provides a map between readily available information,
#' such as sheet title, and more obscure information you might use in scripts,
#' such as the sheet key. This sort of "table lookup" is exploited in the
#' functions \code{\link{gs_title}}, \code{\link{gs_key}}, \code{\link{gs_url}},
#' and \code{\link{gs_ws_feed}}, which register a sheet based on various forms
#' of user input.
#'
#' Which sheets show up in this table? Certainly those owned by the user. But
#' also a subset of the sheets owned by others but visible to the user. We have
#' yet to find explicit Google documentation on this matter. Anecdotally, sheets
#' owned by a third party but for which the user has read access seem to appear
#' in this listing if the user has visited them in the browser. This is an
#' important point for usability because a sheet can be summoned by title
#' instead of key \emph{only} if it appears in this listing. For shared sheets
#' that may not appear in this listing, a more robust workflow is to specify the
#' sheet via its browser URL or unique sheet key.
#'
#' @param regex character; one or more regular expressions; if non-\code{NULL}
#'   only sheets whose titles match will be listed; multiple regular expressions
#'   are concatenated with the vertical bar
#' @param ... optional arguments to be passed to \code{\link{grep}} when
#'   matching \code{regex} to sheet titles
#' @template verbose
#'
#' @return a \code{googlesheet_ls} object, which is a
#'   \code{\link[dplyr]{tbl_df}} with one row per sheet (we use a custom class
#'   only to control how this object is printed)
#'
#' @examples
#' \dontrun{
#' gs_ls()
#'
#' yo_names <- paste0(c("yo", "YO"), c("", 1:3))
#' yo_ret <- yo_names %>% lapply(gs_new)
#' gs_ls("yo")
#' gs_ls("yo", ignore.case = TRUE)
#' gs_ls("yo[23]", ignore.case = TRUE)
#' gs_grepdel("yo", ignore.case = TRUE)
#' gs_ls("yo", ignore.case = TRUE)
#'
#' c("foo", "yo") %>% lapply(gs_new)
#' gs_ls("yo")
#' gs_ls("yo|foo")
#' gs_ls(c("foo", "yo"))
#' gs_vecdel(c("foo", "yo"))
#'
#' }
#'
#' @export
gs_ls <- function(regex = NULL, ..., verbose = TRUE) {

  # only calling spreadsheets feed from here, so hardwiring url
  the_url <- "https://spreadsheets.google.com/feeds/spreadsheets/private/full"
  req <- httr::GET(the_url, google_token()) %>%
    httr::stop_for_status()
  rc <- content_as_xml_UTF8(req)

  ns <- xml2::xml_ns_rename(xml2::xml_ns(rc), d1 = "feed")
  entries <- rc %>% xml2::xml_find_all(".//feed:entry", ns)
  links <- entries %>% xml2::xml_find_all(".//feed:link", ns)

  link_dat <- dplyr::data_frame(
    ws_feed = links %>%
      xml2::xml_find_all("../*[contains(@rel, '2006#worksheetsfeed')]", ns) %>%
      xml2::xml_attr("href"),
    alternate = links %>%
      xml2::xml_find_all("../*[@rel='alternate']", ns) %>%
      xml2::xml_attr("href"),
    self = links %>%
      xml2::xml_find_all("../*[@rel='self']", ns) %>% xml2::xml_attr("href")
  )

  ## variable order is a deliberate effort to get the most important variables
  ## at the front for printing purposes; don't change w/o good reason and
  ## checking effect on printing
  ret <- dplyr::data_frame_(list(
    sheet_title =
      ~ entries %>% xml2::xml_find_all(".//feed:title", ns) %>%
      xml2::xml_text(),
    author =
      ~ entries %>% xml2::xml_find_all(".//feed:author//feed:name", ns) %>%
      xml2::xml_text(),
    perm = ~ link_dat$ws_feed %>%
      stringr::str_detect("values") %>%
      ifelse("r", "rw"),
    version = ~ ifelse(grepl("^https://docs.google.com/spreadsheets/d",
                             link_dat$alternate), "new", "old"),
    updated =
      ~ entries %>% xml2::xml_find_all(".//feed:updated", ns) %>%
      xml2::xml_text() %>%
      as.POSIXct(format = "%Y-%m-%dT%H:%M:%S", tz = "UTC"),
    sheet_key =
      ~ entries %>% xml2::xml_find_all(".//feed:id", ns) %>%
      xml2::xml_text() %>% basename(),
    ws_feed = ~ link_dat$ws_feed,
    alternate = ~ link_dat$alternate,
    self = ~ link_dat$self,
    alt_key = ~ ifelse(version == "new", NA_character_,
                       extract_key_from_url(link_dat$alternate))
  ))

  ret <- structure(ret, class = c("googlesheet_ls", class(ret)))

  if(is.null(regex)) {
    return(ret)
  } else {
    stopifnot(inherits(regex, "character"))
  }

  if(length(regex) > 1) {
    regex <- regex %>% paste(collapse = "|")
  }
  keep_me <- grep(regex, ret$sheet_title, ...)

  if(length(keep_me) == 0L) {
    if(verbose) {
      message("No matching sheets found.")
    }
    invisible(NULL)
  } else {
    ret[keep_me, ]
  }

}

#' @export
print.googlesheet_ls <- function(x, ...) {
  x %>%
    dplyr::mutate_(sheet_title = ~ ellipsize(sheet_title, 24),
                   author = ~ ellipsize(author, 13),
                   ## wish I knew how to drop seconds from last_updated!
                   sheet_key = ~ ellipsize(sheet_key, 9)) %>%
    print()
}

ellipsize <- function(x, n = 20) {
  ifelse(stringr::str_length(x) > n,
         paste0(stringr::str_sub(x, end = n - 1), "\u2026"),
         stringr::str_sub(x, end = n)) %>%
    stringr::str_pad(n)
}
