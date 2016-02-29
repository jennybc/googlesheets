#' @param ... \strong{Optional} arguments to control data download, parsing,
#' and reshaping; for most purposes, the defaults should be fine.
#' \describe{
#'   \item{\code{progress}}{Logical. Whether to display download progress if in
#'   an interactive session.}
#'   \item{\code{col_types}}{Seize control of type conversion for variables.
#'   Passed straight through to
#'   \code{\link[readr:read_delim]{readr::read_csv}} or
#'   \code{\link[readr:type_convert]{readr::type_convert}}. Follow those links
#'   or read the \code{vignette("column-types")} for details.}
#'   \item{\code{locale, trim_ws, na}}{Specify locale, the fate of leading or
#'   trailing whitespace, or a character vector of strings that should become
#'   missing values. Passed straight through to
#'   \code{\link[readr:read_delim]{readr::read_csv}} or
#'   \code{\link[readr:type_convert]{readr::type_convert}}.}
#'   \item{\code{comment, skip, n_max}}{Used only for
#'   \code{\link{gs_read_csv}} or \code{gs_read(..., range = NULL)}.
#'   Passed straight through to
#'   \code{\link[readr:read_delim]{readr::read_csv}}.}
#'   \item{\code{col_names}}{Either \code{TRUE}, \code{FALSE} or a character
#'   vector of column names. If \code{TRUE}, the first row of the data rectangle
#'   will be used for names. If \code{FALSE}, column names will be X1, X2, etc.
#'   If a character vector, it will be used as column names.}
#'   \item{\code{check.names}}{Logical. Whether to run column names through
#'   \code{\link{make.names}} with \code{unique = TRUE}, just like
#'   \code{\link{read.table}} does. By default, \code{googlesheets} implements
#'   the \code{readr} data ingest philosophy, which leaves column names "as is",
#'   with one exception: data frames returned by \code{googlesheets} will have
#'   a name for each variable, even if we have to create one.}
#' }
