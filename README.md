
<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/jennybc/googlesheets.svg?branch=master)](https://travis-ci.org/jennybc/googlesheets) [![Coverage Status](https://coveralls.io/repos/jennybc/googlesheets/badge.svg)](https://coveralls.io/r/jennybc/googlesheets) [![DOI](https://zenodo.org/badge/16122/jennybc/googlesheets.svg)](http://dx.doi.org/10.5281/zenodo.21972) [![CRAN version](http://www.r-pkg.org/badges/version/googlesheets)](https://cran.r-project.org/package=googlesheets) ![](http://cranlogs.r-pkg.org/badges/grand-total/googlesheets)

------------------------------------------------------------------------

Google Sheets R API
-------------------

Access and manage Google spreadsheets from R with `googlesheets`.

Features:

-   Access a spreadsheet by its title, key or URL.
-   Extract data or edit data.
-   Create | delete | rename | copy | upload | download spreadsheets and worksheets.
-   Upload local Excel workbook into a Google Sheet and vice versa.

`googlesheets` is inspired by [gspread](https://github.com/burnash/gspread), a Google Spreadsheets Python API

The exuberant prose in this README is inspired by [Tabletop.js](https://github.com/jsoma/tabletop): If you've ever wanted to get data in or out of a Google Spreadsheet from R without jumping through a thousand hoops, welcome home!

### Install googlesheets

The released version is available on CRAN

``` r
install.packages("googlesheets")
```

Or you can get the development version from GitHub:

``` r
devtools::install_github("jennybc/googlesheets")
```

### Vignettes

GitHub versions:

-   [Basic usage](https://rawgit.com/jennybc/googlesheets/master/vignettes/basic-usage.html)
-   [Formulas and formatted numbers](https://rawgit.com/jennybc/googlesheets/master/vignettes/formulas-and-formatted-numbers.html)
-   [Managing OAuth tokens](https://rawgit.com/jennybc/googlesheets/master/vignettes/managing-auth-tokens.html)

### Talks

-   [Slides](https://speakerdeck.com/jennybc/googlesheets-talk-at-user2015) for a talk in July 2015 at [useR! 2015](http://user2015.math.aau.dk)
-   [Slides](https://speakerdeck.com/jennybc/googlesheets-1) for an [rOpenSci Community Call in March 2016](https://github.com/ropensci/commcalls/issues/9)

### Load googlesheets

`googlesheets` is designed for use with the `%>%` pipe operator and, to a lesser extent, the data-wrangling mentality of [`dplyr`](https://cran.r-project.org/package=dplyr). This README uses both, but the examples in the help files emphasize usage with plain vanilla R, if that's how you roll. `googlesheets` uses `dplyr` internally but does not require the user to do so. You can make the `%>%` pipe operator available in your own work by loading [`dplyr`](https://cran.r-project.org/package=dplyr) or [`magrittr`](https://cran.r-project.org/package=magrittr).

``` r
library("googlesheets")
suppressPackageStartupMessages(library("dplyr"))
```

### Function naming convention

To play nicely with tab completion, we use consistent prefixes:

-   `gs_` = all functions in the package.
-   `gs_ws_` = all functions that operate on worksheets or tabs within a spreadsheet.
-   `gd_` = something to do with Google Drive, usually has a `gs_` synonym, might one day migrate to a Drive client.

### Quick demo

Here's how to get a copy of a Gapminder-based Sheet we publish for practicing and follow along. You'll be sent to the browser to authenticate yourself with Google at this point.

``` r
gs_gap() %>% 
  gs_copy(to = "Gapminder")
## or, if you don't use pipes
gs_copy(gs_gap(), to = "Gapminder")
```

Register a Sheet (in this case, by title):

``` r
gap <- gs_title("Gapminder")
#> Sheet successfully identified: "Gapminder"
```

Here's a registered `googlesheet` object:

``` r
gap
#>                   Spreadsheet title: Gapminder
#>                  Spreadsheet author: gspreadr
#>   Date of googlesheets registration: 2016-06-25 00:12:58 GMT
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
```

Visit a registered `googlesheet` in the browser:

``` r
gap %>% gs_browse()
gap %>% gs_browse(ws = "Europe")
```

Read all the data in a worksheet:

``` r
africa <- gs_read(gap)
#> Accessing worksheet titled 'Africa'.
#> No encoding supplied: defaulting to UTF-8.
str(africa)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    624 obs. of  6 variables:
#>  $ country  : chr  "Algeria" "Algeria" "Algeria" "Algeria" ...
#>  $ continent: chr  "Africa" "Africa" "Africa" "Africa" ...
#>  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
#>  $ lifeExp  : num  43.1 45.7 48.3 51.4 54.5 ...
#>  $ pop      : int  9279525 10270856 11000948 12760499 14760787 17152804 20033753 23254956 26298373 29072015 ...
#>  $ gdpPercap: num  2449 3014 2551 3247 4183 ...
head(africa)
#> <tibble [6 x 6]>
#>   country continent  year lifeExp      pop gdpPercap
#>     <chr>     <chr> <int>   <dbl>    <int>     <dbl>
#> 1 Algeria    Africa  1952  43.077  9279525  2449.008
#> 2 Algeria    Africa  1957  45.685 10270856  3013.976
#> 3 Algeria    Africa  1962  48.303 11000948  2550.817
#> 4 Algeria    Africa  1967  51.407 12760499  3246.992
#> 5 Algeria    Africa  1972  54.518 14760787  4182.664
#> 6 Algeria    Africa  1977  58.014 17152804  4910.417
```

Some of the many ways to target specific cells:

``` r
gap %>% gs_read(ws = 2, range = "A1:D8")
gap %>% gs_read(ws = "Europe", range = cell_rows(1:4))
gap %>% gs_read(ws = "Africa", range = cell_cols(1:4))
```

Full `readr`-style control of data ingest -- highly artificial example!

``` r
gap %>%
  gs_read(ws = "Oceania", col_names = paste0("Z", 1:6),
          na = c("1962", "1977"), col_types = "cccccc", skip = 1, n_max = 7)
#> Accessing worksheet titled 'Oceania'.
#> No encoding supplied: defaulting to UTF-8.
#> <tibble [7 x 6]>
#>          Z1      Z2    Z3    Z4       Z5       Z6
#>       <chr>   <chr> <chr> <chr>    <chr>    <chr>
#> 1 Australia Oceania  1952 69.12  8691212  10039.6
#> 2 Australia Oceania  1957 70.33  9712569 10949.65
#> 3 Australia Oceania  <NA> 70.93 10794968 12217.23
#> 4 Australia Oceania  1967  71.1 11872264 14526.12
#> 5 Australia Oceania  1972 71.93 13177000 16788.63
#> 6 Australia Oceania  <NA> 73.49 14074100  18334.2
#> 7 Australia Oceania  1982 74.74 15184200 19477.01
```

Create a new Sheet from an R object:

``` r
iris_ss <- gs_new("iris", input = head(iris, 3), trim = TRUE)
#> Warning: At least one sheet matching "iris" already exists, so you may
#> need to identify by key, not title, in future.
#> Sheet "iris" created in Google Drive.
#> Range affected by the update: "A1:E4"
#> Worksheet "Sheet1" successfully updated with 20 new value(s).
#> Accessing worksheet titled 'Sheet1'.
#> Sheet successfully identified: "iris"
#> Accessing worksheet titled 'Sheet1'.
#> Worksheet "Sheet1" dimensions changed to 4 x 5.
#> Worksheet dimensions: 4 x 5.
```

Edit some arbitrary cells and append a row:

``` r
iris_ss <- iris_ss %>% 
  gs_edit_cells(input = c("what", "is", "a", "sepal", "anyway?"),
                anchor = "A2", byrow = TRUE)
#> Range affected by the update: "A2:E2"
#> Worksheet "Sheet1" successfully updated with 5 new value(s).
iris_ss <- iris_ss %>% 
  gs_add_row(input = c("sepals", "support", "the", "petals", "!!"))
#> Row successfully appended.
```

Look at what we have wrought:

``` r
iris_ss %>% 
  gs_read()
#> Accessing worksheet titled 'Sheet1'.
#> No encoding supplied: defaulting to UTF-8.
#> <tibble [4 x 5]>
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#>          <chr>       <chr>        <chr>       <chr>   <chr>
#> 1         what          is            a       sepal anyway?
#> 2          4.9           3          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4       sepals     support          the      petals      !!
```

Download this precious thing as csv (other formats are possible):

``` r
iris_ss %>% 
  gs_download(to = "iris-ish-stuff.csv", overwrite = TRUE)
#> Sheet successfully downloaded:
#> /Users/jenny/rrr/googlesheets/iris-ish-stuff.csv
```

Download this precious thing as an Excel workbook (other formats are possible):

``` r
iris_ss %>% 
  gs_download(to = "iris-ish-stuff.xlsx", overwrite = TRUE)
#> Sheet successfully downloaded:
#> /Users/jenny/rrr/googlesheets/iris-ish-stuff.xlsx
```

Upload a Excel workbook into a new Sheet:

``` r
gap_xlsx <- gs_upload(system.file("mini-gap", "mini-gap.xlsx",
                                  package = "googlesheets"))
#> File uploaded to Google Drive:
#> /Users/jenny/resources/R/library/googlesheets/mini-gap/mini-gap.xlsx
#> As the Google Sheet named:
#> mini-gap
```

Clean up our mess locally and on Google Drive:

``` r
gs_vecdel(c("iris", "Gapminder"))
file.remove(c("iris-ish-stuff.csv", "iris-ish-stuff.xlsx"))
```

Remember, [the vignette](https://github.com/jennybc/googlesheets/blob/master/vignettes/basic-usage.md) shows a lot more usage.

### Overview of functions

| fxn                      | description                                               |
|:-------------------------|:----------------------------------------------------------|
| gs\_ls()                 | List Sheets                                               |
| gs\_title()              | Register a Sheet by title                                 |
| gs\_key()                | Register a Sheet by key                                   |
| gs\_url()                | Register a Sheet by URL                                   |
| gs\_gs()                 | Re-register a `googlesheet`                               |
| gs\_browse()             | Visit a registered `googlesheet` in the browser           |
| gs\_read()               | Read data and let `googlesheets` figure out how           |
| gs\_read\_csv()          | Read explicitly via the fast exportcsv link               |
| gs\_read\_listfeed()     | Read explicitly via the list feed                         |
| gs\_read\_cellfeed()     | Read explicitly via the cell feed                         |
| gs\_reshape\_cellfeed()  | Reshape cell feed data into a 2D thing                    |
| gs\_simplify\_cellfeed() | Simplify cell feed data into a 1D thing                   |
| gs\_edit\_cells()        | Edit specific cells                                       |
| gs\_add\_row()           | Append a row to pre-existing data table                   |
| gs\_new()                | Create a new Sheet and optionally populate                |
| gs\_copy()               | Copy a Sheet into a new Sheet                             |
| gs\_rename()             | Rename an existing Sheet                                  |
| gs\_ws\_ls()             | List the worksheets in a Sheet                            |
| gs\_ws\_new()            | Create a new worksheet and optionally populate            |
| gs\_ws\_rename()         | Rename a worksheet                                        |
| gs\_ws\_delete()         | Delete a worksheet                                        |
| gs\_delete()             | Delete a Sheet                                            |
| gs\_grepdel()            | Delete Sheets with matching titles                        |
| gs\_vecdel()             | Delete the named Sheets                                   |
| gs\_upload()             | Upload local file into a new Sheet                        |
| gs\_download()           | Download a Sheet into a local file                        |
| gs\_auth()               | Authorize the package                                     |
| gs\_deauth()             | De-authorize the package                                  |
| gs\_user()               | Get info about current user and auth status               |
| gs\_webapp\_auth\_url()  | Facilitates auth by user of a Shiny app                   |
| gs\_webapp\_get\_token() | Facilitates auth by user of a Shiny app                   |
| gs\_gap()                | Registers a public Gapminder-based Sheet (for practicing) |
| gs\_gap\_key()           | Key of the Gapminder practice Sheet                       |
| gs\_gap\_url()           | Browser URL for the Gapminder practice Sheet              |

#### What the hell do I do with this?

Think of `googlesheets` as a read/write CMS that you (or your less R-obsessed friends) can edit through Google Docs, as well via R. It's like Christmas up in here.

Use a [Google Form](http://www.google.com/forms/about/) to conduct a survey, which populates a Google Sheet.

Gather data while you're in the field in a Google Sheet, maybe [with an iPhone](https://itunes.apple.com/us/app/google-sheets/id842849113?mt=8) or [an Android device](https://play.google.com/store/apps/details?id=com.google.android.apps.docs.editors.sheets&hl=en). Take advantage of [data validation](https://support.google.com/docs/answer/139705?hl=en) to limit the crazy on the way in. You do not have to be online to edit a Google Sheet! Work offline via [the Chrome browser](https://support.google.com/docs/answer/2375012?hl=en), the [Sheets app for Android](https://play.google.com/store/apps/details?id=com.google.android.apps.docs.editors.sheets&hl=en), or the [Sheets app for iOS](https://itunes.apple.com/us/app/google-sheets/id842849113?mt=8).

There are various ways to harvest web data directly into a Google Sheet. For example:

-   [This blog post](http://blog.aylien.com/post/114757623598/sentiment-analysis-of-restaurant-reviews) from Aylien.com has a simple example that uses the `=IMPORTXML()` formula to populate a Google Sheet with restaurant reviews and ratings from TripAdvisor.
-   Martin Hawksey offers [TAGS](https://tags.hawksey.info), a free Google Sheet template to setup and run automated collection of search results from Twitter.
-   Martin Hawksey also has a great blog post, [Feeding Google Spreadsheets](https://mashe.hawksey.info/2012/10/feeding-google-spreadsheets-exercises-in-import/), that demonstrates how functions like `importHTML`, `importFeed`, and `importXML` help you get data from the web into a Google Sheet with no programming.
-   Martin Hawksey has another blog post about [feeding a Google Sheet from IFTTT](https://mashe.hawksey.info/2012/09/ifttt-if-i-do-that-on-insert-social-networkrss-feedother-then-add-row-to-google-spreadsheet/). [IFTTT](https://ifttt.com) stands for "if this, then that" and it's "a web-based service that allows users to create chains of simple conditional statements, called 'recipes', which are triggered based on changes to other web services such as Gmail, Facebook, Instagram, and Craigslist" (from [Wikipedia](http://en.wikipedia.org/wiki/IFTTT)).

Use `googlesheets` to get all that data into R.

Use it in a Shiny app! *[Several example apps](inst/shiny-examples) come with the package.*

What other ideas do you have?
