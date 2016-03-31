## I don't need this in the package but want to record it somewhere.

## How to get scope info from raw token.
## As long as I have managed my token via httr, I can dig this out of the Token
## object.

devtools::load_all("~/rrr/googlesheets")
gs_auth()
## https://developers.google.com/identity/protocols/OAuth2UserAgent#tokeninfo-validation
url <- file.path(.state$gd_base_url, "oauth2/v3/tokeninfo")
## note: we include the token here in a different way from anywhere in the pkg
url <- httr::modify_url(url, query = list(`access_token` = access_token()))
sc_req <- httr::GET(url) %>%
  httr::stop_for_status()
sc_rc <- content_as_json_UTF8(sc_req)
sc_rc
