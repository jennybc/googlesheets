## cell specification functions that are specific to googlesheets, i.e. stuff
## not handled in cellranger

## basically boils down to:
## cell_limits object <--> limits in the list form I need for Sheets API query

limit_list <- function(x) {

  stopifnot(inherits(x, "cell_limits"))

  list(`min-row` = x$rows[1], `max-row` = x$rows[2],
       `min-col` = x$cols[1], `max-col` = x$cols[2])
}

un_limit_list <- function(x) {

  cellranger::cell_limits(rows = c(x[['min-row']], x[['max-row']]),
                          cols = c(x[['min-col']], x[['max-col']]))

}
