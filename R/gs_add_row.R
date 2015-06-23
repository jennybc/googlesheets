#' Append a row to a spreadsheet
#'
#' Add a row to an existing worksheet within an existing spreadsheet. This is
#' based on the
#' \href{https://developers.google.com/google-apps/spreadsheets/#working_with_list-based_feeds}{list
#' feed}, which has a strong assumption that the data occupies a neat rectangle
#' in the upper left corner of the sheet. This function specifically uses \href{https://developers.google.com/google-apps/spreadsheets/#adding_a_list_row}{this method}, which "inserts the new row immediately after the last row that appears in the list feed, which is to say immediately before the first entirely blank row."
#'
#' @template ss
#' @template ws
#' @inheritParams gs_edit_cells
#' @template verbose
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

  ## this fxn defined in gs_edit_cells.R
  input <- as_character_vector(input, col_names = FALSE)

  this_ws <- gs_ws(ss, ws, verbose = FALSE)
  ## this max-results query is undocumented, so don't be surprised if it stops
  ## working!!
  ## http://stackoverflow.com/questions/11361956/limiting-the-resultset-size-on-a-google-spreadsheets-forms-list-feed
  ## http://stackoverflow.com/questions/27678331/retreive-a-range-of-rows-from-google-spreadsheet-using-list-based-feed-api-and
  req <- gsheets_GET(this_ws$listfeed, query = list(`max-results` = 1))

  ns <- xml2::xml_ns_rename(xml2::xml_ns(req$content), d1 = "feed")

  var_names <- req$content %>%
    xml2::xml_find_one("(//feed:entry)[1]", ns) %>%
    xml2::xml_find_all(".//gsx:*", ns) %>%
    xml2::xml_name()
  nc <- length(var_names)

  if(length(input) > nc) {
    if(verbose) {
      sprintf(paste("Input is too long. Only first %d elements will be",
                    "used."), nc) %>% message()
    }
    input <- input[seq_len(nc)]
  } else if(length(input) < nc) {
    if(verbose) {
      message("Input is too short. Padding with empty strings.")
    }
    input <- c(input, rep('', nc - length(input)))
  }
  stopifnot(length(input) == nc)

  lf_post_link <- req$content %>%
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

  req <- gsheets_POST(lf_post_link, XML::toString.XMLNode(new_row))
  if(req$status_code == 201L) {
    if(verbose) {
      message("Row successfully appended.")
    }
  } else {
    if(verbose) {
      message("Unable to confirm that new row was added.")
    }
  }
  ss %>% gs_gs(verbose = FALSE) %>% invisible()

}
