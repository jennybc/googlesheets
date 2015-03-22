# gspreadr Basic Usage
Joanna Zhao, Jenny Bryan  
`r Sys.Date()`  

__NOTE__: The vignette is still under development. Stuff here is not written in stone.


```r
library(gspreadr)
suppressMessages(library(dplyr))
```

This vignette shows the basic functionality of `gspreadr`.

# User Authentication

In order to access spreadsheets that are not "published to the web" and in order to access __any__ spreadsheets by title (vs key), you need to authenticate with Google. Many `gspreadr` functions require authentication and, if necessary, will simply trigger the interactive process we describe here.

The `authorize()` function uses OAuth2 for authentication, but don't worry if you don't know what that means. The first time, you will be kicked into a web browser. You'll be asked to login to your Google account and give `gspreadr` permission to access Sheets and Google Drive. Successful login will lead to the creation of an access token, which will automatically be stored in a file named `.httr-oath` in current working directory. These tokens are perishable and, for the most part, they will be refreshed automatically when they go stale. Under the hood, we use the `httr` package to manage this.

If you want to switch to a different Google account, run `authorize(new_user = TRUE)`, as this will delete the previously stored token and get a new one for the new account.

*In a hidden chunk, we are logging into Google as a user associated with this package, so we can work with some Google spreadsheets later in this vignette.*



# Get a Google spreadsheet to practice with

*Maybe kick off w/ some code just to copy/paste that will copy the Gapminder spreadsheet into the authenticated user's Google Drive. So they can follow along?*

If you don't have any Google Sheets yet, or if you just want to follow along verbatim with this vignette, this bit of code will copy a sheet from the `gspreadr` Google user into your Drive. The sheet holds some of the [Gapminder data](https://github.com/jennybc/gapminder).


```r
gap_key <- "1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE"
copy_ss(key = gap_key, to = "Gapminder")
```

# List your spreadsheets

As an authenticated user, you can get a (partial) listing of accessible sheets. If you have not yet authenticated, you will be prompted to do so. If it's been a while since you authenticated, you'll see a message about refreshing a stale OAuth token.


```r
my_sheets <- list_sheets()
```

```
## Auto-refreshing stale OAuth token.
```

Explore the `my_sheets` object. Here's a look at the top of ours, where we've truncated the variables `sheet_title` and `sheet_key` and suppressed the variable `ws_id` for readability.


```
## Source: local data frame [6 x 5]
## 
##   sheet_title  sheet_key    owner perm        last_updated
## 1  Public Tes 1hff6Az... gspreadr   rw 2015-03-22 20:58:27
## 2     scoring 1w8F3t9... gspreadr   rw 2015-03-20 22:32:48
## 3  gas_mileag 1WH65aJ... woo.kara    r 2015-03-12 01:01:33
## 4  Temperatur 1Hkh20-... gspreadr   rw 2015-03-03 00:07:43
## 5  1F0iNuYW4v 1upHM4K... gspreadr   rw 2015-02-20 01:17:28
## 6  Testing he 1F0iNuY... gspreadr   rw 2015-02-20 01:14:15
```

This provides a nice overview of the spreadsheets you can access and is useful for looking up the __key__ of a spreadsheet (see below).

# Register a spreadsheet

Before you can access a spreadsheet, you must first __register__ it. This returns an object that is of little interest to the user, but is needed by various `gspreadr` functions in order to retrieve or edit spreadsheet data.

Let's register the Gapminder spreadsheet we spied in the list above and that you may have copied into your Google Drive. We can use `str()` to get an overview of the spreadsheet.


```r
gap <- register_ss("Gapminder")
```

```
## Sheet identified!
## sheet_title: Gapminder
## sheet_key: 1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE
```

```r
str(gap)
```

```
##               Spreadsheet title: Gapminder
##   Date of gspreadr::register_ss: 2015-03-22 14:03:08 PDT
## Date of last spreadsheet update: 2015-01-21 18:42:42 UTC
## 
## Contains 5 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Africa: 1000 x 26
## Americas: 1000 x 26
## Asia: 1000 x 26
## Europe: 1000 x 26
## Oceania: 1000 x 26
## 
## Key: 1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE
```

