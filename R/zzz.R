.onLoad <- function(libname, pkgname) {
  op <- options()
  op.googlesheets <- list(
    googlesheets.client_id = "178989665258-f4scmimctv2o96isfppehg1qesrpvjro.apps.googleusercontent.com",
    googlesheets.client_secret = "iWPrYg0lFHNQblnRrDbypvJL",
    googlesheets.shiny.client_id = "178989665258-mbn7q84ai89if6ja59jmh8tqn5aqoe3n.apps.googleusercontent.com",
    googlesheets.shiny.client_secret = "UiF2uCHeMiUH0BeNbSAzzBxL"
  )
  toset <- !(names(op.googlesheets) %in% names(op))
  if(any(toset)) options(op.googlesheets[toset])

  invisible()
}
