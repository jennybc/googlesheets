Extract an example for testing xml2's new ability to create XML
================

This just contains code needed to extract the input needed to test drive xml2's XML-authoring capability. And that is actually done in the next file, because I posted that stuff as a gist for sharing with others.

``` r
#devtools::install_github("hadley/xml2#76")
si <- devtools::session_info("xml2")$packages
stopifnot(si$source[si$package == "xml2"] == "Github (jimhester/xml2@04a83fe)")
```

``` r
library(rprojroot)
```

    ## Warning: package 'rprojroot' was built under R version 3.2.4

``` r
pkg_root <- function(...) file.path(find_package_root_file(), ...) 
library(googlesheets)
```

``` r
token_path <- pkg_root("tests", "testthat", "googlesheets_token.rds")
gs_auth(token = token_path, verbose = FALSE)
```

    ## Auto-refreshing stale OAuth token.

``` r
library(dplyr)
```

    ## 
    ## Attaching package: 'dplyr'

    ## The following objects are masked from 'package:stats':
    ## 
    ##     filter, lag

    ## The following objects are masked from 'package:base':
    ## 
    ##     intersect, setdiff, setequal, union

``` r
# (ss <- gs_mini_gap() %>% 
#   gs_copy("xml2-test"))
(ss <- gs_title("xml2-test"))
```

    ## Sheet successfully identified: "xml2-test"

    ##                   Spreadsheet title: xml2-test
    ##                  Spreadsheet author: gspreadr
    ##   Date of googlesheets registration: 2016-05-13 00:14:30 GMT
    ##     Date of last spreadsheet update: 2016-05-11 19:31:50 GMT
    ##                          visibility: private
    ##                         permissions: rw
    ##                             version: new
    ## 
    ## Contains 5 worksheets:
    ## (Title): (Nominal worksheet extent as rows x columns)
    ## Africa: 6 x 6
    ## Americas: 6 x 6
    ## Asia: 6 x 6
    ## Europe: 6 x 6
    ## Oceania: 6 x 6
    ## 
    ## Key: 1tP1SAErOJbMrTTCONdL0a9lwe3KkhTuZaGhCy3MPZP8
    ## Browser URL: https://docs.google.com/spreadsheets/d/1tP1SAErOJbMrTTCONdL0a9lwe3KkhTuZaGhCy3MPZP8/

``` r
cells_df <- ss %>%
  gs_read_cellfeed(ws = "Africa", return_links = TRUE)
```

    ## Accessing worksheet titled 'Africa'.

``` r
update_fodder <- cells_df %>%
  mutate(update_value = value) %>% 
  select(-cell_alt, -value, -input_value, -numeric_value)
readr::write_csv(update_fodder, "27_update-fodder.csv")
```

``` r
#gs_delete(ss)
```
