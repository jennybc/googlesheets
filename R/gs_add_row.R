#' Append rows to a spreadsheet
#'
#' Add rows to an existing worksheet within an existing spreadsheet. This is
#' based on the
#' \href{https://developers.google.com/google-apps/spreadsheets/#working_with_list-based_feeds}{list
#' feed}, which has a strong assumption that the data occupies a neat rectangle
#' in the upper left corner of the sheet. This function specifically uses
#' \href{https://developers.google.com/google-apps/spreadsheets/#adding_a_list_row}{this
#' method}, which "inserts the new row immediately after the last row that
#' appears in the list feed, which is to say immediately before the first
#' entirely blank row."
#'
#' At the moment, this function will only work in a sheet that has a proper
#' header row of variable or column names and at least one pre-existing data
#' row. If you get \code{Error : No matches}, that suggests the worksheet
#' doesn't meet these minimum requirements. In the future, we will try harder to
#' populate the sheet as necessary, e.g. create default variable names in a
#' header row and be able to cope with \code{input} being the first row of data.
#'
#' If \code{input} is two-dimensional, internally we call \code{gs_add_row} once
#' per input row.
#'
#' @template ss
#' @template ws
#' @inheritParams gs_edit_cells
#' @template verbose
#'
#' @seealso \code{\link{gs_edit_cells}}
#'
#' @examples
#' \dontrun{
#' yo <- gs_copy(gs_gap(), to = "yo")
#' yo <- gs_add_row(yo, ws = "Oceania",
#'                  input = c("Valinor", "Aman", "2015", "10000",
#'                            "35", "1000.5"))
#' tail(gs_read(yo, ws = "Oceania"))
#'
#' gs_delete(yo)
#' }
#'
#' @export
gs_add_row <- function(ss, ws = 1, input = '', verbose = TRUE) {

  nrows <- nrow(input)
  if (!is.null(nrows) && nrows > 1) {

    for (i in seq_len(nrows)) {
      ss <- Recall(ss = ss, ws = ws, input = input[i, ], verbose = verbose)
    }
    return(invisible(ss))
  }

  ## this fxn defined in gs_edit_cells.R
  input <- as_character_vector(input, col_names = FALSE)

  this_ws <- gs_ws(ss, ws, verbose = FALSE)
  ## this max-results query is undocumented, so don't be surprised if it stops
  ## working!!
  ## http://stackoverflow.com/questions/11361956/limiting-the-resultset-size-on-a-google-spreadsheets-forms-list-feed
  ## http://stackoverflow.com/questions/27678331/retreive-a-range-of-rows-from-google-spreadsheet-using-list-based-feed-api-and
  the_url <- this_ws$listfeed
  req <- httr::GET(the_url,
                   omit_token_if(grepl("public", the_url)),
                   query = list(`max-results` = 1)) %>%
    httr::stop_for_status()
  rc <- content_as_xml_UTF8(req)

  ns <- xml2::xml_ns_rename(xml2::xml_ns(rc), d1 = "feed")

  var_names <- rc %>%
    xml2::xml_find_one("(//feed:entry)[1]", ns) %>%
    xml2::xml_find_all(".//gsx:*", ns) %>%
    xml2::xml_name()
  nc <- length(var_names)

  if(length(input) > nc) {
    if(verbose) {
      mpf("Input is too long. Only first %d elements will be used.", nc)
    }
    input <- input[seq_len(nc)]
  } else if(length(input) < nc) {
    if(verbose) {
      message("Input is too short. Padding with empty strings.")
    }
    input <- c(input, rep('', nc - length(input)))
  }
  stopifnot(length(input) == nc)

  lf_post_link <- rc %>%
    xml2::xml_find_one("//feed:link[contains(@rel,'2005#post')]", ns) %>%
    xml2::xml_attr("href")

  child_node_names <- paste("gsx", var_names, sep = ":")
  new_row <-
    XML::xmlNode("entry",
                 .children = mapply(XML::xmlNode, child_node_names,
                                    input,
                                    SIMPLIFY = FALSE, USE.NAMES = FALSE),
                 namespaceDefinitions = c("http://www.w3.org/2005/Atom",
                  gsx = "http://schemas.google.com/spreadsheets/2006/extended"))

  req <- httr::POST(
    lf_post_link,
    google_token(),
    httr::add_headers("Content-Type" = "application/atom+xml"),
    body = XML::toString.XMLNode(new_row)
  ) %>%
    httr::stop_for_status()

  if (verbose) {
    if (httr::status_code(req) == 201L) {
      message("Row successfully appended.")
    } else {
      message("Unable to confirm that new row was added.")
    }
  }

  ss %>% gs_gs(verbose = FALSE) %>% invisible()

}
