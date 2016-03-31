Listing Drive files
================

Fodder for a `gd_ls()` function.

``` r
devtools::load_all("..")
```

    ## Loading googlesheets

``` r
gs_auth(file.path("..", "tests", "testthat", "googlesheets_token.rds"))
```

    ## Auto-refreshing stale OAuth token.

``` r
drfiles <- httr::GET(.state$gd_base_url_files_v3, get_google_token())
httr::status_code(drfiles)
```

    ## [1] 200

``` r
drfiles <- content_as_json_UTF8(drfiles)
str(drfiles)
```

    ## List of 3
    ##  $ kind         : chr "drive#fileList"
    ##  $ nextPageToken: chr "V1*3|0|CiwxWm5HckxSTW9kS0JPeWRMWlRGOV9RbjFFNjFXd0xMQ2RRNi1FLTU5ZFVCOBIHEKzE--OuKg"
    ##  $ files        :'data.frame':   100 obs. of  4 variables:
    ##   ..$ kind    : chr [1:100] "drive#file" "drive#file" "drive#file" "drive#file" ...
    ##   ..$ id      : chr [1:100] "14mAbIi1UyZtJTDuIa7iMb80xYtXbxCr-TGlvFbPgi3E" "1WH65aJjlmhOWYMFkhDuKPcRa5mloOtsTCKxrF7erHgI" "1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ" "137pijO8ml6LAeRjvnEquQgWlPPlr5sysvybuUUs7vX4" ...
    ##   ..$ name    : chr [1:100] "EasyTweetSheet - Shared" "gas_mileage" "12" "test-gs-ingest" ...
    ##   ..$ mimeType: chr [1:100] "application/vnd.google-apps.spreadsheet" "application/vnd.google-apps.spreadsheet" "application/vnd.google-apps.spreadsheet" "application/vnd.google-apps.spreadsheet" ...

``` r
head(drfiles$files)
```

    ##         kind                                           id
    ## 1 drive#file 14mAbIi1UyZtJTDuIa7iMb80xYtXbxCr-TGlvFbPgi3E
    ## 2 drive#file 1WH65aJjlmhOWYMFkhDuKPcRa5mloOtsTCKxrF7erHgI
    ## 3 drive#file 1oLRq_aSy5A6uh60-Hk3EZ3bcu-rGJBx_H7VuXRxn2FQ
    ## 4 drive#file 137pijO8ml6LAeRjvnEquQgWlPPlr5sysvybuUUs7vX4
    ## 5 drive#file 1O26pcuDamhUvdUcK24qF3ZIA64_E8o12QkJkPuCP3zg
    ## 6 drive#file 1g3AIG-z17lTb5_miqcXfxoqpjQUHXrXHolBUfNAyAY4
    ##                               name                                mimeType
    ## 1          EasyTweetSheet - Shared application/vnd.google-apps.spreadsheet
    ## 2                      gas_mileage application/vnd.google-apps.spreadsheet
    ## 3                               12 application/vnd.google-apps.spreadsheet
    ## 4                   test-gs-ingest application/vnd.google-apps.spreadsheet
    ## 5 test-gs-jenny-594a50c22457-name2 application/vnd.google-apps.spreadsheet
    ## 6   Copy of test-gs-mini-gapminder application/vnd.google-apps.spreadsheet
