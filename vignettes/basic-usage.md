# googlesheets Basic Usage
Jenny Bryan, Joanna Zhao  
`r Sys.Date()`  



First we load the `googlesheets` package and `dplyr`, from which we use the `%>%` pipe operator, among other things. `googlesheets` usage *does not require* you to use `%>%` though it was certainly designed to be pipe-friendly. This vignette uses pipes but you will find that all the examples in the help files use base R only.


```r
library(googlesheets)
suppressMessages(library(dplyr))
```





### See some spreadsheets you can access

The `gs_ls()` function returns the sheets you would see in your Google Sheets home screen: <https://docs.google.com/spreadsheets/>. This should include sheets that you own and may also show sheets owned by others but that you are permitted to access, if you have visited the sheet in the browser. Expect a prompt to authenticate yourself in the browser at this point (more below re: auth).


```r
(my_sheets <- gs_ls())
#> Source: local data frame [70 x 10]
#> 
#>                 sheet_title        author  perm version
#>                       (chr)         (chr) (chr)   (chr)
#> 1  test-gs-travis-2139114b…      gspreadr    rw     new
#> 2  test-gs-travis-2139114b…      gspreadr    rw     new
#> 3  test-gs-jenny-12dd43330…      gspreadr    rw     new
#> 4  gs-test-formula-formatt…  rpackagetest     r     new
#> 5   EasyTweetSheet - Shared     m.hawksey     r     new
#> 6  Individual-level admixt…       the.dfx     r     new
#> 7            test-gs-ingest  rpackagetest     r     new
#> 8  Copy of Twitter Archive…   joannazhaoo     r     new
#> 9              #rhizo15 #tw     m.hawksey     r     new
#> 10 test-gs-public-testing-…  rpackagetest     r     new
#> ..                      ...           ...   ...     ...
#> Variables not shown: updated (time), sheet_key (chr), ws_feed (chr),
#>   alternate (chr), self (chr), alt_key (chr).
# (expect a prompt to authenticate with Google interactively HERE)
my_sheets %>% glimpse()
#> Observations: 70
#> Variables: 10
#> $ sheet_title (chr) "test-gs-travis-2139114b77b2-catherine", "test-gs-...
#> $ author      (chr) "gspreadr", "gspreadr", "gspreadr", "rpackagetest"...
#> $ perm        (chr) "rw", "rw", "rw", "r", "r", "r", "r", "r", "r", "r...
#> $ version     (chr) "new", "new", "new", "new", "new", "new", "new", "...
#> $ updated     (time) 2016-03-15 07:32:29, 2016-03-15 07:32:27, 2016-03...
#> $ sheet_key   (chr) "1TYQrJ3QTUIU8u7mzHYmgPSFYqair6MO0bNAu44dAkEc", "1...
#> $ ws_feed     (chr) "https://spreadsheets.google.com/feeds/worksheets/...
#> $ alternate   (chr) "https://docs.google.com/spreadsheets/d/1TYQrJ3QTU...
#> $ self        (chr) "https://spreadsheets.google.com/feeds/spreadsheet...
#> $ alt_key     (chr) NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA, NA...
```

### Get a Google spreadsheet to practice with

Don't worry if you don't have any suitable Google Sheets lying around! We've published a sheet for you to practice with and have built functions into `googlesheets` to help you access it. The example sheet holds some of the [Gapminder data](https://github.com/jennybc/gapminder); feel free to [visit the Sheet in the browser](https://w3id.org/people/jennybc/googlesheets_gap_url). The code below will put a copy of this sheet into your Drive, titled "Gapminder".


```r
gs_gap() %>% 
  gs_copy(to = "Gapminder")
```

If that seems to have worked, go check for a sheet named "Gapminder" in your Google Sheets home screen: <https://docs.google.com/spreadsheets/>. You could also run `gs_ls()` again and make sure the Gapminder sheet is listed.

### Register a spreadsheet

If you plan to consume data from a sheet or edit it, you must first __register__ it. This is how `googlesheets` records important info about the sheet that is required downstream by the Google Sheets or Google Drive APIs. Once registered, you can print the result to get some basic info about the sheet.

`googlesheets` provides several registration functions. Specifying the sheet by title? Use `gs_title()`. By key? Use `gs_key()`. You get the idea.

*We're using the built-in functions `gs_gap_key()` and `gs_gap_url()` to produce the key and browser URL for the Gapminder example sheet, so you can see how this will play out with your own projects.*


```r
gap <- gs_title("Gapminder")
#> Sheet successfully identified: "Gapminder"
gap
#>                   Spreadsheet title: Gapminder
#>                  Spreadsheet author: gspreadr
#>   Date of googlesheets registration: 2016-03-15 21:57:26 GMT
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
#> Browser URL: https://docs.google.com/spreadsheets/d/1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA/

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
# note: registration via URL may not work for "old" sheets

# Worried that a spreadsheet's registration is out-of-date?
# Re-register it!
gap <- gap %>% gs_gs()
#> Sheet successfully identified: "Gapminder"
```



The registration functions `gs_title()`, `gs_key()`, `gs_url()`, and `gs_gs()` return a registered sheet as a `googlesheet` object, which is the first argument to practically every function in this package. Likewise, almost every function returns a freshly registered `googlesheet` object, ready to be stored or piped into the next command.

*We export a utility function, `extract_key_from_url()`, to help you get and store the key from a browser URL. Registering via browser URL is fine, but registering by key is probably a better idea in the long-run.*

