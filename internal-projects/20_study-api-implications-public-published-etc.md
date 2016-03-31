Study of what makes a Sheet available via the API
================

I want to get to the bottom of what makes a Sheet available to whom via the API. Accessing one's own Sheet is trivial. More difficult is making something readable by all people or a specific set of people AND having it apply to all the read methods supported by `googlesheets`. It's clearly more complicated than "Publishing to the web" or making something "Public on the web" (which are, in fact, not the same thing).

Issues or Sheets that have presented unexpected problems (some of which are probably due to known Sheets API bugs and not me):

-   [Sheet that holds the data](https://docs.google.com/spreadsheets/d/1KYMUjrCulPtpUHwep9bVvsBvmVsDEbucdyRZ5uHCDxw/edit#gid=0) for [this caffeine and calories plot](http://www.informationisbeautiful.net/visualizations/caffeine-and-calories/) from informationisbeautiful:
    -   <https://github.com/jennybc/googlesheets/issues/167>
-   The candy data gave us some trouble, I recall
    -   <https://github.com/STAT545-UBC/Discussion/issues/193>
    -   but I think I probably talked Dave into sharing it all possible ways to design away our problem.
-   Gapminder-provided Google Sheets have this property where they can be read via cellfeed and listfeed but not exportcsv
    -   <https://github.com/STAT545-UBC/Discussion/issues/194>

*I'll be back ....*

*TO DO: remember to include `visibility` (public vs private) from Sheet feeds in this exercise.*

``` r
##https://docs.google.com/spreadsheets/d/137pijO8ml6LAeRjvnEquQgWlPPlr5sysvybuUUs7vX4/pubhtml
library(googlesheets)
ingest_key <- "137pijO8ml6LAeRjvnEquQgWlPPlr5sysvybuUUs7vX4"
ss <- gs_key(ingest_key, lookup = FALSE)
```

    ## Authorization will not be used.

    ## Worksheets feed constructed with public visibility

``` r
csv <- gs_read_csv(ss)
```

    ## Accessing worksheet titled "Sheet1"

    ## No encoding supplied: defaulting to UTF-8.

``` r
lf <- gs_read_listfeed(ss)
```

    ## Accessing worksheet titled "Sheet1"

``` r
cf <- gs_read_cellfeed(ss)
```

    ## Accessing worksheet titled "Sheet1"

``` r
csv
```

    ## Source: local data frame [6 x 9]
    ## 
    ##   character integer      dates             iso8601 textcommas numcommas
    ##       (chr)   (int)     (date)              (time)      (chr)     (dbl)
    ## 1        aa       0 2016-02-19 2016-02-19 16:08:41        a,b      1234
    ## 2        bb       1 2016-02-20 2016-02-20 16:08:41        b,c      2345
    ## 3        cc       2 2016-02-21 2016-02-21 16:08:41        c,d      3456
    ## 4        dd       3 2016-02-22 2016-02-22 16:08:41        d,e      4567
    ## 5        NA      NA       <NA>                <NA>         NA        NA
    ## 6        ff       5 2016-02-24 2016-02-24 16:08:41        f,g      6789
    ## Variables not shown: hasempty (chr), NA (chr), hello (chr).

``` r
lf
```

    ## Source: local data frame [4 x 8]
    ## 
    ##   character integer      dates             iso8601 textcommas numcommas
    ##       (chr)   (int)     (date)              (time)      (chr)     (dbl)
    ## 1        aa       0 2016-02-19 2016-02-19 16:08:41        a,b      1234
    ## 2        bb       1 2016-02-20 2016-02-20 16:08:41        b,c      2345
    ## 3        cc       2 2016-02-21 2016-02-21 16:08:41        c,d      3456
    ## 4        dd       3 2016-02-22 2016-02-22 16:08:41        d,e      4567
    ## Variables not shown: hasempty (chr), hello (chr).

``` r
cf
```

    ## Source: local data frame [47 x 5]
    ## 
    ##     cell cell_alt   row   col  cell_text
    ##    (chr)    (chr) (int) (int)      (chr)
    ## 1     A1     R1C1     1     1  character
    ## 2     B1     R1C2     1     2    integer
    ## 3     C1     R1C3     1     3      dates
    ## 4     D1     R1C4     1     4    iso8601
    ## 5     E1     R1C5     1     5 textcommas
    ## 6     F1     R1C6     1     6  numcommas
    ## 7     G1     R1C7     1     7   hasempty
    ## 8     I1     R1C9     1     9      hello
    ## 9     A2     R2C1     2     1         aa
    ## 10    B2     R2C2     2     2          0
    ## ..   ...      ...   ...   ...        ...

``` r
if (!interactive()) {
  gs_auth(file.path("..", "tests", "testthat", "googlesheets_token.rds"))
}
```

    ## Auto-refreshing stale OAuth token.

``` r
meta <- googlesheets:::gd_metadata(ingest_key)
jsonlite::toJSON(meta, pretty = TRUE, auto_unbox = TRUE)
```

    ## {
    ##   "kind": "drive#file",
    ##   "id": "137pijO8ml6LAeRjvnEquQgWlPPlr5sysvybuUUs7vX4",
    ##   "name": "test-gs-ingest",
    ##   "mimeType": "application/vnd.google-apps.spreadsheet",
    ##   "starred": false,
    ##   "trashed": false,
    ##   "explicitlyTrashed": false,
    ##   "spaces": [
    ##     "drive"
    ##   ],
    ##   "version": "1252",
    ##   "webViewLink": "https://docs.google.com/spreadsheets/d/137pijO8ml6LAeRjvnEquQgWlPPlr5sysvybuUUs7vX4/edit?usp=drivesdk",
    ##   "iconLink": "https://ssl.gstatic.com/docs/doclist/images/icon_11_spreadsheet_list.png",
    ##   "thumbnailLink": "https://docs.google.com/feeds/vt?gd=true&id=137pijO8ml6LAeRjvnEquQgWlPPlr5sysvybuUUs7vX4&v=0&s=AMedNnoAAAAAVsoPRohv4w39eLVZSbPlqEXiqXsm0DN-&sz=s220",
    ##   "viewedByMe": true,
    ##   "viewedByMeTime": "2016-02-21T05:46:48.748Z",
    ##   "createdTime": "2016-02-20T00:06:43.577Z",
    ##   "modifiedTime": "2016-02-20T00:31:53.711Z",
    ##   "owners": [
    ##     {
    ##       "kind": "drive#user",
    ##       "displayName": "R package",
    ##       "me": false,
    ##       "permissionId": "03459568024088842658",
    ##       "emailAddress": "rpackagetest@gmail.com"
    ##     }
    ##   ],
    ##   "lastModifyingUser": {
    ##     "kind": "drive#user",
    ##     "displayName": "R package",
    ##     "me": false,
    ##     "permissionId": "03459568024088842658",
    ##     "emailAddress": "rpackagetest@gmail.com"
    ##   },
    ##   "shared": true,
    ##   "ownedByMe": false,
    ##   "capabilities": {
    ##     "canEdit": false,
    ##     "canComment": false,
    ##     "canShare": false,
    ##     "canCopy": true
    ##   },
    ##   "viewersCanCopyContent": true,
    ##   "writersCanShare": true,
    ##   "quotaBytesUsed": "0"
    ## }

``` r
## not sure a data frame is a convenient form for this?
## anyway -- combine this info with the above for a complete report on
## WHO CAN DO WHAT
perm <- googlesheets:::gs_perm_ls(ss)
as.data.frame(perm)
```

    ##                    email      name   type   role              perm_id
    ## 1 rpackagetest@gmail.com R package   user  owner 03459568024088842658
    ## 2                   <NA>      <NA> anyone reader               anyone
    ##      domain
    ## 1 gmail.com
    ## 2      <NA>
    ##                                                                                                                  selfLink
    ## 1 https://www.googleapis.com/drive/v2/files/137pijO8ml6LAeRjvnEquQgWlPPlr5sysvybuUUs7vX4/permissions/03459568024088842658
    ## 2               https://www.googleapis.com/drive/v2/files/137pijO8ml6LAeRjvnEquQgWlPPlr5sysvybuUUs7vX4/permissions/anyone
    ##                                                        etag
    ## 1 "c-g_a-1OtaH-kNQ4WBoXLp3Zv9s/9jvZELRPsg3U7DK7_cAaPVZN6M8"
    ## 2 "c-g_a-1OtaH-kNQ4WBoXLp3Zv9s/-qBATFORfus9Ll30lAuUrFBilwA"
    ##               kind
    ## 1 drive#permission
    ## 2 drive#permission

I am most interested in:

-   *whether user can even retrieve Drive metadata for specific file id*
-   shared
-   ownedByMe
-   capabilities: canEdit, canComment, canShare, canCopy
-   viewersCanCopyContent
-   writersCanShare
