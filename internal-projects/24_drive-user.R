#' ---
#' output: github_document
#' ---

#+ setup, include = FALSE
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

#' wd has to be where this file lives (googlesheets/internal-projects), so that
#' it is same as that during rmarkdown::render.
devtools::load_all("..")
`%>%` <- dplyr::`%>%`

#' Get the JSON from <https://developers.google.com/drive/v2/reference/about>,
#' which retrieves info for the Google Drive user associated with current token.
#' *Refresh an existing token so the one on travis doesn't fall off the end so
#' often.*
gs_auth(token = file.path("..", "tests", "testthat", "googlesheets_token.rds"))
if (!token_available(verbose = FALSE)) {
  stop("NO NO NO NO NO NEW TOKENS!")
}
url <- file.path(.state$gd_base_url, "drive/v2/about")
req <- httr::GET(url, google_token()) %>%
  httr::stop_for_status()

#' Write the JSON to file so we can stick it in this gist.
req %>%
  httr::content(as = "text") %>%
  jsonlite::prettify() %>%
  cat(file = "drive_user.json")

#' JSON --> list
rc <- content_as_json_UTF8(req)

#' Yuck.
str(rc)

#' This has a list column but doesn't need it, i.e. the list could be a
#' character vector.
str(rc$importFormats)

#' This has a list column and does need it.
str(rc$exportFormats)

#' Yo I hear you like data frames with list columns inside a list column inside
#' your data frame.
str(rc$additionalRoleInfo)
#' Amazingly, just printing this is more attractive.
rc$additionalRoleInfo
tibble::as_data_frame(rc$additionalRoleInfo)

# gistr::gist_create("24_drive-user.R",
#                    description = "Annoying list from the Google Drive API",
#                    public = FALSE, knit = TRUE, include_source = TRUE) %>%
#   gistr::add_files("drive_user.json") %>%
#   gistr::update()
