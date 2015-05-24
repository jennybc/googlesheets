# googlesheets Basic Usage
Joanna Zhao, Jenny Bryan  
`r Sys.Date()`  

__NOTE__: The vignette is still under development. Stuff here is not written in stone. The [README](https://github.com/jennybc/googlesheets) on GitHub has gotten __alot more love recently__, so you should read that instead or in addition to this (2015-05-08). Seriously, we've only been making sure this thing compiles, but not updating the text.


```r
library(googlesheets)
suppressMessages(library(dplyr))
```

This vignette shows the basic functionality of `googlesheets`.

# User Authentication

In order to access spreadsheets that are not "published to the web" and in order to access __any__ spreadsheets by title (vs key), you need to authenticate with Google. Many `googlesheets` functions require authentication and, if necessary, will simply trigger the interactive process we describe here.

The `gs_auth()` function uses OAuth2 for authentication, but don't worry if you don't know what that means. The first time, you will be kicked into a web browser. You'll be asked to login to your Google account and give `googlesheets` permission to access Sheets and Google Drive. Successful login will lead to the creation of an access token, which will automatically be stored in a file named `.httr-oath` in current working directory. These tokens are perishable and, for the most part, they will be refreshed automatically when they go stale. Under the hood, we use the `httr` package to manage this.

If you want to switch to a different Google account, run `gs_auth(new_user = TRUE)`, as this will delete the previously stored token and get a new one for the new account.

*In a hidden chunk, we are logging into Google as a user associated with this package, so we can work with some Google spreadsheets later in this vignette.*






# Get a Google spreadsheet to practice with

If you don't have any Google Sheets yet, or if you just want to follow along verbatim with this vignette, this bit of code will copy a sheet from the `googlesheets` Google user into your Drive. The sheet holds some of the [Gapminder data](https://github.com/jennybc/gapminder).


```r
gs_gap() %>% 
  gs_copy(to = "Gapminder")
```

# List your spreadsheets

As an authenticated user, you can get a (partial) listing of accessible sheets. If you have not yet authenticated, you will be prompted to do so. If it's been a while since you authenticated, you'll see a message about refreshing a stale OAuth token.


```r
my_sheets <- gs_ls()
my_sheets
```

```
## Source: local data frame [36 x 10]
## 
##                 sheet_title        author perm version             updated
## 1   EasyTweetSheet - Shared     m.hawksey    r     new 2015-05-23 05:33:43
## 2  Ari's Anchor Text Scrap…      anahmani    r     old 2015-05-22 23:01:31
## 3              #rhizo15 #tw     m.hawksey    r     new 2015-05-22 19:43:33
## 4     All R Phylo Functions  omeara.brian    r     new 2015-05-20 18:34:43
## 5                  ari copy      gspreadr   rw     old 2015-05-19 23:00:13
## 6               gas_mileage      woo.kara    r     new 2015-05-17 00:00:12
## 7  2014-05-10_seaRM-at-van…      gspreadr   rw     new 2015-05-11 04:19:08
## 8  2014-05-10_seaRM-at-van…         jenny    r     new 2015-05-11 03:51:57
## 9       test-gs-permissions      gspreadr   rw     new 2015-05-08 23:08:59
## 10          #TalkPay Tweets      iskaldur    r     new 2015-05-02 06:25:14
## ..                      ...           ...  ...     ...                 ...
## Variables not shown: sheet_key (chr), ws_feed (chr), alternate (chr), self
##   (chr), alt_key (chr)
```

This provides a nice overview of the spreadsheets you can access.

# Register a spreadsheet

Before you can access a spreadsheet, you must first __register__ it. This returns a `googlesheets` object that is needed by downstream functions in order to retrieve or edit spreadsheet data.

Let's register the Gapminder spreadsheet we spied in the list above and that you may have copied into your Google Drive. We have a nice `print` method for these objects, so print to screen for some basic info.


```r
gap <- gs_title("Gapminder")
```

```
## Sheet successfully identifed: "Gapminder"
```

```r
gap
```

```
##                   Spreadsheet title: Gapminder
##   Date of googlesheets registration: 2015-05-23 05:54:27 GMT
##     Date of last spreadsheet update: 2015-03-23 20:34:08 GMT
##                          visibility: private
##                         permissions: rw
##                             version: new
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

Here's an example of registering a sheet via key. While registration by title is handy for interactive use, registration by key might be preferred when programming.


```r
just_gap <- gs_ls("^Gapminder$")
just_gap$sheet_key
```

```
## [1] "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
```

```r
ss2 <- just_gap$sheet_key %>%
  gs_key()
```

```
## Authentication will be used.
## Sheet successfully identifed: "Gapminder"
```

```r
ss2
```

```
##                   Spreadsheet title: Gapminder
##   Date of googlesheets registration: 2015-05-23 05:54:28 GMT
##     Date of last spreadsheet update: 2015-03-23 20:34:08 GMT
##                          visibility: private
##                         permissions: rw
##                             version: new
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

There are three ways to consume data.

  * *The csv way ... bring this over from README*
  * The "list feed": only suitable for well-behaved tabular data. Think: data that looks like an R data.frame
  * The "cell feed": for everything else. Of course, you can get well-behaved tabular data with the cell feed but it's up to 3x slower and will require post-processing (reshaping and coercion).
  
Example of getting nice tabular data from the "list feed":


```r
gap
```

```
##                   Spreadsheet title: Gapminder
##   Date of googlesheets registration: 2015-05-23 05:54:27 GMT
##     Date of last spreadsheet update: 2015-03-23 20:34:08 GMT
##                          visibility: private
##                         permissions: rw
##                             version: new
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

Under the hood, `googlesheets` functions must access a spreadsheet with either public or private __visiblity__. Visibility determines whether or not authorization will be used for a request.

No authorization is used when visibility is set to "public", which will only work for spreadsheets that have been "Published to the Web". Note that requests with visibility set to "public" __will not work__ for spreadsheets that are made "Public on the web" from the "Visibility options" portion of the sharing dialog of a Google Sheets file. In summary, "Published to the web" and "Public on the web" are __different__ ways to share a spreadsheet.

Authorization is used when visibility is set to "private".

#### For spreadsheets that have been published to the web

To access public spreadsheets, you will either need the key of the spreadsheet (as found in the URL) or the entire URL.

*show registering a sheet by these two methods*

#### For private spreadsheets

*this is the scenario when you can use `gs_ls()` to remind yourself what spreadsheets are in your Google drive. A spreadsheet can be opened by its title. kind of covered above, since it's what we do first*

# Add, delete, rename spreadsheets and worksheets

*needs updating; lots of this already in README*

### Add or delete spreadsheet

To add a spreadsheet to your Google Drive, use `gs_new()` and simply pass in the title of the spreadsheet as a character string. The new spreadsheet will contain one worksheet titled "Sheet1" by default. Recall we demonstrate the use of `gs_copy()` at the start of this vignette, which is another common way to get a new sheet.

or delete 
or `gs_delete()` 


```r
# Create a new empty spreadsheet by title
gs_new("hi I am new here")
```

```
## Sheet "hi I am new here" created in Google Drive.
## Worksheet dimensions: 1000 x 26.
```

```r
gs_ls() %>% filter(sheet_title == "hi I am new here")
```

```
## Source: local data frame [1 x 10]
## 
##        sheet_title   author perm version             updated
## 1 hi I am new here gspreadr   rw     new 2015-05-23 05:54:30
## Variables not shown: sheet_key (chr), ws_feed (chr), alternate (chr), self
##   (chr), alt_key (chr)
```

Delete a spreadsheet with `gs_delete()`. This function operates on a registered `googlesheet`, so enclose your sheet identifying information in a suitable function. Here we specify (and delete) the above sheet by title, then confirm it is no longer in our sheet listing.


```r
# Move spreadsheet to trash
gs_delete(gs_title("hi I am new here"))
```

```
## Sheet successfully identifed: "hi I am new here"
## Success. "hi I am new here" moved to trash in Google Drive.
```

```r
gs_ls() %>% filter(sheet_title == "hi I am new here")
```

```
## Source: local data frame [0 x 10]
## 
## Variables not shown: sheet_title (chr), author (chr), perm (chr), version
##   (chr), updated (time), sheet_key (chr), ws_feed (chr), alternate (chr),
##   self (chr), alt_key (chr)
```

### Add, delete, or rename a worksheet

To add a worksheet to a spreadsheet, pass in the spreadsheet object, title of new worksheet and the number of rows and columns. To delete a worksheet from a spreadsheet, pass in the spreadsheet object and the title of the worksheet. Note that after adding or deleting a worksheet, the local `googlesheet` object will not be automatically updated to include the new worksheet(s) information, you must register the spreadsheet again to update local knowledge about, e.g., the contituent worksheets. Notice that we store the sheet back to `x` after adding the worksheet. This is because adding a worksheet changes the information associated with a registered sheet and, within editing functions like `gs_ws_new()`, we re-register the sheet and return the current sheet info.


```r
gs_new("hi I am new here")
```

```
## Sheet "hi I am new here" created in Google Drive.
## Worksheet dimensions: 1000 x 26.
```

```r
x <- gs_title("hi I am new here")
```

```
## Sheet successfully identifed: "hi I am new here"
```

```r
x
```

```
##                   Spreadsheet title: hi I am new here
##   Date of googlesheets registration: 2015-05-23 05:54:36 GMT
##     Date of last spreadsheet update: 2015-05-23 05:54:34 GMT
##                          visibility: private
##                         permissions: rw
##                             version: new
## 
## Contains 1 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Sheet1: 1000 x 26
## 
## Key: 1UhIFltdnN2516Z9CZJYQAT9jLl6VEYhT1FQ4aHBpEoc
```

```r
x <- gs_ws_new(x, ws_title = "foo", row_extent = 10, col_extent = 10)
```

```
## Worksheet "foo" added to sheet "hi I am new here".
## Worksheet dimensions: 10 x 10.
```

```r
x
```

```
##                   Spreadsheet title: hi I am new here
##   Date of googlesheets registration: 2015-05-23 05:54:37 GMT
##     Date of last spreadsheet update: 2015-05-23 05:54:36 GMT
##                          visibility: private
##                         permissions: rw
##                             version: new
## 
## Contains 2 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Sheet1: 1000 x 26
## foo: 10 x 10
## 
## Key: 1UhIFltdnN2516Z9CZJYQAT9jLl6VEYhT1FQ4aHBpEoc
```

```r
gs_ws_delete(x, ws = "foo")
```

```
## Accessing worksheet titled "foo"
## Worksheet "foo" deleted from sheet "hi I am new here".
```

```r
x <- gs_title("hi I am new here")
```

```
## Sheet successfully identifed: "hi I am new here"
```

```r
x
```

```
##                   Spreadsheet title: hi I am new here
##   Date of googlesheets registration: 2015-05-23 05:54:39 GMT
##     Date of last spreadsheet update: 2015-05-23 05:54:37 GMT
##                          visibility: private
##                         permissions: rw
##                             version: new
## 
## Contains 1 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Sheet1: 1000 x 26
## 
## Key: 1UhIFltdnN2516Z9CZJYQAT9jLl6VEYhT1FQ4aHBpEoc
```

To rename a worksheet, pass in the spreadsheet object, the worksheet's current name and the new name you want it to be.  


```r
gs_ws_rename(x, "Sheet1", "First Sheet")
```

```
## Accessing worksheet titled "Sheet1"
## Authentication will be used.
## Sheet successfully identifed: "hi I am new here"
## Worksheet "Sheet1" renamed to "First Sheet".
```

Tidy up by getting rid of the sheet we've playing with.


```r
gs_delete(gs_title("hi I am new here"))
```

```
## Sheet successfully identifed: "hi I am new here"
## Success. "hi I am new here" moved to trash in Google Drive.
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

Otherwise the input is assumed to be the spreadsheet's title or unique key. When we say title, we mean the name of the spreadsheet in, say, Google Drive or in the \code{sheet_title} variable of the data.frame returned by \code{\link{gs_ls}}. Spreadsheet title or key will be sought in the listing of spreadsheets visible to the authenticated user and, if a match is found, the associated worksheets feed is returned.
