#' Edit cells
#'
#' Modify the contents of one or more cells. The cells to be edited are
#' specified implicitly by a single anchor cell, which will be the upper left
#' corner of the edited cell region, and the size and shape of the input. If the
#' input has rectangular shape, i.e. is a data.frame or matrix, then a simiarly
#' shaped range of cells will be updated. If the input has no dimension, i.e.
#' it's a vector, then \code{byrow} controls whether edited cells will extend
#' from the anchor across a row or down a column.
#'
#' @template ss
#' @template ws
#' @param input new cell values, as an object that can be coerced into a
#'   character vector, presumably an atomic vector, a factor, a matrix or a
#'   data.frame
#' @param anchor single character string specifying the upper left cell of the
#'   cell range to edit; positioning notation can be either "A1" or "R1C1"
#' @param byrow logical; should we fill cells across a row (\code{byrow =
#'   TRUE}) or down a column (\code{byrow = FALSE}, default); consulted only
#'   when \code{input} is a vector, i.e. \code{dim(input)} is \code{NULL}
#' @param col_names logical; indicates whether column names of input should be
#'   included in the edit, i.e. prepended to the input; consulted only when
#'   \code{length(dim(input))} equals 2, i.e. \code{input} is a matrix or
#'   data.frame
#' @param trim logical; do you want the worksheet extent to be modified to
#'   correspond exactly to the cells being edited?
#' @template verbose
#'
#' @seealso \code{\link{gs_add_row}}
#'
#' @examples
#' \dontrun{
#' yo <- gs_new("yo")
#' yo <- gs_edit_cells(yo, input = head(iris), trim = TRUE)
#' gs_read(yo)
#'
#' yo <- gs_ws_new(yo, ws = "byrow_FALSE")
#' yo <- gs_edit_cells(yo, ws = "byrow_FALSE",
#'                     input = LETTERS[1:5], anchor = "A8")
#' gs_read_cellfeed(yo, ws = "byrow_FALSE", range = "A8:A12") %>%
#'   gs_simplify_cellfeed()
#'
#' yo <- gs_ws_new(yo, ws = "byrow_TRUE")
#' yo <- gs_edit_cells(yo, ws = "byrow_TRUE", input = LETTERS[1:5],
#'                     anchor = "A8", byrow = TRUE)
#' gs_read_cellfeed(yo, ws = "byrow_TRUE", range = "A8:E8") %>%
#'   gs_simplify_cellfeed()
#'
#' yo <- gs_ws_new(yo, ws = "col_names_FALSE")
#' yo <- gs_edit_cells(yo, ws = "col_names_FALSE", input = head(iris),
#'                     trim = TRUE, col_names = FALSE)
#' gs_read_cellfeed(yo, ws = "col_names_FALSE") %>%
#'   gs_reshape_cellfeed(col_names = FALSE)
#'
#' gs_delete(yo)
#' }
#'
#' @export
gs_edit_cells <- function(ss, ws = 1, input = '', anchor = 'A1',
                          byrow = FALSE, col_names = NULL, trim = FALSE,
                          verbose = TRUE) {

  sleep <- 1 ## we must backoff or operations below don't complete before
             ## next one starts; believe it or not, shorter sleeps cause
             ## problems fairly regularly :(

  catch_hopeless_input(input)
  this_ws <- gs_ws(ss, ws, verbose = FALSE)

  limits <-
    cellranger::anchored(anchor = anchor, input = input, col_names = col_names,
                         byrow = byrow)
  ## TO DO: if I were really nice, I would use the positioning notation from the
  ## user, i.e. learn it from anchor, instead of defaulting to A1
  range <- limits %>%
    cellranger::as.range()
  if(verbose) mpf("Range affected by the update: \"%s\"", range)
  limits <- limits %>%
    limit_list()

  if(limits$`max-row` > this_ws$row_extent ||
     limits$`max-col` > this_ws$col_extent) {
    ss <- ss %>%
      gs_ws_resize(this_ws$ws_title,
                   max(this_ws$row_extent, limits$`max-row`),
                   max(this_ws$col_extent, limits$`max-col`),
                   verbose = verbose)
    Sys.sleep(sleep)
  }

  ## redundant with the default col_names-setting logic from cellranger :(
  ## but we need it here as well to pass directions to as_character_vector()
  if(is.null(dim(input))) { # input is 1-dimensional
    col_names <- FALSE
  } else if(is.null(col_names)) {
    col_names <- !is.null(colnames(input))
  }

  input <- input %>% as_character_vector(col_names = col_names)

  cells_df <- ss %>%
    gs_read_cellfeed(
      ws, range = range, return_empty = TRUE,
      return_links = TRUE, verbose = FALSE) %>%
    dplyr::mutate_(update_value = ~ input)

  f <- function(cell, cell_id, edit_link, row, col, update_value) {
    XML::xmlNode("entry",
                 XML::xmlNode("batch:id", cell),
                 XML::xmlNode("batch:operation",
                              attrs = c("type" = "update")),
                 XML::xmlNode("id", cell_id),
                 XML::xmlNode("link",
                              attrs = c("rel" = "edit",
                                        "type" = "application/atom+xml",
                                        "href" = edit_link)),
                 XML::xmlNode("gs:cell",
                              attrs = c("row" = row,
                                        "col" = col,
                                        "inputValue" = update_value)))
  }
  update_entries <- cells_df %>%
    dplyr::select_(quote(-cell_alt), quote(-value),
                   quote(-input_value), quote(-numeric_value)) %>%
    purrr::pmap(f)

  update_feed <-
    XML::xmlNode("feed",
                 namespaceDefinitions =
                   c("http://www.w3.org/2005/Atom",
                     batch = "http://schemas.google.com/gdata/batch",
                     gs = "http://schemas.google.com/spreadsheets/2006"),
                 .children = list(XML::xmlNode("id", this_ws$cellsfeed))) %>%
    XML::addChildren(kids = update_entries) %>%
    XML::toString.XMLNode()

  req <- httr::POST(
    file.path(this_ws$cellsfeed, "batch"),
    google_token(),
    body = update_feed,
    httr::add_headers("Content-Type" = "application/atom+xml")
  ) %>%
    httr::stop_for_status()
  req <- content_as_xml_UTF8(req)

  cell_status <-
    req %>%
    xml2::xml_find_all("atom:entry//batch:status", xml2::xml_ns(.)) %>%
    xml2::xml_attr("code")

  if (verbose) {
    if (all(cell_status == "200")) {
      mpf("Worksheet \"%s\" successfully updated with %d new value(s).",
          this_ws$ws_title, length(input))
    } else {
      mpf(paste("Problems updating cells in worksheet \"%s\".",
                "Statuses returned:\n%s"), this_ws$ws_title,
              paste(unique(cell_status), collapse = ","))
    }
  }

  if(trim &&
     (limits$`max-row` < this_ws$row_extent ||
      limits$`max-col` < this_ws$col_extent)) {

    Sys.sleep(sleep)
    ss <- ss %>%
      gs_ws_resize(this_ws$ws_title, limits$`max-row`,
                   limits$`max-col`, verbose = verbose)
  }

  Sys.sleep(sleep)
  ss <- ss$sheet_key %>% gs_key(verbose = FALSE)
  invisible(ss)
}

