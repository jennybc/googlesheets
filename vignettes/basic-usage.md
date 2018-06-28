---
title: "googlesheets Basic Usage"
author: "Jenny Bryan, Joanna Zhao"
date: "2018-06-28"
output:
  rmarkdown::html_vignette:
    toc: true
    toc_depth: 4
    keep_md: true
vignette: >
  %\VignetteIndexEntry{googlesheets Basic Usage}
  %\VignetteEngine{knitr::rmarkdown}
  \usepackage[utf8]{inputenc}
---



First we load the `googlesheets` package and `dplyr`, from which we use the `%>%` pipe operator, among other things. `googlesheets` usage *does not require* you to use `%>%` though it was certainly designed to be pipe-friendly. This vignette uses pipes but you will find that all the examples in the help files use base R only.


```r
library(googlesheets)
suppressMessages(library(dplyr))
```





### Function naming convention

To play nicely with tab completion, we use consistent prefixes:

  * `gs_` = all functions in the package.
  * `gs_ws_` = all functions that operate on worksheets or tabs within a spreadsheet.
  * `gd_` = something to do with Google Drive, usually has a `gs_` synonym, might one day migrate to a Drive client.

### List your Google Sheets

The `gs_ls()` function returns a data frame of the sheets you would see in your Google Sheets home screen: <https://docs.google.com/spreadsheets/>. This should include sheets that you own and may also show sheets owned by others but that you are permitted to access, if you have visited the sheet in the browser. Expect a prompt to authenticate yourself in the browser at this point (more below re: auth).


```r
(my_sheets <- gs_ls())
#> # A tibble: 79 x 10
#>    sheet_title  author perm  version updated             sheet_key ws_feed
#>    <chr>        <chr>  <chr> <chr>   <dttm>              <chr>     <chr>  
#>  1 "          … "    … rw    new     2018-06-28 20:28:34 1vz6eeNH… https:…
#>  2 " EasyTweet… "    … r     new     2018-06-28 16:56:08 14mAbIi1… https:…
#>  3 "          … "    … r     new     2018-06-26 03:28:10 1WH65aJj… https:…
#>  4 Individual-… "    … r     new     2018-04-01 21:02:02 1nIwCydo… https:…
#>  5 "   Caffein… david… r     new     2018-03-30 10:07:36 1KYMUjrC… https:…
#>  6 "          … "    … r     new     2017-11-12 14:20:34 1oBQNnsM… https:…
#>  7 Tweet Colle… "    … rw    new     2017-11-10 22:58:38 1t-YMfnQ… https:…
#>  8 dsscollecti… jenny… r     new     2017-08-31 16:29:51 1Y6kLMkL… https:…
#>  9 Copy of Twi… "  jo… r     new     2017-08-23 18:25:37 1DoMXh2m… https:…
#> 10 STAT545 - 2… "    … rw    new     2017-07-27 17:34:46 1Hv31yW-… https:…
#> # ... with 69 more rows, and 3 more variables: alternate <chr>,
#> #   self <chr>, alt_key <chr>
# (expect a prompt to authenticate with Google interactively HERE)
my_sheets %>% glimpse()
#> Observations: 79
#> Variables: 10
#> $ sheet_title <chr> "Gapminder", "EasyTweetSheet - Shared", "gas_milea...
#> $ author      <chr> "gspreadr", "m.hawksey", "woo.kara", "the.dfx", "d...
#> $ perm        <chr> "rw", "r", "r", "r", "r", "r", "rw", "r", "r", "rw...
#> $ version     <chr> "new", "new", "new", "new", "new", "new", "new", "...
#> $ updated     <dttm> 2018-06-28 20:28:34, 2018-06-28 16:56:08, 2018-06...
#> $ sheet_key   <chr> "1vz6eeNH_rutBS2z6QtMq_rffRpqq3R_8Qevw7-vETC0", "1...
#> $ ws_feed     <chr> "https://spreadsheets.google.com/feeds/worksheets/...
#> $ alternate   <chr> "https://docs.google.com/spreadsheets/d/1vz6eeNH_r...
#> $ self        <chr> "https://spreadsheets.google.com/feeds/spreadsheet...
#> $ alt_key     <chr> NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA...
```

### Get a Google Sheet to practice with

Don't worry if you don't have any suitable Google Sheets lying around! We've published a sheet for you to practice with and have built functions into `googlesheets` to help you access it. The example sheet holds some of the [Gapminder data](https://github.com/jennybc/gapminder); feel free to [visit the Sheet in the browser](https://w3id.org/people/jennybc/googlesheets_gap_url). The code below will put a copy of this sheet into your Drive, titled "Gapminder".


```r
gs_gap() %>% 
  gs_copy(to = "Gapminder")
```

If that seems to have worked, go check for a sheet named "Gapminder" in your Google Sheets home screen: <https://docs.google.com/spreadsheets/>.

You can also call `gs_ls()` again to see if the Gapminder sheet appears. Give it a regular expression to narrow the listing down, if you like::


```r
gs_ls("Gapminder")
#> # A tibble: 1 x 10
#>   sheet_title author  perm  version updated             sheet_key ws_feed 
#>   <chr>       <chr>   <chr> <chr>   <dttm>              <chr>     <chr>   
#> 1 Gapminder   gsprea… rw    new     2018-06-28 20:28:34 1vz6eeNH… https:/…
#> # ... with 3 more variables: alternate <chr>, self <chr>, alt_key <chr>
```

### Register a Sheet

If you plan to consume data from a sheet or edit it, you must first __register__ it. This is how `googlesheets` records important info about the sheet that is required downstream by the Google Sheets or Google Drive APIs. Once registered, you can print the result to get some basic info about the sheet.

`googlesheets` provides several registration functions. Specifying the sheet by title? Use `gs_title()`. By key? Use `gs_key()`. You get the idea.

*We're using the built-in functions `gs_gap_key()` and `gs_gap_url()` to produce the key and browser URL for the Gapminder example sheet, so you can see how this will play out with your own projects.*


```r
gap <- gs_title("Gapminder")
#> Sheet successfully identified: "Gapminder"
gap
#>                   Spreadsheet title: Gapminder
#>                  Spreadsheet author: gspreadr
#>   Date of googlesheets registration: 2018-06-28 23:14:41 GMT
#>     Date of last spreadsheet update: 2018-06-28 20:28:33 GMT
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
#> Key: 1vz6eeNH_rutBS2z6QtMq_rffRpqq3R_8Qevw7-vETC0
#> Browser URL: https://docs.google.com/spreadsheets/d/1vz6eeNH_rutBS2z6QtMq_rffRpqq3R_8Qevw7-vETC0/

# Need to access a sheet you do not own?
# Access it by key if you know it!
(GAP_KEY <- gs_gap_key())
#> [1] "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ"
third_party_gap <- GAP_KEY %>%
  gs_key()
#> Sheet successfully identified: "test-gs-gapminder"

# Need to access a sheet you do not own but you have a sharing link?
# Access it by URL!
(GAP_URL <- gs_gap_url())
#> [1] "https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/"
third_party_gap <- GAP_URL %>%
  gs_url()
#> Sheet-identifying info appears to be a browser URL.
#> googlesheets will attempt to extract sheet key from the URL.
#> Putative key: 1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ
#> Sheet successfully identified: "test-gs-gapminder"

# Want to dig the key out of a URL?
# registration by key is the safest, long-run strategy
extract_key_from_url(GAP_URL)
#> [1] "1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ"

# Worried that a spreadsheet's registration is out-of-date?
# Re-register it!
gap <- gap %>% gs_gs()
#> Sheet successfully identified: "Gapminder"
```



