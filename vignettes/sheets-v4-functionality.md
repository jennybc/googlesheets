


```r
library(googlesheets)
```

```r
options(stringsAsFactors = FALSE)

# issues with package default client id and secret having enabled the V4 Sheets API
# using different client instead
options(googlesheets.client_id = '127208642922-0inefa6gok5hv9sl3hkaqtd72prmdtq2.apps.googleusercontent.com')
options(googlesheets.client_secret = 'yesQYnuvMSoRIr_0LJOhL51o')
```


```r
gap_ss <- gs_copy(gs_gap(), to = "Gapminder")
#> Successful copy! New sheet is titled "Gapminder".
```

```r

# cut and paste the value from A1 into A2
gs_cut_paste(gap_ss, source = "A1", anchor = "A2") # assumes sheet 0

# cut and paste across sheets
gs_cut_paste(gap_ss, source = "Africa!A1", anchor = "Americas!A2")

```

```r

# copy and paste 
gs_copy_paste(gap_ss, source = "A1", destination = "A4") # assumes sheet 0

# copy and paste and notice how the larger source expands past the destination
# larger sources will expand automatically and smaller sources will be recycled 
gs_copy_paste(gap_ss, source = "Africa!A1:C2", destination = "Americas!A1")

```

```r

# all of the typical pastespecial functions are available through the 
# paste_type and paste_orientation arugments
gs_copy_paste(gap_ss, source = "Africa!A1:C2", destination = "Americas!A3", paste_orientation='TRANSPOSE')

```

```r

# insert 2 rows below C3
gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", dim = 2)

# insert those 2 rows above now
gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", dim = 2, side = 'above')

# insert the first 6 rows of the iris dataset below C3
gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", input = head(iris))

# other examples that mess with how inputs without dimensions can be 
# inserted row-wise vs. column-wise
gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3,4,5,6))
gs_insert_rows(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3,4,5,6), byrow=TRUE)

```

```r

# these examples are similar to inserting rows except it applies to columns 
# so you can insert to the left or right and paste data into those areas
# in a similar way.
gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", dim = 2)
gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", dim = 2, side = 'left')
gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", input = head(iris))
gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3))
gs_insert_columns(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3), byrow=TRUE)

```

```r

# just like rows and columns can be inserted, so can cells! These will shift 
# other cells to the right or down. 
gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", dim = c(2,2))
gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", dim = c(2,2), shift_direction = 'down')
gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", input = iris[1:2,1:2])
gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3))
gs_insert_cells(gap_ss, ws = "Africa", anchor = "C3", input = c(1,2,3), byrow=TRUE, shift_direction = 'down')

```

```r

gs_delete_rows(gap_ss, ws = "Africa", range = "A2:F4")
gs_delete_rows(gap_ss, ws = "Africa", range = cell_rows(1:3))

```

```r

gs_delete_columns(gap_ss, ws = "Africa", range = "A2:C4")
gs_delete_columns(gap_ss, ws = "Africa", range = cell_cols(1:2))

```

```r

gs_delete_cells(gap_ss, ws = "Africa", range = "C3:E5")
gs_delete_cells(gap_ss, ws = "Africa", range = "B3:B5", shift_direction = 'up')

```

```r


# cells can be merged in a variety of ways, like merging across each row
# or each column in the range, or just merging into one massive blob, but watch 
# out only data from the top left cell will be retained
gs_merge_cells(gap_ss, ws = 1, range = "A1:B2")
gs_merge_cells(gap_ss, ws = "Africa", range = "A5:E10", merge_type="MERGE_ROWS")
gs_merge_cells(gap_ss, ws = "Africa", range = "A11:C15", merge_type="MERGE_COLUMNS")

# if you have a spreadsheet with lots of merges, have no fear, we can easily
# remove all those by referencing a particular range, sheet, or even the 
# entire spreadsheet
gs_unmerge_cells(gap_ss, ws = "Africa", range = "A11:C15")
gs_unmerge_cells(gap_ss, ws = "Africa", range = "A5:E10")
gs_unmerge_cells(gap_ss, ws = 1, range = "A1:B2")

# you can unmerge all cells on a worksheet
gs_unmerge_cells(gap_ss, ws = 1)
#> No merged ranges were found in this spreadsheet.
#> NULL

# or even unmerge all cells in the entire spreadsheet
gs_unmerge_cells(gap_ss)
#> No merged ranges were found in this spreadsheet.
#> NULL
```

```r

gs_insert_note(gap_ss, ws = 1, range = "A1", note = "Test Note")

# you can specify more than one note at a time
gs_insert_note(gap_ss, ws = 1, range = "E1:E2", note = c("Note- E1", "Note - E2"))

# if the notes argument has a length fewer than the number of cells in the 
# supplied range, then the note will be recycled
gs_insert_note(gap_ss, ws = 1, range = "B1:D4", note = "Hello, This is a Note Test!")

gs_clear_note(gap_ss, ws = 1, range = "A1:B2")
gs_clear_note(gap_ss, ws = 1, range = cell_rows(3))
gs_clear_note(gap_ss, ws = 1)

```

