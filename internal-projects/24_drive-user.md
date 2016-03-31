24\_drive-user.R
================
jenny
Sun Mar 20 12:20:50 2016

wd has to be where this file lives (googlesheets/internal-projects), so that it is same as that during rmarkdown::render.

``` r
devtools::load_all("..")
#> Loading googlesheets
`%>%` <- dplyr::`%>%`
```

Get the JSON from <https://developers.google.com/drive/v2/reference/about>, which retrieves info for the Google Drive user associated with current token. *Refresh an existing token so the one on travis doesn't fall off the end so often.*

``` r
gs_auth(token = file.path("..", "tests", "testthat", "googlesheets_token.rds"))
#> Auto-refreshing stale OAuth token.
if (!token_available(verbose = FALSE)) {
  stop("NO NO NO NO NO NEW TOKENS!")
}
url <- file.path(.state$gd_base_url, "drive/v2/about")
req <- httr::GET(url, google_token()) %>%
  httr::stop_for_status()
```

Write the JSON to file so we can stick it in this gist.

``` r
req %>%
  httr::content(as = "text") %>%
  jsonlite::prettify() %>%
  cat(file = "drive_user.json")
```

JSON --&gt; list

``` r
rc <- content_as_json_UTF8(req)
```

Yuck.

``` r
str(rc)
#> List of 23
#>  $ kind                   : chr "drive#about"
#>  $ etag                   : chr "\"AX-9UqTeeqJtNriewvlwE_loMM8/AMp69c9jkxR7nT1-Jr2LKsPS6mM\""
#>  $ selfLink               : chr "https://www.googleapis.com/drive/v2/about"
#>  $ name                   : chr "google sheets"
#>  $ user                   :List of 5
#>   ..$ kind               : chr "drive#user"
#>   ..$ displayName        : chr "google sheets"
#>   ..$ isAuthenticatedUser: logi TRUE
#>   ..$ permissionId       : chr "14497944239034869033"
#>   ..$ emailAddress       : chr "gspreadr@gmail.com"
#>  $ quotaBytesTotal        : chr "16106127360"
#>  $ quotaBytesUsed         : chr "280"
#>  $ quotaBytesUsedAggregate: chr "21152776"
#>  $ quotaBytesUsedInTrash  : chr "0"
#>  $ quotaType              : chr "LIMITED"
#>  $ quotaBytesByService    :'data.frame': 3 obs. of  2 variables:
#>   ..$ serviceName: chr [1:3] "DRIVE" "GMAIL" "PHOTOS"
#>   ..$ bytesUsed  : chr [1:3] "0" "21152496" "0"
#>  $ largestChangeId        : chr "269524"
#>  $ rootFolderId           : chr "0AOdw-qi1jh3fUk9PVA"
#>  $ domainSharingPolicy    : chr "allowed"
#>  $ permissionId           : chr "14497944239034869033"
#>  $ importFormats          :'data.frame': 44 obs. of  2 variables:
#>   ..$ source : chr [1:44] "application/x-vnd.oasis.opendocument.presentation" "text/tab-separated-values" "image/jpeg" "image/bmp" ...
#>   ..$ targets:List of 44
#>   .. ..$ : chr "application/vnd.google-apps.presentation"
#>   .. ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.presentation"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.script"
#>   .. ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.presentation"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   .. ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.script"
#>   .. ..$ : chr "application/vnd.google-apps.drawing"
#>   .. ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   .. ..$ : chr "application/vnd.google-apps.presentation"
#>   .. ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.presentation"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.presentation"
#>   .. ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   .. ..$ : chr "application/vnd.google-apps.script"
#>   .. ..$ : chr "application/vnd.google-apps.presentation"
#>   .. ..$ : chr "application/vnd.google-apps.presentation"
#>   .. ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   .. ..$ : chr "application/vnd.google-apps.presentation"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>   .. ..$ : chr "application/vnd.google-apps.document"
#>  $ exportFormats          :'data.frame': 6 obs. of  2 variables:
#>   ..$ source : chr [1:6] "application/vnd.google-apps.form" "application/vnd.google-apps.document" "application/vnd.google-apps.drawing" "application/vnd.google-apps.spreadsheet" ...
#>   ..$ targets:List of 6
#>   .. ..$ : chr "application/zip"
#>   .. ..$ : chr [1:7] "application/rtf" "application/vnd.oasis.opendocument.text" "text/html" "application/pdf" ...
#>   .. ..$ : chr [1:4] "image/svg+xml" "image/png" "application/pdf" "image/jpeg"
#>   .. ..$ : chr [1:5] "text/csv" "application/x-vnd.oasis.opendocument.spreadsheet" "application/zip" "application/pdf" ...
#>   .. ..$ : chr "application/vnd.google-apps.script+json"
#>   .. ..$ : chr [1:3] "application/vnd.openxmlformats-officedocument.presentationml.presentation" "application/pdf" "text/plain"
#>  $ additionalRoleInfo     :'data.frame': 6 obs. of  2 variables:
#>   ..$ type    : chr [1:6] "application/vnd.google-apps.drawing" "application/vnd.google-apps.document" "application/vnd.google-apps.presentation" "*" ...
#>   ..$ roleSets:List of 6
#>   .. ..$ :'data.frame':  1 obs. of  2 variables:
#>   .. .. ..$ primaryRole    : chr "reader"
#>   .. .. ..$ additionalRoles:List of 1
#>   .. .. .. ..$ : chr "commenter"
#>   .. ..$ :'data.frame':  1 obs. of  2 variables:
#>   .. .. ..$ primaryRole    : chr "reader"
#>   .. .. ..$ additionalRoles:List of 1
#>   .. .. .. ..$ : chr "commenter"
#>   .. ..$ :'data.frame':  1 obs. of  2 variables:
#>   .. .. ..$ primaryRole    : chr "reader"
#>   .. .. ..$ additionalRoles:List of 1
#>   .. .. .. ..$ : chr "commenter"
#>   .. ..$ :'data.frame':  1 obs. of  2 variables:
#>   .. .. ..$ primaryRole    : chr "reader"
#>   .. .. ..$ additionalRoles:List of 1
#>   .. .. .. ..$ : chr "commenter"
#>   .. ..$ :'data.frame':  1 obs. of  2 variables:
#>   .. .. ..$ primaryRole    : chr "reader"
#>   .. .. ..$ additionalRoles:List of 1
#>   .. .. .. ..$ : chr "commenter"
#>   .. ..$ :'data.frame':  0 obs. of  0 variables
#>  $ features               :'data.frame': 2 obs. of  2 variables:
#>   ..$ featureName: chr [1:2] "ocr" "translation"
#>   ..$ featureRate: num [1:2] NA 2
#>  $ maxUploadSizes         :'data.frame': 6 obs. of  2 variables:
#>   ..$ type: chr [1:6] "application/vnd.google-apps.document" "application/vnd.google-apps.spreadsheet" "application/vnd.google-apps.presentation" "application/vnd.google-apps.drawing" ...
#>   ..$ size: chr [1:6] "10485760" "104857600" "104857600" "2097152" ...
#>  $ isCurrentAppInstalled  : logi FALSE
#>  $ languageCode           : chr "en-US"
#>  $ folderColorPalette     : chr [1:24] "#ac725e" "#d06b64" "#f83a22" "#fa573c" ...
```

