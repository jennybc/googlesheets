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

Use a [Google Form](http://www.google.com/forms/about/) to conduct a survey, which populates a Google Sheet.

Gather data while you're in the field in a Google Sheet, maybe [with an iPhone](https://itunes.apple.com/us/app/google-sheets/id842849113?mt=8) or [an Android device](https://play.google.com/store/apps/details?id=com.google.android.apps.docs.editors.sheets&hl=en). Take advantage of [data validation](https://support.google.com/docs/answer/139705?hl=en) to limit the crazy on the way in.

There are various ways to harvest web data directly into a Google Sheet. For example:

-   [This blog post](http://blog.aylien.com/post/114757623598/sentiment-analysis-of-restaurant-reviews) from Aylien.com has a simple example that uses the `=IMPORTXML()` formula to populate a Google Sheet with restaurant reviews and ratings from TripAdvisor.
-   Martin Hawksey offers [TAGS](https://tags.hawksey.info), a free Google Sheet template to setup and run automated collection of search results from Twitter.
-   Martin Hawksey also has a great blog post, [Feeding Google Spreadsheets](https://mashe.hawksey.info/2012/10/feeding-google-spreadsheets-exercises-in-import/), that demonstrates how functions like `importHTML`, `importFeed`, and `importXML` help you get data from the web into a Google Sheet with no programming.
-   Martin Hawksey has another blog post about [feeding a Google Sheet from IFTTT](https://mashe.hawksey.info/2012/09/ifttt-if-i-do-that-on-insert-social-networkrss-feedother-then-add-row-to-google-spreadsheet/). [IFTTT](https://ifttt.com) stands for "if this, then that" and it's "a web-based service that allows users to create chains of simple conditional statements, called 'recipes', which are triggered based on changes to other web services such as Gmail, Facebook, Instagram, and Craigslist" (from [Wikipedia](http://en.wikipedia.org/wiki/IFTTT)).

Use `googlesheets` to get all that data into R.

Use it in a Shiny app! *this will be the next demo/vignette I write*

What other ideas do you have?

### Install googlesheets

``` r
devtools::install_github("jennybc/googlesheets")
```

*We plan to submit to CRAN in June 2015, so feedback on functionality and usability is especially valuable to us now!*

### Take a look at the vignette

No, actually, **don't**. This README is much more current than the vignette, though that will have to change soon!

If you insist, [check out the current state of the vignette](http://htmlpreview.github.io/?https://raw.githubusercontent.com/jennybc/googlesheets/master/vignettes/basic-usage.html).

### Load googlesheets

`googlesheets` is designed for use with the `%>%` pipe operator and, to a lesser extent, the data-wrangling mentality of [`dplyr`](http://cran.r-project.org/web/packages/dplyr/index.html). This README uses both, but the examples in the help files emphasize usage with plain vanilla R, if that's how you roll. `googlesheets` uses `dplyr` internally but does not require the user to do so. You can make the `%>%` pipe operator available in your own work by loading [`dplyr`](http://cran.r-project.org/web/packages/dplyr/index.html) or [`magrittr`](http://cran.r-project.org/web/packages/magrittr/index.html).

``` r
library("googlesheets")
suppressPackageStartupMessages(library("dplyr"))
```

### Function naming convention

*implementation not yet 100% complete ... but we'll get there soon*

All functions start with `gs_`, which plays nicely with tab completion in RStudio, for example. If the function has something to do with worksheets or tabs within a spreadsheet, it will start with `gs_ws_`.

### See some spreadsheets you can access

The `gs_ls()` function returns the sheets you would see in your Google Sheets home screen: <https://docs.google.com/spreadsheets/>. This should include sheets that you own and may also show sheets owned by others but that you are permitted to access, if you visited the sheet in the browser. Expect a prompt to authenticate yourself in the browser at this point (more below re: authentication).

``` r
(my_sheets <- gs_ls())
#> Source: local data frame [40 x 10]
#> 
#>                 sheet_title        author perm version             updated
#> 1  Copy of Twitter Archive…   joannazhaoo    r     new 2015-05-31 22:00:25
#> 2               TAGS v6.0ns     m.hawksey    r     new 2015-05-31 21:12:24
#> 3  Copy of test-gs-gapmind…      gspreadr   rw     new 2015-05-31 21:11:01
#> 4              #rhizo15 #tw     m.hawksey    r     new 2015-05-31 13:12:01
#> 5   EasyTweetSheet - Shared     m.hawksey    r     new 2015-05-31 22:02:01
#> 6  Ari's Anchor Text Scrap…      anahmani    r     new 2015-05-29 07:18:48
#> 7  Tweet Collector (TAGS v…      gspreadr   rw     new 2015-05-28 17:43:29
#> 8      test-gs-cars-private      gspreadr   rw     new 2015-05-27 17:48:34
#> 9     All R Phylo Functions  omeara.brian    r     new 2015-05-20 18:34:43
#> 10 test-gs-public-testing-…  rpackagetest    r     new 2015-05-20 01:32:27
#> ..                      ...           ...  ...     ...                 ...
#> Variables not shown: sheet_key (chr), ws_feed (chr), alternate (chr), self
#>   (chr), alt_key (chr)
# (expect a prompt to authenticate with Google interactively HERE)
my_sheets %>% glimpse()
#> Observations: 40
#> Variables:
#> $ sheet_title (chr) "Copy of Twitter Archiver v2.1", "TAGS v6.0ns", "C...
#> $ author      (chr) "joannazhaoo", "m.hawksey", "gspreadr", "m.hawksey...
#> $ perm        (chr) "r", "r", "rw", "r", "r", "r", "rw", "rw", "r", "r...
#> $ version     (chr) "new", "new", "new", "new", "new", "new", "new", "...
#> $ updated     (time) 2015-05-31 22:00:25, 2015-05-31 21:12:24, 2015-05...
#> $ sheet_key   (chr) "1DoMXh2m3FGPoZAle9vnzg763D9FESTU506iqWkUTwtE", "1...
#> $ ws_feed     (chr) "https://spreadsheets.google.com/feeds/worksheets/...
#> $ alternate   (chr) "https://docs.google.com/spreadsheets/d/1DoMXh2m3F...
#> $ self        (chr) "https://spreadsheets.google.com/feeds/spreadsheet...
#> $ alt_key     (chr) NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA...
```

### Get a Google spreadsheet to practice with

Don't worry if you don't have any suitable Google Sheets lying around! We've published a sheet for you to practice with and have built functions into `googlesheets` to help you access it. The example sheet holds some of the [Gapminder data](https://github.com/jennybc/gapminder); feel free to [visit the Sheet in the browser](https://w3id.org/people/jennybc/googlesheets_gap_url). The code below will put a copy of this sheet into your Drive, titled "Gapminder".

``` r
gs_gap() %>% 
  gs_copy(to = "Gapminder")
```

If that seems to have worked, go check for a sheet named "Gapminder" in your Google Sheets home screen: <https://docs.google.com/spreadsheets/>. You could also run `gs_ls()` again and make sure the Gapminder sheet is listed.

### Register a spreadsheet

If you plan to consume data from a sheet or edit it, you must first **register** it. This is how `googlesheets` records important info about the sheet that is required downstream by the Google Sheets or Google Drive APIs. Once registered, you can print the result to get some basic info about the sheet.

`googlesheets` provides several registration functions. Specifying the sheet by title? Use `gs_title()`. By key? Use `gs_key()`. You get the idea.

*We're using the built-in functions `gs_gap_key()` and `gs_gap_url()` to produce the key and browser URL for the Gapminder example sheet, so you can see how this will play out with your own projects.*

``` r
gap <- gs_title("Gapminder")
#> Sheet successfully identifed: "Gapminder"
gap
#>                   Spreadsheet title: Gapminder
#>   Date of googlesheets registration: 2015-05-31 22:07:47 GMT
#>     Date of last spreadsheet update: 2015-03-23 20:34:08 GMT
#>                          visibility: private
#>                         permissions: rw
#>                             version: new
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
(GAP_KEY <- gs_gap_key())
#> [1] "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ"
third_party_gap <- GAP_KEY %>%
  gs_key()
#> Authentication will be used.
#> Sheet successfully identifed: "test-gs-gapminder"

# Need to access a sheet you do not own but you have a sharing link?
# Access it by URL!
(GAP_URL <- gs_gap_url())
#> [1] "https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/"
third_party_gap <- GAP_URL %>%
  gs_url()
#> Sheet-identifying info appears to be a browser URL.
#> googlesheets will attempt to extract sheet key from the URL.
#> Putative key: 1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ
#> Authentication will be used.
#> Sheet successfully identifed: "test-gs-gapminder"
# note: registration via URL may not work for "old" sheets

# Worried that a spreadsheet's registration is out-of-date?
# Re-register it!
gap <- gap %>% gs_gs()
#> Authentication will be used.
#> Sheet successfully identifed: "Gapminder"
gap
#>                   Spreadsheet title: Gapminder
#>   Date of googlesheets registration: 2015-05-31 22:07:51 GMT
#>     Date of last spreadsheet update: 2015-03-23 20:34:08 GMT
#>                          visibility: private
#>                         permissions: rw
#>                             version: new
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
```

The registration functions `gs_title()`, `gs_key()`, `gs_url()`, and `gs_gs()` return a registered sheet as a `googlesheet` object, which is the first argument to practically every function in this package. Likewise, almost every function returns a freshly registered `googlesheet` object, ready to be stored or piped into the next command.

### Consume data

#### Ignorance is bliss

*coming soon: a wrapper for the functions described below that just gets the data you want, while you remain blissfully ignorant of how we're doing it*

#### Specify the consumption method

There are three ways to consume data from a worksheet within a Google spreadsheet. The order goes from fastest-but-more-limited to slowest-but-most-flexible:

-   `gs_read_csv()`: Don't let the name scare you! Nothing is written to file during this process. The name just reflects that, under the hood, we request the data via the "exportcsv" link. For cases where `gs_read_csv()` and `gs_read_listfeed()` both work, we see that `gs_read_csv()` is around **50 times faster**. Use this when your data occupies a nice rectangle in the sheet and you're willing to consume all of it. You will get a `tbl_df` back, which is basically just a `data.frame`.
-   `gs_read_listfeed()`: Gets data via the ["list feed"](https://developers.google.com/google-apps/spreadsheets/#working_with_list-based_feeds), which consumes data row-by-row. Like `gs_read_csv()`, this is appropriate when your data occupies a nice rectangle. You will again get a `tbl_df` back, but your variable names may have been mangled (by Google, not us!). Specifically, variable names will be forcefully lowercased and all non-alpha-numeric characters will be removed. Why do we even have this function? The list feed supports some query parameters for sorting and filtering the data, which we plan to support (\#17).
-   `gs_read_cellfeed()`: Get data via the ["cell feed"](https://developers.google.com/google-apps/spreadsheets/#working_with_cell-based_feeds), which consumes data cell-by-cell. This is appropriate when you want to consume arbitrary cells, rows, columns, and regions of the sheet. It works great for small amounts of data but can be rather slow otherwise. `gs_read_cellfeed()` returns a `tbl_df` with **one row per cell**. You can specify cell limits in `gs_read_cellfeed()` via the `range` argument. See below for demos of `gs_reshape_cellfeed()` and `gs_simplify_cellfeed()` which help with post-processing.

``` r
# Get the data for worksheet "Oceania": the super-fast csv way
oceania_csv <- gap %>% gs_read_csv(ws = "Oceania")
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
oceania_list_feed <- gap %>% gs_read_listfeed(ws = "Oceania") 
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
oceania_cell_feed <- gap %>% gs_read_cellfeed(ws = "Oceania") 
#> Accessing worksheet titled "Oceania"
str(oceania_cell_feed)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    150 obs. of  5 variables:
#>  $ cell     : chr  "A1" "B1" "C1" "D1" ...
#>  $ cell_alt : chr  "R1C1" "R1C2" "R1C3" "R1C4" ...
#>  $ row      : int  1 1 1 1 1 1 2 2 2 2 ...
#>  $ col      : int  1 2 3 4 5 6 1 2 3 4 ...
#>  $ cell_text: chr  "country" "continent" "year" "lifeExp" ...
#>  - attr(*, "ws_title")= chr "Oceania"
oceania_cell_feed
#> Source: local data frame [150 x 5]
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
#> ..  ...      ... ... ...       ...
```

#### Convenience wrappers and post-processing the data

There are a few ways to limit the data you're consuming. You can put direct limits into `gs_read_cellfeed()`, ~~but there are also convenience functions to get a row (`get_row()`), a column (`get_col()`), or a range (`get_cells()`)~~. Also, when you consume data via the cell feed (which these wrappers are doing under the hood), you will often want to reshape it or simplify it (`gs_reshape_cellfeed()` and `gs_simplify_cellfeed()`).

``` r
# Reshape: instead of one row per cell, make a nice rectangular data.frame
oceania_reshaped <- oceania_cell_feed %>% gs_reshape_cellfeed()
str(oceania_reshaped)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    24 obs. of  6 variables:
#>  $ country  : chr  "Australia" "Australia" "Australia" "Australia" ...
#>  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
#>  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
#>  $ lifeExp  : num  69.1 70.3 70.9 71.1 71.9 ...
#>  $ pop      : int  8691212 9712569 10794968 11872264 13177000 14074100 15184200 16257249 17481977 18565243 ...
#>  $ gdpPercap: num  10040 10950 12217 14526 16789 ...
oceania_reshaped
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

# Limit data retrieval to certain cells

# Example: first 3 rows
gap_3rows <- gap %>% gs_read_cellfeed("Europe", range = cell_rows(1:3))
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
gap_3rows %>% gs_reshape_cellfeed()
#> Source: local data frame [2 x 6]
#> 
#>   country continent year lifeExp     pop gdpPercap
#> 1 Albania    Europe 1952   55.23 1282697  1601.056
#> 2 Albania    Europe 1957   59.28 1476505  1942.284

# Example: first row only
gap_1row <- gap %>% gs_read_cellfeed("Europe", range = cell_rows(1))
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
gap_1row %>% gs_simplify_cellfeed()
#>          A1          B1          C1          D1          E1          F1 
#>   "country" "continent"      "year"   "lifeExp"       "pop" "gdpPercap"

# just 2 columns, converted to data.frame
gap %>%
  gs_read_cellfeed("Oceania", range = cell_cols(3:4)) %>%
  gs_reshape_cellfeed()
#> Accessing worksheet titled "Oceania"
#> Source: local data frame [24 x 2]
#> 
#>    year lifeExp
#> 1  1952   69.12
#> 2  1957   70.33
#> 3  1962   70.93
#> 4  1967   71.10
#> 5  1972   71.93
#> 6  1977   73.49
#> 7  1982   74.74
#> 8  1987   76.32
#> 9  1992   77.56
#> 10 1997   78.83
#> ..  ...     ...

# arbitrary cell range
gap %>%
  gs_read_cellfeed("Oceania", range = "D12:F15") %>%
  gs_reshape_cellfeed(col_names = FALSE)
#> Accessing worksheet titled "Oceania"
#> Source: local data frame [4 x 3]
#> 
#>       X4       X5       X6
#> 1 80.370 19546792 30687.75
#> 2 81.235 20434176 34435.37
#> 3 69.390  1994794 10556.58
#> 4 70.260  2229407 12247.40

# arbitrary cell range, alternative specification
gap %>%
  gs_read_cellfeed("Oceania", range = cell_limits(c(NA, 5), c(1, 3))) %>%
  gs_reshape_cellfeed()
#> Accessing worksheet titled "Oceania"
#> Source: local data frame [4 x 3]
#> 
#>     country continent year
#> 1 Australia   Oceania 1952
#> 2 Australia   Oceania 1957
#> 3 Australia   Oceania 1962
#> 4 Australia   Oceania 1967
```

### Create sheets

You can use `googlesheets` to create new spreadsheets.

``` r
foo <- gs_new("foo")
#> Sheet "foo" created in Google Drive.
#> Worksheet dimensions: 1000 x 26.
foo
#>                   Spreadsheet title: foo
#>   Date of googlesheets registration: 2015-05-31 22:07:56 GMT
#>     Date of last spreadsheet update: 2015-05-31 22:07:55 GMT
#>                          visibility: private
#>                         permissions: rw
#>                             version: new
#> 
#> Contains 1 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> Sheet1: 1000 x 26
#> 
#> Key: 19J9GvlYsWABg3nEGAOpmemkpRFCoBQAggi5Ww2czLP4
```

By default, there will be an empty worksheet called "Sheet1", but you can control it's title, extent, and initial data with additional arguments to `gs_new()`. You can also add, rename, and delete worksheets within an existing sheet via `gs_ws_new()`, `gs_ws_rename()`, and `gs_ws_delete()`. Copy an entire spreadsheet with `gs_copy()`.

### Edit cells

You can modify the data in sheet cells via `gs_edit_cells()`. We'll work on the completely empty sheet created above, `foo`. If your edit populates the sheet with everything it should have, set `trim = TRUE` and we will resize the sheet to match the data. Then the nominal worksheet extent is much more informative (vs. the default of 1000 rows and 26 columns) and any future consumption via the cell feed will be much faster.

``` r
foo <- foo %>% gs_edit_cells(input = head(iris), trim = TRUE)
#> Range affected by the update: "A1:E7"
#> Worksheet "Sheet1" successfully updated with 35 new value(s).
#> Accessing worksheet titled "Sheet1"
#> Authentication will be used.
#> Sheet successfully identifed: "foo"
#> Accessing worksheet titled "Sheet1"
#> Worksheet "Sheet1" dimensions changed to 7 x 5.
```

Go to [your Google Sheets home screen](https://docs.google.com/spreadsheets/u/0/), find the new sheet `foo` and look at it. You should see some iris data in the first (and only) worksheet. We'll also take a look at it here, by consuming `foo` via the list feed.

Note how we always store the returned value from `gs_edit_cells()` (and all other sheet editing functions). That's because the registration info changes whenever we edit the sheet and we re-register it inside these functions, so this idiom will help you make sequential edits and queries to the same sheet.

``` r
foo %>% gs_read()
#> Accessing worksheet titled "Sheet1"
#> Source: local data frame [6 x 5]
#> 
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
#> 5          5.0         3.6          1.4         0.2  setosa
#> 6          5.4         3.9          1.7         0.4  setosa
```

Read the function documentation for `gs_edit_cells()` for how to specify where the data goes, via an anchor cell, and in which direction, via the shape of the input or the `byrow =` argument.

### Delete sheets

Let's clean up by deleting the `foo` spreadsheet we've been playing with.

``` r
gs_delete(foo)
#> Success. "foo" moved to trash in Google Drive.
```

If you'd rather specify sheets for deletion by title, look at `gs_grepdel()` and `gs_vecdel()`. These functions also allow the deletion of multiple sheets at once.

### Upload delimited files or Excel workbooks

Here's how we can create a new spreadsheet from a suitable local file. First, we'll write then upload a comma-delimited excerpt from the iris data.

``` r
iris %>% head(5) %>% write.csv("iris.csv", row.names = FALSE)
iris_ss <- gs_upload("iris.csv")
#> "iris.csv" uploaded to Google Drive and converted to a Google Sheet named "iris"
iris_ss
#>                   Spreadsheet title: iris
#>   Date of googlesheets registration: 2015-05-31 22:08:08 GMT
#>     Date of last spreadsheet update: 2015-05-31 22:08:06 GMT
#>                          visibility: private
#>                         permissions: rw
#>                             version: new
#> 
#> Contains 1 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> iris: 6 x 5
#> 
#> Key: 1JBhoVYK4CjvHvwrWl4N0nr03i6CQ7BBiTUHS6A31u50
iris_ss %>% gs_read_listfeed()
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
gap_xlsx <- gs_upload(system.file("mini-gap.xlsx", package = "googlesheets"))
#> "mini-gap.xlsx" uploaded to Google Drive and converted to a Google Sheet named "mini-gap"
gap_xlsx
#>                   Spreadsheet title: mini-gap
#>   Date of googlesheets registration: 2015-05-31 22:08:13 GMT
#>     Date of last spreadsheet update: 2015-05-31 22:08:11 GMT
#>                          visibility: private
#>                         permissions: rw
#>                             version: new
#> 
#> Contains 5 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> Africa: 1000 x 26
#> Americas: 1000 x 26
#> Asia: 1000 x 26
#> Europe: 1000 x 26
#> Oceania: 1000 x 26
#> 
#> Key: 1AJakJVpaoEkuuwaO4Tm3IJbGAMxaHOr2U5r3jH2uyrY
gap_xlsx %>% gs_read_listfeed(ws = "Oceania")
#> Accessing worksheet titled "Oceania"
#> Source: local data frame [5 x 6]
#> 
#>       country continent year lifeexp      pop gdppercap
#> 1   Australia   Oceania 1952   69.12  8691212  10039.60
#> 2 New Zealand   Oceania 1952   69.39  1994794  10556.58
#> 3   Australia   Oceania 1957   70.33  9712569  10949.65
#> 4 New Zealand   Oceania 1957   70.26  2229407  12247.40
#> 5   Australia   Oceania 1962   70.93 10794968  12217.23
```

And we clean up after ourselves on Google Drive.

``` r
gs_delete(iris_ss)
#> Success. "iris" moved to trash in Google Drive.
gs_delete(gap_xlsx)
#> Success. "mini-gap" moved to trash in Google Drive.
```

### Download sheets as csv, pdf, or xlsx file

You can download a Google Sheet as a csv, pdf, or xlsx file. Downloading the spreadsheet as a csv file will export the first worksheet (default) unless another worksheet is specified.

``` r
gs_title("Gapminder") %>%
  gs_download(ws = "Africa", to = "~/tmp/gapminder-africa.csv")
#> Sheet successfully identifed: "Gapminder"
#> Accessing worksheet titled "Africa"
#> Sheet successfully downloaded: /Users/jenny/tmp/gapminder-africa.csv
## is it there? yes!
read.csv("~/tmp/gapminder-africa.csv") %>% head()
#>   country continent year lifeExp      pop gdpPercap
#> 1 Algeria    Africa 1952  43.077  9279525  2449.008
#> 2 Algeria    Africa 1957  45.685 10270856  3013.976
#> 3 Algeria    Africa 1962  48.303 11000948  2550.817
#> 4 Algeria    Africa 1967  51.407 12760499  3246.992
#> 5 Algeria    Africa 1972  54.518 14760787  4182.664
#> 6 Algeria    Africa 1977  58.014 17152804  4910.417
```

Download the entire spreadsheet as an Excel workbook.

``` r
gs_title("Gapminder") %>% 
  gs_download(to = "~/tmp/gapminder.xlsx")
#> Sheet successfully identifed: "Gapminder"
#> Sheet successfully downloaded: /Users/jenny/tmp/gapminder.xlsx
```

Go check it out in Excel, if you wish!

And now we clean up the downloaded files.

``` r
file.remove(file.path("~/tmp", c("gapminder.xlsx", "gapminder-africa.csv")))
#> [1] TRUE TRUE
```

### Authorization using OAuth2

If you use a function that requires authentication, it will be auto-triggered. But you can also initiate the process explicitly if you wish, like so:

``` r
# Give googlesheets permission to access your spreadsheets and google drive
gs_auth() 
```

Use `gs_auth(new_user = TRUE)`, to force the process to begin anew. Otherwise, the credentials left behind will be used to refresh your access token as needed.

The function `gs_user()` will print and return some information about the current authenticated user and session.

``` r
user_session_info <- gs_user()
#>                        displayName: google sheets
#>                       emailAddress: gspreadr@gmail.com
#> Date-time of session authorization: 2015-05-31 22:07:45
#>   Date-time of access token expiry: 2015-05-31 15:11:01
#> Access token is valid.
user_session_info
#> $displayName
#> [1] "google sheets"
#> 
#> $emailAddress
#> [1] "gspreadr@gmail.com"
#> 
#> $auth_date
#> [1] "2015-05-31 22:07:45 GMT"
#> 
#> $exp_date
#> [1] "2015-05-31 15:11:01 PDT"
```

### "Old" Google Sheets

In March 2014 [Google introduced "new" Sheets](https://support.google.com/docs/answer/3541068?hl=en). "New" Sheets and "old" sheets behave quite differently with respect to access via API and present a big headache for us. Recently, we've noted that Google is forcibly converting sheets: [all "old" Sheets will be switched over the "new" sheets during 2015](https://support.google.com/docs/answer/6082736?p=new_sheets_migrate&rd=1). However there are still "old" sheets lying around, so we've made some effort to support them, when it's easy to do so. But keep your expectations low.

In particular, `gs_read_csv()` does not and indeed **cannot** work for "old" sheets.
