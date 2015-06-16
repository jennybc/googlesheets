.onLoad <- function(libname, pkgname) {

  op <- options()
  op.googlesheets <- list(
    ## httr_oauth_cache can be a path, but I'm only really thinking about and
    ## supporting the simpler TRUE/FALSE usage, i.e. assuming that .httr-oauth
    ## will live in current working directory if it exists at all
    ## this is main reason for creating this googlesheets-specific variant
    googlesheets.httr_oauth_cache = TRUE,
    googlesheets.client_id = "178989665258-f4scmimctv2o96isfppehg1qesrpvjro.apps.googleusercontent.com",
    googlesheets.client_secret = "iWPrYg0lFHNQblnRrDbypvJL",
    googlesheets.webapp.client_id = "178989665258-mbn7q84ai89if6ja59jmh8tqn5aqoe3n.apps.googleusercontent.com",
    googlesheets.webapp.client_secret = "UiF2uCHeMiUH0BeNbSAzzBxL",
    googlesheets.webapp.redirect_uri = "http://127.0.0.1:4642"
  )
  toset <- !(names(op.googlesheets) %in% names(op))
  if(any(toset)) options(op.googlesheets[toset])

  invisible()

}
