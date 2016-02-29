#' \code{googlesheets} package
#'
#' Google spreadsheets R API
#'
#' See the \href{https://github.com/jennybc/googlesheets}{README} on GitHub
#'
#' @docType package
#' @name googlesheets
#' @importFrom dplyr %>%
#' @importFrom purrr %||%
NULL

## quiets concerns of R CMD check re: the .'s that appear in pipelines
if(getRversion() >= "2.15.1")  utils::globalVariables(c("."))
