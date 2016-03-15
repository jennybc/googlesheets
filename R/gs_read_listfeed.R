#' Read data via the "list feed"
#'
#' Gets data via the "list feed", which assumes populated cells form a neat
#' rectangle. The list feed consumes data row by row. The first row is assumed
#' to hold variable or column names; it can be empty. The second row is assumed
#' to hold the first data row and, if it is empty, no data will be read and you
#' will get an empty data frame.
#'
#' The other read functions are generally superior, so use them if you can.
#' However, you may need to use this function if you are dealing with an "old"
#' Google Sheet, which is beyond the reach of \code{\link{gs_read_csv}}. The
#' list feed also has some ability to sort and filter rows via the API (more
#' below). Consult the Google Sheets API documentation for more details about
#' \href{https://developers.google.com/google-apps/spreadsheets/data#work_with_list-based_feeds}{the
#' list feed}.
#'
#' @template ss
#' @template ws
#' @param reverse logical, optional. Indicates whether to request reverse row
#'   order in the actual API call.
#' @param orderby character, optional. Specifies a column to sort on in the
#'   actual API call.
#' @param sq character, optional. Provides a structured query for row filtering
#'   in the actual API call.
#' @template read-ddd
#' @template verbose
#'
#' @section Column names:
#'
#'   For the list feed, and only for the list feed, the Sheets API wants to
#'   transform the variable or column names like so: 'The column names are the
#'   header values of the worksheet lowercased and with all non-alpha-numeric
#'   characters removed. For example, if the cell A1 contains the value "Time 2
#'   Eat!" the column name would be "time2eat".' In \code{googlesheets}, we do
#'   not let this happen and, instead, use the column names "as is", for
#'   consistent output across all \code{gs_read*} functions. If you direct
#'   \code{gs_read_listfeed} to pass query parameters to the actual API call,
#'   you must refer to variables using the column names \emph{under this
#'   API-enforced transformation}. For example, to order the data by the column
#'   with "Time 2 Eat!" in the header row, you must specify \code{orderby =
#'   "time2eat"} in the \code{gs_read_listfeed} call.
#'
#' @section Sorting and filtering via the API:
#'
#'   Why on earth would you want to sort and filter via the API instead of in R?
#'   Just because you can? It is conceivable there are situations, such as a
#'   large spreadsheet, in which it is faster to sort or filter via API. Be sure
#'   to refer to variables using the API-transformed column names explained
#'   above! It is a
#'   \href{https://code.google.com/a/google.com/p/apps-api-issues/issues/detail?id=3588}{known
#'    bug} that \code{reverse=true} alone will NOT, in fact, reverse the row
#'   order of the result. In our experience, the \code{reverse} query parameter
#'   will only have effect in combination with explicit specification of a
#'   column to sort on via \code{orderby}. The syntax for these queries
#'   \href{http://stackoverflow.com/questions/25732784/official-reference-for-google-spreadsheet-api-structured-query-syntax}{is
#'    apparently undocumented}, so keep it simple or bring your spirit of
#'   adventure!
#'
#' @family data consumption functions
#'
#' @template return-tbl-df
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_gap() # register the Gapminder example sheet
#' oceania_lf <- gs_read_listfeed(gap_ss, ws = "Oceania")
#' head(oceania_lf, 3)
#'
#' ## do row ordering and filtering in the API call
#' oceania_fancy <-
#'   gs_read_listfeed(gap_ss,
#'                    ws = "Oceania",
#'                    reverse = TRUE, orderby = "gdppercap",
#'                    sq = "lifeexp > 79 or year < 1960")
#' oceania_fancy
#'
#' ## passing args through to readr::type_convert()
#' oceania_crazy <-
#'   gs_read_listfeed(gap_ss,
#'                    ws = "Oceania",
#'                    col_names = paste0("z", 1:6), skip = 1,
#'                    col_types = "ccncnn",
#'                    na = "1962")
#' oceania_crazy
#' }
#'
#' @export
gs_read_listfeed <- function(ss, ws = 1,
                             reverse = NULL, orderby = NULL, sq = NULL,
                             ...,
                             verbose = TRUE) {

  stopifnot(inherits(ss, "googlesheet"))
  stopifnot(is_toggle(reverse))
  if (!is.null(orderby)) {
    stopifnot(is.character(orderby), length(orderby) == 1L)
    orderby <- paste("column", orderby, sep = ":")
  }
  if (!is.null(sq)) {
    stopifnot(is.character(sq), length(sq) == 1L)
  }

  ddd <- parse_read_ddd(..., verbose = verbose)

  this_ws <- gs_ws(ss, ws, verbose)
  if (!is.null(reverse)) reverse <- tolower(as.character(reverse))
  the_query <- list(reverse = reverse, orderby = orderby, sq = sq)
  the_url <- httr::modify_url(this_ws$listfeed, query = the_query)
  req <-
    httr::GET(the_url,
              omit_token_if(grepl("public", the_url)),
              if (interactive() && ddd$progress && verbose) httr::progress() else NULL) %>%
    httr::stop_for_status()
  rc <- content_as_xml_UTF8(req)
  ns <- xml2::xml_ns_rename(xml2::xml_ns(rc), d1 = "feed")

  rows <- rc %>%
    ## list of nodesets: one component per spreadsheet row
    xml2::xml_find_all(xpath = "//feed:entry", ns = ns) %>%
    ## keep only nodes that give cell contents
    purrr::map(~xml2::xml_find_all(.x, xpath = "./gsx:*", ns = ns))

  if (length(rows) == 0L) {
    if (verbose) mpf("Worksheet '%s' is empty.", this_ws$ws_title)
    return(dplyr::data_frame())
  }

  ## make a data frame with row-specific nodesets in a list-column
  rows_df <- dplyr::data_frame_(list(row = ~seq_along(rows),
                                     nodeset = ~rows))

  ## rows_df has one row spreadsheet row
  ## cells_df has one row per nonempty spreadsheet cell
  cells_df <- rows_df %>%
    ## extract (alleged) col name, cell text; i = within-row cell counter
    dplyr::mutate_(col_name_raw = ~nodeset %>% purrr::map(~xml2::xml_name(.)),
                   value = ~nodeset %>% purrr::map(~xml2::xml_text(.)),
                   i = ~nodeset %>% purrr::map(~ seq_along(.))) %>%
    dplyr::select_(~row, ~i, ~col_name_raw, ~value) %>%
    tidyr::unnest_(c("i", "col_name_raw", "value"))

  hrow <- cells_df %>%
    ## figure out which column things came from
    ## it is not necessarily column i because of empty cells or columns
    dplyr::group_by_(~col_name_raw) %>%
    dplyr::summarise_(col = ~max(i)) %>%
    dplyr::arrange_(~col) %>%
    ## no docs re: dummy column name given by the API when it's missing
    ## this regex derived from limited personal experience so :shrug:
    dplyr::mutate_(col_name = ~stringr::str_replace(col_name_raw,
                                                    "_[a-z0-9]{5}", ""))

  suppressMessages(
    cells_df <- cells_df %>%
      ## add column info to the data
      dplyr::left_join(hrow) %>%
      dplyr::select_(~row, ~col, ~value) %>%
      ## increment row to anticipate prepending data for the header row
      dplyr::mutate_(row = ~row + 1L)
  )

  if (isTRUE(ddd$col_names)) {

    ## we are going to use column names from the Sheet, so get them from cell
    ## feed (vs. the transformed ones provided by the list feed)
    vnames <- ss %>%
      gs_read_cellfeed(ws = ws, range = cellranger::cell_rows(1),
        return_empty = TRUE, verbose = FALSE) %>%
      gs_simplify_cellfeed(notation = "none")
    ## still guessing at exactly how Google transforms header cells on the list
    ## feed
    vnames_mangled <- vnames %>% tolower() %>%
      stringr::str_replace_all("[^a-z0-9\\.]", "")
    hrow$col_name <- vnames[match(hrow$col_name, vnames_mangled)]
  }

  ## prepend column name cells to the data, just like the cell feed
  cells_df <- hrow %>%
    dplyr::mutate_(row = 1L) %>%
    dplyr::select_(~row, ~col, value = ~col_name) %>%
    dplyr::bind_rows(cells_df)

  gs_reshape_feed(cells_df, ddd, verbose)

}