```r

gs_add_named_range(gap_ss, name = "RangeAtAfricaA2", range = "Africa!A2")

# check the named ranges that exist in our sheet
gs_get_named_range(gap_ss)
#>   namedRangeId            name range.sheetId range.startRowIndex
#> 1    667099280 RangeAtAfricaA2    1150108545                   1
#>   range.endRowIndex range.startColumnIndex range.endColumnIndex
#> 1                 2                      0                    1

# make multiple updates to this range we initially created
gs_update_named_range(gap_ss, named_range = "RangeAtAfricaA2", name = "RangeAtAfricaA3", range = "Africa!A3")
gs_update_named_range(gap_ss, named_range = "RangeAtAfricaA3", name = "Range1")
gs_update_named_range(gap_ss, named_range = "Range1", range = "Africa!A4")

# confirm our updates
gs_get_named_range(gap_ss)
#>   namedRangeId   name range.sheetId range.startRowIndex range.endRowIndex
#> 1    667099280 Range1    1150108545                   3                 4
#>   range.startColumnIndex range.endColumnIndex
#> 1                      0                    1

gs_delete_named_range(gap_ss, named_range = "Range1")
gs_get_named_range(gap_ss)
#> data frame with 0 columns and 0 rows
```

```r

gs_add_protected_range(gap_ss, range = "Africa!A1", description = "PR - Test")
gs_add_protected_range(gap_ss, range = cell_limits(sheet="Africa")) # protect whole sheet!
#> Error in gsv4_ProtectedRange(description = description, range = prepped_range, : argument "description" is missing, with no default

# check the sheets we protected
# note that if the editors are not specified at least the creator is 
# listed as the sole editor
gs_get_protected_range(gap_ss)
#>   protectedRangeId range.sheetId range.startRowIndex range.endRowIndex
#> 1       1115893113    1150108545                   0                 1
#>   range.startColumnIndex range.endColumnIndex description
#> 1                      0                    1   PR - Test
#>   requestingUserCanEdit                                 editors
#> 1                  TRUE steven.mortimer@dominionenterprises.com

gs_update_protected_range(gap_ss, protected_range = "PR - Test", range = "Africa!A2")
gs_update_protected_range(gap_ss, protected_range = "PR - Test", description = "PR - Test2")
gs_update_protected_range(gap_ss, protected_range = "PR - Test2", named_range = 'Range1')
#> Error in gs_update_protected_range(gap_ss, protected_range = "PR - Test2", : A named range could not be found in the spreadsheet by id or name: Range1

gs_delete_protected_range(gap_ss, protected_range = "PR - Test2")

# delete based on an Id and not the range's description
# note that protected ranges have "descriptions" and named ranges have "names"
# as their character string reference aside from their Id
pr <- gs_get_protected_range(gap_ss)
gs_delete_protected_range(gap_ss, protected_range = pr$protectedRangeId[1])
#> Error: length(protected_range) == 1 is not TRUE
gs_get_protected_range(gap_ss)
#> data frame with 0 columns and 0 rows
```

```r

gs_set_basic_filter(gap_ss, ws = 1)

# an example where the filter does not extend through every column, just the 
# columns specified (3 thru 6) where the first column of that range is 
# filtered to be a number less than 1970
gs_set_basic_filter(gap_ss, ws = 1, range = cell_cols(3:6), criteria=list(list(1, "NUMBER_LESS", 1970)))

# a more complicated example that creates the filter with two criteria on 
# different columns and sorts the third column in descending order
gs_set_basic_filter(gap_ss, ws = "Americas",
                    sort_spec = list(list(3, "DESCENDING")),
                    criteria = list(list(4, "NUMBER_LESS", 50),
                                    list(6, "NUMBER_GREATER_THAN_EQ", 1000)))

gs_set_basic_filter(gap_ss, ws = "Americas", range = cell_cols(3:6), sort_spec=list(list(2, "DESCENDING")))

gs_clear_basic_filter(gap_ss, ws = 1)
gs_clear_basic_filter(gap_ss, ws = "Americas")

```

```r

# if rows 1 thru 4 are blank, then autofill up based on row 5
# if rows 2 thru 5 are blank, then autofill down based on row 1
gs_autofill(gap_ss, ws = 1, range = cell_rows(1:5))

# autofill columns 6 & 7 based on column 5
gs_autofill(gap_ss, ws = 1, range = cell_cols(5:7))

```

```r

gs_clear_cells(gap_ss, ws = 1, range = "A1:B2")

# clear cell values in A1 on every worksheet
gs_clear_cells(gap_ss, range = "A1")

# clear cell formatting in the first 2 rows
gs_clear_cells(gap_ss, ws = 1, range = cell_rows(1:2), clear_type = 'formats')

# you can clear all cells on a worksheet
gs_clear_cells(gap_ss, ws = 1)

# or even clear all cell values in the entire spreadsheet
gs_clear_cells(gap_ss, clear_type = 'values')

# or the nuclear option to clear values, formats, all cell data across all worksheets
gs_clear_cells(gap_ss, clear_type = 'all')
```

