# googlesheets Basic Usage
Joanna Zhao, Jenny Bryan  
`r Sys.Date()`  

__NOTE__: The vignette is still under development. Stuff here is not written in stone. The [README](https://github.com/jennybc/googlesheets) on GitHub has gotten alot more love recently, so you might want to read that instead or in addition to this (2015-03-23).


```r
library(googlesheets)
suppressMessages(library(dplyr))
```

This vignette shows the basic functionality of `googlesheets`.

# User Authentication

In order to access spreadsheets that are not "published to the web" and in order to access __any__ spreadsheets by title (vs key), you need to authenticate with Google. Many `googlesheets` functions require authentication and, if necessary, will simply trigger the interactive process we describe here.

The `authorize()` function uses OAuth2 for authentication, but don't worry if you don't know what that means. The first time, you will be kicked into a web browser. You'll be asked to login to your Google account and give `googlesheets` permission to access Sheets and Google Drive. Successful login will lead to the creation of an access token, which will automatically be stored in a file named `.httr-oath` in current working directory. These tokens are perishable and, for the most part, they will be refreshed automatically when they go stale. Under the hood, we use the `httr` package to manage this.

If you want to switch to a different Google account, run `authorize(new_user = TRUE)`, as this will delete the previously stored token and get a new one for the new account.

*In a hidden chunk, we are logging into Google as a user associated with this package, so we can work with some Google spreadsheets later in this vignette.*






# Get a Google spreadsheet to practice with

If you don't have any Google Sheets yet, or if you just want to follow along verbatim with this vignette, this bit of code will copy a sheet from the `googlesheets` Google user into your Drive. The sheet holds some of the [Gapminder data](https://github.com/jennybc/gapminder).


```r
gap_key <- "1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE"
copy_ss(key = gap_key, to = "Gapminder")
```

# List your spreadsheets

As an authenticated user, you can get a (partial) listing of accessible sheets. If you have not yet authenticated, you will be prompted to do so. If it's been a while since you authenticated, you'll see a message about refreshing a stale OAuth token.


```r
my_sheets <- list_sheets()
```

Explore the `my_sheets` object. Here's a look at the top of ours, where we've truncated the variables `sheet_title` and `sheet_key` and suppressed the variable `ws_id` for readability.


```
## Source: local data frame [6 x 9]
## 
##   sheet_title  sheet_key      owner perm        last_updated version
## 1  Ari's Anch tQKSYVR...   anahmani    r 2015-04-05 21:46:18     old
## 2  Public Tes 1hff6Az...   gspreadr   rw 2015-04-05 21:50:27     new
## 3  Projects_2 1ET1NGc... david.orme    r 2015-04-01 15:21:36     new
## 4  iris_publi 1cAYN-a...   gspreadr   rw 2015-03-30 18:24:06     new
## 5  Flight Ris 1OvDq4_...       omid    r 2015-03-27 09:33:43     new
## 6   Gapminder 1HT5B8S...   gspreadr   rw 2015-03-23 20:59:10     new
## Variables not shown: alternate (chr), self (chr), alt_key (chr)
```

This provides a nice overview of the spreadsheets you can access and is useful for looking up the __key__ of a spreadsheet (see below).

# Register a spreadsheet

Before you can access a spreadsheet, you must first __register__ it. This returns an object that is of little interest to the user, but is needed by various `googlesheets` functions in order to retrieve or edit spreadsheet data.

Let's register the Gapminder spreadsheet we spied in the list above and that you may have copied into your Google Drive. We can use `str()` to get an overview of the spreadsheet.


```r
gap <- register_ss("Gapminder")
```

```
## Sheet identified!
## sheet_title: Gapminder
## sheet_key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA
```

```r
gap
```

```
##                   Spreadsheet title: Gapminder
##   Date of googlesheets::register_ss: 2015-04-05 14:52:40 PDT
##     Date of last spreadsheet update: 2015-03-23 20:34:08 UTC
##                          visibility: private
## 
## Contains 5 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Africa: 625 x 6
## Americas: 301 x 6
## Asia: 397 x 6
## Europe: 361 x 6
## Oceania: 25 x 6
## 
## Key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA
```

Besides using the spreadsheet title, you can also specify a spreadsheet in three other ways:

  * By key: this unfriendly but unique string is probably the best long-term strategy.
  * By URL: copy and paste the URL in your browser while visiting the spreadsheet.
  * By the "worksheets feed": under the hood, this is how `googlesheets` actually gets spreadsheet information from the API. Unlikely to be relevant to a regular user.

Here's an example of using the sheet title to retrieve the key, then registering the sheet by key. While registration by title is handy for interactive use, registration by key is preferred for scripts.


```r
(gap_key <- my_sheets$sheet_key[my_sheets$sheet_title == "Gapminder"])
```

```
## [1] "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
```

```r
ss2 <- register_ss(gap_key)
```

```
## Sheet identified!
## sheet_title: Gapminder
## sheet_key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA
```

```r
ss2
```

```
##                   Spreadsheet title: Gapminder
##   Date of googlesheets::register_ss: 2015-04-05 14:52:41 PDT
##     Date of last spreadsheet update: 2015-03-23 20:34:08 UTC
##                          visibility: private
## 
## Contains 5 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Africa: 625 x 6
## Americas: 301 x 6
## Asia: 397 x 6
## Europe: 361 x 6
## Oceania: 25 x 6
## 
## Key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA
```

# Consuming data from a worksheet

Spreadsheet data is parcelled out into __worksheets__. To consume data from a Google spreadsheet, you'll need to specify a registered spreadsheet and, within that, a worksheet. Specify the worksheet either by name or positive integer index.

There are two ways to consume data.

  * The "list feed": only suitable for well-behaved tabular data. Think: data that looks like an R data.frame
  * The "cell feed": for everything else. Of course, you can get well-behaved tabular data with the cell feed but it's up to 3x slower and will require post-processing (reshaping and coercion).
  
Example of getting nice tabular data from the "list feed":


```r
gap
```

```
##                   Spreadsheet title: Gapminder
##   Date of googlesheets::register_ss: 2015-04-05 14:52:40 PDT
##     Date of last spreadsheet update: 2015-03-23 20:34:08 UTC
##                          visibility: private
## 
## Contains 5 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Africa: 625 x 6
## Americas: 301 x 6
## Asia: 397 x 6
## Europe: 361 x 6
## Oceania: 25 x 6
## 
## Key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA
```

```r
oceania_list_feed <- get_via_lf(gap, ws = "Oceania") 
```

```
## Accessing worksheet titled "Oceania"
```

```r
str(oceania_list_feed)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	24 obs. of  6 variables:
##  $ country  : chr  "Australia" "Australia" "Australia" "Australia" ...
##  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
##  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
##  $ lifeexp  : num  69.1 70.3 70.9 71.1 71.9 ...
##  $ pop      : int  8691212 9712569 10794968 11872264 13177000 14074100 15184200 16257249 17481977 18565243 ...
##  $ gdppercap: num  10040 10950 12217 14526 16789 ...
```

```r
oceania_list_feed
```

```
## Source: local data frame [24 x 6]
## 
##      country continent year lifeexp      pop gdppercap
## 1  Australia   Oceania 1952   69.12  8691212  10039.60
## 2  Australia   Oceania 1957   70.33  9712569  10949.65
## 3  Australia   Oceania 1962   70.93 10794968  12217.23
## 4  Australia   Oceania 1967   71.10 11872264  14526.12
## 5  Australia   Oceania 1972   71.93 13177000  16788.63
## 6  Australia   Oceania 1977   73.49 14074100  18334.20
## 7  Australia   Oceania 1982   74.74 15184200  19477.01
## 8  Australia   Oceania 1987   76.32 16257249  21888.89
## 9  Australia   Oceania 1992   77.56 17481977  23424.77
## 10 Australia   Oceania 1997   78.83 18565243  26997.94
## ..       ...       ...  ...     ...      ...       ...
```

If you wish, go look at the [Oceania worksheet from the Gapminder spreadsheet](https://docs.google.com/spreadsheets/d/1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE/edit#gid=431684907) for comparison.

Example of getting the same data from the "cell feed".


```r
oceania_cell_feed <- get_via_cf(gap, ws = "Oceania") 
```

```
## Accessing worksheet titled "Oceania"
```

```r
str(oceania_cell_feed)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	150 obs. of  5 variables:
##  $ cell     : chr  "A1" "B1" "C1" "D1" ...
##  $ cell_alt : chr  "R1C1" "R1C2" "R1C3" "R1C4" ...
##  $ row      : int  1 1 1 1 1 1 2 2 2 2 ...
##  $ col      : int  1 2 3 4 5 6 1 2 3 4 ...
##  $ cell_text: chr  "country" "continent" "year" "lifeExp" ...
##  - attr(*, "ws_title")= chr "Oceania"
```

```r
head(oceania_cell_feed, 10)
```

```
## Source: local data frame [10 x 5]
## 
##    cell cell_alt row col cell_text
## 1    A1     R1C1   1   1   country
## 2    B1     R1C2   1   2 continent
## 3    C1     R1C3   1   3      year
## 4    D1     R1C4   1   4   lifeExp
## 5    E1     R1C5   1   5       pop
## 6    F1     R1C6   1   6 gdpPercap
## 7    A2     R2C1   2   1 Australia
## 8    B2     R2C2   2   2   Oceania
## 9    C2     R2C3   2   3      1952
## 10   D2     R2C4   2   4     69.12
```

```r
oceania_reshaped <- reshape_cf(oceania_cell_feed)
str(oceania_reshaped)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	24 obs. of  6 variables:
##  $ country  : chr  "Australia" "Australia" "Australia" "Australia" ...
##  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
##  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
##  $ lifeExp  : num  69.1 70.3 70.9 71.1 71.9 ...
##  $ pop      : int  8691212 9712569 10794968 11872264 13177000 14074100 15184200 16257249 17481977 18565243 ...
##  $ gdpPercap: num  10040 10950 12217 14526 16789 ...
```

```r
head(oceania_reshaped, 10)
```

```
## Source: local data frame [10 x 6]
## 
##      country continent year lifeExp      pop gdpPercap
## 1  Australia   Oceania 1952   69.12  8691212  10039.60
## 2  Australia   Oceania 1957   70.33  9712569  10949.65
## 3  Australia   Oceania 1962   70.93 10794968  12217.23
## 4  Australia   Oceania 1967   71.10 11872264  14526.12
## 5  Australia   Oceania 1972   71.93 13177000  16788.63
## 6  Australia   Oceania 1977   73.49 14074100  18334.20
## 7  Australia   Oceania 1982   74.74 15184200  19477.01
## 8  Australia   Oceania 1987   76.32 16257249  21888.89
## 9  Australia   Oceania 1992   77.56 17481977  23424.77
## 10 Australia   Oceania 1997   78.83 18565243  26997.94
```

Note that data from the cell feed comes back as a data.frame with one row per cell. We provide the function `reshape_cf()` to reshape this data into something tabular.

*To add, using row and column limits on the cell feed. All covered in the README.*

*Stuff below partialy redundant with above*

Eventually, you may want to read parts of the [Google Sheets API version 3.0 documentation](https://developers.google.com/google-apps/spreadsheets/). The types of data access supported by the API determine what is possible and also what is (relatively) fast vs slow in the `googlesheets` package. The Sheets API uses the term "feed" much like other APIs will refer to an "endpoint".

There are two basic modes of consuming data stored in a worksheet (quotes taken from the [API docs](https://developers.google.com/google-apps/spreadsheets/):

  * the __list feed__: implicitly assumes data is in a neat rectangle, like an R matrix or data.frame, with a header row followed by one or more data rows, none of which are completely empty
    - "list row: Row of cells in a worksheet, represented as a key-value pair, where each key is a column name, and each value is the cell value. The first row of a worksheet is always considered the header row when using the API, and therefore is the row that defines the keys represented in each row."
  * the __cell feed__: unconstrained access to individual non-empty cells specified in either Excel-like notation, e.g. cell D9, or in row-number-column-number notation, e.g. R9C4
    - "cell: Single piece of data in a worksheet."

*show how to iterate across worksheets, i.e. get cell D4 from all worksheets*

### Visibility stuff

*Rework this for the new era.*

Under the hood, `gspread` functions must access a spreadsheet with either public or private __visiblity__. Visibility determines whether or not authorization will be used for a request.

No authorization is used when visibility is set to "public", which will only work for spreadsheets that have been "Published to the Web". Note that requests with visibility set to "public" __will not work__ for spreadsheets that are made "Public on the web" from the "Visibility options" portion of the sharing dialog of a Google Sheets file. In summary, "Published to the web" and "Public on the web" are __different__ ways to share a spreadsheet.

Authorization is used when visibility is set to "private".

#### For spreadsheets that have been published to the web

To access public spreadsheets, you will either need the key of the spreadsheet (as found in the URL) or the entire URL.

*show registering a sheet by these two methods*

#### For private spreadsheets

*this is the scenario when you can use `list_sheets()` to remind yourself what spreadsheets are in your Google drive. A spreadsheet can be opened by its title. kind of covered above, since it's what we do first*

# Add, delete, rename spreadsheets and worksheets

*needs updating; lots of this already in README*

### Add or delete spreadsheet

To add or delete a spreadsheet in your Google Drive, use `new_ss()` or `delete_ss()` and simply pass in the title of the spreadsheet as a character string. The new spreadsheet by default will contain one worksheet titled "Sheet1". Recall we demonstrate the use of `copy_ss()` at the start of this vignette.


```r
# Create a new empty spreadsheet by title
new_ss("hi I am new here")
```

```
## Sheet "hi I am new here" created in Google Drive.
## Identifying info is a googlesheet object; googlesheets will re-identify the sheet based on sheet key.
## Sheet identified!
## sheet_title: hi I am new here
## sheet_key: 1jvITM4n3BewIP8t9_wyOOyVKYTPSStakel90iHsZefE
```

```r
list_sheets() %>% filter(sheet_title == "hi I am new here")
```

```
## Source: local data frame [1 x 10]
## 
##        sheet_title                                    sheet_key    owner
## 1 hi I am new here 1jvITM4n3BewIP8t9_wyOOyVKYTPSStakel90iHsZefE gspreadr
## Variables not shown: perm (chr), last_updated (time), version (chr),
##   ws_feed (chr), alternate (chr), self (chr), alt_key (chr)
```

```r
# Move spreadsheet to trash
delete_ss("hi I am new here")
```

```
## Sheets found and slated for deletion:
## hi I am new here
## Success. All moved to trash in Google Drive.
```

```r
list_sheets() %>% filter(sheet_title == "hi I am new here")
```

```
## Source: local data frame [0 x 10]
## 
## Variables not shown: sheet_title (chr), sheet_key (chr), owner (chr), perm
##   (chr), last_updated (time), version (chr), ws_feed (chr), alternate
##   (chr), self (chr), alt_key (chr)
```

### Add, delete, or rename a worksheet

To add a worksheet to a spreadsheet, pass in the spreadsheet object, title of new worksheet and the number of rows and columns. To delete a worksheet from a spreadsheet, pass in the spreadsheet object and the title of the worksheet. Note that after adding or deleting a worksheet, the local spreadsheet object will not be automatically updated to include the new worksheet(s) information, you must register the spreadsheet again to update local knowledge about, e.g., the contituent worksheets. Notice that we store the sheet back to `x` after adding the worksheet. This is because adding a worksheet changes the information associate with a registered sheet and, within editing function like `add_ws()`, we re-register the sheet and return the current sheet info.


```r
new_ss("hi I am new here")
```

```
## Sheet "hi I am new here" created in Google Drive.
## Identifying info is a googlesheet object; googlesheets will re-identify the sheet based on sheet key.
## Sheet identified!
## sheet_title: hi I am new here
## sheet_key: 1XtZVTUaLCBDcT8zKGexWY8FQ-G1t2OhfFEdprvhOioE
```

```r
x <- register_ss("hi I am new here")
```

```
## Sheet identified!
## sheet_title: hi I am new here
## sheet_key: 1XtZVTUaLCBDcT8zKGexWY8FQ-G1t2OhfFEdprvhOioE
```

```r
x
```

```
##                   Spreadsheet title: hi I am new here
##   Date of googlesheets::register_ss: 2015-04-05 14:52:52 PDT
##     Date of last spreadsheet update: 2015-04-05 21:52:48 UTC
##                          visibility: private
## 
## Contains 1 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Sheet1: 1000 x 26
## 
## Key: 1XtZVTUaLCBDcT8zKGexWY8FQ-G1t2OhfFEdprvhOioE
```

```r
x <- add_ws(x, ws_title = "foo", nrow = 10, ncol = 10)
```

```
## Worksheet "foo" added to sheet "hi I am new here".
```

```r
x
```

```
##                   Spreadsheet title: hi I am new here
##   Date of googlesheets::register_ss: 2015-04-05 14:52:52 PDT
##     Date of last spreadsheet update: 2015-04-05 21:52:52 UTC
##                          visibility: private
## 
## Contains 2 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Sheet1: 1000 x 26
## foo: 10 x 10
## 
## Key: 1XtZVTUaLCBDcT8zKGexWY8FQ-G1t2OhfFEdprvhOioE
```

```r
delete_ws(x, ws = "foo")
```

```
## Accessing worksheet titled "foo"
## Worksheet "foo" deleted from sheet "hi I am new here".
```

```r
x <- register_ss("hi I am new here")
```

```
## Sheet identified!
## sheet_title: hi I am new here
## sheet_key: 1XtZVTUaLCBDcT8zKGexWY8FQ-G1t2OhfFEdprvhOioE
```

```r
x
```

```
##                   Spreadsheet title: hi I am new here
##   Date of googlesheets::register_ss: 2015-04-05 14:52:54 PDT
##     Date of last spreadsheet update: 2015-04-05 21:52:53 UTC
##                          visibility: private
## 
## Contains 1 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Sheet1: 1000 x 26
## 
## Key: 1XtZVTUaLCBDcT8zKGexWY8FQ-G1t2OhfFEdprvhOioE
```

To rename a worksheet, pass in the spreadsheet object, the worksheet's current name and the new name you want it to be.  


```r
rename_ws(x, "Sheet1", "First Sheet")
```

```
## Accessing worksheet titled "Sheet1"
## Worksheet "Sheet1" renamed to "First Sheet".
```

Tidy up by getting rid of the sheet we've playing with.


```r
delete_ss("hi I am new here")
```

```
## Sheets found and slated for deletion:
## hi I am new here
## Success. All moved to trash in Google Drive.
```

# Worksheet Operations

## View worksheet

*this function has not been resurrected yet*

You can take a look at your worksheets to get an idea of what it looks like. Use `view()` to look at one worksheet and `view_all()` to look at all worksheets contained in a spreadsheet. `view_all()` returns a gallery of all the worksheets. Set `show_overlay = TRUE` to view an overlay of all the worksheets to identify the density of the cells occupied by worksheets. **showing Error: could not find function "ggplotGrob"**


```r
view(ws)

view_all(ssheet)
```


## Update cells

*documented only in README right now*

# Appendix: Visibility table

Accessing spreadsheets that are or are not "published to the web" with visibility set of "public" vs "private"


| Sheet Type           | Public? (Published to the web) | URL visibility setting | Response      | Content Type         | Content                |
|----------------------|--------------------------------|------------------------|---------------|----------------------|------------------------|
| My sheet             | Yes                            | private                | 200 OK        | application/atom+xml | data                   |
| My sheet             | Yes                            | public                 | 200 OK        | application/atom+xml | data                   |
| My sheet             | No                             | private                | 200 OK        | application/atom+xml | data                   |
| My sheet             | No                             | public                 | 200 OK        | text/html            | this doc is not public |
| Someone else's sheet | Yes                            | private                | 403 Forbidden | Error                | Error                  |
| Someone else's sheet | Yes                            | public                 | 200 OK        | application/atom+xml | data                   |
| Someone else's sheet | No                             | private                | 200 OK        | application/atom+xml | data                   |
| Someone else's sheet | No                             | public                 | 200 OK        | text/html            | this doc is not public |

# Appendix: Words about sheet identifiers

For a user, it is natural to specify a Google sheet via the URL displayed in the browser or by its title. The primary identifier as far as Google Sheets and `gspread` are concerned is the sheet key. To access a sheet via the Google Sheets API, one must know the sheet's worksheets feed. The worksheets feed is simply a URL, but different from the one you see when visiting a spreadsheet in the browser!

Stuff from roxygen comments for a function that no longer exists: Given a Google spreadsheet's URL, unique key, title, or worksheets feed, return its worksheets feed. The worksheets feed is simply a URL -- different from the one you see when visiting a spreadsheet in the browser! -- and is the very best way to specify a spreadsheet for API access. There's no simple way to capture a spreadsheet's worksheets feed, so this function helps you convert readily available information (spreadsheet title or URL) into the worksheets feed.

Simple regexes are used to detect if the input is a worksheets feed or the URL one would see when visiting a spreadsheet in the browser. If it's a URL, we attempt to extract the spreadsheet's unique key, assuming the URL followsthe pattern characteristic of "new style" Google spreadsheets.

Otherwise the input is assumed to be the spreadsheet's title or unique key. When we say title, we mean the name of the spreadsheet in, say, Google Drive or in the \code{sheet_title} variable of the data.frame returned by \code{\link{list_sheets}}. Spreadsheet title or key will be sought in the listing of spreadsheets visible to the authenticated user and, if a match is found, the associated worksheets feed is returned.
