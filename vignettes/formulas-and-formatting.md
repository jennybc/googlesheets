# Dealing with formulas and formatted numbers
Jenny Bryan  
`r Sys.Date()`  





### Preliminaries

Load `googlesheets` and `dplyr`, from which we use the `%>%` pipe operator and which gives us nicer printing of data frames (`tbl_df`s)


```r
library(googlesheets)
#devtools::load_all()
suppressMessages(library(dplyr))
```



### Different notions of cell contents

When working with Google Sheets via [the cell feed](https://developers.google.com/google-apps/spreadsheets/data#work_with_cell-based_feeds), there are three ways to define cell contents:

  * **Literal value.** This is what hits your eyeballs when you view a Sheet in the browser. It's what `googlesheets` returns by default, because it's what the API returns by default.
    - API docs: "The literal value of the cell element is the calculated value of the cell, without formatting applied. If the cell contains a formula, the calculated value is given here. The Sheets API has no concept of formatting, and thus cannot manipulate formatting of cells."
    - Google describes this as "the calculated value of the cell, without formatting applied" but that is misleading. The only formatting they mean to exclude here is decorative stuff, e.g., font size or cell background color. **Numeric formatting is very much in force**.
    - If cell contains a formula, this is the calculated result. Examples: an average of some other cells, a live hyperlink specified via `=HYPERLINK()`, an image specified via `=IMAGE()`.
    - If cell contains formatted numeric data, this is the formatted result. Examples: 2.35E+05, 12.34%, $112.03.
    - If cell contains a formatted numeric formula, this is the calculated, formatted result.
  * **Input value.** This is what was entered in the cell, with one gotcha.
    - API docs: "The `inputValue` attribute of a cell entry always contains the value that a user would otherwise type into the Google Sheets user interface to manipulate the cell (i.e. either a literal value or a formula)."
    - If cell contains a formula, this is the formula. If cell contains a string, this is the string. Easy.
    - If cell contains a number, this *generally* contains the number. Exception: a number formatted as a percentage. In this case Google assumes you know the spreadsheet data entry trick in which you type `0.12345%` to simultaneously enter the numeric value 0.12345 and format it as a percentage. Therefore, the numeric value 0.12345 will have input value `0.12345%` if formatted as a percentage and 0.12345 otherwise. Why, Google, why?
    - Empirically, input value seems to be what is displayed in the formula bar to the right of the $f_{x}$ when you visit a cell in the browser.
  * **Numeric value.**
    - API docs: "The `numericValue` attribute of a cell entry, when present, indicates that the cell was determined to have a numeric value, and its numeric value is indicated with this attributed."
    - If cell contains a number, this is that number.
    - If cell contains a numeric formula, this is the calculated numeric result.
    - Otherwise, the `numericValue` attribute doesn't even exist in the underlying XML and it will be an `NA` in any object `googlesheets` creates from reading the Sheet.

#### Vocabulary: there's formatting and then there's *formatting*

Click on the Format menu in Google Sheets and you'll gain access to a "Number" sub-menu and ... lots of other stuff. Let's agree that "formatting" can mean two different things:

  * Decoration. Font, font size, font color, bold, italic, cell background, text alignment, etc.
  * Numeric formatting. Meaning this:
    - UNformatted: 123456 or 32.61 or 0.53
    - Formatted: 123,456 or $32.61 or 53%

Decorative formatting is completely invisible to the Sheets API. It is also a terrible idea to encode data in decorative formatting, though it can be used to visually reinforce information that is properly stored in data (Google Sheets is capable of [conditional formatting](https://support.google.com/docs/answer/78413?hl=en)). Nothing in `googlesheets` or the rest of this vignette addresses decorative formatting. We shall not speak of it again. From now on, "formatting" means numeric formatting.

### A worthy challenge

We've created a formula and formatting ~~nightmare~~ sampler Sheet. [Go visit it in the browser!](https://w3id.org/people/jennybc/googlesheets_ff_url). Or check out this screenshot.

![gs-test-formula-formatting-screenshot](img/gs-test-formula-formatting-screenshot.png)

It's one of the built-in example sheets. Access it with various functions that start with `gs_ff`.

Let's read it in the usual ways, confirming we get "literal values", that we get them uniformly across all read methods that return data frame, and that it matches `readr::read_csv()`.


```r
ff <- gs_ff()
(ff_read_csv <- gs_read_csv(ff))
#> Accessing worksheet titled 'Sheet1'.
#> No encoding supplied: defaulting to UTF-8.
#> Source: local data frame [5 x 6]
#> 
#>   number number_formatted number_rounded character      formula
#>    (int)            (chr)          (dbl)     (chr)        (chr)
#> 1 123456          654,321           1.23       one       Google
#> 2 345678           12.34%           2.35        NA 1,271,591.00
#> 3 234567         1.23E+09           3.46     three           NA
#> 4     NA            3 1/7           4.57      four         $A$1
#> 5 567890            $0.36           5.68      five           NA
#> Variables not shown: formula_formatted (chr).
(ff_read_list <- gs_read_listfeed(ff))
#> Accessing worksheet titled 'Sheet1'.
#> Source: local data frame [5 x 6]
#> 
#>   number number_formatted number_rounded character      formula
#>    (int)            (chr)          (dbl)     (chr)        (chr)
#> 1 123456          654,321           1.23       one       Google
#> 2 345678           12.34%           2.35        NA 1,271,591.00
#> 3 234567         1.23E+09           3.46     three           NA
#> 4     NA            3 1/7           4.57      four         $A$1
#> 5 567890            $0.36           5.68      five           NA
#> Variables not shown: formula_formatted (chr).
(ff_read_cell <- gs_read(ff, range = "A1:F6"))
#> Accessing worksheet titled 'Sheet1'.
#> Source: local data frame [5 x 6]
#> 
#>   number number_formatted number_rounded character      formula
#>    (int)            (chr)          (dbl)     (chr)        (chr)
#> 1 123456          654,321           1.23       one       Google
#> 2 345678           12.34%           2.35        NA 1,271,591.00
#> 3 234567         1.23E+09           3.46     three           NA
#> 4     NA            3 1/7           4.57      four         $A$1
#> 5 567890            $0.36           5.68      five           NA
#> Variables not shown: formula_formatted (chr).
(ff_download_csv <-
  gs_download(ff, to = "gs-test-formula-formatting.csv", overwrite = TRUE) %>% 
  readr::read_csv())
#> Sheet successfully downloaded:
#> /Users/jenny/rrr/googlesheets/vignettes/gs-test-formula-formatting.csv
#> Source: local data frame [5 x 6]
#> 
#>   number number_formatted number_rounded character      formula
#>    (int)            (chr)          (dbl)     (chr)        (chr)
#> 1 123456          654,321           1.23       one       Google
#> 2 345678           12.34%           2.35        NA 1,271,591.00
#> 3 234567         1.23E+09           3.46     three           NA
#> 4     NA            3 1/7           4.57      four         $A$1
#> 5 567890            $0.36           5.68      five           NA
#> Variables not shown: formula_formatted (chr).
identical(ff_read_csv, ff_read_list)
#> [1] TRUE
identical(ff_read_csv, ff_read_cell)
#> [1] TRUE
identical(ff_read_csv, ff_download_csv)
#> [1] TRUE
## YEESSSSSSS
```

What have we confirmed? That existing ways to read Sheets return the **literal values**.

What if you want unformatted numbers? What if you want the actual formulas? You must use the cell feed, which, in `googlesheets`, means you must use `gs_read_cellfeed()`.

### The cell feed

The Sheet reading done above -- via `gs_read_csv()`, `gs_read_list()`, and `gs_download(..., to = "foo.csv")` + csv import -- all assume that the data occupies a neat rectangle in the upper left corner, that you want all of it, and that you want the literal values.

What if you need more control over which cells? What if you want input or numeric values? Use the cell feed via `gs_read_cellfeed()`. This is what is happening under the hood when a cell range is provided to `gs_read()`, i.e. when the call is like `gs_read(..., range = "B4:D9")` or `gs_read(..., range = cell_cols(4:6))`.

Let's play with a modified version of `gs_read_cellfeed()`. As before, we return a data frame with one row per cell, but now we return all 3 notions of cell contents:

  * `literal_value`: The variable previously known as `cell_text`. What you see in the browser and what is returned by all other methods of reading.
  * `input_value`: What you would have typed into the cell (if you are a total spreadsheet nerd, when it comes to percentages).
  * `numeric_value`: The actual number, if such exists.


```r
cf <- gs_read_cellfeed(ff)
#> Accessing worksheet titled 'Sheet1'.
cf_printme <- cf %>%
  arrange(col, row) %>%
  select(cell, literal_value, input_value, numeric_value)
```

Putting the screenshot in before and after the table of the cell contents, for my own convenience.

![gs-test-formula-formatting-screenshot](img/gs-test-formula-formatting-screenshot.png)


|cell |literal_value     |input_value                                             |numeric_value       |
|:----|:-----------------|:-------------------------------------------------------|:-------------------|
|A1   |number            |number                                                  |NA                  |
|A2   |123456            |123456                                                  |123456.0            |
|A3   |345678            |345678                                                  |345678.0            |
|A4   |234567            |234567                                                  |234567.0            |
|A6   |567890            |567890                                                  |567890.0            |
|B1   |number_formatted  |number_formatted                                        |NA                  |
|B2   |654,321           |654321                                                  |654321.0            |
|B3   |12.34%            |12.34%                                                  |0.1234              |
|B4   |1.23E+09          |1234567890                                              |1.23456789E9        |
|B5   |3 1/7             |3.14159265359                                           |3.14159265359       |
|B6   |$0.36             |0.36                                                    |0.36                |
|C1   |number_rounded    |number_rounded                                          |NA                  |
|C2   |1.23              |1.2345                                                  |1.2345              |
|C3   |2.35              |2.3456                                                  |2.3456              |
|C4   |3.46              |3.4567                                                  |3.4567              |
|C5   |4.57              |4.5678                                                  |4.5678              |
|C6   |5.68              |5.6789                                                  |5.6789              |
|D1   |character         |character                                               |NA                  |
|D2   |one               |one                                                     |NA                  |
|D4   |three             |three                                                   |NA                  |
|D5   |four              |four                                                    |NA                  |
|D6   |five              |five                                                    |NA                  |
|E1   |formula           |formula                                                 |NA                  |
|E2   |Google            |=HYPERLINK("http://www.google.com/","Google")           |NA                  |
|E3   |1,271,591.00      |=sum(R[-1]C[-4]:R[3]C[-4])                              |1271591.0           |
|E4   |                  |=IMAGE("https://www.google.com/images/srpr/logo3w.png") |NA                  |
|E5   |$A$1              |=ADDRESS(1,1)                                           |NA                  |
|E6   |                  |=SPARKLINE(R[-4]C[-4]:R[0]C[-4])                        |NA                  |
|F1   |formula_formatted |formula_formatted                                       |NA                  |
|F2   |3.18E+05          |=average(R[0]C[-5]:R[4]C[-5])                           |317897.75           |
|F3   |52.63%            |=R[-1]C[-5]/R[1]C[-5]                                   |0.5263144432081239  |
|F4   |0.22              |=R[-2]C[-5]/R[2]C[-5]                                   |0.21739421366813996 |
|F5   |123,456.00        |=min(R[-3]C[-5]:R[1]C[-5])                              |123456.0            |
|F6   |317,898           |=average(R2C1:R6C1)                                     |317897.75           |

![gs-test-formula-formatting-screenshot](img/gs-test-formula-formatting-screenshot.png)

### Proposed uses of the new cell contents

Consider a formatted numeric column. In some cases, the existing read methods will return character when really they should not. What is the right way to offer user the option of populating that column with `numeric_value` and getting a proper numeric variable?

Proposed logic for optionally redefining cell contents, prior to reshaping/simplification and type conversion:

  * If there is no numeric value, take the literal value. If there is ... take numeric value instead. Except when that would make an integers look like a double. In that case, take input value.

Anyone who wants formulas = `input_value` can work directly with cell feed and doesn't get reshaping. I don't think they would want it anyway?

Exploring this with the sampler Sheet.

Here's column 2, `Number_wFormat`, which holds formatted numbers. Compare `literal_value` (current default) and `numeric_value` (what people probably want). Except when an integer gains a `.0`. Then we probably want `input_value`, for type conversion purposes. And note what's going on with `numeric_value` for scientific notation.


```r
cf %>%
  filter(col == 2) %>%
  select(literal_value, input_value, numeric_value)
#> Source: local data frame [6 x 3]
#> 
#>      literal_value      input_value numeric_value
#>              (chr)            (chr)         (chr)
#> 1 number_formatted number_formatted            NA
#> 2          654,321           654321      654321.0
#> 3           12.34%           12.34%        0.1234
#> 4         1.23E+09       1234567890  1.23456789E9
#> 5            3 1/7    3.14159265359 3.14159265359
#> 6            $0.36             0.36          0.36
```

Here's column 4, `Formulas`, which has a bunch of formulas, which show up as such in `input_value`. *Note we had to truncate `input_value` a wee bit for printing purposes.*


```r
cf %>%
  filter(col == 4) %>%
  select(literal_value, input_value, numeric_value) %>% 
  mutate(input_value = substr(input_value, 1, 54))
#> Source: local data frame [5 x 3]
#> 
#>   literal_value input_value numeric_value
#>           (chr)       (chr)         (chr)
#> 1     character   character            NA
#> 2           one         one            NA
#> 3         three       three            NA
#> 4          four        four            NA
#> 5          five        five            NA
```

Here's column 5, `Formula_wFormat`, which has a bunch of formatted numeric formulas. Compare `literal_value` (current default) and `numeric_value` (what people want) and `input_value` (the actual formulas).


```r
cf %>%
  filter(col == 5) %>%
  select(literal_value, input_value, numeric_value)
#> Source: local data frame [6 x 3]
#> 
#>   literal_value                                             input_value
#>           (chr)                                                   (chr)
#> 1       formula                                                 formula
#> 2        Google           =HYPERLINK("http://www.google.com/","Google")
#> 3  1,271,591.00                              =sum(R[-1]C[-4]:R[3]C[-4])
#> 4               =IMAGE("https://www.google.com/images/srpr/logo3w.png")
#> 5          $A$1                                           =ADDRESS(1,1)
#> 6                                      =SPARKLINE(R[-4]C[-4]:R[0]C[-4])
#> Variables not shown: numeric_value (chr).
```

Logic in the experimental new version of `gs_reshape_cellfeed()`:

  * Create an indicator for: does `numeric_value` exist?
  * Create an indicator for: does this look like an integer that is at risk of looking like a double if we take `numeric_value`?
  * Create new putative cell content like so:
    - if `numeric_value` does not exist, use `literal_value` (business as usual)
    - else if it's an "at risk" integer, use `input_value`
    - else use `numeric_value`
  * Isolate, reshape and type convert THAT
  
Set the new argument `literal = FALSE` to try this out:


```r
how_about_this <- cf %>%
  gs_reshape_cellfeed(literal = FALSE)
how_about_this
#> Source: local data frame [5 x 6]
#> 
#>   number number_formatted number_rounded character   formula
#>    (int)            (dbl)          (dbl)     (chr)     (chr)
#> 1 123456     6.543210e+05         1.2345       one    Google
#> 2 345678     1.234000e-01         2.3456        NA 1271591.0
#> 3 234567     1.234568e+09         3.4567     three        NA
#> 4     NA     3.141593e+00         4.5678      four      $A$1
#> 5 567890     3.600000e-01         5.6789      five        NA
#> Variables not shown: formula_formatted (dbl).
ff_read_csv
#> Source: local data frame [5 x 6]
#> 
#>   number number_formatted number_rounded character      formula
#>    (int)            (chr)          (dbl)     (chr)        (chr)
#> 1 123456          654,321           1.23       one       Google
#> 2 345678           12.34%           2.35        NA 1,271,591.00
#> 3 234567         1.23E+09           3.46     three           NA
#> 4     NA            3 1/7           4.57      four         $A$1
#> 5 567890            $0.36           5.68      five           NA
#> Variables not shown: formula_formatted (chr).
```

What do we think? Top is what we get when we remove numeric formats before type conversion. Bottom is what current read methods return.

While I'm at it, let's see if I've got `gs_simplify_cellfeed()` working again.


```r
cf_E <- gs_read_cellfeed(ff, range = cell_cols("E"))
#> Accessing worksheet titled 'Sheet1'.
cf_E %>% gs_simplify_cellfeed()
#>             E2             E3             E4             E5             E6 
#>       "Google" "1,271,591.00"             NA         "$A$1"             NA
cf_E %>% gs_simplify_cellfeed(literal = FALSE)
#>          E2          E3          E4          E5          E6 
#>    "Google" "1271591.0"          NA      "$A$1"          NA
```




