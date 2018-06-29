# googlesheets 0.3.0

The motivation for this release is to avoid a warning on R-devel that occurs if 
a package is referenced in the tests (in this case, tibble) that is not a direct dependency. We now use an equivalent function from the imported package dplyr.

# googlesheets 0.2.2

The motivation for this release is for compatibility with the about-to-be released purrr 0.2.2.1.

  * Update ggplot2 usage to clear warnings about use of deprecated arguments.
  * Remove all uses of `purrr::dmap()` and friends, which have been removed from purrr.
  * `gs_upload()` now has an `overwrite` argument. (#285 @omgjens)
  * Add vignette to show interactive authentication in a non-default browser.

# googlesheets 0.2.1

  * `XML` is no longer a dependency.
  * Automatic retries for `Internal Server Error (HTTP 500)`. On or around 2016-03-11, there was a huge increase in the frequency of this error on Google Drive API calls.
    - Remedy: all HTTP `GET` calls in the package are automatically retried up to 5 times, with exponential backoff, for statuses 500 and higher.
  * Functions prefixed with `gd_` refer to Google Drive and might eventually migrate into a separate Google Drive package. Generally there is a synonym with the `gs_` prefix.
  * `gd_token()` is a new function to expose information about the current Google token. Some of this was migrated out of `gd_user()` and into `gd_token()`. New information includes scopes and cache path.
  * `gd_user()` now returns an S3 object of class `drive_user`, but it's really just a list with a nice print method. It exposes information about the current Google user. New information includes user's Drive `permissionId` and `rootFolderId`.

# googlesheets 0.2.0

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
    - The `header` argument is no longer accepted. Use `col_names`.
    - If you're not happy with the defaults, take control via the `...` arguments of `gs_read*` or reshape/simplify functions. Specify `column_types`, `col_names`, `locale`, `na`, `trim_ws`, etc. here.
    - See the sections "Controlling data ingest, theory and practice" in the the Basic Usage vignette for details and examples.
    - `readr` exception #1: variables that consist entirely of missing values will be `NA` of the logical type, not `NA_character_`.
    - `readr` exception #2: `googlesheets` will never return a data frame with `NA` as a variable name. Instead, it will create a dummy variable name, like `X5`.
    - `readr` exception #3: All read/reshape functions accept `check.names`, in the spirit of `utils::read.table()`, which defaults to `FALSE`. If `TRUE`, variable names will be run through `make.names(..., unique = TRUE)`. (#208)
  * `gs_read_cellfeed()` now returns all possible definitions of cell contents:
    - `value`: The variable previously known as `cell_text`. What you see in the browser and what Sheets API returns by default.
    - `input_value`: What you would have typed into the cell. Will give unevaluated formulas. (#18, #19, #152)
    - `numeric_value`: An actual number, if such exists, unmangled by rounding or other numeric formatting. (#152, #178)
  * New argument `literal = FALSE` available in reading/reshaping functions that call the cell feed. Tries to be clever about using different definitions of cell contents.
  * `gs_deauth()` is a newly exported function that allows you to suspend the current token and, optionally, disable the `.httr-oauth` token cache file by renaming it to `.httr-oauth-SUSPENDED`.