Besides using the spreadsheet title, you can also specify a spreadsheet in three other ways:

  * By key: this unfriendly but unique string is probably the best long-term strategy.
  * By URL: copy and paste the URL in your browser while visiting the spreadsheet.
  * By the "worksheets feed": under the hood, this is how `gspreadr` actually gets spreadsheet information from the API. Unlikely to be relevant to a regular user.

Here's an example of using the sheet title to retrieve the key, then registering the sheet by key. While registration by title is handy for interactive use, registration by key is preferred for scripts.


```r
(gap_key <- my_sheets$sheet_key[my_sheets$sheet_title == "Gapminder"])
```

```
## [1] "1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE"
```

```r
ss2 <- register_ss(gap_key)
```

```
## Sheet identified!
## sheet_title: Gapminder
## sheet_key: 1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE
```

```r
str(ss2)
```

```
##               Spreadsheet title: Gapminder
##   Date of gspreadr::register_ss: 2015-03-22 14:03:08 PDT
## Date of last spreadsheet update: 2015-01-21 18:42:42 UTC
## 
## Contains 5 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Africa: 1000 x 26
## Americas: 1000 x 26
## Asia: 1000 x 26
## Europe: 1000 x 26
## Oceania: 1000 x 26
## 
## Key: 1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE
```

# Consuming data from a worksheet

Spreadsheet data is parcelled out into __worksheets__. To consume data from a Google spreadsheet, you'll need to specify a registered spreadsheet and, within that, a worksheet. Specify the worksheet either by name or positive integer index.

There are two ways to consume data.

  * The "list feed": only suitable for well-behaved tabular data. Think: data that looks like an R data.frame
  * The "cell feed": for everything else. Of course, you can get well-behaved tabular data with the cell feed but it's up to 3x slower and will require post-processing (reshaping and coercion).
  
Example of getting nice tabular data from the "list feed":


```r
str(gap)
```

```
##               Spreadsheet title: Gapminder
##   Date of gspreadr::register_ss: 2015-03-22 14:03:08 PDT
## Date of last spreadsheet update: 2015-01-21 18:42:42 UTC
## 
## Contains 5 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Africa: 1000 x 26
## Americas: 1000 x 26
## Asia: 1000 x 26
## Europe: 1000 x 26
## Oceania: 1000 x 26
## 
## Key: 1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE
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
##  $ country  : chr  "Australia" "New Zealand" "Australia" "New Zealand" ...
##  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
##  $ year     : int  2007 2007 2002 2002 1997 1997 1992 1992 1987 1987 ...
##  $ lifeexp  : num  81.2 80.2 80.4 79.1 78.8 ...
##  $ pop      : int  20434176 4115771 19546792 3908037 18565243 3676187 17481977 3437674 16257249 3317166 ...
##  $ gdppercap: num  34435 25185 30688 23190 26998 ...
```

```r
oceania_list_feed
```

```
## Source: local data frame [24 x 6]
## 
##        country continent year lifeexp      pop gdppercap
## 1    Australia   Oceania 2007  81.235 20434176  34435.37
## 2  New Zealand   Oceania 2007  80.204  4115771  25185.01
## 3    Australia   Oceania 2002  80.370 19546792  30687.75
## 4  New Zealand   Oceania 2002  79.110  3908037  23189.80
## 5    Australia   Oceania 1997  78.830 18565243  26997.94
## 6  New Zealand   Oceania 1997  77.550  3676187  21050.41
## 7    Australia   Oceania 1992  77.560 17481977  23424.77
## 8  New Zealand   Oceania 1992  76.330  3437674  18363.32
## 9    Australia   Oceania 1987  76.320 16257249  21888.89
## 10 New Zealand   Oceania 1987  74.320  3317166  19007.19
## ..         ...       ...  ...     ...      ...       ...
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
## 9    C2     R2C3   2   3      2007
## 10   D2     R2C4   2   4    81.235
```

```r
oceania_reshaped <- reshape_cf(oceania_cell_feed)
str(oceania_reshaped)
```

```
## 'data.frame':	24 obs. of  6 variables:
##  $ country  : chr  "Australia" "New Zealand" "Australia" "New Zealand" ...
##  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
##  $ year     : int  2007 2007 2002 2002 1997 1997 1992 1992 1987 1987 ...
##  $ lifeExp  : num  81.2 80.2 80.4 79.1 78.8 ...
##  $ pop      : int  20434176 4115771 19546792 3908037 18565243 3676187 17481977 3437674 16257249 3317166 ...
##  $ gdpPercap: num  34435 25185 30688 23190 26998 ...
```