Use `gs_browse()` to visit the Sheet corresponding to a registered `googlesheet`
in your browser. Optionally, you can specify the worksheet of interest.


```r
gap %>% gs_browse()
gap %>% gs_browse(ws = 2)
gap %>% gs_browse(ws = "Europe")
```

### Consume data

#### Ignorance is bliss

If you want to consume the data in a worksheet and get something rectangular back, use the all-purpose function `gs_read()`. By default, it reads all the data in a worksheet.


```r
oceania <- gap %>% gs_read(ws = "Oceania")
#> Accessing worksheet titled 'Oceania'.
#> No encoding supplied: defaulting to UTF-8.
oceania
#> Source: local data frame [24 x 6]
#> 
#>      country continent  year lifeExp      pop gdpPercap
#>        (chr)     (chr) (int)   (dbl)    (int)     (dbl)
#> 1  Australia   Oceania  1952   69.12  8691212  10039.60
#> 2  Australia   Oceania  1957   70.33  9712569  10949.65
#> 3  Australia   Oceania  1962   70.93 10794968  12217.23
#> 4  Australia   Oceania  1967   71.10 11872264  14526.12
#> 5  Australia   Oceania  1972   71.93 13177000  16788.63
#> 6  Australia   Oceania  1977   73.49 14074100  18334.20
#> 7  Australia   Oceania  1982   74.74 15184200  19477.01
#> 8  Australia   Oceania  1987   76.32 16257249  21888.89
#> 9  Australia   Oceania  1992   77.56 17481977  23424.77
#> 10 Australia   Oceania  1997   78.83 18565243  26997.94
#> ..       ...       ...   ...     ...      ...       ...
str(oceania)
#> Classes 'tbl_df', 'tbl' and 'data.frame':	24 obs. of  6 variables:
#>  $ country  : chr  "Australia" "Australia" "Australia" "Australia" ...
#>  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
#>  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
#>  $ lifeExp  : num  69.1 70.3 70.9 71.1 71.9 ...
#>  $ pop      : int  8691212 9712569 10794968 11872264 13177000 14074100 15184200 16257249 17481977 18565243 ...
#>  $ gdpPercap: num  10040 10950 12217 14526 16789 ...
glimpse(oceania)
#> Observations: 24
#> Variables: 6
#> $ country   (chr) "Australia", "Australia", "Australia", "Australia", ...
#> $ continent (chr) "Oceania", "Oceania", "Oceania", "Oceania", "Oceania...
#> $ year      (int) 1952, 1957, 1962, 1967, 1972, 1977, 1982, 1987, 1992...
#> $ lifeExp   (dbl) 69.120, 70.330, 70.930, 71.100, 71.930, 73.490, 74.7...
#> $ pop       (int) 8691212, 9712569, 10794968, 11872264, 13177000, 1407...
#> $ gdpPercap (dbl) 10039.60, 10949.65, 12217.23, 14526.12, 16788.63, 18...
```

You can target specific cells via the `range =` argument. The simplest usage is to specify an Excel-like cell range, such as range = "D12:F15" or range = "R1C12:R6C15". The cell rectangle can be specified in various other ways, using helper functions. It can be degenerate, i.e. open-ended.


```r
gap %>% gs_read(ws = 2, range = "A1:D8")
#> Accessing worksheet titled 'Americas'.
#> Source: local data frame [7 x 4]
#> 
#>     country continent  year lifeExp
#>       (chr)     (chr) (int)   (dbl)
#> 1 Argentina  Americas  1952  62.485
#> 2 Argentina  Americas  1957  64.399
#> 3 Argentina  Americas  1962  65.142
#> 4 Argentina  Americas  1967  65.634
#> 5 Argentina  Americas  1972  67.065
#> 6 Argentina  Americas  1977  68.481
#> 7 Argentina  Americas  1982  69.942
gap %>% gs_read(ws = "Europe", range = cell_rows(1:4))
#> Accessing worksheet titled 'Europe'.
#> Source: local data frame [3 x 6]
#> 
#>   country continent  year lifeExp     pop gdpPercap
#>     (chr)     (chr) (int)   (dbl)   (int)     (dbl)
#> 1 Albania    Europe  1952   55.23 1282697  1601.056
#> 2 Albania    Europe  1957   59.28 1476505  1942.284
#> 3 Albania    Europe  1962   64.82 1728137  2312.889
gap %>% gs_read(ws = "Europe", range = cell_rows(100:103), col_names = FALSE)
#> Accessing worksheet titled 'Europe'.
#> Source: local data frame [4 x 6]
#> 
#>        X1     X2    X3    X4      X5        X6
#>     (chr)  (chr) (int) (dbl)   (int)     (dbl)
#> 1 Finland Europe  1962 68.75 4491443  9371.843
#> 2 Finland Europe  1967 69.83 4605744 10921.636
#> 3 Finland Europe  1972 70.87 4639657 14358.876
#> 4 Finland Europe  1977 72.52 4738902 15605.423
gap %>% gs_read(ws = "Africa", range = cell_cols(1:4))
#> Accessing worksheet titled 'Africa'.
#> Source: local data frame [624 x 4]
#> 
#>    country continent  year lifeExp
#>      (chr)     (chr) (int)   (dbl)
#> 1  Algeria    Africa  1952  43.077
#> 2  Algeria    Africa  1957  45.685
#> 3  Algeria    Africa  1962  48.303
#> 4  Algeria    Africa  1967  51.407
#> 5  Algeria    Africa  1972  54.518
#> 6  Algeria    Africa  1977  58.014
#> 7  Algeria    Africa  1982  61.368
#> 8  Algeria    Africa  1987  65.799
#> 9  Algeria    Africa  1992  67.744
#> 10 Algeria    Africa  1997  69.152
#> ..     ...       ...   ...     ...
gap %>% gs_read(ws = "Asia", range = cell_limits(c(1, 4), c(5, NA)))
#> Accessing worksheet titled 'Asia'.
#> Source: local data frame [4 x 3]
#> 
#>   lifeExp      pop gdpPercap
#>     (dbl)    (int)     (dbl)
#> 1  28.801  8425333  779.4453
#> 2  30.332  9240934  820.8530
#> 3  31.997 10267083  853.1007
#> 4  34.020 11537966  836.1971
```

