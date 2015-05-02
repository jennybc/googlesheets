## 2015-04-30
## Google is forcibly converting old sheets to new sheets

## But this process is incomplete, so we have not yet completely abandoned
## support of old sheets.

## However, *our* old test sheet keeps getting forcibly converted, causing tests
## to fail out of the blue. I am sick of these failures and the manual process
## of creating new old sheets.

## So I'm going to check if the old sheet has been forcibly converted and, if
## so, simply skip the affected  tests.

## Every now and then, I'll create a fresh old sheet so all tests can run.
## Hopefully before long Google's process will be complete and we can rip out
## everything re: old sheets.

## Also, our old sheet tests only work if the old sheet shows up in the
## spreadsheets feed, which requires that we have recently viewed it in the
## browser, since it is owned by rpackagetest and not gspreadr. So we check for
## that as well and, if not true, skip.

# https://github.com/jennybc/googlesheets/issues/107

## NOTE: old_title is defined in helper01 !!!

check_old_sheet <- function() {
  ss_df <- gs_ls()
  if(!(old_title %in% ss_df$sheet_title)) {
    skip(sprintf("Old sheet \"%s\" doesn't appear in the spreadsheets feed.",
                 old_title))
  } else {
    here_i_am <- old_title == ss_df$sheet_title
    if(ss_df$version[here_i_am] == "new") {
      skip(sprintf("Old sheet \"%s\" has been converted to a new sheet again.",
                   old_title))
    }
  }
}
