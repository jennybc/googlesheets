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
  structure(list(auth = c("email", "passwd"),
                 http_session = NULL), class = "client")
}

# HTTPSession class

#' HTTPSession
#'
#' This function creates http session object.
#'
#'@return Object of class http_session
#'
#' 
#'  
http_session <- function() {
  structure(list(headers = list(),
                 connections = list()), class = "http_session")
}

