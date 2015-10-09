## not exported
## use upstream of Google Drive API, which requires a sheet's alternate key
gs_get_alt_key <- function(x) {

  if(x$version == "new") {
    x$sheet_key
  } else {
    if(is.na(x$alt_key)) {
      paste("This googlesheet object is missing the alternate sheet",
            "key necessary to perform this operation on an \"old\" Google",
            "Sheet. The alternate key can only be learned from the",
            "spreadsheets feed and, therefore with authorization.",
            "Re-register the sheet in a way that allows information",
            "to be looked up in the spreadsheet feed and try again.",
            "See the help for functions gs_title(), gs_key(), etc.") %>%
        stop()
    } else {
      x$alt_key
    }
  }

}
