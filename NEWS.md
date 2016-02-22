# googlesheets 0.1.0.9001

* Added a `NEWS.md` file to track changes to the package.
* `httr v1.1.0`: to become compatible with this version, we now require it.
* We explicitly try to match the behavior and interface of `readr::read_csv()` for data ingest.
  - Within the `googlesheets` package, the explicit data ingest reference is `gs_read_csv()`, which now parses sheet contents via `readr::read_csv()` instead of `read.csv()`. Note this is also what is called whenever `range = NULL` in `gs_read()`.
  - `gs_read_listfeed()` now parses sheet content via `readr::type_convert()` instead of `type.convert()` and tries to match behavior and interface of `gs_read_csv()` wherever possible.
  - __Main message:__ Take control of `readr`-style data ingest via the `...` arguments of `gs_read` functions. Read the [`readr` vignette on column types](https://cran.r-project.org/web/packages/readr/vignettes/column-types.html) to better understand its automatic variable conversion behaviour and how to use the `col_types` argument.
  - To explicitly indicate presence/absence of column names, use the `col_names` argument instead of `header`. Example: `col_names = FALSE` instead of `header = FALSE`.
  - Columns that look like dates or date-times will, by default, be read in as such (vs. as character). 
  - Columns that consist entirely of empty cells will be *character* instead of *logical*, i.e. the `NA`s will be `NA_character_` vs `NA`.
  - "Column names are left as is, not munged into valid R identifiers (i.e. there is no check.names = TRUE)." This means you can get column names that are `NA`. I am considering adding an argument to `gs_read*()` functions to request that variable names be processed through `make.names()` or similar.
* `gs_add_row()` now works for two-dimensional `input`, by calling itself once per row of `input` (#188, @jimhester).
* Updated the scope for the Drive API. It is possible that new/updated Drive functions will require a token obtained with the new scope. This could mean that tokens stored and loaded from file in a non-interactive environment will need to be remade.
* Newly exported function `gs_deauth()` allows you to suspend the current token and, optionally, disable the `.httr-oauth` token cache file by renaming it to `.httr-oauth-SUSPENDED`.
* `gs_rename()` is a new function to rename an existing Sheet (#145).
* `gs_read_listfeed()` now supports parameters to manipulate data in the API call itself: `reverse` inverts row order, `orderby` selects a column to sort on, `sq` accepts a structured query to filter rows. (#17)
 * `gs_browse()` is a new function to visit a Google Sheet in the browser.
