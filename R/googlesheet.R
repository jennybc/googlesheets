#' The googlesheet object
#' 
#' The googlesheet object stores information that \code{googlesheets} requires in
#' order to communicate with the
#' \href{https://developers.google.com/google-apps/spreadsheets/}{Google Sheets
#' API}.
#' 
#' Very little of this is of interest to the user. A googlesheet object
#' includes the fields:
#'
#' \itemize{
#' \item \code{sheet_key} the key of the spreadsheet
#' \item \code{sheet_title} the title of the spreadsheet
#' \item \code{n_ws} the number of worksheets contained in the spreadsheet
#' \item \code{ws_feed} the "worksheets feed" of the spreadsheet
#' \item \code{sheet_id} the id of the spreadsheet
#' \item \code{updated} the time of last update (at time of registration)
#' \item \code{get_date} the time of registration
#' \item \code{visibility} visibility of spreadsheet (Google's confusing 
#' vocabulary); actually, does not describe a property of spreadsheet itself but
#' rather whether requests will be made with or without authentication
#' \item \code{is_public} logical indicating visibility is "public", as opposed to "private"
#' \item \code{author_name} the name of the owner
#' \item \code{author_email} the email of the owner
#' \item \code{links} data.frame of links specific to the spreadsheet
#' \item \code{ws} a data.frame about the worksheets contained in the
#' spreadsheet
#' \item \code{alt_key} alternate key; applies only to "old" sheets
#' }
#'
#' TO DO: this documentation is neither here nor there. Either the object is
#' self-explanatory and this isn't really needed. Or this needs to get beefed
#' up. Probably the latter.
#' 
#' @name googlesheet
googlesheet <- function() {
  structure(list(sheet_key = character(),
                 sheet_title = character(),
                 n_ws = integer(),
                 ws_feed = character(),
                 sheet_id = character(),
                 updated = character() %>% as.POSIXct(),
                 get_date = character() %>% as.POSIXct(),
                 visibility = character(),
                 is_public = logical(),
                 author_name = character(),
                 author_email = character(),
                 links = character(), # initialize as data.frame?
                 ws = list(),
                 alt_key = character()),
            class = c("googlesheet", "list"))
  
}
