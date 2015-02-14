## current hack to test as authenticted user
## requires GSPREADR_PASSWORD environment variable

## achieved locally by the file ~/.R/check.Renviron
## that contains:
## GSPREADR_USERNAME=blahblahblah <-- not actually consulted now
## GSPREADR_PASSWORD=blahblahblah
## this approach works for R CMD check

## there is a second hack on top of the above hack so that lighter-weight
## approaches to testing work, i.e. those that don't fire up a fresh R process,
## such as RStudio > Build > Test package

## finally, this works on Travis because I followed the directions here
## http://docs.travis-ci.com/user/environment-variables/
## http://docs.travis-ci.com/user/encryption-keys/

if(Sys.getenv("GSPREADR_PASSWORD") == "") {
  gspreadr_credentials <- read.table(file.path("~", ".R", "check.Renviron"),
                                     sep = "=", stringsAsFactors = FALSE)
  login("gspreadr@gmail.com", gspreadr_credentials$V2[2])
} else {
  login("gspreadr@gmail.com", Sys.getenv("GSPREADR_PASSWORD"))
}
