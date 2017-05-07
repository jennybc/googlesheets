# Formulas and formatted numbers
Jenny Bryan  
`r Sys.Date()`  



## Preliminaries

Load `googlesheets` and `dplyr`, from which we use the `%>%` pipe operator and which gives us nicer printing of data frames (`tbl_df`s)


```r
library(googlesheets)
suppressMessages(library(dplyr))
```

## TL;DR

To see how your data comes in as a data frame *without numeric formatting*, try this:


```r
gs_read(..., literal = FALSE)
```

The `googlesheets` package comes with functions to access a public Sheet with formulas and formatted numbers. [Visit it in the browser](https://w3id.org/people/jennybc/googlesheets_ff_url) or check out this screenshot.

![](img/gs-test-formula-formatting-screenshot-smaller.png)

We use it to demo the effect of `literal` in `gs_read()`. First we accept the default, which is `literal = TRUE`.


```r
gs_ff() %>% 
  gs_read(range = cell_cols("B:C"))
#> Accessing worksheet titled 'Sheet1'.
#> 
Downloading: 820 B     
Downloading: 820 B     
Downloading: 2.2 kB     
Downloading: 2.2 kB     
Downloading: 3.1 kB     
Downloading: 3.1 kB     
Downloading: 4.5 kB     
Downloading: 4.5 kB     
Downloading: 5.9 kB     
Downloading: 5.9 kB     
Downloading: 7.3 kB     
Downloading: 7.3 kB     
Downloading: 8.7 kB     
Downloading: 8.7 kB     
Downloading: 9 kB     
Downloading: 9 kB     
Downloading: 9 kB     
Downloading: 9 kB     
Downloading: 9 kB     
Downloading: 9 kB
#> Parsed with column specification:
#> cols(
#>   number_formatted = col_character(),
#>   number_rounded = col_double()
#> )
#> # A tibble: 5 × 2
#>   number_formatted number_rounded
#>              <chr>          <dbl>
#> 1          654,321           1.23
#> 2           12.34%           2.35
#> 3         1.23E+09           3.46
#> 4            3 1/7           4.57
#> 5            $0.36           5.68
```

See the problem? Numeric formatting causes the first column to come in as character.

Try again with `literal = FALSE`:


```r
gs_ff() %>% 
  gs_read(literal = FALSE, range = cell_cols("B:C"))
#> Accessing worksheet titled 'Sheet1'.
#> 
Downloading: 820 B     
Downloading: 820 B     
Downloading: 2.2 kB     
Downloading: 2.2 kB     
Downloading: 3.1 kB     
Downloading: 3.1 kB     
Downloading: 4.5 kB     
Downloading: 4.5 kB     
Downloading: 5.9 kB     
Downloading: 5.9 kB     
Downloading: 7.2 kB     
Downloading: 7.2 kB     
Downloading: 8.6 kB     
Downloading: 8.6 kB     
Downloading: 9 kB     
Downloading: 9 kB     
Downloading: 9 kB     
Downloading: 9 kB     
Downloading: 9 kB     
Downloading: 9 kB
#> Parsed with column specification:
#> cols(
#>   number_formatted = col_double(),
#>   number_rounded = col_double()
#> )
#> # A tibble: 5 × 2
#>   number_formatted number_rounded
#>              <dbl>          <dbl>
#> 1     6.543210e+05         1.2345
#> 2     1.234000e-01         2.3456
#> 3     1.234568e+09         3.4567
#> 4     3.141593e+00         4.5678
#> 5     3.600000e-01         5.6789
```

Fixed it! First column is numeric. And we've also gained precision in the second column, previously lost to rounding.

If you want full access to cell contents, use `gs_read_cellfeed(..., literal = FALSE)` to get a data frame with one per cell. Then take your pick from `value`, `input_value`, and `numeric_value`. Here's an example with lots of formulas:


```r
gs_ff() %>% 
  gs_read_cellfeed(range = cell_cols("E")) %>% 
  select(-cell_alt, -row, -col) %>% 
  knitr::kable()
#> Accessing worksheet titled 'Sheet1'.
```


Downloading: 820 B     
Downloading: 820 B     
Downloading: 2.2 kB     
Downloading: 2.2 kB     
Downloading: 3.1 kB     
Downloading: 3.1 kB     
Downloading: 4.5 kB     
Downloading: 4.5 kB     
Downloading: 5.4 kB     
Downloading: 5.4 kB     
Downloading: 5.4 kB     
Downloading: 5.4 kB     
Downloading: 5.4 kB     
Downloading: 5.4 kB     

cell   value          input_value                                               numeric_value 
-----  -------------  --------------------------------------------------------  --------------
E1     formula        formula                                                   NA            
E2     Google         =HYPERLINK("http://www.google.com/","Google")             NA            
E3     1,271,591.00   =sum(R[-1]C[-4]:R[3]C[-4])                                1271591.0     
E4                    =IMAGE("https://www.google.com/images/srpr/logo3w.png")   NA            
E5     $A$1           =ADDRESS(1,1)                                             NA            
E6                    =SPARKLINE(R[-4]C[-4]:R[0]C[-4])                          NA            

Read on if you want to know more.

## Different notions of cell contents

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
    - API docs: "The `numericValue` attribute of a cell entry, when present, indicates that the cell was determined to have a numeric value, and its numeric value is indicated with this attributed [sic]."
    - If cell contains a number, this is that number.
    - If cell contains a numeric formula, this is the calculated numeric result.
    - Otherwise, the `numericValue` attribute doesn't even exist in the underlying XML and it will be an `NA` in any object `googlesheets` creates from reading the Sheet.

### Vocabulary: there's formatting and then there's *formatting*

Click on the Format menu in Google Sheets and you'll gain access to a "Number" sub-menu and ... lots of other stuff. Let's agree that "formatting" can mean two different things:

  * Decoration. Font, font size, font color, bold, italic, cell background, text alignment, etc.
  * Numeric formatting. Meaning this:
    - UNformatted: 123456 or 32.61 or 0.53
    - Formatted: 123,456 or $32.61 or 53%

Decorative formatting is completely invisible to the Sheets API. It is also a terrible idea to encode data in decorative formatting, though it can be used to visually reinforce information that is properly stored in data (Google Sheets is capable of [conditional formatting](https://support.google.com/docs/answer/78413?hl=en)). Nothing in `googlesheets` or the rest of this vignette addresses decorative formatting. We shall not speak of it again. From now on, "formatting" means numeric formatting.

## A worthy challenge

We've created a formula and formatting ~~nightmare~~ sampler Sheet. [Go visit it in the browser!](https://w3id.org/people/jennybc/googlesheets_ff_url). Or check out this screenshot.

![gs-test-formula-formatting-screenshot](img/gs-test-formula-formatting-screenshot-smaller.png)

It's one of the built-in example sheets. Access it with various functions that start with `gs_ff`.

Here's how it comes in as a data frame by default: you get "literal values" (suppressing a boring column in order to show the interesting ones).


```r
gs_ff() %>% 
  gs_read() %>% 
  select(-integer)
#> Accessing worksheet titled 'Sheet1'.
#> 
Downloading: 200 B     
Downloading: 200 B     
Downloading: 210 B     
Downloading: 210 B     
Downloading: 210 B     
Downloading: 210 B
#> Parsed with column specification:
#> cols(
#>   integer = col_integer(),
#>   number_formatted = col_character(),
#>   number_rounded = col_double(),
#>   character = col_character(),
#>   formula = col_character(),
#>   formula_formatted = col_character()
#> )
#> # A tibble: 5 × 5
#>   number_formatted number_rounded character      formula formula_formatted
#>              <chr>          <dbl>     <chr>        <chr>             <chr>
#> 1          654,321           1.23       one       Google          3.18E+05
#> 2           12.34%           2.35      <NA> 1,271,591.00            52.63%
#> 3         1.23E+09           3.46     three         <NA>              0.22
#> 4            3 1/7           4.57      four         $A$1        123,456.00
#> 5            $0.36           5.68      five         <NA>           317,898
```

What if you want unformatted numbers? What if you want the actual formulas? You can now get them the cell feed, which, in `googlesheets`, means you must use `gs_read_cellfeed()`. You can cause `gs_read()` to consult the cell feed by specifying `literal = FALSE`.

## The cell feed

Default methods of reading Sheet data assume that the data occupies a neat rectangle in the upper left corner, that you want all of it, and that you want the literal values.

What if you need more control over which cells? What if you want input or numeric values? Use the cell feed via `gs_read_cellfeed()`. Under the hood, `gs_read()` will use the cell feed whenever a cell range is provided, i.e. when the call is like `gs_read(..., range = "B4:D9")` or `gs_read(..., range = cell_cols(4:6))`, or when the new argument `literal = FALSE`.

`gs_read_cellfeed()` has been extended. As before, we return a data frame with one row per cell, but now we return all 3 notions of cell contents:

  * `value`: The variable previously known as `cell_text`. Described as "literal value", what you see in the browser, and what is returned by all other methods of reading.
  * `input_value`: What you would have typed into the cell (if you are a total spreadsheet nerd, when it comes to percentages).
  * `numeric_value`: The actual number, if such exists.


```r
cf <- gs_read_cellfeed(gs_ff())
#> Accessing worksheet titled 'Sheet1'.
#> 
Downloading: 820 B     
Downloading: 820 B     
Downloading: 2.2 kB     
Downloading: 2.2 kB     
Downloading: 3.1 kB     
Downloading: 3.1 kB     
Downloading: 4.5 kB     
Downloading: 4.5 kB     
Downloading: 5.9 kB     
Downloading: 5.9 kB     
Downloading: 7.2 kB     
Downloading: 7.2 kB     
Downloading: 8.6 kB     
Downloading: 8.6 kB     
Downloading: 10 kB     
Downloading: 10 kB     
Downloading: 11 kB     
Downloading: 11 kB     
Downloading: 13 kB     
Downloading: 13 kB     
Downloading: 14 kB     
Downloading: 14 kB     
Downloading: 15 kB     
Downloading: 15 kB     
Downloading: 17 kB     
Downloading: 17 kB     
Downloading: 18 kB     
Downloading: 18 kB     
Downloading: 20 kB     
Downloading: 20 kB     
Downloading: 21 kB     
Downloading: 21 kB     
Downloading: 22 kB     
Downloading: 22 kB     
Downloading: 22 kB     
Downloading: 22 kB     
Downloading: 22 kB     
Downloading: 22 kB
```

![gs-test-formula-formatting-screenshot](img/gs-test-formula-formatting-screenshot-smaller.png)


cell   value               input_value                                               numeric_value       
-----  ------------------  --------------------------------------------------------  --------------------
A1     integer             integer                                                   NA                  
A2     123456              123456                                                    123456.0            
A3     345678              345678                                                    345678.0            
A4     234567              234567                                                    234567.0            
A6     567890              567890                                                    567890.0            
B1     number_formatted    number_formatted                                          NA                  
B2     654,321             654321                                                    654321.0            
B3     12.34%              12.34%                                                    0.1234              
B4     1.23E+09            1234567890                                                1.23456789E9        
B5     3 1/7               3.14159265359                                             3.14159265359       
B6     \$0.36              0.36                                                      0.36                
C1     number_rounded      number_rounded                                            NA                  
C2     1.23                1.2345                                                    1.2345              
C3     2.35                2.3456                                                    2.3456              
C4     3.46                3.4567                                                    3.4567              
C5     4.57                4.5678                                                    4.5678              
C6     5.68                5.6789                                                    5.6789              
D1     character           character                                                 NA                  
D2     one                 one                                                       NA                  
D4     three               three                                                     NA                  
D5     four                four                                                      NA                  
D6     five                five                                                      NA                  
E1     formula             formula                                                   NA                  
E2     Google              =HYPERLINK("http://www.google.com/","Google")             NA                  
E3     1,271,591.00        =sum(R[-1]C[-4]:R[3]C[-4])                                1271591.0           
E4                         =IMAGE("https://www.google.com/images/srpr/logo3w.png")   NA                  
E5     \$A\$1              =ADDRESS(1,1)                                             NA                  
E6                         =SPARKLINE(R[-4]C[-4]:R[0]C[-4])                          NA                  
F1     formula_formatted   formula_formatted                                         NA                  
F2     3.18E+05            =average(R[0]C[-5]:R[4]C[-5])                             317897.75           
F3     52.63%              =R[-1]C[-5]/R[1]C[-5]                                     0.5263144432081239  
F4     0.22                =R[-2]C[-5]/R[2]C[-5]                                     0.21739421366813996 
F5     123,456.00          =min(R[-3]C[-5]:R[1]C[-5])                                123456.0            
F6     317,898             =average(R2C1:R6C1)                                       317897.75           

![gs-test-formula-formatting-screenshot](img/gs-test-formula-formatting-screenshot-smaller.png)

### Exploration of cell contents

We explore the different cell contents for different variables. This motivates the logic behind what happens when `gs_read(..., literal = FALSE)` and `gs_simply_cellfeed(..., literal = FALSE)`.

#### Formatted numbers

Column 2, `number_formatted`, holds variously formatted numbers. It is quite pathological, because in real life numeric formatting is likely to be uniform within a column, which helps `readr` make good decisions about type conversion.

  * `value` (what you get by default) imports as character. Not good.
  * `input_value` is attractive for the first number, because an integer looks like an integer, which is ultimately good for type conversion. But this variable still imports as character, because of the percent sign.
  * `numeric_value` is usually what you want for numbers.


```r
cf %>%
  filter(row > 1, col == 2) %>%
  select(value, input_value, numeric_value) %>% 
  readr::type_convert()
#> Parsed with column specification:
#> cols(
#>   value = col_character(),
#>   input_value = col_character(),
#>   numeric_value = col_double()
#> )
#> # A tibble: 5 × 3
#>      value   input_value numeric_value
#>      <chr>         <chr>         <dbl>
#> 1  654,321        654321  6.543210e+05
#> 2   12.34%        12.34%  1.234000e-01
#> 3 1.23E+09    1234567890  1.234568e+09
#> 4    3 1/7 3.14159265359  3.141593e+00
#> 5    $0.36          0.36  3.600000e-01
```

#### Rounded numbers

Column 3, `number_rounded`, holds numbers with four decimal places, rounded to show just two. Here we want `numeric_value`.


```r
cf %>%
  filter(row > 1, col == 3) %>%
  select(value, input_value, numeric_value) %>% 
  readr::type_convert()
#> Parsed with column specification:
#> cols(
#>   value = col_double(),
#>   input_value = col_double(),
#>   numeric_value = col_double()
#> )
#> # A tibble: 5 × 3
#>   value input_value numeric_value
#>   <dbl>       <dbl>         <dbl>
#> 1  1.23      1.2345        1.2345
#> 2  2.35      2.3456        2.3456
#> 3  3.46      3.4567        3.4567
#> 4  4.57      4.5678        4.5678
#> 5  5.68      5.6789        5.6789
```

#### Formulas

Column 5, `formula`, holds various formulas, not necessarily numeric. *Note we had to truncate `input_value` for printing purposes.*

  * `value` is what you want ... except for the formula which evaluates to numeric and is formatted.
  * `input_value` holds the actual formulas.
  * `numeric_value` is what you want for the single formula that is numeric.


```r
cf %>%
  filter(row > 1, col == 5) %>%
  select(value, input_value, numeric_value) %>% 
  mutate(input_value = substr(input_value, 1, 43)) %>% 
  readr::type_convert()
#> Parsed with column specification:
#> cols(
#>   value = col_character(),
#>   input_value = col_character(),
#>   numeric_value = col_double()
#> )
#> # A tibble: 5 × 3
#>          value                                 input_value numeric_value
#>          <chr>                                       <chr>         <dbl>
#> 1       Google =HYPERLINK("http://www.google.com/","Google            NA
#> 2 1,271,591.00                  =sum(R[-1]C[-4]:R[3]C[-4])       1271591
#> 3         <NA> =IMAGE("https://www.google.com/images/srpr/            NA
#> 4         $A$1                               =ADDRESS(1,1)            NA
#> 5         <NA>            =SPARKLINE(R[-4]C[-4]:R[0]C[-4])            NA
```

#### Numeric formulas, formatted

Column 6, `formula_formatted`, holds formatted numeric formulas:

  * `value` (default) will come in as character.
  * `input_value` holds the actual formulas.
  * `numeric_value` (what you usualy want, when it exists) holds the calcuated numbers.


```r
cf %>%
  filter(row > 1, col == 6) %>%
  select(value, input_value, numeric_value) %>% 
  readr::type_convert()
#> Parsed with column specification:
#> cols(
#>   value = col_character(),
#>   input_value = col_character(),
#>   numeric_value = col_double()
#> )
#> # A tibble: 5 × 3
#>        value                   input_value numeric_value
#>        <chr>                         <chr>         <dbl>
#> 1   3.18E+05 =average(R[0]C[-5]:R[4]C[-5])  3.178978e+05
#> 2     52.63%         =R[-1]C[-5]/R[1]C[-5]  5.263144e-01
#> 3       0.22         =R[-2]C[-5]/R[2]C[-5]  2.173942e-01
#> 4 123,456.00    =min(R[-3]C[-5]:R[1]C[-5])  1.234560e+05
#> 5    317,898           =average(R2C1:R6C1)  3.178978e+05
```

## Logic for cell contents when `literal = FALSE`

Based on the above examples (and more), here's the current logic for which cell contents are used in `gs_read(..., literal = FALSE)` and `gs_reshape_cellfeed(..., literal = FALSE)`. The goal is to create an input that gives the desired result most often with default behavior of `readr::type_convert()`. If you think this is wrong, please discuss in [an issue](https://github.com/jennybc/googlesheets/issues).

  * Create an indicator for: does `numeric_value` exist?
  * Create an indicator for: does this look like an integer that is at risk of looking like a double if we take `numeric_value`?
  * Create putative cell content like so:
    - if `numeric_value` does not exist, use `value` (business as usual)
    - else if it's an "at risk" integer, use `input_value`
    - else use `numeric_value`
  * Isolate, reshape and type convert THAT
