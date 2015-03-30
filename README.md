<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Project Status: Active - The project has reached a stable, usable state and is being actively developed.](http://www.repostatus.org/badges/0.1.0/active.svg)](http://www.repostatus.org/#active) [![Build Status](https://travis-ci.org/jennybc/googlesheets.svg?branch=master)](https://travis-ci.org/jennybc/googlesheets) [![Coverage Status](https://coveralls.io/repos/jennybc/googlesheets/badge.svg)](https://coveralls.io/r/jennybc/googlesheets)

------------------------------------------------------------------------

Google Sheets R API
-------------------

Access and manage Google spreadsheets from R with `googlesheets`.

Features:

-   Access a spreadsheet by its title, key or URL.
-   Extract data or edit data.
-   Create | delete | rename | copy | upload | download spreadsheets and worksheets.

`googlesheets` is inspired by [gspread](https://github.com/burnash/gspread), a Google Spreadsheets Python API

The exuberant prose in this README is inspired by [Tabletop.js](https://github.com/jsoma/tabletop): If you've ever wanted to get data in or out of a Google Spreadsheet from R without jumping through a thousand hoops, welcome home!

#### What the hell do I do with this?

Think of `googlesheets` as a read/write CMS that you (or your less R-obsessed friends) can edit through Google Docs, as well via R. It's like Christmas up in here.

Use a Google Form to conduct a survey, which populates a Google Sheet.

Gather data while you're in the field in a Google Sheet, maybe [with an iPhone](https://itunes.apple.com/us/app/google-sheets/id842849113?mt=8) or [an Android device](https://play.google.com/store/apps/details?id=com.google.android.apps.docs.editors.sheets&hl=en).

Use `googlesheets` to get all that data into R.

Use it in a Shiny app! *this will be the next demo/vignette I write*

What other ideas do you have?

### Install googlesheets

``` r
devtools::install_github("jennybc/googlesheets")
```

### Take a look at the vignette

This README is arguably as or more useful as the vignette and both are still under development. But feel free to [check out the current state of the vignette](http://htmlpreview.github.io/?https://raw.githubusercontent.com/jennybc/googlesheets/master/vignettes/basic-usage.html).

### Load googlesheets

`googlesheets` is designed for use with the `%>%` pipe operator and, to a lesser extent, the data-wrangling mentality of `dplyr`. The examples here use both, but we'll soon develop a vignette that shows usage with plain vanilla R. `googlesheets` uses `dplyr` internally but does not require the user to do so.

``` r
library("googlesheets")
suppressMessages(library("dplyr"))
```

### See some spreadsheets you can access

The `list_sheets()` function returns the sheets you would see in your Google Sheets home screen: <https://docs.google.com/spreadsheets/>. This should include sheets that you own and may also show sheets owned by others but that you are permitted to access, especially if you have clicked on a link shared by the owner. Expect a prompt to authenticate yourself in the browser at this point (more below re: authentication).

``` r
(my_sheets <- list_sheets())
#> Auto-refreshing stale OAuth token.
#> Source: local data frame [17 x 6]
#> 
#>                                     sheet_title
#> 1                          Public Testing Sheet
#> 2                                     Gapminder
#> 3                      Gapminder 2007 Can Write
#> 4                                 Gapminder_old
#> 5                                Testing helper
#> 6                                       scoring
#> 7                                WI15 ARCHY 499
#> 8                                   gas_mileage
#> 9                                   Temperature
#> 10 1F0iNuYW4v_oG69s7c5NzdoMF_aXq1aOP-OAOJ4gK6Xc
#> 11                              Old Style Sheet
#> 12                                   jenny-test
#> 13                       Gapminder by Continent
#> 14                                  basic-usage
#> 15                 Caffeine craver? (Responses)
#> 16                        Private Sheet Example
#> 17                                  Code Sample
#> Variables not shown: sheet_key (chr), owner (chr), perm (chr),
#>   last_updated (time), ws_feed (chr)
# (expect a prompt to authenticate with Google interactively HERE)
my_sheets %>% glimpse()
#> Observations: 17
#> Variables:
#> $ sheet_title  (chr) "Public Testing Sheet", "Gapminder", "Gapminder 2...
#> $ sheet_key    (chr) "1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk", "...
#> $ owner        (chr) "gspreadr", "gspreadr", "gspreadr", "gspreadr", "...
#> $ perm         (chr) "rw", "rw", "rw", "rw", "rw", "rw", "r", "r", "rw...
#> $ last_updated (time) 2015-03-30 05:44:24, 2015-03-23 20:59:10, 2015-0...
#> $ ws_feed      (chr) "https://spreadsheets.google.com/feeds/worksheets...
```

### Register a spreadsheet

If you plan to consume data from a sheet or edit it, you must first register it. Basically this is where `googlesheets` makes a note of important info about the sheet that's needed to access via the Sheets API. Once registered, you can print the result to get some basic info about the sheet.

``` r
# Hey let's look at the Gapminder data
gap <- register_ss("Gapminder")
#> Sheet identified!
#> sheet_title: Gapminder
#> sheet_key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA
gap
#>                   Spreadsheet title: Gapminder
#>   Date of googlesheets::register_ss: 2015-03-30 10:12:49 PDT
#>     Date of last spreadsheet update: 2015-03-23 20:34:08 UTC
#> 
#> Contains 5 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> Africa: 625 x 6
#> Americas: 301 x 6
#> Asia: 397 x 6
#> Europe: 361 x 6
#> Oceania: 25 x 6
#> 
#> Key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA

# Need to access a sheet you do not own?
# Access it by key if you know it!
gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
gap <- gap_key %>% register_ss
#> Sheet identified!
#> sheet_title: Gapminder
#> sheet_key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA

# googlesheets may be able to determine the key from the browser URL
# may not work (yet) for old sheets ... open an issue if have problem
gap_url <- "https://docs.google.com/spreadsheets/d/1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA/"
gap <- gap_url %>% register_ss
#> Identifying info will be processed as a URL.
#> googlesheets will attempt to extract sheet key from the URL.
#> Putative key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA
#> Sheet identified!
#> sheet_title: Gapminder
#> sheet_key: 1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA
```

### Get a Google spreadsheet to practice with

If you don't have any suitable Google Sheets lying around, or if you just want to follow along verbatim with this vignette, this bit of code will copy a sheet from the `googlesheets` Google user into your Drive. The sheet holds some of the [Gapminder data](https://github.com/jennybc/gapminder).

``` r
gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
copy_ss(key = gap_key, to = "Gapminder")
```

If that seems to have worked, go check that you see a sheet named Gapminder listed in your Google Sheets home screen: <https://docs.google.com/spreadsheets/>. You could also try `list_sheets()` again and make sure the Gapminder sheet is listed.

Now register your copy of the Gapminder sheet and you can follow along:

``` r
gap <- register_ss("Gapminder")
gap
```

### Consume data

There are three ways to consume data from a worksheet within a Google spreadsheet. The order goes from fastest-but-more-limited to slowest-but-most-flexible:

-   `get_via_csv()`: Don't let the name scare you! Nothing is written to file during this process. The name just reflects that, under the hood, we request the data via the "exportcsv" link. For cases where `get_via_csv()` and `get_via_lf()` both work, we see that `get_via_csv()` is around **50 times faster**. Use this when your data occupies a nice rectangle in the sheet and you're willing to consume all of it. You will get a `tbl_df` back, which is basically just a `data.frame`.
-   `get_via_lf()`: Gets data via the ["list feed"](https://developers.google.com/google-apps/spreadsheets/#working_with_list-based_feeds), which consumes data row-by-row. Like `get_via_csv()`, this is appropriate when your data occupies a nice rectangle. You will again get a `tbl_df` back, but your variable names may have been mangled (by Google, not us!). Specifically, variable names will be forcefully lowercased and all non-alpha-numeric characters will be removed. Why do we even have this function? The list feed supports some query parameters for sorting and filtering the data, which we plan to support in the near future (\#17).
-   `get_via_cf()`: Get data via the ["cell feed"](https://developers.google.com/google-apps/spreadsheets/#working_with_cell-based_feeds), which consumes data cell-by-cell. This is appropriate when you want to consume arbitrary cells, rows, columns, and regions of the sheet. It works great for small amounts of data but can be rather slow otherwise. `get_via_cf()` returns a `tbl_df` with **one row per cell**. You can specify cell limits directly in `get_via_cf()` or use convenience wrappers `get_row()`, `get_col()` or `get_cells()` for some common special cases. See below for demos of `reshape_cf()` and `simplify_cf()` which help with post-processing.

``` r
# Get the data for worksheet "Oceania": the super-fast csv way
oceania_csv <- gap %>% get_via_csv(ws = "Oceania")
#> Accessing worksheet titled "Oceania"
str(oceania_csv)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    24 obs. of  6 variables:
#>  $ country  : chr  "Australia" "Australia" "Australia" "Australia" ...
#>  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
#>  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
#>  $ lifeExp  : num  69.1 70.3 70.9 71.1 71.9 ...
#>  $ pop      : int  8691212 9712569 10794968 11872264 13177000 14074100 15184200 16257249 17481977 18565243 ...
#>  $ gdpPercap: num  10040 10950 12217 14526 16789 ...
oceania_csv
#> Source: local data frame [24 x 6]
#> 
#>      country continent year lifeExp      pop gdpPercap
#> 1  Australia   Oceania 1952   69.12  8691212  10039.60
#> 2  Australia   Oceania 1957   70.33  9712569  10949.65
#> 3  Australia   Oceania 1962   70.93 10794968  12217.23
#> 4  Australia   Oceania 1967   71.10 11872264  14526.12
#> 5  Australia   Oceania 1972   71.93 13177000  16788.63
#> 6  Australia   Oceania 1977   73.49 14074100  18334.20
#> 7  Australia   Oceania 1982   74.74 15184200  19477.01
#> 8  Australia   Oceania 1987   76.32 16257249  21888.89
#> 9  Australia   Oceania 1992   77.56 17481977  23424.77
#> 10 Australia   Oceania 1997   78.83 18565243  26997.94
#> ..       ...       ...  ...     ...      ...       ...

# Get the data for worksheet "Oceania": the fast tabular way ("list feed")
oceania_list_feed <- gap %>% get_via_lf(ws = "Oceania") 
#> Accessing worksheet titled "Oceania"
str(oceania_list_feed)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    24 obs. of  6 variables:
#>  $ country  : chr  "Australia" "Australia" "Australia" "Australia" ...
#>  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
#>  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
#>  $ lifeexp  : num  69.1 70.3 70.9 71.1 71.9 ...
#>  $ pop      : int  8691212 9712569 10794968 11872264 13177000 14074100 15184200 16257249 17481977 18565243 ...
#>  $ gdppercap: num  10040 10950 12217 14526 16789 ...
oceania_list_feed
#> Source: local data frame [24 x 6]
#> 
#>      country continent year lifeexp      pop gdppercap
#> 1  Australia   Oceania 1952   69.12  8691212  10039.60
#> 2  Australia   Oceania 1957   70.33  9712569  10949.65
#> 3  Australia   Oceania 1962   70.93 10794968  12217.23
#> 4  Australia   Oceania 1967   71.10 11872264  14526.12
#> 5  Australia   Oceania 1972   71.93 13177000  16788.63
#> 6  Australia   Oceania 1977   73.49 14074100  18334.20
#> 7  Australia   Oceania 1982   74.74 15184200  19477.01
#> 8  Australia   Oceania 1987   76.32 16257249  21888.89
#> 9  Australia   Oceania 1992   77.56 17481977  23424.77
#> 10 Australia   Oceania 1997   78.83 18565243  26997.94
#> ..       ...       ...  ...     ...      ...       ...

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
#> 9    C2     R2C3   2   3      1952
#> 10   D2     R2C4   2   4     69.12
```

#### Convenience wrappers and post-processing the data

There are a few ways to limit the data you're consuming. You can put direct limits into `get_via_cf()`, but there are also convenience functions to get a row (`get_row()`), a column (`get_col()`), or a range (`get_cells()`). Also, when you consume data via the cell feed (which these wrappers are doing under the hood), you will often want to reshape it or simplify it (`reshape_cf()` and `simplify_cf()`).

``` r
# Reshape: instead of one row per cell, make a nice rectangular data.frame
oceania_reshaped <- oceania_cell_feed %>% reshape_cf()
str(oceania_reshaped)
#> 'data.frame':    24 obs. of  6 variables:
#>  $ country  : chr  "Australia" "Australia" "Australia" "Australia" ...
#>  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
#>  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
#>  $ lifeExp  : num  69.1 70.3 70.9 71.1 71.9 ...
#>  $ pop      : int  8691212 9712569 10794968 11872264 13177000 14074100 15184200 16257249 17481977 18565243 ...
#>  $ gdpPercap: num  10040 10950 12217 14526 16789 ...
head(oceania_reshaped, 10)
#>      country continent year lifeExp      pop gdpPercap
#> 1  Australia   Oceania 1952   69.12  8691212  10039.60
#> 2  Australia   Oceania 1957   70.33  9712569  10949.65
#> 3  Australia   Oceania 1962   70.93 10794968  12217.23
#> 4  Australia   Oceania 1967   71.10 11872264  14526.12
#> 5  Australia   Oceania 1972   71.93 13177000  16788.63
#> 6  Australia   Oceania 1977   73.49 14074100  18334.20
#> 7  Australia   Oceania 1982   74.74 15184200  19477.01
#> 8  Australia   Oceania 1987   76.32 16257249  21888.89
#> 9  Australia   Oceania 1992   77.56 17481977  23424.77
#> 10 Australia   Oceania 1997   78.83 18565243  26997.94

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
#> 1 Albania    Europe 1952   55.23 1282697  1601.056
#> 2 Albania    Europe 1957   59.28 1476505  1942.284

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
#> 1  1952  69.120
#> 2  1957  70.330
#> 3  1962  70.930
#> 4  1967  71.100
#> 5  1972  71.930
#> 6  1977  73.490
#> 7  1982  74.740
#> 8  1987  76.320
#> 9  1992  77.560
#> 10 1997  78.830
#> 11 2002  80.370
#> 12 2007  81.235
#> 13 1952  69.390
#> 14 1957  70.260
#> 15 1962  71.240
#> 16 1967  71.520
#> 17 1972  71.890
#> 18 1977  72.220
#> 19 1982  73.840
#> 20 1987  74.320
#> 21 1992  76.330
#> 22 1997  77.550
#> 23 2002  79.110
#> 24 2007  80.204

# arbitrary cell range
gap %>%
  get_cells("Oceania", range = "D12:F15") %>%
  reshape_cf(header = FALSE)
#> Accessing worksheet titled "Oceania"
#>       X4       X5       X6
#> 1 80.370 19546792 30687.75
#> 2 81.235 20434176 34435.37
#> 3 69.390  1994794 10556.58
#> 4 70.260  2229407 12247.40

# arbitrary cell range, alternative specification
gap %>%
  get_via_cf("Oceania", max_row = 5, min_col = 1, max_col = 3) %>%
  reshape_cf()
#> Accessing worksheet titled "Oceania"
#>     country continent year
#> 1 Australia   Oceania 1952
#> 2 Australia   Oceania 1957
#> 3 Australia   Oceania 1962
#> 4 Australia   Oceania 1967
```

### Create sheets

You can use `googlesheets` to create new spreadsheets.

``` r
foo <- new_ss("foo")
#> Sheet "foo" created in Google Drive.
#> Identifying info is a googlesheet object; googlesheets will re-identify the sheet based on sheet key.
#> Sheet identified!
#> sheet_title: foo
#> sheet_key: 15F5oaaXxst4Jf5UP-4ZWocjtHBuGYP-VuIN5muRRAY4
foo
#>                   Spreadsheet title: foo
#>   Date of googlesheets::register_ss: 2015-03-30 10:12:58 PDT
#>     Date of last spreadsheet update: 2015-03-30 17:12:54 UTC
#> 
#> Contains 1 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> Sheet1: 1000 x 26
#> 
#> Key: 15F5oaaXxst4Jf5UP-4ZWocjtHBuGYP-VuIN5muRRAY4
```

By default, there will be an empty worksheet called "Sheet1". You can also add, rename, and delete worksheets within an existing sheet via `add_ws()`, `rename_ws()`, and `delete_ws()`. Copy an entire spreadsheet with `copy_ss()`.

### Edit cells

You can modify the data in sheet cells via `edit_cells()`. We'll work on the completely empty sheet created above, `foo`. If your edit essentially populates the sheet with everything it should have, set `trim = TRUE` and we will resize the sheet to match the data. Then the nominal worksheet extent is much more informative (vs. the default of 1000 rows and 26 columns).

``` r
foo <- foo %>% edit_cells(input = head(iris), header = TRUE, trim = TRUE)
#> Range affected by the update: "A1:E7"
#> Worksheet "Sheet1" successfully updated with 35 new value(s).
#> Worksheet "Sheet1" dimensions changed to 7 x 5.
```

Go to [your spreadsheets home page](https://docs.google.com/spreadsheets/u/0/), find the new sheet `foo` and look at it. You should see some iris data in the first (and only) worksheet. We'll also take a look at it here, by consuming `foo` via the list feed.

Note that we always store the returned value from `edit_cells()` (and all other sheet editing functions). That's because the registration info changes whenever we edit the sheet and we re-register it inside these functions, so this idiom will help you make sequential edits and queries to the same sheet.

``` r
foo %>% get_via_lf()
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
#> Sheets found and slated for deletion:
#> foo
#> Success. All moved to trash in Google Drive.
```

### Upload delimited files or Excel workbooks

Here's how we can create a new spreadsheet from a suitable local file. First, we'll write then upload a comma-delimited excerpt from the iris data.

``` r
iris %>% head(5) %>% write.csv("iris.csv", row.names = FALSE)
iris_ss <- upload_ss("iris.csv")
#> "iris.csv" uploaded to Google Drive and converted to a Google Sheet named "iris"
iris_ss
#>                   Spreadsheet title: iris
#>   Date of googlesheets::register_ss: 2015-03-30 10:13:53 PDT
#>     Date of last spreadsheet update: 2015-03-30 17:13:50 UTC
#> 
#> Contains 1 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> iris: 6 x 5
#> 
#> Key: 1scy2YTJBqV16dFhgzu6hpAvKKcQfLLw_LVaMf_w-T0Y
iris_ss %>% get_via_lf()
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

Now we'll upload a multi-sheet Excel workbook. Slowly.

``` r
gap_xlsx <- upload_ss("tests/testthat/gap-data.xlsx")
#> "gap-data.xlsx" uploaded to Google Drive and converted to a Google Sheet named "gap-data"
gap_xlsx
#>                   Spreadsheet title: gap-data
#>   Date of googlesheets::register_ss: 2015-03-30 10:13:58 PDT
#>     Date of last spreadsheet update: 2015-03-30 17:13:55 UTC
#> 
#> Contains 5 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> Africa: 619 x 6
#> Americas: 301 x 6
#> Asia: 397 x 6
#> Europe: 361 x 6
#> Oceania: 25 x 6
#> 
#> Key: 1XVAxSxmqUUFalyJsa-3WPZMxfR9WGwgvt3oPSCyEFyU
gap_xlsx %>% get_via_lf(ws = "Oceania")
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
#> Sheets found and slated for deletion:
#> iris
#> Success. All moved to trash in Google Drive.
delete_ss("gap-data")
#> Sheets found and slated for deletion:
#> gap-data
#> Success. All moved to trash in Google Drive.
```

### Authorization using OAuth2

If you use a function that requires authentication, it will be auto-triggered. But you can also initiate the process explicitly if you wish, like so:

``` r
# Give googlesheets permission to access your spreadsheets and google drive
authorize() 
```

Use `authorize(new_user = TRUE)`, to force the process to begin anew. Otherwise, the credentials left behind will be used to refresh your access token as needed.

##### Stuff we are in the process of bringing back online after the Great Refactor of February 2015

-   visual overview of which cells are populated
