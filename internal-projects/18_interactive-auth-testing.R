x <- "~/rrr/googlesheets/internal-projects/auth-testing"
if (!dir.exists(x)) dir.create(x)
setwd(x)
getwd()
unlink(list.files(x, all.files = TRUE, no.. = TRUE))

## FYI: in the browser, I am already logged into my personal Google account.

gs_auth()
## kicks to browser:
## googlesheets would like to:
## View and manage your spreadsheets in Google Drive
## View and manage the files in your Google Drive
## Choices: Deny Allow

## Deny!!
## "Authentication complete. Please close this page and return to R."

## Back in R:
# > gs_auth()
# Waiting for authentication in browser...
# Press Esc/Ctrl + C to abort
# Authentication complete.
# Show Traceback
#
# Rerun with Debug
# Error in init_oauth2.0(self$endpoint, self$app, scope = self$params$scope,  :
#                          Bad Request (HTTP 400). Failed to get an access token.

gs_auth()
## this time I "Allow"
## Authentication complete. Please close this page and return to R.
## Back in R:
# Waiting for authentication in browser...
# Press Esc/Ctrl + C to abort
# Authentication complete.

## I want a peek at the access and refresh tokens
user <- gd_user()
# displayName: Jennifer Bryan
# emailAddress: jenny@stat.ubc.ca
# date: 2016-02-15 19:38:08 GMT
# access token: valid
# peek at access token: ya29....tIspM
# peek at refresh token: 1/QO6...F4Ei0

## confirm gs_auth() uses / returns the current token
ttt <- gs_auth()
substr(ttt$credentials$access_token, 1, 5) == substr(user$peek_acc, 1, 5)
substr(ttt$credentials$refresh_token, 1, 5) == substr(user$peek_ref, 1, 5)
## TRUE, TRUE

### write token to file for safekeeping
saveRDS(ttt, "ttt.rds")

## force a new OAuth2.0 flow
uuu <- gs_auth(new_user = TRUE)

## make sure we have a different access and refresh token
user2 <- gd_user()
# displayName: Jennifer Bryan
# emailAddress: jenny@stat.ubc.ca
# date: 2016-02-15 19:42:19 GMT
# access token: valid
# peek at access token: ya29....8OOin
# peek at refresh token: 1/SV2...dOFzA
user$peek_acc != user2$peek_acc
user$peek_ref != user2$peek_ref
## TRUE, TRUE

## put the original token back into force via a token object
vvv <- gs_auth(token = ttt)

## confirm we have original refresh and access token
substr(ttt$credentials$access_token, 1, 5) ==
  substr(vvv$credentials$access_token, 1, 5)
substr(ttt$credentials$refresh_token, 1, 5) ==
  substr(vvv$credentials$refresh_token, 1, 5)
## TRUE, TRUE

### write the second token to file for safekeeping
saveRDS(uuu, "uuu.rds")

## load the second token from rds
www <- gs_auth(token = "uuu.rds")

## confirm we're back to second refresh and access token
substr(www$credentials$access_token, 1, 5) == substr(user2$peek_acc, 1, 5)
substr(www$credentials$refresh_token, 1, 5) == substr(user2$peek_ref, 1, 5)
## TRUE, TRUE

## confirm we react appropriately when garbage provided as token
gs_auth(token = iris)
# Error: Input provided via 'token' is neither a token,
# nor a path to an .rds file containing a token.
gs_auth(token = "i-dont-exist.rds")
# Cannot read token from alleged .rds file:
#   i-dont-exist.rds

## a token should be available
token_available()
## TRUE

## explicitly suspend auth, but don't rename .httr-oauth
(fls <- list.files(pattern = "httr", all.files = TRUE))
any(grepl("^\\.httr-oauth$", fls)) ## TRUE
gs_deauth(clear_cache = FALSE)
(fls <- list.files(pattern = "httr", all.files = TRUE))
any(grepl("^\\.httr-oauth$", fls)) ## TRUE

## a token should NOT be available
token_available(verbose = FALSE)
## FALSE

## again, but DO suspend/rename .httr-oauth
gs_deauth()
(fls <- list.files(pattern = "httr", all.files = TRUE))
any(grepl("^\\.httr-oauth$", fls)) ## FALSE
