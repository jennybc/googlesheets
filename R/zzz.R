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