```r
head(oceania_reshaped, 10)
```

```
##        country continent year lifeExp      pop gdpPercap
## 1    Australia   Oceania 2007  81.235 20434176  34435.37
## 2  New Zealand   Oceania 2007  80.204  4115771  25185.01
## 3    Australia   Oceania 2002  80.370 19546792  30687.75
## 4  New Zealand   Oceania 2002  79.110  3908037  23189.80
## 5    Australia   Oceania 1997  78.830 18565243  26997.94
## 6  New Zealand   Oceania 1997  77.550  3676187  21050.41
## 7    Australia   Oceania 1992  77.560 17481977  23424.77
## 8  New Zealand   Oceania 1992  76.330  3437674  18363.32
## 9    Australia   Oceania 1987  76.320 16257249  21888.89
## 10 New Zealand   Oceania 1987  74.320  3317166  19007.19
```

Note that data from the cell feed comes back as a data.frame with one row per cell. We provide the function `reshape_cf()` to reshape this data into something tabular.

*To add, using row and column limits on the cell feed.*

*Stuff below partialy redundant with above*

Eventually, you may want to read parts of the [Google Sheets API version 3.0 documentation](https://developers.google.com/google-apps/spreadsheets/). The types of data access supported by the API determine what is possible and also what is (relatively) fast vs slow in the `gspreadr` package. The Sheets API uses the term "feed" much like other APIs will refer to an "endpoint".

There are two basic modes of consuming data stored in a worksheet (quotes taken from the [API docs](https://developers.google.com/google-apps/spreadsheets/):

  * the __list feed__: implicitly assumes data is in a neat rectangle, like an R matrix or data.frame, with a header row followed by one or more data rows, none of which are completely empty
    - "list row: Row of cells in a worksheet, represented as a key-value pair, where each key is a column name, and each value is the cell value. The first row of a worksheet is always considered the header row when using the API, and therefore is the row that defines the keys represented in each row."
  * the __cell feed__: unconstrained access to individual non-empty cells specified in either Excel-like notation, e.g. cell D9, or in row-number-column-number notation, e.g. R9C4
    - "cell: Single piece of data in a worksheet."

*note: current cell feed function doesn't support what we say above but it's still being brought back online; revise above when dust has settled.*

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

*needs updating*

### Add or delete spreadsheet

To add or delete a spreadsheet in your Google Drive, use `new_ss()` or `delete_ss()` and simply pass in the title of the spreadsheet as a character string. The new spreadsheet by default will contain one worksheet titled "Sheet1". Recall we demonstrate the use of `copy_ss()` at the start of this vignette.


```r
# Create a new empty spreadsheet by title
new_ss("hi I am new here")
```

```
## Sheet "hi I am new here" created in Google Drive.
## Identifying info is a spreadsheet object; gspreadr will re-identify the sheet based on sheet key.
## Sheet identified!
## sheet_title: hi I am new here
## sheet_key: 1AO1WyxHdnReJfh9q-xMZTjJbVrGHUxddxknh2AxbNDg
```

```r
list_sheets() %>% filter(sheet_title == "hi I am new here")
```

```
## Source: local data frame [1 x 6]
## 
##        sheet_title                                    sheet_key    owner
## 1 hi I am new here 1AO1WyxHdnReJfh9q-xMZTjJbVrGHUxddxknh2AxbNDg gspreadr
## Variables not shown: perm (chr), last_updated (time), ws_feed (chr)
```

```r
# Move spreadsheet to trash
delete_ss("hi I am new here")
```

```
## Sheet "hi I am new here" moved to trash in Google Drive.
```

```r
list_sheets() %>% filter(sheet_title == "hi I am new here")
```

```
## Source: local data frame [0 x 6]
## 
## Variables not shown: sheet_title (chr), sheet_key (chr), owner (chr), perm
##   (chr), last_updated (time), ws_feed (chr)
```

### Add, delete, or rename a worksheet

To add a worksheet to a spreadsheet, pass in the spreadsheet object, title of new worksheet and the number of rows and columns. To delete a worksheet from a spreadsheet, pass in the spreadsheet object and the title of the worksheet. Note that after adding or deleting a worksheet, the local spreadsheet object will not be automatically updated to include the new worksheet(s) information, you must register the spreadsheet again to update local knowledge about, e.g., the contituent worksheets. 


```r
new_ss("hi I am new here")
```

```
## Sheet "hi I am new here" created in Google Drive.
## Identifying info is a spreadsheet object; gspreadr will re-identify the sheet based on sheet key.
## Sheet identified!
## sheet_title: hi I am new here
## sheet_key: 1TDCSaosJl_O6pn8Phxk_W6JoP6SCTYPpGr3TTiuHFR8
```

```r
x <- register_ss("hi I am new here")
```

```
## Sheet identified!
## sheet_title: hi I am new here
## sheet_key: 1TDCSaosJl_O6pn8Phxk_W6JoP6SCTYPpGr3TTiuHFR8
```

```r
str(x)
```

```
##               Spreadsheet title: hi I am new here
##   Date of gspreadr::register_ss: 2015-03-22 14:03:18 PDT
## Date of last spreadsheet update: 2015-03-22 21:03:17 UTC
## 
## Contains 1 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Sheet1: 1000 x 26
## 
## Key: 1TDCSaosJl_O6pn8Phxk_W6JoP6SCTYPpGr3TTiuHFR8
```

```r
add_ws(x, ws_title = "foo", nrow = 10, ncol = 10)
```

```
## Worksheet "foo" added to sheet "hi I am new here".
```

```r
x <- register_ss("hi I am new here")
```

```
## Sheet identified!
## sheet_title: hi I am new here
## sheet_key: 1TDCSaosJl_O6pn8Phxk_W6JoP6SCTYPpGr3TTiuHFR8
```

```r
str(x)
```

```
##               Spreadsheet title: hi I am new here
##   Date of gspreadr::register_ss: 2015-03-22 14:03:20 PDT
## Date of last spreadsheet update: 2015-03-22 21:03:20 UTC
## 
## Contains 2 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Sheet1: 1000 x 26
## foo: 10 x 10
## 
## Key: 1TDCSaosJl_O6pn8Phxk_W6JoP6SCTYPpGr3TTiuHFR8
```

```r
delete_ws(x, ws_title = "foo")
```

```
## Worksheet "foo" deleted from sheet "hi I am new here".
```

```r
x <- register_ss("hi I am new here")
```

```
## Sheet identified!
## sheet_title: hi I am new here
## sheet_key: 1TDCSaosJl_O6pn8Phxk_W6JoP6SCTYPpGr3TTiuHFR8
```

```r
str(x)
```

```
##               Spreadsheet title: hi I am new here
##   Date of gspreadr::register_ss: 2015-03-22 14:03:21 PDT
## Date of last spreadsheet update: 2015-03-22 21:03:21 UTC
## 
## Contains 1 worksheets:
## (Title): (Nominal worksheet extent as rows x columns)
## Sheet1: 1000 x 26
## 
## Key: 1TDCSaosJl_O6pn8Phxk_W6JoP6SCTYPpGr3TTiuHFR8
```

To rename a worksheet, pass in the spreadsheet object, the worksheet's current name and the new name you want it to be.  


```r
## oops this function not resurrected yet!
rename_worksheet(ssheet, "Sheet1", "First Sheet")
```

Tidy up by getting rid of the sheet we've playing with.


```r
delete_ss("hi I am new here")
```

```
## Sheet "hi I am new here" moved to trash in Google Drive.
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

*this functionality has not been resurrected yet*

### Update a single cell

You can update a cell's value by specifying the cell's position, either in `A1` or `R1C1` notation, and the new value. The new value may be a formula followed by a `=`, ie. `=A1+B1`. 


```r
update_cell(ws, "A1", "Oops")

get_cell(ws, "A1")

update_cell(ws, "R1C1", "country")

get_cell(ws, "R1C1")
```

### Update cells in batch

You can update a batch of cells by specifying the range (ie. "A1:A4"). Alternatively, if you just want to dump an entire dataframe or vector into a worksheet, you can specify an anchor cell as the reference cell position and the range will be calculated for you. You can pass in a vector of new values or an entire data frame.


```r
update_cells(ws, "C1:E1", c("A", "B", "C"))

read_range(ws, "A1:F3")

update_cells(ws, "G1", head(iris))

read_range(ws, "G1:K7")
```



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
