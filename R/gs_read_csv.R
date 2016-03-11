#' Read data via the \code{exportcsv} link
#'
#' This function reads all data from a worksheet and returns it as a
#' \code{tbl_df} or \code{data.frame}. Don't be spooked by the "csv" thing --
#' the data is NOT actually written to file during this process. Data is read
#' from the "maximal data rectangle", i.e. the rectangle spanned by the maximal
#' row and column extent of the data. By default, empty cells within this
#' rectangle will be assigned \code{NA}. This is the fastest method of data
#' consumption, so use it as long as you can tolerate the lack of control re:
#' which cells are being read.
#'
#' @template ss
#' @template ws
#' @template read-ddd
#' @template verbose
#'
#' @family data consumption functions
#'
#' @template return-tbl-df
#'
#' @examples
#' \dontrun{
#' gap_ss <- gs_gap() # register the Gapminder example sheet
#' oceania_csv <- gs_read_csv(gap_ss, ws = "Oceania")
#' str(oceania_csv)
#' oceania_csv
#'
#' ## crazy demo of passing args through to readr::read_csv()
#' oceania_crazy <- gs_read_csv(gap_ss, ws = "Oceania",
#'   col_names = paste0("Z", 1:6), na = "1962", col_types = "cccccc", skip = 1)
#' oceania_crazy
#' }
#' @export
gs_read_csv <- function(ss, ws = 1, ..., verbose = TRUE) {

  stopifnot(inherits(ss, "googlesheet"))
  ddd <- parse_read_ddd(..., verbose = verbose)
  this_ws <- gs_ws(ss, ws, verbose)

  if (is.null(this_ws$exportcsv)) {
    stop("This appears to be an \"old\" Google Sheet. The old Sheets do\n",
         "not offer the API access required by this function.\n",
         "Consider converting it from an old Sheet to a new Sheet.\n",
         "Or use another data consumption function, such as\n",
         "gs_read_listfeed() or gs_read_cellfeed(). Or use gs_download()\n",
         "to export it to a local file and then read it into R.",
         call. = FALSE)
  }

  req <-
    httr::GET(this_ws$exportcsv,
              omit_token_if(ss$is_public),
              if (interactive() && ddd$progress && verbose) httr::progress() else NULL) %>%
    httr::stop_for_status()
  stop_for_content_type(req, "text/csv")

  if (is.null(req$content) || length(req$content) == 0L) {
    if (verbose) mpf("Worksheet '%s' is empty.", this_ws$ws_title)
    return(dplyr::data_frame())
  }

  content <- httr::content(req, as = "text")
  if (!stringr::str_detect(content, "\n")) {
    content <- stringr::str_c(content, "\n")
  }

  allowed_args <- c("col_types", "col_names", "locale", "trim_ws", "na",
                    ## specific to csv
                    "comment", "skip", "n_max")
  read_csv_args <- c(list(file = content), dropnulls(ddd[allowed_args]))
  df <- do.call(readr::read_csv, read_csv_args)

  ## our departures from readr data ingest:
  ## no NA variable names
  ## NA vars should be logical, not character
  nms <- names(df)
  names(df) <- fix_names(nms, ddd$check.names)
  df %>%
    purrr::dmap(force_na_type)

}
