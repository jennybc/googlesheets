.onLoad <- function(libname, pkgname) {

  ## we could actually hardwire the id and secret into gs_auth()
  ## but I'm leaving this here ... in case other uses arise for package options
  op <- options()
  op.googlesheets <- list(
    googlesheets.client_id = "178989665258-f4scmimctv2o96isfppehg1qesrpvjro.apps.googleusercontent.com",
    googlesheets.client_secret = "iWPrYg0lFHNQblnRrDbypvJL"
  )
  toset <- !(names(op.googlesheets) %in% names(op))
  if(any(toset)) options(op.googlesheets[toset])

  invisible()

}

.onAttach <- function(libname, pkgname) {

  ## look up key for gapminder example sheet online
  ## if doesn't seem to go well, fall back value defined in gs_example_sheets.R
  ## is already in place
  jfun <- function(purl, key) {
    req <-
      try(httr::GET(get(purl, envir = .gs_exsheets)), silent = TRUE)
    if(inherits(req, "response") && httr::status_code(req) == 200) {
      assign(key, extract_key_from_url(req$url), envir = .gs_exsheets)
    } else {
      paste("googlesheets: can't resolve persistent URL for example sheet",
            "\"%s\" online; falling back to static default.") %>%
        sprintf(purl) %>%
        packageStartupMessage()
    }
  }
  jfun("gap_purl", "gap_key")

  invisible()

}
