<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Project Status: Wip - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/0.1.0/wip.svg)](http://www.repostatus.org/#wip)[![Build Status](https://travis-ci.org/jennybc/gspreadr.svg?branch=master)](https://travis-ci.org/jennybc/gspreadr)[![Coverage Status](https://coveralls.io/repos/jennybc/gspreadr/badge.svg)](https://coveralls.io/r/jennybc/gspreadr)

------------------------------------------------------------------------

Google Sheets R API
-------------------

Manage your spreadsheets with *gspreadr* in R.

*gspreadr* is inspired by [gspread](https://github.com/burnash/gspread), a Google Spreadsheets Python API

Features:

-   Access a spreadsheet by its title, key or URL.
-   Extract data or edit data.
-   Create | delete | rename | copy spreadsheets and worksheets.

### Install gspreadr

``` r
devtools::install_github("jennybc/gspreadr")
```

### Load gspreadr

`gspreadr` is designed for use with the `%>%` pipe operator and, to a lesser extent, the data-wrangling mentality of `dplyr`. But rest assured, neither is strictly necessary to use `gspreadr`. The examples here use both, but we'll soon develop a vignette that shows usage with plain vanilla R.

``` r
library("gspreadr")
suppressMessages(library("dplyr"))
```

### See some spreadsheets you can access

The `list_sheets()` function returns the sheets you would see in your Google Sheets home screen: <https://docs.google.com/spreadsheets/>. This should include sheets that you own and may also show sheets owned by others but that you are permitted to access, especially if you have clicked on a link shared by the owner. Expect a prompt to authenticate yourself in the browser at this point (more below re: authentication).

``` r
(my_sheets <- list_sheets())
#> Source: local data frame [21 x 6]
#> 
#>                                     sheet_title
#> 1                          Public Testing Sheet
#> 2                                       scoring
#> 3                                   gas_mileage
#> 4                                   Temperature
#> 5  1F0iNuYW4v_oG69s7c5NzdoMF_aXq1aOP-OAOJ4gK6Xc
#> 6                                Testing helper
#> 7                               Old Style Sheet
#> 8                                    jenny-test
#> 9                                     Gapminder
#> 10                                   Gapminderx
#> ..                                          ...
#> Variables not shown: sheet_key (chr), owner (chr), perm (chr),
#>   last_updated (time), ws_feed (chr)
# (expect a prompt to authenticate with Google interactively HERE)
my_sheets %>% glimpse()
#> Observations: 21
#> Variables:
#> $ sheet_title  (chr) "Public Testing Sheet", "scoring", "gas_mileage",...
#> $ sheet_key    (chr) "1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk", "...
#> $ owner        (chr) "gspreadr", "gspreadr", "woo.kara", "gspreadr", "...
#> $ perm         (chr) "rw", "rw", "r", "rw", "rw", "rw", "rw", "rw", "r...
#> $ last_updated (time) 2015-03-22 20:21:17, 2015-03-20 22:32:48, 2015-0...
#> $ ws_feed      (chr) "https://spreadsheets.google.com/feeds/worksheets...
```

### Register a spreadsheet

If you plan to consume data from a sheet or edit it, you must first register it. Basically this is where `gspreadr` makes a note of important info about the sheet that's needed to access via the Sheets API. Once registered, you can get some basic info about the sheet via `str()`.

``` r
# Hey let's look at the Gapminder data
gap <- register_ss("Gapminder")
#> Sheet identified!
#> sheet_title: Gapminder
#> sheet_key: 1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE
str(gap)
#>               Spreadsheet title: Gapminder
#>   Date of gspreadr::register_ss: 2015-03-22 13:34:32 PDT
#> Date of last spreadsheet update: 2015-01-21 18:42:42 UTC
#> 
#> Contains 5 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> Africa: 1000 x 26
#> Americas: 1000 x 26
#> Asia: 1000 x 26
#> Europe: 1000 x 26
#> Oceania: 1000 x 26
#> 
#> Key: 1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE

# Need to access a sheet you do not own?
## Access it by key if you know it!
gap_key <- "1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE"
gap <- gap_key %>% register_ss
#> Sheet identified!
#> sheet_title: Gapminder
#> sheet_key: 1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE

# gspreadr may be able to determine the key from the browser URL
gap_url <- "https://docs.google.com/spreadsheets/d/1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE/"
gap <- gap_url %>% register_ss
#> Identifying info will be processed as a URL.
#> gspreadr will attempt to extract sheet key from the URL.
#> Putative key: 1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE
#> Sheet identified!
#> sheet_title: Gapminder
#> sheet_key: 1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE
```

### Get a Google spreadsheet to practice with

If you don't have any suitable Google Sheets lying around, or if you just want to follow along verbatim with this vignette, this bit of code will copy a sheet from the `gspreadr` Google user into your Drive. The sheet holds some of the [Gapminder data](https://github.com/jennybc/gapminder).

``` r
gap_key <- "1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE"
copy_ss(key = gap_key, to = "Gapminder")
```

If that seems to have worked, go check that you see a sheet named Gapminder listed in your Google Sheets home screen: <https://docs.google.com/spreadsheets/>. You could also try `list_sheets()` again and make sure the Gapminder sheet is listed.

Now register your copy of the Gapminder sheet and you can follow along:

``` r
gap <- register_ss("Gapminder")
str(gap)
```

### Consume data

There are two ways to consume data from a worksheet within a Google spreadsheet: the cell feed and the list feed. The cell feed gets data cell-by-cell. The list feed gets data by row. Read the function-level docs for more details about when to use which function.

``` r
# Get the data for worksheet "Oceania": the fast tabular way ("list feed")
oceania_list_feed <- gap %>% get_via_lf(ws = "Oceania") 
#> Accessing worksheet titled "Oceania"
str(oceania_list_feed)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    24 obs. of  6 variables:
#>  $ country  : chr  "Australia" "New Zealand" "Australia" "New Zealand" ...
#>  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
#>  $ year     : int  2007 2007 2002 2002 1997 1997 1992 1992 1987 1987 ...
#>  $ lifeexp  : num  81.2 80.2 80.4 79.1 78.8 ...
#>  $ pop      : int  20434176 4115771 19546792 3908037 18565243 3676187 17481977 3437674 16257249 3317166 ...
#>  $ gdppercap: num  34435 25185 30688 23190 26998 ...
oceania_list_feed
#> Source: local data frame [24 x 6]
#> 
#>        country continent year lifeexp      pop gdppercap
#> 1    Australia   Oceania 2007  81.235 20434176  34435.37
#> 2  New Zealand   Oceania 2007  80.204  4115771  25185.01
#> 3    Australia   Oceania 2002  80.370 19546792  30687.75
#> 4  New Zealand   Oceania 2002  79.110  3908037  23189.80
#> 5    Australia   Oceania 1997  78.830 18565243  26997.94
#> 6  New Zealand   Oceania 1997  77.550  3676187  21050.41
#> 7    Australia   Oceania 1992  77.560 17481977  23424.77
#> 8  New Zealand   Oceania 1992  76.330  3437674  18363.32
#> 9    Australia   Oceania 1987  76.320 16257249  21888.89
#> 10 New Zealand   Oceania 1987  74.320  3317166  19007.19
#> ..         ...       ...  ...     ...      ...       ...

# Get the data for worksheet "Oceania": the slower cell-by-cell way ("cell feed")
oceania_cell_feed <- gap %>% get_via_cf(ws = "Oceania") 
#> Accessing worksheet titled "Oceania"
str(oceania_cell_feed)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    150 obs. of  5 variables:
#>  $ cell     : chr  "A1" "B1" "C1" "D1" ...
#>  $ cell_alt : chr  "R1C1" "R1C2" "R1C3" "R1C4" ...
#>  $ row      : int  1 1 1 1 1 1 2 2 2 2 ...
#>  $ col      : int  1 2 3 4 5 6 1 2 3 4 ...
#>  $ cell_text: chr  "country" "continent" "year" "lifeExp" ...
#>  - attr(*, "ws_title")= chr "Oceania"
head(oceania_cell_feed, 10)
#> Source: local data frame [10 x 5]
#> 
#>    cell cell_alt row col cell_text
#> 1    A1     R1C1   1   1   country
#> 2    B1     R1C2   1   2 continent
#> 3    C1     R1C3   1   3      year
#> 4    D1     R1C4   1   4   lifeExp
#> 5    E1     R1C5   1   5       pop
#> 6    F1     R1C6   1   6 gdpPercap
#> 7    A2     R2C1   2   1 Australia
#> 8    B2     R2C2   2   2   Oceania
#> 9    C2     R2C3   2   3      2007
#> 10   D2     R2C4   2   4    81.235
```

#### Convenience wrappers and post-processing the data

There are a few ways to limit the data you're consuming. You can put direct limits into `get_via_cf()`, but there are also convenience functions to get a row (`get_row()`), a column (`get_col()`), or a range (`get_cells()`). Also, when you consume data via the cell feed (which these wrappers are doing under the hood), you will often want to reshape it or simplify it (`reshape_cf()` and `simplify_cf()`).

``` r
# Reshape: instead of one row per cell, make a nice rectangular data.frame
oceania_reshaped <- oceania_cell_feed %>% reshape_cf()
str(oceania_reshaped)
#> 'data.frame':    24 obs. of  6 variables:
#>  $ country  : chr  "Australia" "New Zealand" "Australia" "New Zealand" ...
#>  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
#>  $ year     : int  2007 2007 2002 2002 1997 1997 1992 1992 1987 1987 ...
#>  $ lifeExp  : num  81.2 80.2 80.4 79.1 78.8 ...
#>  $ pop      : int  20434176 4115771 19546792 3908037 18565243 3676187 17481977 3437674 16257249 3317166 ...
#>  $ gdpPercap: num  34435 25185 30688 23190 26998 ...
head(oceania_reshaped, 10)
#>        country continent year lifeExp      pop gdpPercap
#> 1    Australia   Oceania 2007  81.235 20434176  34435.37
#> 2  New Zealand   Oceania 2007  80.204  4115771  25185.01
#> 3    Australia   Oceania 2002  80.370 19546792  30687.75
#> 4  New Zealand   Oceania 2002  79.110  3908037  23189.80
#> 5    Australia   Oceania 1997  78.830 18565243  26997.94
#> 6  New Zealand   Oceania 1997  77.550  3676187  21050.41
#> 7    Australia   Oceania 1992  77.560 17481977  23424.77
#> 8  New Zealand   Oceania 1992  76.330  3437674  18363.32
#> 9    Australia   Oceania 1987  76.320 16257249  21888.89
#> 10 New Zealand   Oceania 1987  74.320  3317166  19007.19

# Limit data retrieval to certain cells

# Example: first 3 rows
gap_3rows <- gap %>% get_row("Europe", row = 1:3)
#> Accessing worksheet titled "Europe"
gap_3rows %>% head()
#> Source: local data frame [6 x 5]
#> 
#>   cell cell_alt row col cell_text
#> 1   A1     R1C1   1   1   country
#> 2   B1     R1C2   1   2 continent
#> 3   C1     R1C3   1   3      year
#> 4   D1     R1C4   1   4   lifeExp
#> 5   E1     R1C5   1   5       pop
#> 6   F1     R1C6   1   6 gdpPercap

# convert to a data.frame (first row treated as header by default)
gap_3rows %>% reshape_cf()
#>   country continent year lifeExp     pop gdpPercap
#> 1 Albania    Europe 2007  76.423 3600523  5937.029
#> 2 Austria    Europe 2007  79.829 8199783 36126.493

# Example: first row only
gap_1row <- gap %>% get_row("Europe", row = 1)
#> Accessing worksheet titled "Europe"
gap_1row
#> Source: local data frame [6 x 5]
#> 
#>   cell cell_alt row col cell_text
#> 1   A1     R1C1   1   1   country
#> 2   B1     R1C2   1   2 continent
#> 3   C1     R1C3   1   3      year
#> 4   D1     R1C4   1   4   lifeExp
#> 5   E1     R1C5   1   5       pop
#> 6   F1     R1C6   1   6 gdpPercap

# convert to a named character vector
gap_1row %>% simplify_cf()
#>          A1          B1          C1          D1          E1          F1 
#>   "country" "continent"      "year"   "lifeExp"       "pop" "gdpPercap"

# just 2 columns, converted to data.frame
gap %>%
  get_col("Oceania", col = 3:4) %>%
  reshape_cf()
#> Accessing worksheet titled "Oceania"
#>    year lifeExp
#> 1  2007  81.235
#> 2  2007  80.204
#> 3  2002  80.370
#> 4  2002  79.110
#> 5  1997  78.830
#> 6  1997  77.550
#> 7  1992  77.560
#> 8  1992  76.330
#> 9  1987  76.320
#> 10 1987  74.320
#> 11 1982  74.740
#> 12 1982  73.840
#> 13 1977  73.490
#> 14 1977  72.220
#> 15 1972  71.930
#> 16 1972  71.890
#> 17 1967  71.100
#> 18 1967  71.520
#> 19 1962  70.930
#> 20 1962  71.240
#> 21 1957  70.330
#> 22 1957  70.260
#> 23 1952  69.120
#> 24 1952  69.390

# arbitrary cell range
gap %>%
  get_cells("Oceania", range = "D12:F15") %>%
  reshape_cf(header = FALSE)
#> Accessing worksheet titled "Oceania"
#>      X4       X5       X6
#> 1 74.74 15184200 19477.01
#> 2 73.84  3210650 17632.41
#> 3 73.49 14074100 18334.20
#> 4 72.22  3164900 16233.72

# arbitrary cell range, alternative specification
gap %>%
  get_via_cf("Oceania", max_row = 5, min_col = 1, max_col = 3) %>%
  reshape_cf()
#> Accessing worksheet titled "Oceania"
#>       country continent year
#> 1   Australia   Oceania 2007
#> 2 New Zealand   Oceania 2007
#> 3   Australia   Oceania 2002
#> 4 New Zealand   Oceania 2002
```

### Create sheets

You can use `gspreadr` to create new spreadsheets.

``` r
foo <- new_ss("foo")
#> Sheet "foo" created in Google Drive.
#> Identifying info is a spreadsheet object; gspreadr will re-identify the sheet based on sheet key.
#> Sheet identified!
#> sheet_title: foo
#> sheet_key: 1HY6QF9331CHBqWNJltXvsS2eeGHnJ_P1Cy5CUsUa0qE
foo %>% str
#>               Spreadsheet title: foo
#>   Date of gspreadr::register_ss: 2015-03-22 13:34:40 PDT
#> Date of last spreadsheet update: 2015-03-22 20:34:39 UTC
#> 
#> Contains 1 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> Sheet1: 1000 x 26
#> 
#> Key: 1HY6QF9331CHBqWNJltXvsS2eeGHnJ_P1Cy5CUsUa0qE
```

By default, there will be an empty worksheet called "Sheet1". You can also add, rename, and delete worksheets within an existing sheet via `add_ws()`, `rename_ws()`, and `delete_ws()`. Copy an entire spreadsheet with `copy_ss()`.

### Edit cells

You can modify the data in sheet cells via `edit_cells()`. We'll work on the completely empty sheet created above, `foo`.

``` r
foo <- foo %>% edit_cells(input = head(iris), header = TRUE)
#> Range affected by the update: "A1:E7"
#> Worksheet "Sheet1" successfully updated with 35 new value(s).
```

Go to [your spreadsheets home page](https://docs.google.com/spreadsheets/u/0/), find the new sheet `foo` and look at it. You should see some iris data in the first (and only) worksheet. We'll also take a look at it here, by consuming `foo` via the list feed.

Note that we always store the returned value from `edit-cells()` (and all other sheet editing functions). That's because the registration info changes whenever we edit the sheet and we re-register it inside these functions, so this idiom will help you make sequential edits and queries to the same sheet.

``` r
foo %>% get_via_lf() %>% print()
#> Accessing worksheet titled "Sheet1"
#> Source: local data frame [6 x 5]
#> 
#>   sepal.length sepal.width petal.length petal.width species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
#> 5          5.0         3.6          1.4         0.2  setosa
#> 6          5.4         3.9          1.7         0.4  setosa
```

Read the function documentation for `edit_cells()` for ways to specify where the data goes and in which direction.

### Delete sheets

Let's clean up by deleting the `foo` spreadsheets we've been playing with.

``` r
delete_ss("foo")
#> Sheet "foo" moved to trash in Google Drive.
```

### Upload delimited files or Excel workbooks cells

Here's how we can create a new spreadsheet from a suitable local file. First, we'll write then upload a comma-delimited excerpt from the iris data.

``` r
iris %>% head(5) %>% write.csv("iris.csv", row.names = FALSE)
iris_ss <- upload_ss("iris.csv")
#> "iris.csv" uploaded to Google Drive and converted to a Google Sheet named "iris"
iris_ss %>% str()
#>               Spreadsheet title: iris
#>   Date of gspreadr::register_ss: 2015-03-22 13:34:49 PDT
#> Date of last spreadsheet update: 2015-03-22 20:34:48 UTC
#> 
#> Contains 1 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> iris: 6 x 5
#> 
#> Key: 10HFiLsQLXW6lxikxmvLNEJEy6XR8ntMhmBkmlohmPUQ
iris_ss %>% get_via_lf() %>% print()
#> Accessing worksheet titled "iris"
#> Source: local data frame [5 x 5]
#> 
#>   sepal.length sepal.width petal.length petal.width species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
#> 5          5.0         3.6          1.4         0.2  setosa
file.remove("iris.csv")
#> [1] TRUE
```

Now we'll upload a multi-sheet Excel workbook.

``` r
upload_ss("tests/testthat/gap-data.xlsx")
#> "gap-data.xlsx" uploaded to Google Drive and converted to a Google Sheet named "gap-data"
gap_xlsx <- register_ss("gap-data")
#> Sheet identified!
#> sheet_title: gap-data
#> sheet_key: 1cOWpovWS0LmHiFO1JVqavKmZjav_AUYs3V6UQX2CyWk
gap_xlsx %>% str()
#>               Spreadsheet title: gap-data
#>   Date of gspreadr::register_ss: 2015-03-22 13:34:56 PDT
#> Date of last spreadsheet update: 2015-03-22 20:34:54 UTC
#> 
#> Contains 5 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> Africa: 619 x 6
#> Americas: 301 x 6
#> Asia: 397 x 6
#> Europe: 361 x 6
#> Oceania: 25 x 6
#> 
#> Key: 1cOWpovWS0LmHiFO1JVqavKmZjav_AUYs3V6UQX2CyWk
gap_xlsx %>% get_via_lf(ws = "Oceania") %>% print()
#> Accessing worksheet titled "Oceania"
#> Source: local data frame [24 x 6]
#> 
#>        country continent year lifeexp      pop gdppercap
#> 1    Australia   Oceania 2007  81.235 20434176  34435.37
#> 2  New Zealand   Oceania 2007  80.204  4115771  25185.01
#> 3    Australia   Oceania 2002  80.370 19546792  30687.75
#> 4  New Zealand   Oceania 2002  79.110  3908037  23189.80
#> 5    Australia   Oceania 1997  78.830 18565243  26997.94
#> 6  New Zealand   Oceania 1997  77.550  3676187  21050.41
#> 7    Australia   Oceania 1992  77.560 17481977  23424.77
#> 8  New Zealand   Oceania 1992  76.330  3437674  18363.32
#> 9    Australia   Oceania 1987  76.320 16257249  21888.89
#> 10 New Zealand   Oceania 1987  74.320  3317166  19007.19
#> ..         ...       ...  ...     ...      ...       ...
```

And we clean up after ourselves on Google Drive.

``` r
delete_ss("iris")
#> Sheet "iris" moved to trash in Google Drive.
delete_ss("gap-data")
#> Sheet "gap-data" moved to trash in Google Drive.
```

### Authorization using OAuth2

If you use a function that requires authentication, it will be auto-triggered. But you can also initiate the process explicitly if you wish, like so:

``` r
# Give gspreadr permission to access your spreadsheets and google drive
authorize() 
```

Use `authorize(new_user = TRUE)`, to force the process to begin anew. Otherwise, the credentials left behind will be used to refresh your access token as needed.

##### Stuff we are in the process of bringing back online after the Great Refactor of February 2015

-   visual overview of which cells are populated
