# Constructors for spreadsheet, worksheet client, http_session classes ----

#' Spreadsheets 
#'
#' This function creates spreadsheet objects.
#'
#'@return Object of class spreadsheet.
#'
#' 
#'  
spreadsheet <- function() {
  structure(list(sheet_id = character(),
                 updated = character(),
                 sheet_title = character(),
                 nsheets = integer(),
                 ws_names = character(),
                 worksheets = list()), class = "spreadsheet")
}

#' Worksheets
#'
#' This function creates worksheet objects
#'
#'@return Object of class worksheet.
#'
worksheet <- function() {
  structure(list(sheet_id = character(),
                 id = character(),
                 title = character(),
                 listfeed = character(),
                 cellsfeed = character()), class = "worksheet")
}


# Client class

#' Client
#'
#' The function creates client object.
#'
#'@return Object of class client.
#'
#'
#'
client <- function() {
  structure(list(auth = NULL), 
            class = "client")
}

# # HTTPSession class
# 
# #' HTTPSession
# #'
# #' This function creates http session object.
# #'
# #'@return Object of class http_session
# #'
# #'
# #'
# http_session <- function() {
#   structure(list(headers = list(),
#                  connections = list()), class = "http_session")
# }
