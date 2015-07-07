<!-- README.md is generated from README.Rmd. Please edit that file -->
[![Build Status](https://travis-ci.org/jennybc/googlesheets.svg?branch=master)](https://travis-ci.org/jennybc/googlesheets) [![Coverage Status](https://coveralls.io/repos/jennybc/googlesheets/badge.svg)](https://coveralls.io/r/jennybc/googlesheets)

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

Use it in a Shiny app! *[Several example apps](inst/shiny-examples) come with the package.*

What other ideas do you have?

### Install googlesheets

The released version is available on CRAN

``` r
install.packages("googlesheets")
```

Or you can get the development version from GitHub:

``` r
devtools::install_github("jennybc/googlesheets")
```

### Take a look at the vignette

Read [the vignette](http://htmlpreview.github.io/?https://raw.githubusercontent.com/jennybc/googlesheets/master/vignettes/basic-usage.html) on GitHub.

### Slides from UseR2015

[Slides](https://speakerdeck.com/jennybc/googlesheets-talk-at-user2015) for a talk in July 2015 at the [UseR2015 conference](http://user2015.math.aau.dk)

### Load googlesheets

`googlesheets` is designed for use with the `%>%` pipe operator and, to a lesser extent, the data-wrangling mentality of [`dplyr`](http://cran.r-project.org/web/packages/dplyr/index.html). This README uses both, but the examples in the help files emphasize usage with plain vanilla R, if that's how you roll. `googlesheets` uses `dplyr` internally but does not require the user to do so. You can make the `%>%` pipe operator available in your own work by loading [`dplyr`](http://cran.r-project.org/web/packages/dplyr/index.html) or [`magrittr`](http://cran.r-project.org/web/packages/magrittr/index.html).

``` r
library("googlesheets")
suppressPackageStartupMessages(library("dplyr"))
```

### Function naming convention

All functions start with `gs_`, which plays nicely with tab completion. If the function has something to do with worksheets or tabs within a spreadsheet, then it will start with `gs_ws_`.

### Quick demo

First, here's how to get a copy of a Gapminder-based Sheet we publish for practicing and follow along. You'll be sent to the browser to authenticate yourself with Google at this point.

``` r
gs_gap() %>% 
  gs_copy(to = "Gapminder")
## or, if you don't use pipes
gs_copy(gs_gap(), to = "Gapminder")
```

Register a Sheet (in this case, by title):

``` r
gap <- gs_title("Gapminder")
#> Sheet successfully identifed: "Gapminder"
```

Here's a registered `googlesheet` object:

``` r
gap
#>                   Spreadsheet title: Gapminder
#>                  Spreadsheet author: gspreadr
#>   Date of googlesheets registration: 2015-07-07 08:33:29 GMT
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

Read all the data in a worksheet:

``` r
africa <- gs_read(gap)
#> Accessing worksheet titled "Africa"
str(africa)
#> Classes 'tbl_df', 'tbl' and 'data.frame':    624 obs. of  6 variables:
#>  $ country  : chr  "Algeria" "Algeria" "Algeria" "Algeria" ...
#>  $ continent: chr  "Africa" "Africa" "Africa" "Africa" ...
#>  $ year     : int  1952 1957 1962 1967 1972 1977 1982 1987 1992 1997 ...
#>  $ lifeExp  : num  43.1 45.7 48.3 51.4 54.5 ...
#>  $ pop      : int  9279525 10270856 11000948 12760499 14760787 17152804 20033753 23254956 26298373 29072015 ...
#>  $ gdpPercap: num  2449 3014 2551 3247 4183 ...
head(africa)
#> Source: local data frame [6 x 6]
#> 
#>   country continent year lifeExp      pop gdpPercap
#> 1 Algeria    Africa 1952  43.077  9279525  2449.008
#> 2 Algeria    Africa 1957  45.685 10270856  3013.976
#> 3 Algeria    Africa 1962  48.303 11000948  2550.817
#> 4 Algeria    Africa 1967  51.407 12760499  3246.992
#> 5 Algeria    Africa 1972  54.518 14760787  4182.664
#> 6 Algeria    Africa 1977  58.014 17152804  4910.417
```

Some of the many ways to target specific cells:

``` r
gap %>% gs_read(ws = 2, range = "A1:D8")
gap %>% gs_read(ws = "Europe", range = cell_rows(1:4))
gap %>% gs_read(ws = "Africa", range = cell_cols(1:4))
```

Create a new Sheet:

``` r
iris_ss <- gs_new("iris", input = head(iris, 3), trim = TRUE)
#> Warning in gs_new("iris", input = head(iris, 3), trim = TRUE): At least one
#> sheet matching "iris" already exists, so you may need to identify by key,
#> not title, in future.
#> Sheet "iris" created in Google Drive.
#> Range affected by the update: "A1:E4"
#> Worksheet "Sheet1" successfully updated with 20 new value(s).
#> Accessing worksheet titled "Sheet1"
#> Authentication will be used.
#> Sheet successfully identifed: "iris"
#> Accessing worksheet titled "Sheet1"
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
#> Accessing worksheet titled "Sheet1"
#> Source: local data frame [4 x 5]
#> 
#>   Sepal.Length Sepal.Width Petal.Length Petal.Width Species
#> 1         what          is            a       sepal anyway?
#> 2          4.9           3          1.4         0.2  setosa
#> 3          4.7         3.2          1.3         0.2  setosa
#> 4       sepals     support          the      petals      !!
```

Download this precious thing (other formats are possible):

``` r
iris_ss %>% 
  gs_download(to = "iris-ish-stuff.csv", overwrite = TRUE)
#> Sheet successfully downloaded: /Users/jenny/research/googlesheets/iris-ish-stuff.csv
```

Clean up our mess:

``` r
gs_vecdel("iris", "Gapminder")
file.remove("iris-ish-stuff.csv")
```

Remember, [the vignette](http://htmlpreview.github.io/?https://raw.githubusercontent.com/jennybc/googlesheets/master/vignettes/basic-usage.html) shows a lot more usage.

### Overview of functions

| fxn                      | description                                               |
|:-------------------------|:----------------------------------------------------------|
| gs\_ls()                 | List Sheets                                               |
| gs\_title()              | Register a Sheet by title                                 |
| gs\_key()                | Register a Sheet by key                                   |
| gs\_url()                | Register a Sheet by URL                                   |
| gs\_gs()                 | Re-register a `googlesheet`                               |
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
| gs\_user()               | Get info about current user and auth status               |
| gs\_webapp\_auth\_url()  | Facilitates auth by user of a Shiny app                   |
| gs\_webapp\_get\_token() | Facilitates auth by user of a Shiny app                   |
| gs\_gap()                | Registers a public Gapminder-based Sheet (for practicing) |
| gs\_gap\_key()           | Key of the Gapminder practice Sheet                       |
| gs\_gap\_url()           | Browser URL for the Gapminder practice Sheet              |