catch_hopeless_input <- function(x) {

  if(x %>% is.recursive() && !(x %>% is.data.frame())) {
    stop(paste("Non-data-frame, list-like objects not suitable as input.",
               "Maybe pre-process it yourself?"))
  }

  if(!is.null(dim(x)) && length(dim(x)) > 2) {
    stop("Input has more than 2 dimensions.")
  }

  invisible(NULL)
}

## deeply pragmatic function to turn input destined for upload into cells
## into a character vector
## col_names controls whether column names are prepended, when x has 2
## dimensions
as_character_vector <- function(x, col_names) {

  catch_hopeless_input(x)
  x_colnames <- NULL

  ## instead of fiddly tests on x (see comments below), just go with it, if x
  ## can be turned into a character vector
  if(is.null(dim(x))) {
    y <- try(as.character(x), silent = TRUE)
  } else if(length(dim(x)) == 2L) {
    x_colnames <- colnames(x)
    y <- try(x %>% t() %>% as.character() %>% drop(), silent = TRUE)
  }

  if(y %>% inherits("try-error")) {
    stop("Input cannot be converted to character vector.")
  }

  if(col_names) {
    y <- c(x_colnames, y)
  }

  y
  ## re: why vetting x directly is not as simple as you would expect
  ## http://stackoverflow.com/questions/19501186/how-to-test-if-object-is-a-vector
  ## https://twitter.com/JennyBryan/status/577950939744591872
  ## https://stat.ethz.ch/pipermail/r-devel/1997-April/017019.html
}
