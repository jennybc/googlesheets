#' Edit cells
#'
#' Modify the contents of one or more cells. The cells to be edited are
#' specified implicitly by a single anchor cell, which will be the upper left
#' corner of the edited cell region, and the size and shape of the input. If the
#' input has rectangular shape, i.e. is a data.frame or matrix, then a simiarly
#' shaped range of cells will be updated. If the input has no dimension, i.e.
#' it's a vector, then \code{by_row} controls whether edited cells will extend
#' from the anchor across a row or down a column.
#'
#' @inheritParams get_via_lf
#' @param input new cell values, as an object that can be coerced into a
#'   character vector, presumably an atomic vector, a factor, a matrix or a
#'   data.frame
#' @param anchor single character string specifying the upper left cell of the
#'   cell range to edit; positioning notation can be either "A1" or "R1C1"
#' @param by_row logical; should we fill cells across a row (\code{by_row =
#'   TRUE}) or down a column (\code{by_row = FALSE}, default); consulted only
#'   when \code{input} is a vector, i.e. \code{dim(input)} is \code{NULL}
#' @param header logical; indicates whether column names of input should be
#'   included in the edit, i.e. prepended to the input; consulted only when
#'   \code{length(dim(input))} equals 2, i.e. \code{input} is a matrix or
#'   data.frame
#' @param trim logical; do you want the worksheet extent to be modified to
#'   correspond exactly to the cells being edited?
#' @param verbose logical; do you want informative message?
#'
#' @examples
#' \dontrun{
#' yo <- new_ss("yo")
#' yo <- edit_cells(yo, input = head(iris), header = TRUE, trim = TRUE)
#' get_via_csv(yo)
#'
#' yo <- add_ws(yo, "by_row_FALSE")
#' yo <- edit_cells(yo, ws = "by_row_FALSE", LETTERS[1:5], "A8")
#' get_via_cf(yo, ws = "by_row_FALSE", min_row = 7) %>% simplify_cf()
#'
#' yo <- add_ws(yo, "by_row_TRUE")
#' yo <- edit_cells(yo, ws = "by_row_TRUE", LETTERS[1:5], "A8", by_row = TRUE)
#' get_via_cf(yo, ws = "by_row_TRUE", min_row = 7) %>% simplify_cf()
#' }
#'
#' @export
edit_cells <- function(ss, ws = 1, input = '', anchor = 'A1',
                       by_row = FALSE, header = FALSE, trim = FALSE,
                       verbose = TRUE) {

  catch_hopeless_input(input)
  this_ws <- get_ws(ss, ws, verbose = FALSE)

  if(dim(input) %>% is.null()) {
    if(by_row) {
      input_extent <- c(1L, length(input))
    } else {
      input_extent <- c(length(input), 1L)
    }
  } else {
    input_extent <- dim(input)
    if(header) {
      input_extent[1] <- input_extent[1] + 1
    }
  }
  limits <- convert_range_to_limit_list(anchor)
  limits$`max-row` <- limits$`max-row` + input_extent[1] - 1
  limits$`max-col` <- limits$`max-col` + input_extent[2] - 1
  ## TO DO: if I were really nice, I would use the positioning notation from the
  ## user, i.e. learn it from anchor, instead of defaulting to A1
  range <- limits %>% convert_limit_list_to_range(pn = 'A1')
  if(verbose) {
    message(sprintf("Range affected by the update: \"%s\"", range))
  }

  if(limits$`max-row` > this_ws$row_extent ||
     limits$`max-col` > this_ws$col_extent) {

    ss <- ss %>%
      resize_ws(this_ws$ws_title,
                max(this_ws$row_extent, limits$`max-row`),
                max(this_ws$col_extent, limits$`max-col`),
                verbose)
    Sys.sleep(1)
    
  }

  input <- input %>% as_character_vector(header = header)

  cells_df <- ss %>%
    get_via_cf(ws, limits = limits,
               return_empty = TRUE, return_links = TRUE, verbose = FALSE) %>%
    dplyr::mutate_(update_value = ~ input)

  update_entries <-
    plyr::alply(
      cells_df, 1, function(x) {
        XML::xmlNode("entry",
                     XML::xmlNode("batch:id", x$cell),
                     XML::xmlNode("batch:operation",
                                  attrs = c("type" = "update")),
                     XML::xmlNode("id", x$cell_id),
                     XML::xmlNode("link",
                                  attrs = c("rel" = "edit",
                                            "type" = "application/atom+xml",
                                            "href" = x$edit_link)),
                     XML::xmlNode("gs:cell",
                                  attrs = c("row" = x$row,
                                            "col" = x$col,
                                            "inputValue" = x$update_value)))})
  update_feed <-
    XML::xmlNode("feed",
                 namespaceDefinitions =
                   c("http://www.w3.org/2005/Atom",
                     batch = "http://schemas.google.com/gdata/batch",
                     gs = "http://schemas.google.com/spreadsheets/2006"),
                 .children = list(XML::xmlNode("id", this_ws$cellsfeed))) %>%
                     XML::addChildren(kids = update_entries) %>%
                     XML::toString.XMLNode()

  ## TO DO: according to our policy, we should be using the capability of
  ## httr::POST() to append 'batch` here, but current version of gsheets_POST()
  ## would not support that and other edits are coming there soon ... leave it
  ## for now
  req <-
    gsheets_POST(paste(this_ws$cellsfeed, "batch", sep = "/"), update_feed)

  ## proactive check for successful update
  cell_status <- req$content %>%
    lfilt("entry") %>%
    lapluck("status", .drop = FALSE)
  if(verbose) {
    if(all(cell_status[ , 1] == "200")) {
      sprintf("Worksheet \"%s\" successfully updated with %d new value(s).",
              this_ws$ws_title, length(input)) %>% message()
    } else {
      sprintf(paste("Problems updating cells in worksheet \"%s\".",
                    "Statuses returned:\n"),
              this_ws$ws_title,
              cell_status[ , 2] %>%
                  unique() %>%
                  paste(sep = ",")) %>%
                  message()
    }
  }

  if(trim) {

    Sys.sleep(1)
    ss <- ss %>%
      resize_ws(this_ws$ws_title, limits$`max-row`, limits$`max-col`, verbose)
  }

  Sys.sleep(1)
  ss <- ss %>% register_ss(verbose = FALSE)
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
## header controls whether column names are prepended, when x has 2 dimensions
as_character_vector <- function(x, header = FALSE) {

  catch_hopeless_input(x)

  x_colnames <- NULL

  ## instead of fiddly tests on x (see comments below), just go with it, if x
  ## can be turned into a character vector
  if(dim(x) %>% is.null()) {
    y <- try(x %>% as.character(), silent = TRUE)
  } else if(length(dim(x)) == 2L) {
    x_colnames <- x %>% colnames()
    y <- try(x %>% t() %>% as.character() %>% drop(), silent = TRUE)
  }

  if(y %>% inherits("try-error")) {
    stop("Input cannot be converted to character vector.")
  }

  if(header) {
    y <- c(x_colnames, y)
  }

  y
  ## re: why vetting x directly is not as simple as you would expect
  ## http://stackoverflow.com/questions/19501186/how-to-test-if-object-is-a-vector
  ## https://twitter.com/JennyBryan/status/577950939744591872
  ## https://stat.ethz.ch/pipermail/r-devel/1997-April/017019.html
}