This has a list column but doesn't need it, i.e. the list could be a character vector.

``` r
str(rc$importFormats)
#> 'data.frame':    44 obs. of  2 variables:
#>  $ source : chr  "application/x-vnd.oasis.opendocument.presentation" "text/tab-separated-values" "image/jpeg" "image/bmp" ...
#>  $ targets:List of 44
#>   ..$ : chr "application/vnd.google-apps.presentation"
#>   ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.presentation"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.script"
#>   ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.presentation"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.script"
#>   ..$ : chr "application/vnd.google-apps.drawing"
#>   ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   ..$ : chr "application/vnd.google-apps.presentation"
#>   ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.presentation"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.presentation"
#>   ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   ..$ : chr "application/vnd.google-apps.script"
#>   ..$ : chr "application/vnd.google-apps.presentation"
#>   ..$ : chr "application/vnd.google-apps.presentation"
#>   ..$ : chr "application/vnd.google-apps.spreadsheet"
#>   ..$ : chr "application/vnd.google-apps.presentation"
#>   ..$ : chr "application/vnd.google-apps.document"
#>   ..$ : chr "application/vnd.google-apps.document"
```

This has a list column and does need it.

``` r
str(rc$exportFormats)
#> 'data.frame':    6 obs. of  2 variables:
#>  $ source : chr  "application/vnd.google-apps.form" "application/vnd.google-apps.document" "application/vnd.google-apps.drawing" "application/vnd.google-apps.spreadsheet" ...
#>  $ targets:List of 6
#>   ..$ : chr "application/zip"
#>   ..$ : chr  "application/rtf" "application/vnd.oasis.opendocument.text" "text/html" "application/pdf" ...
#>   ..$ : chr  "image/svg+xml" "image/png" "application/pdf" "image/jpeg"
#>   ..$ : chr  "text/csv" "application/x-vnd.oasis.opendocument.spreadsheet" "application/zip" "application/pdf" ...
#>   ..$ : chr "application/vnd.google-apps.script+json"
#>   ..$ : chr  "application/vnd.openxmlformats-officedocument.presentationml.presentation" "application/pdf" "text/plain"
```

