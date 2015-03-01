`%>%` <- magrittr::`%>%`

## current hacks to test as authorized user:
## first choice is to use (and trigger auto-refresh) of .httr-oauth
## second choice is to login w/ gpsreadr username and password, using
## GSPREADR_PASSWORD environment variable

## assume the worst
Sys.setenv(OAUTH = "FALSE")

## look for .httr-oauth in pwd (assuming pwd is gspreadr) or two levels up
## (assuming pwd is gspreadr/tests/testthat)
pwd <- getwd()
two_up <- pwd %>% dirname() %>% dirname()
HTTR_OAUTH <- c(two_up, pwd) %>% file.path(".httr-oauth")
HTTR_OAUTH <- HTTR_OAUTH[HTTR_OAUTH %>% file.exists()]

if(length(HTTR_OAUTH) > 0) {
  HTTR_OAUTH <- HTTR_OAUTH[1]
  file.copy(from = HTTR_OAUTH, to = ".httr-oauth", overwrite = TRUE)
  Sys.setenv(OAUTH = "TRUE")
}

## uncomment to force username/password auth
#Sys.setenv(OAUTH = "FALSE")

## we define environment variables on local machines in ~/.R/check.Renviron
## which contains:
## GSPREADR_USERNAME=blahblahblah <-- not actually consulted now
## GSPREADR_PASSWORD=blahblahblah
## this approach works for R CMD check

## for other testing approaches, we might just read that file explicitly
## example: RStudio > Build > Test package (if no .httr-oauth had been found)

## finally, login approach works on Travis because did this:
## http://docs.travis-ci.com/user/environment-variables/
## http://docs.travis-ci.com/user/encryption-keys/

if(Sys.getenv("OAUTH") == "FALSE") {
  
  if(Sys.getenv("GSPREADR_PASSWORD") == "") {
    gspreadr_credentials <- read.table(file.path("~", ".R", "check.Renviron"),
                                       sep = "=", stringsAsFactors = FALSE)
    login("gspreadr@gmail.com", gspreadr_credentials$V2[2])
  } else {
    login("gspreadr@gmail.com", Sys.getenv("GSPREADR_PASSWORD"))
  }

}

## custom skipper to skip tests against Google Drive API when authenticating via
## login/username, which it does not support
check_oauth <- function() {
  if (Sys.getenv("OAUTH") == "FALSE") {
    skip("OAuth not in use; cannot test this function")
  }
}

## I DON"T KNOW WHY THIS WORKS / HELPS BUT IT DOES!
## MORE RELIABLY FORCED AUTO-REFRESH OF STALE OAUTH TOKEN
list_sheets()
