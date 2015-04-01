.onLoad <- function(libname, pkgname) {
  op <- options()
  op.gspreadr <- list(
    gspreadr.client_id = "178989665258-f4scmimctv2o96isfppehg1qesrpvjro.apps.googleusercontent.com",
    gspreadr.client_secret = "iWPrYg0lFHNQblnRrDbypvJL"
  )
  toset <- !(names(op.gspreadr) %in% names(op))
  if(any(toset)) options(op.gspreadr[toset])

  invisible()
}
