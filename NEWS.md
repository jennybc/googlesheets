# googlesheets 0.1.0.9001

  * Added a `NEWS.md` file to track changes to the package.
  * `httr v1.1.0`: to become compatible with this version, we now require it.
  * Dependency changes:
    - `plyr` is no longer required (#204)
    - `purrr` is a new dependency
  * `gs_browse()` is a new function to visit a Google Sheet in the browser.
  * `gs_rename()` is a new function to rename an existing Sheet (#145).
  * `gs_add_row()` now works for two-dimensional `input`, by calling itself once per row of `input` (#188, @jimhester).
  * Updated the scope for the Drive API. It is possible that new/updated Drive functions will require a token obtained with the new scope. This could mean that tokens stored and loaded from file in a non-interactive environment will need to be remade.
  * `gs_read_listfeed()` now supports parameters to manipulate data in the API call itself: `reverse` inverts row order, `orderby` selects a column to sort on, `sq` accepts a structured query to filter rows. (#17)
  * `gs_read_listfeed()` doesn't return API-mangled column names anymore. They should now be the same as those from the other read functions and what you see in the browser.
  * `readr`-style data ingest: We explicitly try to match the interface of `readr::read_csv()`. The read functions `gs_read()`, `gs_read_csv()`, and `gs_read_listfeed()` and the reshaper `gs_reshape_cellfeed()` should all return the same data frame when operating on the same worksheet. And this should match what `readr::read_csv()` would return on a `.csv` file exported from that worksheet. The type conversion arguments for `gs_simplify_cellfeed()` have also changed accordingly.
    - The `header` argument is no longer accepted.
    - If you're not happy with the defaults, take control via the `...` arguments of `gs_read*` or reshape functions. You can now specify `column_types`, `col_names`, `locale`, `na`, `trim_ws`, etc. here.
    - See the sections "Controlling data ingest, theory and practice" in the [the basic usage vignette](https://github.com/jennybc/googlesheets/blob/master/vignettes/basic-usage.md) for details and examples.
    - `readr` exception #1: variables that consist entirely of missing values will be `NA` of the logical type, not `NA_character_`.
    - `readr` exception #2: `googlesheets` will never return a data frame with `NA` as a variable name. Instead, it will create a dummy variable name, like `X5`.
    - `readr` exception #3: All read/reshape functions accept `check.names`, in the spirit of `utils::read.table()`, which defaults to `FALSE`. If `TRUE`, variable names will be run through `make.names(..., unique = TRUE)`. (#208)
  * `gs_deauth()` is a newly exported function that allows you to suspend the current token and, optionally, disable the `.httr-oauth` token cache file by renaming it to `.httr-oauth-SUSPENDED`.