`gs_read()` is a wrapper that bundles together the most common methods to read data from the API and transform it for downstream use. You can refine it's behavior further, by passing more arguments via `...`. See the section below on `readr`-style data ingest.

If `gs_read()` doesn't do what you need, then keep reading for the underlying functions to read and post-process data.

#### Specify the consumption method

There are three ways to consume data from a worksheet within a Google spreadsheet. The order goes from fastest-but-more-limited to slowest-but-most-flexible:

  * `gs_read_csv()`: Don't let the name scare you! Nothing is written to file during this process. The name just reflects that, under the hood, we request the data via the "exportcsv" link. For cases where `gs_read_csv()` and `gs_read_listfeed()` both work, we see that `gs_read_csv()` is often __5 times faster__. Use this when your data occupies a nice rectangle in the sheet and you're willing to consume all of it. You will get a `tbl_df` back, which is basically just a `data.frame`. In fact, you might want to use `gs_read_csv()` in other, less tidy scenarios and do further munging in R.
  * `gs_read_listfeed()`: Gets data via the ["list feed"](https://developers.google.com/google-apps/spreadsheets/#working_with_list-based_feeds), which consumes data row-by-row. Like `gs_read_csv()`, this is appropriate when your data occupies a nice rectangle. Why do we even have this function? The list feed supports some query parameters for sorting and filtering the data. And might also be necessary for reading an "old" Sheet.
  * `gs_read_cellfeed()`: Get data via the ["cell feed"](https://developers.google.com/google-apps/spreadsheets/#working_with_cell-based_feeds), which consumes data cell-by-cell. This is appropriate when you want to consume arbitrary cells, rows, columns, and regions of the sheet or when you want to get formulas or cell contents without numeric formatting applied, e.g. rounding. It is invoked by `gs_read()` whenever the `range =` argument is non-`NULL` or `literal = FALSE`. It works great for modest amounts of data but can be rather slow otherwise. `gs_read_cellfeed()` returns a `tbl_df` with __one row per cell__. You can target specific cells via the `range` argument. See below for demos of `gs_reshape_cellfeed()` and `gs_simplify_cellfeed()` which help with post-processing.


```r
# Get the data for worksheet "Oceania": the super-fast csv way
oceania_csv <- gap %>% gs_read_csv(ws = "Oceania")
#> Accessing worksheet titled 'Oceania'.
#> No encoding supplied: defaulting to UTF-8.
str(oceania_csv)
#> Classes 'tbl_df', 'tbl' and 'data.frame':	24 obs. of  6 variables:
#>  $ country  : chr  "Australia" "Australia" "Australia" "Australia" ...
#>  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
#>  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
#>  $ lifeExp  : num  69.1 70.3 70.9 71.1 71.9 ...
#>  $ pop      : int  8691212 9712569 10794968 11872264 13177000 14074100 15184200 16257249 17481977 18565243 ...
#>  $ gdpPercap: num  10040 10950 12217 14526 16789 ...
oceania_csv
#> Source: local data frame [24 x 6]
#> 
#>      country continent  year lifeExp      pop gdpPercap
#>        (chr)     (chr) (int)   (dbl)    (int)     (dbl)
#> 1  Australia   Oceania  1952   69.12  8691212  10039.60
#> 2  Australia   Oceania  1957   70.33  9712569  10949.65
#> 3  Australia   Oceania  1962   70.93 10794968  12217.23
#> 4  Australia   Oceania  1967   71.10 11872264  14526.12
#> 5  Australia   Oceania  1972   71.93 13177000  16788.63
#> 6  Australia   Oceania  1977   73.49 14074100  18334.20
#> 7  Australia   Oceania  1982   74.74 15184200  19477.01
#> 8  Australia   Oceania  1987   76.32 16257249  21888.89
#> 9  Australia   Oceania  1992   77.56 17481977  23424.77
#> 10 Australia   Oceania  1997   78.83 18565243  26997.94
#> ..       ...       ...   ...     ...      ...       ...

# Get the data for worksheet "Oceania": the less-fast tabular way ("list feed")
oceania_list_feed <- gap %>% gs_read_listfeed(ws = "Oceania") 
#> Accessing worksheet titled 'Oceania'.
str(oceania_list_feed)
#> Classes 'tbl_df', 'tbl' and 'data.frame':	24 obs. of  6 variables:
#>  $ country  : chr  "Australia" "Australia" "Australia" "Australia" ...
#>  $ continent: chr  "Oceania" "Oceania" "Oceania" "Oceania" ...
#>  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
#>  $ lifeExp  : num  69.1 70.3 70.9 71.1 71.9 ...
#>  $ pop      : int  8691212 9712569 10794968 11872264 13177000 14074100 15184200 16257249 17481977 18565243 ...
#>  $ gdpPercap: num  10040 10950 12217 14526 16789 ...
oceania_list_feed
#> Source: local data frame [24 x 6]
#> 
#>      country continent  year lifeExp      pop gdpPercap
#>        (chr)     (chr) (int)   (dbl)    (int)     (dbl)
#> 1  Australia   Oceania  1952   69.12  8691212  10039.60
#> 2  Australia   Oceania  1957   70.33  9712569  10949.65
#> 3  Australia   Oceania  1962   70.93 10794968  12217.23
#> 4  Australia   Oceania  1967   71.10 11872264  14526.12
#> 5  Australia   Oceania  1972   71.93 13177000  16788.63
#> 6  Australia   Oceania  1977   73.49 14074100  18334.20
#> 7  Australia   Oceania  1982   74.74 15184200  19477.01
#> 8  Australia   Oceania  1987   76.32 16257249  21888.89
#> 9  Australia   Oceania  1992   77.56 17481977  23424.77
#> 10 Australia   Oceania  1997   78.83 18565243  26997.94
#> ..       ...       ...   ...     ...      ...       ...

# Get the data for worksheet "Oceania": the slow cell-by-cell way ("cell feed")
oceania_cell_feed <- gap %>% gs_read_cellfeed(ws = "Oceania") 
#> Accessing worksheet titled 'Oceania'.
str(oceania_cell_feed)
#> Classes 'tbl_df', 'tbl' and 'data.frame':	150 obs. of  7 variables:
#>  $ cell         : chr  "A1" "B1" "C1" "D1" ...
#>  $ cell_alt     : chr  "R1C1" "R1C2" "R1C3" "R1C4" ...
#>  $ row          : int  1 1 1 1 1 1 2 2 2 2 ...
#>  $ col          : int  1 2 3 4 5 6 1 2 3 4 ...
#>  $ value        : chr  "country" "continent" "year" "lifeExp" ...
#>  $ input_value  : chr  "country" "continent" "year" "lifeExp" ...
#>  $ numeric_value: chr  NA NA NA NA ...
#>  - attr(*, "ws_title")= chr "Oceania"
oceania_cell_feed
#> Source: local data frame [150 x 7]
#> 
#>     cell cell_alt   row   col     value input_value numeric_value
#>    (chr)    (chr) (int) (int)     (chr)       (chr)         (chr)
#> 1     A1     R1C1     1     1   country     country            NA
#> 2     B1     R1C2     1     2 continent   continent            NA
#> 3     C1     R1C3     1     3      year        year            NA
#> 4     D1     R1C4     1     4   lifeExp     lifeExp            NA
#> 5     E1     R1C5     1     5       pop         pop            NA
#> 6     F1     R1C6     1     6 gdpPercap   gdpPercap            NA
#> 7     A2     R2C1     2     1 Australia   Australia            NA
#> 8     B2     R2C2     2     2   Oceania     Oceania            NA
#> 9     C2     R2C3     2     3      1952        1952        1952.0
#> 10    D2     R2C4     2     4     69.12       69.12         69.12
#> ..   ...      ...   ...   ...       ...         ...           ...
```

#### Quick speed comparison

Let's consume all the data for Africa by all 3 methods and see how long it takes.




|          |gs_read_csv  |gs_read_listfeed |gs_read_cellfeed |
|:---------|:------------|:----------------|:----------------|
|user.self |0.040 (1.00) |0.280 (6.39)     |1.620 (36.80)    |
|sys.self  |0.000 (1.00) |0.020 (6.00)     |0.070 (17.00)    |
|elapsed   |0.680 (1.00) |1.280 (1.87)     |2.640 ( 3.87)    |

#### Post-processing data from the cell feed

If you consume data from the cell feed with `gs_read_cellfeed(..., range = ...)`, you get a data.frame back with **one row per cell**. The package offers two functions to post-process this into something more useful:

  * `gs_reshape_cellfeed()`, makes a 2D thing, i.e. a data frame
  * `gs_simplify_cellfeed()` makes a 1D thing, i.e. a vector

Reshaping into a 2D data frame is covered well elsewhere, so here we mostly demonstrate the use of `gs_simplify_cellfeed()`.


```r
## reshape into 2D data frame
gap_3rows <- gap %>% gs_read_cellfeed("Europe", range = cell_rows(1:3))
#> Accessing worksheet titled 'Europe'.
gap_3rows %>% head()
#> Source: local data frame [6 x 7]
#> 
#>    cell cell_alt   row   col     value input_value numeric_value
#>   (chr)    (chr) (int) (int)     (chr)       (chr)         (chr)
#> 1    A1     R1C1     1     1   country     country            NA
#> 2    B1     R1C2     1     2 continent   continent            NA
#> 3    C1     R1C3     1     3      year        year            NA
#> 4    D1     R1C4     1     4   lifeExp     lifeExp            NA
#> 5    E1     R1C5     1     5       pop         pop            NA
#> 6    F1     R1C6     1     6 gdpPercap   gdpPercap            NA
gap_3rows %>% gs_reshape_cellfeed()
#> Source: local data frame [2 x 6]
#> 
#>   country continent  year lifeExp     pop gdpPercap
#>     (chr)     (chr) (int)   (dbl)   (int)     (dbl)
#> 1 Albania    Europe  1952   55.23 1282697  1601.056
#> 2 Albania    Europe  1957   59.28 1476505  1942.284

# Example: first row only
gap_1row <- gap %>% gs_read_cellfeed("Europe", range = cell_rows(1))
#> Accessing worksheet titled 'Europe'.
gap_1row
#> Source: local data frame [6 x 7]
#> 
#>    cell cell_alt   row   col     value input_value numeric_value
#>   (chr)    (chr) (int) (int)     (chr)       (chr)         (chr)
#> 1    A1     R1C1     1     1   country     country            NA
#> 2    B1     R1C2     1     2 continent   continent            NA
#> 3    C1     R1C3     1     3      year        year            NA
#> 4    D1     R1C4     1     4   lifeExp     lifeExp            NA
#> 5    E1     R1C5     1     5       pop         pop            NA
#> 6    F1     R1C6     1     6 gdpPercap   gdpPercap            NA

# convert to a named (character) vector
gap_1row %>% gs_simplify_cellfeed()
#>          A1          B1          C1          D1          E1          F1 
#>   "country" "continent"      "year"   "lifeExp"       "pop" "gdpPercap"

# Example: single column
gap_1col <- gap %>% gs_read_cellfeed("Europe", range = cell_cols(3))
#> Accessing worksheet titled 'Europe'.
gap_1col
#> Source: local data frame [361 x 7]
#> 
#>     cell cell_alt   row   col value input_value numeric_value
#>    (chr)    (chr) (int) (int) (chr)       (chr)         (chr)
#> 1     C1     R1C3     1     3  year        year            NA
#> 2     C2     R2C3     2     3  1952        1952        1952.0
#> 3     C3     R3C3     3     3  1957        1957        1957.0
#> 4     C4     R4C3     4     3  1962        1962        1962.0
#> 5     C5     R5C3     5     3  1967        1967        1967.0
#> 6     C6     R6C3     6     3  1972        1972        1972.0
#> 7     C7     R7C3     7     3  1977        1977        1977.0
#> 8     C8     R8C3     8     3  1982        1982        1982.0
#> 9     C9     R9C3     9     3  1987        1987        1987.0
#> 10   C10    R10C3    10     3  1992        1992        1992.0
#> ..   ...      ...   ...   ...   ...         ...           ...

# drop the `year` variable name, convert to integer, return un-named vector
yr <- gap_1col %>% gs_simplify_cellfeed(notation = "none")
str(yr)
#>  int [1:360] 1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
```

#### Controlling data ingest, theory

`googlesheets` provides control of data ingest in the style of [`readr`](http://cran.r-project.org/package=readr). Some arguments are passed straight through to `readr::read_csv()` or `readr::type_convert()` and others are used internally by `googlesheets`, hopefully in the same way!

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
  * Read the [`readr` vignette on column types](https://cran.r-project.org/web/packages/readr/vignettes/column-types.html) to better understand the automatic variable conversion behavior and how to use the `col_types` argument to override it.
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
#> Source: local data frame [4 x 3]
#> 
#>   thing1 thing2 thing3
#>    (chr)  (chr)  (chr)
#> 1     A2      *     C2
#> 2    #A3     B3     C3
#> 3     A4     B4     C4
#> 4     A5     B5     C5

ss <- gs_new("data-ingest-practice", ws_title = "simple",
             input = df, trim = TRUE) %>% 
  gs_ws_new("one-blank-row", input = df, trim = TRUE, anchor = "A2") %>% 
  gs_ws_new("two-blank-rows", input = df, trim = TRUE, anchor = "A3")
#> Sheet "data-ingest-practice" created in Google Drive.
#> Worksheet "Sheet1" renamed to "simple".
#> Range affected by the update: "A1:C5"
#> Worksheet "simple" successfully updated with 15 new value(s).
#> Accessing worksheet titled 'simple'.
#> Sheet successfully identified: "data-ingest-practice"
#> Accessing worksheet titled 'simple'.
#> Worksheet "simple" dimensions changed to 5 x 3.
#> Worksheet dimensions: 5 x 3.
#> Worksheet "one-blank-row" added to sheet "data-ingest-practice".
#> Range affected by the update: "A2:C6"
#> Worksheet "one-blank-row" successfully updated with 15 new value(s).
#> Accessing worksheet titled 'one-blank-row'.
#> Sheet successfully identified: "data-ingest-practice"
#> Accessing worksheet titled 'one-blank-row'.
#> Worksheet "one-blank-row" dimensions changed to 6 x 3.
#> Worksheet dimensions: 6 x 3.
#> Worksheet "two-blank-rows" added to sheet "data-ingest-practice".
#> Range affected by the update: "A3:C7"
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
#> No encoding supplied: defaulting to UTF-8.
#> Source: local data frame [4 x 3]
#> 
#>      X1    X2    X3
#>   (chr) (chr) (chr)
#> 1    A2     *    C2
#> 2   #A3    B3    C3
#> 3    A4    B4    C4
#> 4    A5    B5    C5
ss %>% gs_read(col_names = letters[1:3], skip = 1)
#> Accessing worksheet titled 'simple'.
#> No encoding supplied: defaulting to UTF-8.
#> Source: local data frame [4 x 3]
#> 
#>       a     b     c
#>   (chr) (chr) (chr)
#> 1    A2     *    C2
#> 2   #A3    B3    C3
#> 3    A4    B4    C4
#> 4    A5    B5    C5

## explicitly use gs_read_listfeed
ss %>% gs_read_listfeed(col_names = FALSE, skip = 1)
#> Accessing worksheet titled 'simple'.
#> Source: local data frame [4 x 3]
#> 
#>      X1    X2    X3
#>   (chr) (chr) (chr)
#> 1    A2     *    C2
#> 2   #A3    B3    C3
#> 3    A4    B4    C4
#> 4    A5    B5    C5

## use range to force use of gs_read_cellfeed
ss %>% gs_read_listfeed(col_names = FALSE, skip = 1, range = cell_cols("A:Z"))
#> Accessing worksheet titled 'simple'.
#> Source: local data frame [4 x 3]
#> 
#>      X1    X2    X3
#>   (chr) (chr) (chr)
#> 1    A2     *    C2
#> 2   #A3    B3    C3
#> 3    A4    B4    C4
#> 4    A5    B5    C5
```

Read from the worksheet with a blank row at the top. Start to play with some other ingest arguments.

![top-filler](img/not-so-simple-ingest.png)


```r
## blank row causes variable names to show up in the data frame :(
ss %>% gs_read(ws = "one-blank-row")
#> Accessing worksheet titled 'one-blank-row'.
#> No encoding supplied: defaulting to UTF-8.
#> Source: local data frame [5 x 3]
#> 
#>       X1     X2     X3
#>    (chr)  (chr)  (chr)
#> 1 thing1 thing2 thing3
#> 2     A2      *     C2
#> 3    #A3     B3     C3
#> 4     A4     B4     C4
#> 5     A5     B5     C5

## skip = 1 fixes it :)
ss %>% gs_read(ws = "one-blank-row", skip = 1)
#> Accessing worksheet titled 'one-blank-row'.
#> No encoding supplied: defaulting to UTF-8.
#> Source: local data frame [4 x 3]
#> 
#>   thing1 thing2 thing3
#>    (chr)  (chr)  (chr)
#> 1     A2      *     C2
#> 2    #A3     B3     C3
#> 3     A4     B4     C4
#> 4     A5     B5     C5

## more arguments, more better
ss %>% gs_read(ws = "one-blank-row", skip = 2,
               col_names = paste0("yo ?!*", 1:3), check.names = TRUE,
               na = "*", comment = "#", n_max = 2)
#> Accessing worksheet titled 'one-blank-row'.
#> No encoding supplied: defaulting to UTF-8.
#> Source: local data frame [2 x 3]
#> 
#>   yo....1 yo....2 yo....3
#>     (chr)   (chr)   (chr)
#> 1      A2      NA      C2
#> 2      A4      B4      C4

## also works on list feed
ss %>% gs_read_listfeed(ws = "one-blank-row", skip = 2,
                        col_names = paste0("yo ?!*", 1:3), check.names = TRUE,
                        na = "*", comment = "#", n_max = 2)
#> Accessing worksheet titled 'one-blank-row'.
#> Source: local data frame [2 x 3]
#> 
#>   yo....1 yo....2 yo....3
#>     (chr)   (chr)   (chr)
#> 1      A2      NA      C2
#> 2      A4      B4      C4

## also works on the cell feed
ss %>% gs_read_listfeed(ws = "one-blank-row", range = cell_cols("A:Z"), skip = 2,
                        col_names = paste0("yo ?!*", 1:3), check.names = TRUE,
                        na = "*", comment = "#", n_max = 2)
#> Accessing worksheet titled 'one-blank-row'.
#> Source: local data frame [2 x 3]
#> 
#>   yo....1 yo....2 yo....3
#>     (chr)   (chr)   (chr)
#> 1      A2      NA      C2
#> 2      A4      B4      C4
```

Finally, we read from the worksheet with TWO blank rows at the top, which is more than the list feed can handle.


```r
## use skip to get correct result via gs_read() --> gs_read_csv()
ss %>% gs_read(ws = "two-blank-rows", skip = 2)
#> Accessing worksheet titled 'two-blank-rows'.
#> No encoding supplied: defaulting to UTF-8.
#> Source: local data frame [4 x 3]
#> 
#>   thing1 thing2 thing3
#>    (chr)  (chr)  (chr)
#> 1     A2      *     C2
#> 2    #A3     B3     C3
#> 3     A4     B4     C4
#> 4     A5     B5     C5

## or use range in gs_read() --> gs_read_cellfeed() + gs_reshape_cellfeed()
ss %>% gs_read(ws = "two-blank-rows", range = cell_limits(c(3, NA), c(NA, NA)))
#> Accessing worksheet titled 'two-blank-rows'.
#> Source: local data frame [4 x 3]
#> 
#>   thing1 thing2 thing3
#>    (chr)  (chr)  (chr)
#> 1     A2      *     C2
#> 2    #A3     B3     C3
#> 3     A4     B4     C4
#> 4     A5     B5     C5
ss %>% gs_read(ws = "two-blank-rows", range = cell_cols("A:C"))
#> Accessing worksheet titled 'two-blank-rows'.
#> Source: local data frame [4 x 3]
#> 
#>   thing1 thing2 thing3
#>    (chr)  (chr)  (chr)
#> 1     A2      *     C2
#> 2    #A3     B3     C3
#> 3     A4     B4     C4
#> 4     A5     B5     C5

## list feed can't cope because the 1st data row is empty
ss %>% gs_read_listfeed(ws = "two-blank-rows")
#> Accessing worksheet titled 'two-blank-rows'.
#> Worksheet 'two-blank-rows' is empty.
#> Source: local data frame [0 x 0]
ss %>% gs_read_listfeed(ws = "two-blank-rows", skip = 2)
#> Accessing worksheet titled 'two-blank-rows'.
#> Worksheet 'two-blank-rows' is empty.
#> Source: local data frame [0 x 0]
```

Let's clean up after ourselves.


```r
gs_delete(ss)
#> Success. "data-ingest-practice" moved to trash in Google Drive.
```


### Create sheets

You can use `googlesheets` to create new spreadsheets.


```r
foo <- gs_new("foo")
#> Sheet "foo" created in Google Drive.
#> Worksheet dimensions: 1000 x 26.
foo
#>                   Spreadsheet title: foo
#>                  Spreadsheet author: gspreadr
#>   Date of googlesheets registration: 2016-03-15 21:58:21 GMT
#>     Date of last spreadsheet update: 2016-03-15 21:58:20 GMT
#>                          visibility: private
#>                         permissions: rw
#>                             version: new
#> 
#> Contains 1 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> Sheet1: 1000 x 26
#> 
#> Key: 1qfXH28X0kuXPRvT0XgIGqGJuFlhUT-iaxHi1n4Rtv1w
#> Browser URL: https://docs.google.com/spreadsheets/d/1qfXH28X0kuXPRvT0XgIGqGJuFlhUT-iaxHi1n4Rtv1w/
```

*Note how we store the returned value from `gs_new()` (and all other sheet editing functions). That's because the registration info changes whenever we edit the sheet and we re-register it inside these functions, so this idiom will help you make sequential edits and queries to the same sheet.*

By default, there will be an empty worksheet called "Sheet1", but you can control its title, extent, and initial data with additional arguments to `gs_new()` (see `gs_edit_cells()` in the next section). You can also add, rename, and delete worksheets within an existing sheet via `gs_ws_new()`, `gs_ws_rename()`, and `gs_ws_delete()`. Copy an entire spreadsheet with `gs_copy()` and rename one with `gs_rename()`.

### Edit cells

*Note how we continue to store the returned value from `gs_edit_cells()`. This workflow keeps the local registration info about the sheet up-to-date.*

There are two ways to edit cells within an existing worksheet of an existing spreadsheet:

  * `gs_edit_cells()` can write into an arbitrary cell rectangle
  * `gs_add_row()` can add a new row to the bottom of an existing cell rectangle
  
If you have the choice, `gs_add_row()` is faster, but it can only be used when your data occupies a very neat rectangle in the upper left corner of the sheet. It relies on the [list feed](https://developers.google.com/google-apps/spreadsheets/#working_with_list-based_feeds). `gs_edit_cells()` relies on [batch editing](https://developers.google.com/google-apps/spreadsheets/#updating_multiple_cells_with_a_batch_request) on the [cell feed](https://developers.google.com/google-apps/spreadsheets/#working_with_cell-based_feeds).

We'll work within the completely empty sheet created above, `foo`. If your edit populates the sheet with everything it should have, set `trim = TRUE` and we will resize the sheet to match the data. Then the nominal worksheet extent is much more informative (vs. the default of 1000 rows and 26 columns) and future consumption via the cell feed will potentially be faster.


```r
## foo <- gs_new("foo")
## initialize the worksheets
foo <- foo %>% gs_ws_new("edit_cells")
#> Worksheet "edit_cells" added to sheet "foo".
#> Worksheet dimensions: 1000 x 26.
foo <- foo %>% gs_ws_new("add_row")
#> Worksheet "add_row" added to sheet "foo".
#> Worksheet dimensions: 1000 x 26.

## add first six rows of iris data (and var names) into a blank sheet
foo <- foo %>%
  gs_edit_cells(ws = "edit_cells", input = head(iris), trim = TRUE)
#> Range affected by the update: "A1:E7"
#> Worksheet "edit_cells" successfully updated with 35 new value(s).
#> Accessing worksheet titled 'edit_cells'.
#> Sheet successfully identified: "foo"
#> Accessing worksheet titled 'edit_cells'.
#> Worksheet "edit_cells" dimensions changed to 7 x 5.

## initialize sheet with column headers and one row of data
## the list feed is picky about this
foo <- foo %>% 
  gs_edit_cells(ws = "add_row", input = head(iris, 1), trim = TRUE)
#> Range affected by the update: "A1:E2"
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

## let's inspect out work
foo %>% gs_read(ws = "edit_cells")
#> Accessing worksheet titled 'edit_cells'.
#> No encoding supplied: defaulting to UTF-8.
#> Source: local data frame [6 x 5]
#> 
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          (dbl)       (dbl)        (dbl)       (dbl)   (chr)
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
#> 5          5.0         3.6          1.4         0.2  setosa
#> 6          5.4         3.9          1.7         0.4  setosa
foo %>% gs_read(ws = "add_row")
#> Accessing worksheet titled 'add_row'.
#> No encoding supplied: defaulting to UTF-8.
#> Source: local data frame [6 x 5]
#> 
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          (dbl)       (dbl)        (dbl)       (dbl)   (chr)
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
#> 5          5.0         3.6          1.4         0.2  setosa
#> 6          5.4         3.9          1.7         0.4  setosa
```

Go to [your Google Sheets home screen](https://docs.google.com/spreadsheets/u/0/), find the new sheet `foo` and look at it. You should see some iris data in the worksheets named `edit_cells` and `add_row`. You could also use `gs_browse()` to take you directly to those worksheets.


```r
gs_browse(foo, ws = "edit_cells")
gs_browse(foo, ws = "add_row")
```

Read the function documentation for `gs_edit_cells()` for how to specify where the data goes, via an anchor cell, and in which direction, via the shape of the input or the `byrow =` argument.

### Delete sheets

Let's clean up by deleting the `foo` spreadsheet we've been playing with.


```r
gs_delete(foo)
#> Success. "foo" moved to trash in Google Drive.
```

If you'd rather specify sheets for deletion by title, look at `gs_grepdel()` and `gs_vecdel()`. These functions also allow the deletion of multiple sheets at once.

### Upload delimited files or Excel workbooks

Here's how we can create a new spreadsheet from a suitable local file. First, we'll write then upload a comma-delimited excerpt from the iris data.


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
#>   Date of googlesheets registration: 2016-03-15 21:58:58 GMT
#>     Date of last spreadsheet update: 2016-03-15 21:58:55 GMT
#>                          visibility: private
#>                         permissions: rw
#>                             version: new
#> 
#> Contains 1 worksheets:
#> (Title): (Nominal worksheet extent as rows x columns)
#> iris: 1000 x 26
#> 
#> Key: 1Q12sZh6QXsfCMqjzCyv8M0QXukjVysTTtoYAgJ4d1Oc
#> Browser URL: https://docs.google.com/spreadsheets/d/1Q12sZh6QXsfCMqjzCyv8M0QXukjVysTTtoYAgJ4d1Oc/
iris_ss %>% gs_read()
#> Accessing worksheet titled 'iris'.
#> No encoding supplied: defaulting to UTF-8.
#> Source: local data frame [5 x 5]
#> 
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          (dbl)       (dbl)        (dbl)       (dbl)   (chr)
#> 1          5.1         3.5          1.4         0.2  setosa
#> 2          4.9         3.0          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4          4.6         3.1          1.5         0.2  setosa
#> 5          5.0         3.6          1.4         0.2  setosa
file.remove("iris.csv")
#> [1] TRUE
```

Now we'll upload a multi-sheet Excel workbook. Slowly.


```r
gap_xlsx <- gs_upload(system.file("mini-gap.xlsx", package = "googlesheets"))
#> File uploaded to Google Drive:
#> /Users/jenny/rrr/googlesheets/inst/mini-gap.xlsx
#> As the Google Sheet named:
#> mini-gap
gap_xlsx
#>                   Spreadsheet title: mini-gap
#>                  Spreadsheet author: gspreadr
#>   Date of googlesheets registration: 2016-03-15 21:59:02 GMT
#>     Date of last spreadsheet update: 2016-03-15 21:59:00 GMT
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
#> Key: 19hgxEAHquVjk8a84tKtHHBb51PtcZFgbXpQq9Ih7Hpw
#> Browser URL: https://docs.google.com/spreadsheets/d/19hgxEAHquVjk8a84tKtHHBb51PtcZFgbXpQq9Ih7Hpw/
gap_xlsx %>% gs_read(ws = "Asia")
#> Accessing worksheet titled 'Asia'.
#> No encoding supplied: defaulting to UTF-8.
#> Source: local data frame [5 x 6]
#> 
#>       country continent  year lifeExp       pop gdpPercap
#>         (chr)     (chr) (int)   (dbl)     (int)     (dbl)
#> 1 Afghanistan      Asia  1952  28.801   8425333  779.4453
#> 2     Bahrain      Asia  1952  50.939    120447 9867.0848
#> 3  Bangladesh      Asia  1952  37.484  46886859  684.2442
#> 4    Cambodia      Asia  1952  39.417   4693836  368.4693
#> 5       China      Asia  1952  44.000 556263527  400.4486
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

### Download sheets as csv, pdf, or xlsx file

You can download a Google Sheet as a csv, pdf, or xlsx file. Downloading the spreadsheet as a csv file will export the first worksheet (default) unless another worksheet is specified.


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
#>           displayName: google sheets
#>          emailAddress: gspreadr@gmail.com
#>                  date: 2016-03-15 21:57:23 GMT
#>          access token: valid
#>  peek at access token: ya29....V8u2M
#> peek at refresh token: 1/LxW...4wRNU
user_session_info
#> $displayName
#> [1] "google sheets"
#> 
#> $emailAddress
#> [1] "gspreadr@gmail.com"
#> 
#> $date
#> [1] "2016-03-15 21:57:23 GMT"
#> 
#> $token_valid
#> [1] TRUE
#> 
#> $peek_acc
#> [1] "ya29....V8u2M"
#> 
#> $peek_ref
#> [1] "1/LxW...4wRNU"
```

### "Old" Google Sheets

In March 2014 [Google introduced "new" Sheets](https://support.google.com/docs/answer/3541068?hl=en). "New" Sheets and "old" sheets behave quite differently with respect to access via API and present a big headache for us. In 2015, Google started forcibly converting sheets: [all "old" Sheets will be switched over the "new" sheets during 2015](https://support.google.com/docs/answer/6082736?p=new_sheets_migrate&rd=1). For a while, there were still "old" sheets lying around, so we've made some effort to support them, when it's easy to do so. But keep your expectations low. You can expect what little support there is to go away in the next version of `googlesheets`.

`gs_read_csv()` does not work for "old" sheets. Nor will it ever.
