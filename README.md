<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Project Status: Wip - Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](http://www.repostatus.org/badges/0.1.0/wip.svg)](http://www.repostatus.org/#wip)

**Not quite ready for showtime but release coming very soon!**

------------------------------------------------------------------------

Google Sheets R API
-------------------

[![Build Status](https://travis-ci.org/jennybc/gspreadr.png?branch=master)](https://travis-ci.org/jennybc/gspreadr)

Manage your spreadsheets with *gspreadr* in R.

*gspreadr* is inspired by [gspread](https://github.com/burnash/gspread), a Google Spreadsheets Python API

Features:

-   Access a spreadsheet by its title, key or URL.
-   Extract data or edit data.
-   Add | delete | rename | copy spreadsheets and worksheets.

![gspreadr](README-gspreadr.png)

Basic Usage
-----------

``` r
library("gspreadr")
suppressMessages(library("dplyr"))
```

``` r
# See what spreadsheets you have
# (expect a prompt to authenticate with Google interactively HERE)
(my_sheets <- list_sheets())
#> Auto-refreshing stale OAuth token.
#> Source: local data frame [21 x 6]
#> 
#>                                     sheet_title
#> 1                          Public Testing Sheet
#> 2                                   Temperature
#> 3                                   gas_mileage
#> 4  1F0iNuYW4v_oG69s7c5NzdoMF_aXq1aOP-OAOJ4gK6Xc
#> 5                                Testing helper
#> 6                               Old Style Sheet
#> 7                                    jenny-test
#> 8                                     Gapminder
#> 9                                    Gapminderx
#> 10                                      Testing
#> ..                                          ...
#> Variables not shown: sheet_key (chr), owner (chr), perm (chr),
#>   last_updated (time), ws_feed (chr)
my_sheets %>% glimpse()
#> Observations: 21
#> Variables:
#> $ sheet_title  (chr) "Public Testing Sheet", "Temperature", "gas_milea...
#> $ sheet_key    (chr) "1hff6AzFAZgFdb5-onYc1FZySxTP4hlrcsPSkR0dG3qk", "...
#> $ owner        (chr) "gspreadr", "gspreadr", "woo.kara", "gspreadr", "...
#> $ perm         (chr) "rw", "rw", "r", "rw", "rw", "rw", "rw", "rw", "r...
#> $ last_updated (time) 2015-03-04 18:06:51, 2015-03-03 00:07:43, 2015-0...
#> $ ws_feed      (chr) "https://spreadsheets.google.com/feeds/worksheets...

# Hey let's look at the Gapminder data
gap <- register_ss("Gapminder")
#> Sheet identified!
#> sheet_title: Gapminder
#> sheet_key: 1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE
str(gap)
#>               Spreadsheet title: Gapminder
#>   Date of gspreadr::register_ss: 2015-03-04 10:12:46 PST
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

# Get the data for worksheet "Oceania": the fast tabular way ("list feed")
oceania_list_feed <- gap %>% get_via_lf(ws = "Oceania") 
#> Accessing worksheet titled "Oceania"
str(oceania_list_feed, give.attr = FALSE)
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
str(oceania_cell_feed, give.attr = FALSE)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    150 obs. of  5 variables:
#>  $ cell     : chr  "A1" "B1" "C1" "D1" ...
#>  $ cell_alt : chr  "R1C1" "R1C2" "R1C3" "R1C4" ...
#>  $ row      : int  1 1 1 1 1 1 2 2 2 2 ...
#>  $ col      : int  1 2 3 4 5 6 1 2 3 4 ...
#>  $ cell_text: chr  "country" "continent" "year" "lifeExp" ...
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
oceania_reshaped <- oceania_cell_feed %>% reshape_cf()
str(oceania_reshaped, give.attr = FALSE)
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

Authorization
-------------

##### Authorization using OAuth2 (recommended and auto-triggered in many cases)

``` r
# Give gspreadr permission to access your spreadsheets and google drive
authorize() 
```

##### Alternate authorization: login with your Google account

``` r
login("my_email", "password")
```

Stuff we are in the process of bringing back online after the Great Refactor of February 2015
---------------------------------------------------------------------------------------------

-   edit cells
-   visual overview of which cells are populated
-   finding a cell ?will we even do this?
