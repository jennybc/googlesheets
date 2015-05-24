# Playing with readxl


```r
suppressPackageStartupMessages(library("dplyr"))
library("readxl")
library("googlesheets")
```



I'm about to rework our data consumption functions and want to keep the `readxl` UI in mind.


```r
mini_gap <-
  read_excel(system.file("mini-gap.xlsx", package = "googlesheets"))
str(mini_gap)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	5 obs. of  6 variables:
##  $ country  : chr  "Albania" "Austria" "Belgium" "Bosnia and Herzegovina" ...
##  $ continent: chr  "Europe" "Europe" "Europe" "Europe" ...
##  $ year     : num  1952 1952 1952 1952 1952
##  $ lifeExp  : num  55.2 66.8 68 53.8 59.6
##  $ pop      : num  1282697 6927772 8730405 2791000 7274900
##  $ gdpPercap: num  1601 6137 8343 974 2444
```

The `sheet` argument: "Sheet to read. Either a string (the name of a sheet), or an integer (the position of the sheet). Defaults to the first sheet."

*Note: at the moment, the sheet argument and this sheet don't play nicely together, i.e. I'm getting Europe above but should be getting Africa. Let's just pretend this isn't happening and do our thing anyway.*


```r
mini_gap <-
  read_excel(system.file("mini-gap.xlsx", package = "googlesheets"),
             sheet = 3)
str(mini_gap)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	5 obs. of  6 variables:
##  $ country  : chr  "Argentina" "Bolivia" "Brazil" "Canada" ...
##  $ continent: chr  "Americas" "Americas" "Americas" "Americas" ...
##  $ year     : num  1952 1952 1952 1952 1952
##  $ lifeExp  : num  62.5 40.4 50.9 68.8 54.7
##  $ pop      : num  17876956 2883315 56602560 14785584 6377619
##  $ gdpPercap: num  5911 2677 2109 11367 3940
```

The `col_names` argument:  "Either TRUE to use the first row as column names, FALSE to number columns sequentially from X1 to Xn, or a character vector giving a name for each column."


```r
mini_gap <-
  read_excel(system.file("mini-gap.xlsx", package = "googlesheets"),
             col_names = FALSE)
str(mini_gap)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	6 obs. of  6 variables:
##  $ X0: chr  "country" "Albania" "Austria" "Belgium" ...
##  $ X1: chr  "continent" "Europe" "Europe" "Europe" ...
##  $ X2: chr  "year" "1952.0" "1952.0" "1952.0" ...
##  $ X3: chr  "lifeExp" "55.23" "66.8" "68.0" ...
##  $ X4: chr  "pop" "1282697.0" "6927772.0" "8730405.0" ...
##  $ X5: chr  "gdpPercap" "1601.0561" "6137.0765" "8343.1051" ...
```

```r
mini_gap <-
  read_excel(system.file("mini-gap.xlsx", package = "googlesheets"),
             col_names = paste0("yo", 1:6))
str(mini_gap)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	6 obs. of  6 variables:
##  $ yo1: chr  "country" "Albania" "Austria" "Belgium" ...
##  $ yo2: chr  "continent" "Europe" "Europe" "Europe" ...
##  $ yo3: chr  "year" "1952.0" "1952.0" "1952.0" ...
##  $ yo4: chr  "lifeExp" "55.23" "66.8" "68.0" ...
##  $ yo5: chr  "pop" "1282697.0" "6927772.0" "8730405.0" ...
##  $ yo6: chr  "gdpPercap" "1601.0561" "6137.0765" "8343.1051" ...
```

The `col_types` argument:  "Either NULL to guess from the spreadsheet or a character vector containing "blank", "numeric", "date" or "text"."


```r
mini_gap <-
  read_excel(system.file("mini-gap.xlsx", package = "googlesheets"),
             col_types = c("text", "text", "text", "numeric", "numeric", "numeric"))
str(mini_gap)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	5 obs. of  6 variables:
##  $ country  : chr  "Albania" "Austria" "Belgium" "Bosnia and Herzegovina" ...
##  $ continent: chr  "Europe" "Europe" "Europe" "Europe" ...
##  $ year     : chr  "1952.0" "1952.0" "1952.0" "1952.0" ...
##  $ lifeExp  : num  55.2 66.8 68 53.8 59.6
##  $ pop      : num  1282697 6927772 8730405 2791000 7274900
##  $ gdpPercap: num  1601 6137 8343 974 2444
```

The `na` argument:  "Missing value. By default readxl converts blank cells to missing data. Set this value if you have used a sentinel value for missing values."

*Note: hard to demo with mini-gap, skipping.*

The `skip` argument:  "Number of rows to skip before reading any data."


```r
mini_gap <-
  read_excel(system.file("mini-gap.xlsx", package = "googlesheets"),
             skip = 3, col_names = FALSE)
str(mini_gap)
```

```
## Classes 'tbl_df', 'tbl' and 'data.frame':	3 obs. of  6 variables:
##  $ X0: chr  "Belgium" "Bosnia and Herzegovina" "Bulgaria"
##  $ X1: chr  "Europe" "Europe" "Europe"
##  $ X2: num  1952 1952 1952
##  $ X3: num  68 53.8 59.6
##  $ X4: num  8730405 2791000 7274900
##  $ X5: num  8343 974 2444
```