Yo I hear you like data frames with list columns inside a list column inside your data frame.

``` r
str(rc$additionalRoleInfo)
#> 'data.frame':    6 obs. of  2 variables:
#>  $ type    : chr  "application/vnd.google-apps.drawing" "application/vnd.google-apps.document" "application/vnd.google-apps.presentation" "*" ...
#>  $ roleSets:List of 6
#>   ..$ :'data.frame': 1 obs. of  2 variables:
#>   .. ..$ primaryRole    : chr "reader"
#>   .. ..$ additionalRoles:List of 1
#>   .. .. ..$ : chr "commenter"
#>   ..$ :'data.frame': 1 obs. of  2 variables:
#>   .. ..$ primaryRole    : chr "reader"
#>   .. ..$ additionalRoles:List of 1
#>   .. .. ..$ : chr "commenter"
#>   ..$ :'data.frame': 1 obs. of  2 variables:
#>   .. ..$ primaryRole    : chr "reader"
#>   .. ..$ additionalRoles:List of 1
#>   .. .. ..$ : chr "commenter"
#>   ..$ :'data.frame': 1 obs. of  2 variables:
#>   .. ..$ primaryRole    : chr "reader"
#>   .. ..$ additionalRoles:List of 1
#>   .. .. ..$ : chr "commenter"
#>   ..$ :'data.frame': 1 obs. of  2 variables:
#>   .. ..$ primaryRole    : chr "reader"
#>   .. ..$ additionalRoles:List of 1
#>   .. .. ..$ : chr "commenter"
#>   ..$ :'data.frame': 0 obs. of  0 variables
```

Amazingly, just printing this is more attractive.

``` r
rc$additionalRoleInfo
#>                                       type          roleSets
#> 1      application/vnd.google-apps.drawing reader, commenter
#> 2     application/vnd.google-apps.document reader, commenter
#> 3 application/vnd.google-apps.presentation reader, commenter
#> 4                                        * reader, commenter
#> 5  application/vnd.google-apps.spreadsheet reader, commenter
#> 6            application/vnd.google-apps.*              NULL
tibble::as_data_frame(rc$additionalRoleInfo)
#> Source: local data frame [6 x 2]
#> 
#>                                       type           roleSets
#>                                      <chr>             <list>
#> 1      application/vnd.google-apps.drawing <data.frame [1,2]>
#> 2     application/vnd.google-apps.document <data.frame [1,2]>
#> 3 application/vnd.google-apps.presentation <data.frame [1,2]>
#> 4                                        * <data.frame [1,2]>
#> 5  application/vnd.google-apps.spreadsheet <data.frame [1,2]>
#> 6            application/vnd.google-apps.* <data.frame [0,0]>

# gistr::gist_create("24_drive-user.R",
#                    description = "Annoying list from the Google Drive API",
#                    public = FALSE, knit = TRUE, include_source = TRUE) %>%
#   gistr::add_files("drive_user.json") %>%
#   gistr::update()
```
