## Gapminder
gap_URL <- "https://docs.google.com/spreadsheets/d/1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE/"
gap_title <- "Gapminder"
gap_key <- "1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE"
gap_ws_feed <- "https://spreadsheets.google.com/feeds/worksheets/1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE/private/full"


## Public Testing Sheet (also based on Gapminder)
pts_url <- "https://docs.google.com/spreadsheets/d/1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk/"
pts_title <- "Public Testing Sheet"
pts_key <- "1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk"
pts_ws_feed <- "https://spreadsheets.google.com/feeds/worksheets/1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk/public/full"

## current hack to test as authenticted user
## requires there be a file ~/.R/check.Renviron
## that contains:
## GSPREADR_USERNAME=blahblahblah
## GSPREADR_PASSWORD=blahblahblah
## this approach works for R CMD check

## hack on top of the above hack so that lighter-weight approaches to testing,
## that don't fire up a fresh R process, e.g. "Test package", also works
if(Sys.getenv("TRAVIS") != "true") {
  if(Sys.getenv("GSPREADR_USERNAME") == "") {
    gspreadr_credentials <- read.table(file.path("~", ".R", "check.Renviron"),
                                       sep = "=", stringsAsFactors = FALSE)
    login(gspreadr_credentials$V2[1], gspreadr_credentials$V2[2])
  } else {
    login(Sys.getenv("GSPREADR_USERNAME"), Sys.getenv("GSPREADR_PASSWORD"))
  }
}
