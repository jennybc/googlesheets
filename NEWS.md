# googlesheets 0.1.0.9001

  * Added a `NEWS.md` file to track changes to the package.
  * `httr v1.1.0`: to become compatible with this version, we now require it.
  * Dependency changes:
    - `plyr` is no longer required
    - `purrr` is a new dependency
  * We explicitly try to match the behavior and interface of `readr::read_csv()` for all data ingest. The read functions `gs_read()`, `gs_read_csv()`, and `gs_read_listfeed()` and the reshaper `gs_reshape_cellfeed()` should all return the same data frame when operating on the same worksheet. This should also match what `readr::read_csv()` would return on a `.csv` file exported from that worksheet.
    - If you're not happy with the defaults, take control of `readr`-style data ingest via the `...` arguments of `gs_read*` or reshape functions. You can now specify `column_types`, `col_names`, `locale`, `na`, `trim_ws`, etc. here.
    - Column types: read the [`readr` vignette on column types](https://cran.r-project.org/web/packages/readr/vignettes/column-types.html) to better understand the automatic variable conversion behaviour and how to use the `col_types` argument to override it.
    - Column names: Use the `col_names` argument. If character, it should provide actual names. If logical, `TRUE` implies that column names should be taken from the first row and `FALSE` implies that column names like `X1`, `X2`, etc. should be manufactured. Don't use `header` anymore.
    - `readr` exception #1: variables that consist entirely of missing values will be `NA` of the logical type, whereas they are `NA_character_` for `readr`.
    - `readr` exception #2: `googlesheets` will never return a data frame with `NA` as a variable name. Instead, it will fabricate a variable name, like `X5`.
    - `readr` exception #3: All read/reshape functions accept `check.names`, in the spirit of `read.table()`, which defaults to `FALSE`. If `TRUE`, variable names will be run through `make.names()`.
  * `gs_add_row()` now works for two-dimensional `input`, by calling itself once per row of `input` (#188, @jimhester).
  * Updated the scope for the Drive API. It is possible that new/updated Drive functions will require a token obtained with the new scope. This could mean that tokens stored and loaded from file in a non-interactive environment will need to be remade.
  * Newly exported function `gs_deauth()` allows you to suspend the current token and, optionally, disable the `.httr-oauth` token cache file by renaming it to `.httr-oauth-SUSPENDED`.
  * `gs_rename()` is a new function to rename an existing Sheet (#145).
  * `gs_read_listfeed()` now supports parameters to manipulate data in the API call itself: `reverse` inverts row order, `orderby` selects a column to sort on, `sq` accepts a structured query to filter rows. (#17)
  * `gs_browse()` is a new function to visit a Google Sheet in the browser.
