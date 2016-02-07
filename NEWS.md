# googlesheets 0.1.0.9000

* Added a `NEWS.md` file to track changes to the package.
* To become compatible with `httr v1.1.0`, we now require that version.
* `gs_read_csv()` and `gs_read(..., range = NULL)` now parse the sheet contents via `readr::read_csv()` instead of `read.csv()`, which has fairly different default behavior. Here's what to expect:
  - __Main message:__ Take control of data ingest via `readr` through the `...` argument. For example, you can use `col_types` to specify how variables should be treated: `gs_read(ss, ws, col_types = "cc")` will bring the two variables in as character. Read the [`readr` vignette on column types](https://cran.r-project.org/web/packages/readr/vignettes/column-types.html) to better understand its variable conversion behaviour.
  - To explicitly indicate presence/absence of column names use the `col_names` argument instead of `header`. Example: `col_names = FALSE` instead of `header = FALSE`.
  - Columns that look like dates or date-times will, by default, be read in as such (vs. as character). 
  - Columns that consist entirely of empty cells will be *character* instead of *logical*, i.e. the `NA`s will be `NA_character_` vs `NA`.
  - "Column names are left as is, not munged into valid R identifiers (i.e. there is no check.names = TRUE)." This means you can get column names that are `NA`. I am considering adding an argument to `gs_read*()` functions to request that variable names be processed through `make.names()` or similar.
* `gs_add_row()` now works for two-dimensional `input`, by calling itself once per row of input (#188, @jimhester).

