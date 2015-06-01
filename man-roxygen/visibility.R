#' @param visibility character, either "public" or "private". Consulted during
#'   explicit construction of a worksheets feed from a key, which happens only
#'   when \code{lookup = FALSE} and \code{googlesheets} is prevented from
#'   looking up information in the spreadsheets feed. If unspecified, will be
#'   set to "public" if \code{lookup = FALSE} and "private" if \code{lookup =
#'   TRUE}. Consult the API docs for more info about
#'   \href{https://developers.google.com/google-apps/spreadsheets/worksheets#sheets_api_urls_visibilities_and_projections}{visibility}