The registration functions `gs_title()`, `gs_key()`, `gs_url()`, and `gs_gs()` return a registered sheet as a `googlesheet` object, which is the first argument to practically every function in this package. Likewise, almost every function returns a freshly registered `googlesheet` object, ready to be stored or piped into the next command.

The utility function, `extract_key_from_url()`, helps you dig the key out of a browser URL. Registering via browser URL is fine, but registering by key is a better idea in the long-run.

Use `gs_browse()` to visit the Sheet corresponding to a registered `googlesheet`
in your browser. Optionally, you can specify the worksheet of interest.


```r
gap %>% gs_browse()
gap %>% gs_browse(ws = 2)
gap %>% gs_browse(ws = "Europe")
```



### Inspect a Sheet

Once you've registered a Sheet, print it to get an overview of, e.g., its worksheets, their names, and dimensions. Use `gs_ws_ls()` to get worksheet names as a character vector.


```r
gap
#>                   Spreadsheet title: test-gs-gapminder
#>                  Spreadsheet author: rpackagetest
#>   Date of googlesheets registration: 2018-06-28 23:14:47 GMT
#>     Date of last spreadsheet update: 2015-04-22 18:27:11 GMT
#>                          visibility: public
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
#> Key: 1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ
#> Browser URL: https://docs.google.com/spreadsheets/d/1BzfL0kZUz1TsI5zxJF1WNF01IxvC67FbOJUiiGMZ_mQ/
gs_ws_ls(gap)
#> [1] "Africa"   "Americas" "Asia"     "Europe"   "Oceania"
```

### Read all the data in one worksheet

`gs_read()` returns the contents of a worksheet as a data frame.


```r
oceania <- gap %>%
  gs_read(ws = "Oceania")
#> Accessing worksheet titled 'Oceania'.
#> Parsed with column specification:
#> cols(
#>   country = col_character(),
#>   continent = col_character(),
#>   year = col_double(),
#>   lifeExp = col_double(),
#>   pop = col_double(),
#>   gdpPercap = col_double()
#> )
oceania
#> # A tibble: 24 x 6
#>    country   continent  year lifeExp      pop gdpPercap
#>    <chr>     <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#>  1 Australia Oceania    1952    69.1  8691212    10040.
#>  2 Australia Oceania    1957    70.3  9712569    10950.
#>  3 Australia Oceania    1962    70.9 10794968    12217.
#>  4 Australia Oceania    1967    71.1 11872264    14526.
#>  5 Australia Oceania    1972    71.9 13177000    16789.
#>  6 Australia Oceania    1977    73.5 14074100    18334.
#>  7 Australia Oceania    1982    74.7 15184200    19477.
#>  8 Australia Oceania    1987    76.3 16257249    21889.
#>  9 Australia Oceania    1992    77.6 17481977    23425.
#> 10 Australia Oceania    1997    78.8 18565243    26998.
#> # ... with 14 more rows
str(oceania)
#> Classes 'tbl_df', 'tbl' and 'data.frame':	24 obs. of  6 variables:
#>  $ country  : chr  "Australia" "Australia" "Australia" "Australia" ...
#>  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
#>  $ year     : num  1952 1957 1962 1967 1972 ...
#>  $ lifeExp  : num  69.1 70.3 70.9 71.1 71.9 ...
#>  $ pop      : num  8691212 9712569 10794968 11872264 13177000 ...
#>  $ gdpPercap: num  10040 10950 12217 14526 16789 ...
#>  - attr(*, "spec")=
#>   .. cols(
#>   ..   country = col_character(),
#>   ..   continent = col_character(),
#>   ..   year = col_double(),
#>   ..   lifeExp = col_double(),
#>   ..   pop = col_double(),
#>   ..   gdpPercap = col_double()
#>   .. )
glimpse(oceania)
#> Observations: 24
#> Variables: 6
#> $ country   <chr> "Australia", "Australia", "Australia", "Australia", ...
#> $ continent <chr> "Oceania", "Oceania", "Oceania", "Oceania", "Oceania...
#> $ year      <dbl> 1952, 1957, 1962, 1967, 1972, 1977, 1982, 1987, 1992...
#> $ lifeExp   <dbl> 69.120, 70.330, 70.930, 71.100, 71.930, 73.490, 74.7...
#> $ pop       <dbl> 8691212, 9712569, 10794968, 11872264, 13177000, 1407...
#> $ gdpPercap <dbl> 10039.60, 10949.65, 12217.23, 14526.12, 16788.63, 18...
```

### Read only certain cells

You can target specific cells via the `range =` argument. The simplest usage is to specify an Excel-like cell range, such as range = "D12:F15" or range = "R1C12:R6C15". The cell rectangle can be specified in various other ways, using helper functions. It can be degenerate, i.e. open-ended.


```r
gap %>% gs_read(ws = 2, range = "A1:D8")
#> Accessing worksheet titled 'Americas'.
#> Parsed with column specification:
#> cols(
#>   country = col_character(),
#>   continent = col_character(),
#>   year = col_double(),
#>   lifeExp = col_double()
#> )
#> # A tibble: 7 x 4
#>   country   continent  year lifeExp
#>   <chr>     <chr>     <dbl>   <dbl>
#> 1 Argentina Americas   1952    62.5
#> 2 Argentina Americas   1957    64.4
#> 3 Argentina Americas   1962    65.1
#> 4 Argentina Americas   1967    65.6
#> 5 Argentina Americas   1972    67.1
#> 6 Argentina Americas   1977    68.5
#> 7 Argentina Americas   1982    69.9
gap %>% gs_read(ws = "Europe", range = cell_rows(1:4))
#> Accessing worksheet titled 'Europe'.
#> Parsed with column specification:
#> cols(
#>   country = col_character(),
#>   continent = col_character(),
#>   year = col_double(),
#>   lifeExp = col_double(),
#>   pop = col_double(),
#>   gdpPercap = col_double()
#> )
#> # A tibble: 3 x 6
#>   country continent  year lifeExp     pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>   <dbl>     <dbl>
#> 1 Albania Europe     1952    55.2 1282697     1601.
#> 2 Albania Europe     1957    59.3 1476505     1942.
#> 3 Albania Europe     1962    64.8 1728137     2313.
gap %>% gs_read(ws = "Europe", range = cell_rows(100:103), col_names = FALSE)
#> Accessing worksheet titled 'Europe'.
#> Parsed with column specification:
#> cols(
#>   X1 = col_character(),
#>   X2 = col_character(),
#>   X3 = col_double(),
#>   X4 = col_double(),
#>   X5 = col_double(),
#>   X6 = col_double()
#> )
#> # A tibble: 4 x 6
#>   X1      X2        X3    X4      X5     X6
#>   <chr>   <chr>  <dbl> <dbl>   <dbl>  <dbl>
#> 1 Finland Europe  1962  68.8 4491443  9372.
#> 2 Finland Europe  1967  69.8 4605744 10922.
#> 3 Finland Europe  1972  70.9 4639657 14359.
#> 4 Finland Europe  1977  72.5 4738902 15605.
gap %>% gs_read(ws = "Africa", range = cell_cols(1:4))
#> Accessing worksheet titled 'Africa'.
#> Parsed with column specification:
#> cols(
#>   country = col_character(),
#>   continent = col_character(),
#>   year = col_double(),
#>   lifeExp = col_double()
#> )
#> # A tibble: 624 x 4
#>    country continent  year lifeExp
#>    <chr>   <chr>     <dbl>   <dbl>
#>  1 Algeria Africa     1952    43.1
#>  2 Algeria Africa     1957    45.7
#>  3 Algeria Africa     1962    48.3
#>  4 Algeria Africa     1967    51.4
#>  5 Algeria Africa     1972    54.5
#>  6 Algeria Africa     1977    58.0
#>  7 Algeria Africa     1982    61.4
#>  8 Algeria Africa     1987    65.8
#>  9 Algeria Africa     1992    67.7
#> 10 Algeria Africa     1997    69.2
#> # ... with 614 more rows
gap %>% gs_read(ws = "Asia", range = cell_limits(c(1, 4), c(5, NA)))
#> Accessing worksheet titled 'Asia'.
#> Parsed with column specification:
#> cols(
#>   lifeExp = col_double(),
#>   pop = col_double(),
#>   gdpPercap = col_double()
#> )
#> # A tibble: 4 x 3
#>   lifeExp      pop gdpPercap
#>     <dbl>    <dbl>     <dbl>
#> 1    28.8  8425333      779.
#> 2    30.3  9240934      821.
#> 3    32.0 10267083      853.
#> 4    34.0 11537966      836.
```

Do you need more control?

  * `googlesheets` aims to match the interface of the [`readr` package](https://cran.r-project.org/package=readr). See more below on how to pass more arguments via `...` to control `readr`-style data ingest.
  * `gs_read()` is a wrapper that bundles together the most common methods to read data from the API and transform it for downstream use. Later sections discuss the underlying functions, in case you need to call them yourself.

### Create a new Google Sheet

Here we use `gs_new()` to create a new Sheet *de novo* and populate it with a bit of the iris data:


```r
boring_ss <- gs_new("boring", ws_title = "iris-gs_new", input = head(iris),
                    trim = TRUE, verbose = FALSE)
boring_ss %>% 
  gs_read()
#> Accessing worksheet titled 'iris-gs_new'.
#> Parsed with column specification:
#> cols(
#>   Sepal.Length = col_double(),
#>   Sepal.Width = col_double(),
#>   Petal.Length = col_double(),
#>   Petal.Width = col_double(),
#>   Species = col_character()
#> )
#> # A tibble: 6 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <chr>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          4.9         3            1.4         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa 
#> 4          4.6         3.1          1.5         0.2 setosa 
#> 5          5           3.6          1.4         0.2 setosa 
#> 6          5.4         3.9          1.7         0.4 setosa
```

Note how we store the returned value from `gs_new()` (and all other sheet editing functions). That's because the registration info changes whenever we edit the sheet and we re-register it inside these functions, so this idiom will help you make sequential edits and queries to the same sheet.

You can copy an entire Sheet with `gs_copy()` and rename one with `gs_rename()`.

### Add a new worksheet to an existing Google Sheet

Use `gs_ws_new()` to add some mtcars data as a second worksheet to `boring_ss`.


```r
boring_ss <- boring_ss %>% 
  gs_ws_new(ws_title = "mtcars-gs_ws_new", input = head(mtcars),
                    trim = TRUE, verbose = FALSE)
boring_ss %>% 
  gs_read(ws = 2)
#> Accessing worksheet titled 'mtcars-gs_ws_new'.
#> Parsed with column specification:
#> cols(
#>   mpg = col_double(),
#>   cyl = col_double(),
#>   disp = col_double(),
#>   hp = col_double(),
#>   drat = col_double(),
#>   wt = col_double(),
#>   qsec = col_double(),
#>   vs = col_double(),
#>   am = col_double(),
#>   gear = col_double(),
#>   carb = col_double()
#> )
#> # A tibble: 6 x 11
#>     mpg   cyl  disp    hp  drat    wt  qsec    vs    am  gear  carb
#>   <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl> <dbl>
#> 1  21       6   160   110  3.9   2.62  16.5     0     1     4     4
#> 2  21       6   160   110  3.9   2.88  17.0     0     1     4     4
#> 3  22.8     4   108    93  3.85  2.32  18.6     1     1     4     1
#> 4  21.4     6   258   110  3.08  3.22  19.4     1     0     3     1
#> 5  18.7     8   360   175  3.15  3.44  17.0     0     0     3     2
#> 6  18.1     6   225   105  2.76  3.46  20.2     1     0     3     1
```

### Rename or delete worksheets

We use `gs_ws_delete()` and `gs_ws_rename()` to delete the mtcars worksheet and rename the iris worksheets, respectively:


```r
boring_ss <- boring_ss %>% 
  gs_ws_delete(ws = 2) %>% 
  gs_ws_rename(to = "iris")
#> Accessing worksheet titled 'mtcars-gs_ws_new'.
#> Worksheet "mtcars-gs_ws_new" deleted from sheet "boring".
#> Accessing worksheet titled 'iris-gs_new'.
#> Sheet successfully identified: "boring"
#> Worksheet "iris-gs_new" renamed to "iris".
boring_ss
#>                   Spreadsheet title: boring
#>                  Spreadsheet author: gspreadr
#>   Date of googlesheets registration: 2018-06-28 23:15:34 GMT
#>     Date of last spreadsheet update: 2018-06-28 23:15:33 GMT
#>                          visibility: private
#>                         permissions: rw
#>                             version: new
#> 
#> Contains 1 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> iris: 7 x 5
#> 
#> Key: 1lYNu6vqhYZR-6HU7jM8l7BHQIqZ4kAOQdowpBx6orYc
#> Browser URL: https://docs.google.com/spreadsheets/d/1lYNu6vqhYZR-6HU7jM8l7BHQIqZ4kAOQdowpBx6orYc/
```

### Edit cells

There are two ways to edit cells within an existing worksheet of an existing spreadsheet:

  * `gs_edit_cells()` can write into an arbitrary cell rectangle
  * `gs_add_row()` can add a new row to the bottom of an existing cell rectangle
  
They are both slow and you're better off using `gs_upload()` if you creating a new Sheet is compatible with your workflow.

Of the two, `gs_add_row()` is faster, but it can only be used when your data occupies a very neat rectangle in the upper left corner of the sheet. It relies on the [list feed](https://developers.google.com/google-apps/spreadsheets/#working_with_list-based_feeds). `gs_edit_cells()` relies on [batch editing](https://developers.google.com/google-apps/spreadsheets/#updating_multiple_cells_with_a_batch_request) on the [cell feed](https://developers.google.com/google-apps/spreadsheets/#working_with_cell-based_feeds).

We create a new Sheet, `foo`, and set up some well-named empty worksheets to practice with.


```r
foo <- gs_new("foo") %>% 
  gs_ws_rename(from = "Sheet1", to = "edit_cells") %>% 
  gs_ws_new("add_row")
#> Sheet "foo" created in Google Drive.
#> Worksheet dimensions: 1000 x 26.
#> Accessing worksheet titled 'Sheet1'.
#> Sheet successfully identified: "foo"
#> Worksheet "Sheet1" renamed to "edit_cells".
#> Worksheet "add_row" added to sheet "foo".
#> Worksheet dimensions: 1000 x 26.
foo
#>                   Spreadsheet title: foo
#>                  Spreadsheet author: gspreadr
#>   Date of googlesheets registration: 2018-06-28 23:15:43 GMT
#>     Date of last spreadsheet update: 2018-06-28 23:15:42 GMT
#>                          visibility: private
#>                         permissions: rw
#>                             version: new
#> 
#> Contains 2 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> edit_cells: 1000 x 26
#> add_row: 1000 x 26
#> 
#> Key: 1JIaesRG3wgc1HDGb_wEKGCVmymGo4mxjOOZ_tlTee64
#> Browser URL: https://docs.google.com/spreadsheets/d/1JIaesRG3wgc1HDGb_wEKGCVmymGo4mxjOOZ_tlTee64/

## add first six rows of iris data (and var names) into a blank sheet
foo <- foo %>%
  gs_edit_cells(ws = "edit_cells", input = head(iris), trim = TRUE)
#> Range affected by the update: "R1C1:R7C5"
#> Worksheet "edit_cells" successfully updated with 35 new value(s).
#> Accessing worksheet titled 'edit_cells'.
#> Sheet successfully identified: "foo"
#> Accessing worksheet titled 'edit_cells'.
#> Worksheet "edit_cells" dimensions changed to 7 x 5.

## initialize sheet with column headers and one row of data
## the list feed is picky about this
foo <- foo %>% 
  gs_edit_cells(ws = "add_row", input = head(iris, 1), trim = TRUE)
#> Range affected by the update: "R1C1:R2C5"
#> Worksheet "add_row" successfully updated with 10 new value(s).
#> Accessing worksheet titled 'add_row'.
#> Sheet successfully identified: "foo"
#> Accessing worksheet titled 'add_row'.
#> Worksheet "add_row" dimensions changed to 2 x 5.
## add the next 5 rows of data ... careful not to go too fast
for (i in 2:6) {
  foo <- foo %>% gs_add_row(ws = "add_row", input = iris[i, ])
  Sys.sleep(0.3)
}
#> Row successfully appended.
#> Row successfully appended.
#> Row successfully appended.
#> Row successfully appended.
#> Row successfully appended.

## gs_add_row() will actually handle multiple rows at once
foo <- foo %>% 
  gs_add_row(ws = "add_row", input = tail(iris))
#> Row successfully appended.
#> Row successfully appended.
#> Row successfully appended.
#> Row successfully appended.
#> Row successfully appended.
#> Row successfully appended.

## let's inspect our work
foo %>% gs_read(ws = "edit_cells")
#> Accessing worksheet titled 'edit_cells'.
#> Parsed with column specification:
#> cols(
#>   Sepal.Length = col_double(),
#>   Sepal.Width = col_double(),
#>   Petal.Length = col_double(),
#>   Petal.Width = col_double(),
#>   Species = col_character()
#> )
#> # A tibble: 6 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <chr>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          4.9         3            1.4         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa 
#> 4          4.6         3.1          1.5         0.2 setosa 
#> 5          5           3.6          1.4         0.2 setosa 
#> 6          5.4         3.9          1.7         0.4 setosa
foo %>% gs_read(ws = "add_row")
#> Accessing worksheet titled 'add_row'.
#> Parsed with column specification:
#> cols(
#>   Sepal.Length = col_double(),
#>   Sepal.Width = col_double(),
#>   Petal.Length = col_double(),
#>   Petal.Width = col_double(),
#>   Species = col_character()
#> )
#> # A tibble: 12 x 5
#>    Sepal.Length Sepal.Width Petal.Length Petal.Width Species  
#>           <dbl>       <dbl>        <dbl>       <dbl> <chr>    
#>  1          5.1         3.5          1.4         0.2 setosa   
#>  2          4.9         3            1.4         0.2 setosa   
#>  3          4.7         3.2          1.3         0.2 setosa   
#>  4          4.6         3.1          1.5         0.2 setosa   
#>  5          5           3.6          1.4         0.2 setosa   
#>  6          5.4         3.9          1.7         0.4 setosa   
#>  7          6.7         3.3          5.7         2.5 virginica
#>  8          6.7         3            5.2         2.3 virginica
#>  9          6.3         2.5          5           1.9 virginica
#> 10          6.5         3            5.2         2   virginica
#> 11          6.2         3.4          5.4         2.3 virginica
#> 12          5.9         3            5.1         1.8 virginica
```

Go to [your Google Sheets home screen](https://docs.google.com/spreadsheets/u/0/), find the new sheet `foo` and admire it. You should see some iris data in the worksheets named `edit_cells` and `add_row`. You could also use `gs_browse()` to take you directly to those worksheets.


```r
gs_browse(foo, ws = "edit_cells")
gs_browse(foo, ws = "add_row")
```

Do you need more control?

 * Read the function documentation for `gs_edit_cells()` for how to specify where the data goes, via an anchor cell, and in which direction, via the shape of the input or the `byrow =` argument.
 
Protip: If your edit populates the sheet with everything it should have, set `trim = TRUE` and we will resize the sheet to match the data. Then the nominal worksheet extent is much more informative (vs. the default of 1000 rows and 26 columns) and future consumption via the cell feed will potentially be faster.

### Delete Sheets

Use `gs_delete()` and friends to delete entire Sheets. Let's clean up by deleting the `foo` spreadsheet.


```r
gs_delete(foo)
#> Success. "foo" moved to trash in Google Drive.
```

If you'd rather specify sheets for deletion by title, look at `gs_grepdel()` and `gs_vecdel()`. These functions also allow the deletion of multiple sheets at once.

### Make new Sheets from local delimited files or Excel workbooks

Use `gs_upload()` to create a new Sheet *de novo* from a suitable local file. First, we'll write then upload a comma-delimited excerpt from the iris data.


```r
iris %>%
  head(5) %>%
  write.csv("iris.csv", row.names = FALSE)
iris_ss <- gs_upload("iris.csv")
#> File uploaded to Google Drive:
#> iris.csv
#> As the Google Sheet named:
#> iris
iris_ss
#>                   Spreadsheet title: iris
#>                  Spreadsheet author: gspreadr
#>   Date of googlesheets registration: 2018-06-28 23:16:25 GMT
#>     Date of last spreadsheet update: 2018-06-28 23:16:23 GMT
#>                          visibility: private
#>                         permissions: rw
#>                             version: new
#> 
#> Contains 1 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> iris: 1000 x 26
#> 
#> Key: 1Q_jU7tvkjaSPwHHWPFPQsSfOp5G4FpQ6Fkrp5wUWq0Q
#> Browser URL: https://docs.google.com/spreadsheets/d/1Q_jU7tvkjaSPwHHWPFPQsSfOp5G4FpQ6Fkrp5wUWq0Q/
iris_ss %>% gs_read()
#> Accessing worksheet titled 'iris'.
#> Parsed with column specification:
#> cols(
#>   Sepal.Length = col_double(),
#>   Sepal.Width = col_double(),
#>   Petal.Length = col_double(),
#>   Petal.Width = col_double(),
#>   Species = col_character()
#> )
#> # A tibble: 5 x 5
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <dbl>       <dbl>        <dbl>       <dbl> <chr>  
#> 1          5.1         3.5          1.4         0.2 setosa 
#> 2          4.9         3            1.4         0.2 setosa 
#> 3          4.7         3.2          1.3         0.2 setosa 
#> 4          4.6         3.1          1.5         0.2 setosa 
#> 5          5           3.6          1.4         0.2 setosa
file.remove("iris.csv")
#> [1] TRUE
```

Now we'll upload a multi-sheet Excel workbook. Slowly.


```r
gap_xlsx <- gs_upload(system.file("mini-gap", "mini-gap.xlsx",
                                  package = "googlesheets"))
#> File uploaded to Google Drive:
#> /Users/jenny/resources/R/library/googlesheets/mini-gap/mini-gap.xlsx
#> As the Google Sheet named:
#> mini-gap
gap_xlsx
#>                   Spreadsheet title: mini-gap
#>                  Spreadsheet author: gspreadr
#>   Date of googlesheets registration: 2018-06-28 23:16:31 GMT
#>     Date of last spreadsheet update: 2018-06-28 23:16:28 GMT
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
#> Key: 1SNLYFKy_-VpFY3jNwrcqNSODAzBzl48QPIOu59nGDa4
#> Browser URL: https://docs.google.com/spreadsheets/d/1SNLYFKy_-VpFY3jNwrcqNSODAzBzl48QPIOu59nGDa4/
gap_xlsx %>% gs_read(ws = "Asia")
#> Accessing worksheet titled 'Asia'.
#> Parsed with column specification:
#> cols(
#>   country = col_character(),
#>   continent = col_character(),
#>   year = col_double(),
#>   lifeExp = col_double(),
#>   pop = col_double(),
#>   gdpPercap = col_double()
#> )
#> # A tibble: 5 x 6
#>   country     continent  year lifeExp       pop gdpPercap
#>   <chr>       <chr>     <dbl>   <dbl>     <dbl>     <dbl>
#> 1 Afghanistan Asia       1952    28.8   8425333      779.
#> 2 Bahrain     Asia       1952    50.9    120447     9867.
#> 3 Bangladesh  Asia       1952    37.5  46886859      684.
#> 4 Cambodia    Asia       1952    39.4   4693836      368.
#> 5 China       Asia       1952    44   556263527      400.
```

And we clean up after ourselves on Google Drive.


```r
gs_vecdel(c("iris", "mini-gap"))
#> Sheet successfully identified: "mini-gap"
#> Success. "mini-gap" moved to trash in Google Drive.
#> Sheet successfully identified: "iris"
#> Success. "iris" moved to trash in Google Drive.
#> [1] TRUE TRUE
## achieves same as:
## gs_delete(iris_ss)
## gs_delete(gap_xlsx)
```

### Download Sheets as csv, pdf, or xlsx file

Use `gs_download()` to download a Google Sheet as a csv, pdf, or xlsx file. Downloading the spreadsheet as a csv file will export the first worksheet (default) unless another worksheet is specified.


```r
gs_title("Gapminder") %>%
  gs_download(ws = "Africa", to = "gapminder-africa.csv")
#> Sheet successfully identified: "Gapminder"
#> Accessing worksheet titled 'Africa'.
#> Sheet successfully downloaded:
#> /Users/jenny/rrr/googlesheets/vignettes/gapminder-africa.csv
## is it there? yes!
read.csv("gapminder-africa.csv") %>% head()
#>   country continent year lifeExp      pop gdpPercap
#> 1 Algeria    Africa 1952  43.077  9279525  2449.008
#> 2 Algeria    Africa 1957  45.685 10270856  3013.976
#> 3 Algeria    Africa 1962  48.303 11000948  2550.817
#> 4 Algeria    Africa 1967  51.407 12760499  3246.992
#> 5 Algeria    Africa 1972  54.518 14760787  4182.664
#> 6 Algeria    Africa 1977  58.014 17152804  4910.417
```

Download the entire spreadsheet as an Excel workbook.


```r
gs_title("Gapminder") %>% 
  gs_download(to = "gapminder.xlsx")
#> Sheet successfully identified: "Gapminder"
#> Sheet successfully downloaded:
#> /Users/jenny/rrr/googlesheets/vignettes/gapminder.xlsx
```

Go check it out in Excel, if you wish!

And now we clean up the downloaded files.


```r
file.remove(c("gapminder.xlsx", "gapminder-africa.csv"))
#> [1] TRUE TRUE
```

### Read data, but with more control

#### Specify the consumption method

There are three ways to consume data from a worksheet within a Google spreadsheet. The order goes from fastest-but-more-limited to slowest-but-most-flexible:

  * `gs_read_csv()`: Don't let the name scare you! Nothing is written to file during this process. The name just reflects that, under the hood, we request the data via the "exportcsv" link. For cases where `gs_read_csv()` and `gs_read_listfeed()` both work, we see that `gs_read_csv()` is often __5 times faster__. Use this when your data occupies a nice rectangle in the sheet and you're willing to consume all of it. You will get a `tbl_df` back, which is basically just a `data.frame`. In fact, you might want to use `gs_read_csv()` in other, less tidy scenarios and do further munging in R.
  * `gs_read_listfeed()`: Gets data via the ["list feed"](https://developers.google.com/google-apps/spreadsheets/#working_with_list-based_feeds), which consumes data row-by-row. Like `gs_read_csv()`, this is appropriate when your data occupies a nice rectangle. Why do we even have this function? The list feed supports some query parameters for sorting and filtering the data. And might also be necessary for reading an "old" Sheet.
  * `gs_read_cellfeed()`: Get data via the ["cell feed"](https://developers.google.com/google-apps/spreadsheets/#working_with_cell-based_feeds), which consumes data cell-by-cell. This is appropriate when you want to consume arbitrary cells, rows, columns, and regions of the sheet or when you want to get formulas or cell contents without numeric formatting applied, e.g. rounding. It is invoked by `gs_read()` whenever the `range =` argument is non-`NULL` or `literal = FALSE`. It works great for modest amounts of data but can be rather slow otherwise. `gs_read_cellfeed()` returns a `tbl_df` with __one row per cell__. You can target specific cells via the `range` argument. See below for demos of `gs_reshape_cellfeed()` and `gs_simplify_cellfeed()` which help with post-processing.


```r
# Get the data for worksheet "Oceania": the super-fast csv way
oceania_csv <- gap %>% gs_read_csv(ws = "Oceania")
#> Accessing worksheet titled 'Oceania'.
#> Parsed with column specification:
#> cols(
#>   country = col_character(),
#>   continent = col_character(),
#>   year = col_double(),
#>   lifeExp = col_double(),
#>   pop = col_double(),
#>   gdpPercap = col_double()
#> )
oceania_csv
#> # A tibble: 24 x 6
#>    country   continent  year lifeExp      pop gdpPercap
#>    <chr>     <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#>  1 Australia Oceania    1952    69.1  8691212    10040.
#>  2 Australia Oceania    1957    70.3  9712569    10950.
#>  3 Australia Oceania    1962    70.9 10794968    12217.
#>  4 Australia Oceania    1967    71.1 11872264    14526.
#>  5 Australia Oceania    1972    71.9 13177000    16789.
#>  6 Australia Oceania    1977    73.5 14074100    18334.
#>  7 Australia Oceania    1982    74.7 15184200    19477.
#>  8 Australia Oceania    1987    76.3 16257249    21889.
#>  9 Australia Oceania    1992    77.6 17481977    23425.
#> 10 Australia Oceania    1997    78.8 18565243    26998.
#> # ... with 14 more rows
glimpse(oceania_csv)
#> Observations: 24
#> Variables: 6
#> $ country   <chr> "Australia", "Australia", "Australia", "Australia", ...
#> $ continent <chr> "Oceania", "Oceania", "Oceania", "Oceania", "Oceania...
#> $ year      <dbl> 1952, 1957, 1962, 1967, 1972, 1977, 1982, 1987, 1992...
#> $ lifeExp   <dbl> 69.120, 70.330, 70.930, 71.100, 71.930, 73.490, 74.7...
#> $ pop       <dbl> 8691212, 9712569, 10794968, 11872264, 13177000, 1407...
#> $ gdpPercap <dbl> 10039.60, 10949.65, 12217.23, 14526.12, 16788.63, 18...

# Get the data for worksheet "Oceania": the less-fast tabular way ("list feed")
oceania_list_feed <- gap %>% gs_read_listfeed(ws = "Oceania") 
#> Accessing worksheet titled 'Oceania'.
#> Parsed with column specification:
#> cols(
#>   country = col_character(),
#>   continent = col_character(),
#>   year = col_double(),
#>   lifeExp = col_double(),
#>   pop = col_double(),
#>   gdpPercap = col_double()
#> )
oceania_list_feed
#> # A tibble: 24 x 6
#>    country   continent  year lifeExp      pop gdpPercap
#>    <chr>     <chr>     <dbl>   <dbl>    <dbl>     <dbl>
#>  1 Australia Oceania    1952    69.1  8691212    10040.
#>  2 Australia Oceania    1957    70.3  9712569    10950.
#>  3 Australia Oceania    1962    70.9 10794968    12217.
#>  4 Australia Oceania    1967    71.1 11872264    14526.
#>  5 Australia Oceania    1972    71.9 13177000    16789.
#>  6 Australia Oceania    1977    73.5 14074100    18334.
#>  7 Australia Oceania    1982    74.7 15184200    19477.
#>  8 Australia Oceania    1987    76.3 16257249    21889.
#>  9 Australia Oceania    1992    77.6 17481977    23425.
#> 10 Australia Oceania    1997    78.8 18565243    26998.
#> # ... with 14 more rows
glimpse(oceania_list_feed)
#> Observations: 24
#> Variables: 6
#> $ country   <chr> "Australia", "Australia", "Australia", "Australia", ...
#> $ continent <chr> "Oceania", "Oceania", "Oceania", "Oceania", "Oceania...
#> $ year      <dbl> 1952, 1957, 1962, 1967, 1972, 1977, 1982, 1987, 1992...
#> $ lifeExp   <dbl> 69.120, 70.330, 70.930, 71.100, 71.930, 73.490, 74.7...
#> $ pop       <dbl> 8691212, 9712569, 10794968, 11872264, 13177000, 1407...
#> $ gdpPercap <dbl> 10039.60, 10949.65, 12217.23, 14526.12, 16788.63, 18...

# Get the data for worksheet "Oceania": the slow cell-by-cell way ("cell feed")
oceania_cell_feed <- gap %>% gs_read_cellfeed(ws = "Oceania") 
#> Accessing worksheet titled 'Oceania'.
oceania_cell_feed
#> # A tibble: 150 x 7
#>    cell  cell_alt   row   col value     input_value numeric_value
#>    <chr> <chr>    <int> <int> <chr>     <chr>       <chr>        
#>  1 A1    R1C1         1     1 country   country     <NA>         
#>  2 B1    R1C2         1     2 continent continent   <NA>         
#>  3 C1    R1C3         1     3 year      year        <NA>         
#>  4 D1    R1C4         1     4 lifeExp   lifeExp     <NA>         
#>  5 E1    R1C5         1     5 pop       pop         <NA>         
#>  6 F1    R1C6         1     6 gdpPercap gdpPercap   <NA>         
#>  7 A2    R2C1         2     1 Australia Australia   <NA>         
#>  8 B2    R2C2         2     2 Oceania   Oceania     <NA>         
#>  9 C2    R2C3         2     3 1952      1952        1952.0       
#> 10 D2    R2C4         2     4 69.12     69.12       69.12        
#> # ... with 140 more rows
glimpse(oceania_cell_feed)
#> Observations: 150
#> Variables: 7
#> $ cell          <chr> "A1", "B1", "C1", "D1", "E1", "F1", "A2", "B2", ...
#> $ cell_alt      <chr> "R1C1", "R1C2", "R1C3", "R1C4", "R1C5", "R1C6", ...
#> $ row           <int> 1, 1, 1, 1, 1, 1, 2, 2, 2, 2, 2, 2, 3, 3, 3, 3, ...
#> $ col           <int> 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, 5, 6, 1, 2, 3, 4, ...
#> $ value         <chr> "country", "continent", "year", "lifeExp", "pop"...
#> $ input_value   <chr> "country", "continent", "year", "lifeExp", "pop"...
#> $ numeric_value <chr> NA, NA, NA, NA, NA, NA, NA, NA, "1952.0", "69.12...
```

#### Quick speed comparison

Let's consume all the data for Africa by all 3 methods and see how long it takes.




            gs_read_csv    gs_read_listfeed   gs_read_cellfeed 
----------  -------------  -----------------  -----------------
user.self   0.030 (1.00)   0.480 (15.00)      1.580 (49.53)    
sys.self    0.000 (1.00)   0.040 (39.00)      0.070 (68.00)    
elapsed     0.440 (1.00)   1.550 ( 3.56)      2.850 ( 6.54)    

#### Post-processing data from the cell feed

If you consume data from the cell feed with `gs_read_cellfeed()`, you get a data.frame back with **one row per cell**. The package offers two functions to post-process this into something more useful:

  * `gs_reshape_cellfeed()`, makes a 2D thing, i.e. a data frame
  * `gs_simplify_cellfeed()` makes a 1D thing, i.e. a vector

Reshaping into a 2D data frame is covered well elsewhere, so here we mostly demonstrate the use of `gs_simplify_cellfeed()`.


```r
## reshape into 2D data frame
gap_3rows <- gap %>% gs_read_cellfeed("Europe", range = cell_rows(1:3))
#> Accessing worksheet titled 'Europe'.
gap_3rows %>% head()
#> # A tibble: 6 x 7
#>   cell  cell_alt   row   col value     input_value numeric_value
#>   <chr> <chr>    <int> <int> <chr>     <chr>       <chr>        
#> 1 A1    R1C1         1     1 country   country     <NA>         
#> 2 B1    R1C2         1     2 continent continent   <NA>         
#> 3 C1    R1C3         1     3 year      year        <NA>         
#> 4 D1    R1C4         1     4 lifeExp   lifeExp     <NA>         
#> 5 E1    R1C5         1     5 pop       pop         <NA>         
#> 6 F1    R1C6         1     6 gdpPercap gdpPercap   <NA>
gap_3rows %>% gs_reshape_cellfeed()
#> Parsed with column specification:
#> cols(
#>   country = col_character(),
#>   continent = col_character(),
#>   year = col_double(),
#>   lifeExp = col_double(),
#>   pop = col_double(),
#>   gdpPercap = col_double()
#> )
#> # A tibble: 2 x 6
#>   country continent  year lifeExp     pop gdpPercap
#>   <chr>   <chr>     <dbl>   <dbl>   <dbl>     <dbl>
#> 1 Albania Europe     1952    55.2 1282697     1601.
#> 2 Albania Europe     1957    59.3 1476505     1942.

# Example: first row only
gap_1row <- gap %>% gs_read_cellfeed("Europe", range = cell_rows(1))
#> Accessing worksheet titled 'Europe'.
gap_1row
#> # A tibble: 6 x 7
#>   cell  cell_alt   row   col value     input_value numeric_value
#>   <chr> <chr>    <int> <int> <chr>     <chr>       <chr>        
#> 1 A1    R1C1         1     1 country   country     <NA>         
#> 2 B1    R1C2         1     2 continent continent   <NA>         
#> 3 C1    R1C3         1     3 year      year        <NA>         
#> 4 D1    R1C4         1     4 lifeExp   lifeExp     <NA>         
#> 5 E1    R1C5         1     5 pop       pop         <NA>         
#> 6 F1    R1C6         1     6 gdpPercap gdpPercap   <NA>

# convert to a named (character) vector
gap_1row %>% gs_simplify_cellfeed()
#>          A1          B1          C1          D1          E1          F1 
#>   "country" "continent"      "year"   "lifeExp"       "pop" "gdpPercap"

# Example: single column
gap_1col <- gap %>% gs_read_cellfeed("Europe", range = cell_cols(3))
#> Accessing worksheet titled 'Europe'.
gap_1col
#> # A tibble: 361 x 7
#>    cell  cell_alt   row   col value input_value numeric_value
#>    <chr> <chr>    <int> <int> <chr> <chr>       <chr>        
#>  1 C1    R1C3         1     3 year  year        <NA>         
#>  2 C2    R2C3         2     3 1952  1952        1952.0       
#>  3 C3    R3C3         3     3 1957  1957        1957.0       
#>  4 C4    R4C3         4     3 1962  1962        1962.0       
#>  5 C5    R5C3         5     3 1967  1967        1967.0       
#>  6 C6    R6C3         6     3 1972  1972        1972.0       
#>  7 C7    R7C3         7     3 1977  1977        1977.0       
#>  8 C8    R8C3         8     3 1982  1982        1982.0       
#>  9 C9    R9C3         9     3 1987  1987        1987.0       
#> 10 C10   R10C3       10     3 1992  1992        1992.0       
#> # ... with 351 more rows

# drop the `year` variable name, convert to integer, return un-named vector
yr <- gap_1col %>% gs_simplify_cellfeed(notation = "none")
str(yr)
#>  num [1:360] 1952 1957 1962 1967 1972 ...
```

#### Controlling data ingest, theory

`googlesheets` provides control of data ingest in the style of [`readr`](https://cran.r-project.org/package=readr). Some arguments are passed straight through to `readr::read_csv()` or `readr::type_convert()` and others are used internally by `googlesheets`, hopefully in the same way!

Which cells?

  * `range` gives finest control and is enacted first. Available on `gs_read()`, which calls `gs_read_cellfeed()`, which can also be called directly.
  * `skip` skips rows, from the top only. Available in all read functions.
  * `comment` can be used to skip rows inside the data rectangle, if the `comment` string occurs at the start of the first cell.  Available in all read functions.
  * `n_max` can be used to limit the number of rows. Available in all read functions.
  * The list feed supports structured queries to filter rows. See its help file.

Where do variable names come from?

  * `col_names` works just as it does in `readr`, for all read functions.
    - `TRUE`, the default, will treat first row as a header row of variable names.
    - `FALSE` will cause `googlesheets` to create variable names. Combine that with `skip = 1` if the sheet contains variable names, but you just don't like them.
    - A character vector of names also works. Again, possibly combine with `skip = 1`.
  * Two departures from `readr`:
    - `googlesheets` will never return a data frame with `NA` as a variable name. Instead, it will create a dummy variable name, like `X5`.
    - All read/reshape functions accept `check.names`, in the spirit of `utils::read.table()`, which defaults to `FALSE`. If `TRUE`, variable names will be run through `make.names(..., unique = TRUE)`.
    
How to do type conversion of variables?

  * The `readr` default behavior might be just fine. Try it!
  * Read about column specification in the [`readr` vignette](http://readr.tidyverse.org/articles/readr.html) to better understand the automatic variable conversion behavior and how to use the `col_types` argument to override it.
  * `col_types`, `locale`, `trim_ws`, and `na` are all available for finer control.
  * One departure from `readr`:
    - If a variable consists entirely of `NA`s, they will be logical `NA`s, not `NA_character_`.

How to get raw formulas or numbers without numeric formatting applied?

  * `gs_read(..., literal = FALSE)` will get unformatted numbers via the cell feed. Useful if numeric formatting is causing a number to come in as character or if rounding is a problem.
  * If you want full access to formulas and alternative definitions of cell contents, use `gs_read_cellfeed()` directly.
  * See the "Formulas and Formatting" vignette for more.



#### Controlling data ingest, practice

Let's make a practice sheet to explore ways to control data ingest. On different worksheets, we put the same data frame into slightly more challenging positions.


```r
df <- data_frame(thing1 = paste0("A", 2:5),
                 thing2 = paste0("B", 2:5),
                 thing3 = paste0("C", 2:5))
df$thing1[2] <- paste0("#", df$thing1[2])
df$thing2[1] <- "*"
df
#> # A tibble: 4 x 3
#>   thing1 thing2 thing3
#>   <chr>  <chr>  <chr> 
#> 1 A2     *      C2    
#> 2 #A3    B3     C3    
#> 3 A4     B4     C4    
#> 4 A5     B5     C5

ss <- gs_new("data-ingest-practice", ws_title = "simple",
             input = df, trim = TRUE) %>% 
  gs_ws_new("one-blank-row", input = df, trim = TRUE, anchor = "A2") %>% 
  gs_ws_new("two-blank-rows", input = df, trim = TRUE, anchor = "A3")
#> Sheet "data-ingest-practice" created in Google Drive.
#> Worksheet "Sheet1" renamed to "simple".
#> Range affected by the update: "R1C1:R5C3"
#> Worksheet "simple" successfully updated with 15 new value(s).
#> Accessing worksheet titled 'simple'.
#> Sheet successfully identified: "data-ingest-practice"
#> Accessing worksheet titled 'simple'.
#> Worksheet "simple" dimensions changed to 5 x 3.
#> Worksheet dimensions: 5 x 3.
#> Worksheet "one-blank-row" added to sheet "data-ingest-practice".
#> Range affected by the update: "R2C1:R6C3"
#> Worksheet "one-blank-row" successfully updated with 15 new value(s).
#> Accessing worksheet titled 'one-blank-row'.
#> Sheet successfully identified: "data-ingest-practice"
#> Accessing worksheet titled 'one-blank-row'.
#> Worksheet "one-blank-row" dimensions changed to 6 x 3.
#> Worksheet dimensions: 6 x 3.
#> Worksheet "two-blank-rows" added to sheet "data-ingest-practice".
#> Range affected by the update: "R3C1:R7C3"
#> Worksheet "two-blank-rows" successfully updated with 15 new value(s).
#> Accessing worksheet titled 'two-blank-rows'.
#> Sheet successfully identified: "data-ingest-practice"
#> Accessing worksheet titled 'two-blank-rows'.
#> Worksheet "two-blank-rows" dimensions changed to 7 x 3.
#> Worksheet dimensions: 7 x 3.
```

Go visit it in the browser via `gs_browse(ss)`. The first worksheet will look something like this:

![simple-ingest](img/simple-ingest.png)

Override the default variable names, but use `skip = 1` to keep them from ending up in the data frame. Try it with different read methods.


```r
## will use gs_read_csv
ss %>% gs_read(col_names = FALSE, skip = 1)
#> Accessing worksheet titled 'simple'.
#> Parsed with column specification:
#> cols(
#>   X1 = col_character(),
#>   X2 = col_character(),
#>   X3 = col_character()
#> )
#> # A tibble: 4 x 3
#>   X1    X2    X3   
#>   <chr> <chr> <chr>
#> 1 A2    *     C2   
#> 2 #A3   B3    C3   
#> 3 A4    B4    C4   
#> 4 A5    B5    C5
ss %>% gs_read(col_names = letters[1:3], skip = 1)
#> Accessing worksheet titled 'simple'.
#> Parsed with column specification:
#> cols(
#>   a = col_character(),
#>   b = col_character(),
#>   c = col_character()
#> )
#> # A tibble: 4 x 3
#>   a     b     c    
#>   <chr> <chr> <chr>
#> 1 A2    *     C2   
#> 2 #A3   B3    C3   
#> 3 A4    B4    C4   
#> 4 A5    B5    C5

## explicitly use gs_read_listfeed
ss %>% gs_read_listfeed(col_names = FALSE, skip = 1)
#> Accessing worksheet titled 'simple'.
#> Parsed with column specification:
#> cols(
#>   X1 = col_character(),
#>   X2 = col_character(),
#>   X3 = col_character()
#> )
#> # A tibble: 4 x 3
#>   X1    X2    X3   
#>   <chr> <chr> <chr>
#> 1 A2    *     C2   
#> 2 #A3   B3    C3   
#> 3 A4    B4    C4   
#> 4 A5    B5    C5

## use range to force use of gs_read_cellfeed
ss %>% gs_read_listfeed(col_names = FALSE, skip = 1, range = cell_cols("A:Z"))
#> Accessing worksheet titled 'simple'.
#> Parsed with column specification:
#> cols(
#>   X1 = col_character(),
#>   X2 = col_character(),
#>   X3 = col_character()
#> )
#> # A tibble: 4 x 3
#>   X1    X2    X3   
#>   <chr> <chr> <chr>
#> 1 A2    *     C2   
#> 2 #A3   B3    C3   
#> 3 A4    B4    C4   
#> 4 A5    B5    C5
```



Read from the worksheet with a blank row at the top. Start to play with some other ingest arguments.

![top-filler](img/not-so-simple-ingest.png)


```r
## blank row causes variable names to show up in the data frame :(
ss %>% gs_read(ws = "one-blank-row")
#> Accessing worksheet titled 'one-blank-row'.
#> Warning: Missing column names filled in: 'X1' [1], 'X2' [2], 'X3' [3]
#> Parsed with column specification:
#> cols(
#>   X1 = col_character(),
#>   X2 = col_character(),
#>   X3 = col_character()
#> )
#> # A tibble: 5 x 3
#>   X1     X2     X3    
#>   <chr>  <chr>  <chr> 
#> 1 thing1 thing2 thing3
#> 2 A2     *      C2    
#> 3 #A3    B3     C3    
#> 4 A4     B4     C4    
#> 5 A5     B5     C5

## skip = 1 fixes it :)
ss %>% gs_read(ws = "one-blank-row", skip = 1)
#> Accessing worksheet titled 'one-blank-row'.
#> Parsed with column specification:
#> cols(
#>   thing1 = col_character(),
#>   thing2 = col_character(),
#>   thing3 = col_character()
#> )
#> # A tibble: 4 x 3
#>   thing1 thing2 thing3
#>   <chr>  <chr>  <chr> 
#> 1 A2     *      C2    
#> 2 #A3    B3     C3    
#> 3 A4     B4     C4    
#> 4 A5     B5     C5

## more arguments, more better
ss %>% gs_read(ws = "one-blank-row", skip = 2,
               col_names = paste0("yo ?!*", 1:3), check.names = TRUE,
               na = "*", comment = "#", n_max = 2)
#> Accessing worksheet titled 'one-blank-row'.
#> Parsed with column specification:
#> cols(
#>   `yo ?!*1` = col_character(),
#>   `yo ?!*2` = col_character(),
#>   `yo ?!*3` = col_character()
#> )
#> # A tibble: 2 x 3
#>   yo....1 yo....2 yo....3
#>   <chr>   <chr>   <chr>  
#> 1 A2      <NA>    C2     
#> 2 A4      B4      C4

## also works on list feed
ss %>% gs_read_listfeed(ws = "one-blank-row", skip = 2,
                        col_names = paste0("yo ?!*", 1:3), check.names = TRUE,
                        na = "*", comment = "#", n_max = 2)
#> Accessing worksheet titled 'one-blank-row'.
#> Parsed with column specification:
#> cols(
#>   yo....1 = col_character(),
#>   yo....2 = col_character(),
#>   yo....3 = col_character()
#> )
#> # A tibble: 2 x 3
#>   yo....1 yo....2 yo....3
#>   <chr>   <chr>   <chr>  
#> 1 A2      <NA>    C2     
#> 2 A4      B4      C4

## also works on the cell feed
ss %>% gs_read_listfeed(ws = "one-blank-row", range = cell_cols("A:Z"), skip = 2,
                        col_names = paste0("yo ?!*", 1:3), check.names = TRUE,
                        na = "*", comment = "#", n_max = 2)
#> Accessing worksheet titled 'one-blank-row'.
#> Parsed with column specification:
#> cols(
#>   yo....1 = col_character(),
#>   yo....2 = col_character(),
#>   yo....3 = col_character()
#> )
#> # A tibble: 2 x 3
#>   yo....1 yo....2 yo....3
#>   <chr>   <chr>   <chr>  
#> 1 A2      <NA>    C2     
#> 2 A4      B4      C4
```

Finally, we read from the worksheet with TWO blank rows at the top, which is more than the list feed can handle.


```r
## use skip to get correct result via gs_read() --> gs_read_csv()
ss %>% gs_read(ws = "two-blank-rows", skip = 2)
#> Accessing worksheet titled 'two-blank-rows'.
#> Parsed with column specification:
#> cols(
#>   thing1 = col_character(),
#>   thing2 = col_character(),
#>   thing3 = col_character()
#> )
#> # A tibble: 4 x 3
#>   thing1 thing2 thing3
#>   <chr>  <chr>  <chr> 
#> 1 A2     *      C2    
#> 2 #A3    B3     C3    
#> 3 A4     B4     C4    
#> 4 A5     B5     C5

## or use range in gs_read() --> gs_read_cellfeed() + gs_reshape_cellfeed()
ss %>% gs_read(ws = "two-blank-rows", range = cell_limits(c(3, NA), c(NA, NA)))
#> Accessing worksheet titled 'two-blank-rows'.
#> Parsed with column specification:
#> cols(
#>   thing1 = col_character(),
#>   thing2 = col_character(),
#>   thing3 = col_character()
#> )
#> # A tibble: 4 x 3
#>   thing1 thing2 thing3
#>   <chr>  <chr>  <chr> 
#> 1 A2     *      C2    
#> 2 #A3    B3     C3    
#> 3 A4     B4     C4    
#> 4 A5     B5     C5
ss %>% gs_read(ws = "two-blank-rows", range = cell_cols("A:C"))
#> Accessing worksheet titled 'two-blank-rows'.
#> Parsed with column specification:
#> cols(
#>   thing1 = col_character(),
#>   thing2 = col_character(),
#>   thing3 = col_character()
#> )
#> # A tibble: 4 x 3
#>   thing1 thing2 thing3
#>   <chr>  <chr>  <chr> 
#> 1 A2     *      C2    
#> 2 #A3    B3     C3    
#> 3 A4     B4     C4    
#> 4 A5     B5     C5

## list feed can't cope because the 1st data row is empty
ss %>% gs_read_listfeed(ws = "two-blank-rows")
#> Accessing worksheet titled 'two-blank-rows'.
#> Worksheet 'two-blank-rows' is empty.
#> # A tibble: 0 x 0
ss %>% gs_read_listfeed(ws = "two-blank-rows", skip = 2)
#> Accessing worksheet titled 'two-blank-rows'.
#> Worksheet 'two-blank-rows' is empty.
#> # A tibble: 0 x 0
```

Let's clean up after ourselves.


```r
gs_delete(ss)
#> Success. "data-ingest-practice" moved to trash in Google Drive.
```



### Authorization using OAuth2
 
If you use a function that requires authorization, it will be auto-triggered. But you can also initiate the process explicitly if you wish, like so:
 

```r
# Give googlesheets permission to access your spreadsheets and google drive
gs_auth() 
```
 
Use `gs_auth(new_user = TRUE)`, to force the process to begin anew. Otherwise, the credentials left behind will be used to refresh your access token as needed.

The function `gs_user()` will print and return some information about the current authenticated user and session.


```r
user_session_info <- gs_user()
user_session_info
#>           displayName: google sheets
#>          emailAddress: gspreadr@gmail.com
#>                  date: 2018-06-28 23:18:17 GMT
#>          permissionId: 14497944239034869033
#>          rootFolderId: 0AOdw-qi1jh3fUk9PVA
```

### "Old" Google Sheets

In March 2014 [Google introduced "new" Sheets](https://support.google.com/docs/answer/3541068?hl=en). "New" Sheets and "old" sheets behave quite differently with respect to access via API and present a big headache for us. In 2015, Google started forcibly converting sheets: [all "old" Sheets will be switched over the "new" sheets during 2015](https://support.google.com/docs/answer/6082736?p=new_sheets_migrate&rd=1). For a while, there were still "old" sheets lying around, so we've made some effort to support them, when it's easy to do so. But keep your expectations low. You can expect what little support there is to go away in the next version of `googlesheets`.

`gs_read_csv()` does not work for "old" sheets. Nor will it ever.
