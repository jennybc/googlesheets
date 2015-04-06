#' Create a new spreadsheet
#'
#' Create a new (empty) spreadsheet in your Google Drive. The new sheet will
#' contain 1 default worksheet titled "Sheet1".
#'
#' @param title the title for the new sheet
#' @param verbose logical; do you want informative message?
#'   
#' @return a googlesheet object
#' 
#' @examples
#' \dontrun{
#' foo <- new_ss("foo")
#' foo
#' }
#'
#' @export
new_ss <- function(title = "my_sheet", verbose = TRUE) {

  ## TO DO? warn if sheet with same title alredy exists?
  ## right now we proceed quietly, because sheet is identified by key
  
  the_body <- list(title = title,
                   mimeType = "application/vnd.google-apps.spreadsheet")

  req <-
    gdrive_POST(url = "https://www.googleapis.com/drive/v2/files", 
                body = the_body)

  new_sheet_key <- httr::content(req)$id
  ## I set verbose = FALSE here because it seems weird to message "Spreadsheet
  ## identified!" in this context, esp. to do so *before* message confirming
  ## creation
  ss <- identify_ss(new_sheet_key, verbose = FALSE)

  if(verbose) {
    message(sprintf("Sheet \"%s\" created in Google Drive.", ss$sheet_title))
  }

  ss %>%
    register_ss() %>%
    invisible()

}

#' Move spreadsheets to trash on Google Drive
#'
#' You must own a sheet in order to move it to the trash. If you try to delete a
#' sheet you do not own, a 403 Forbidden HTTP status code will be returned; such
#' shared spreadsheets can only be moved to the trash manually in the web
#' browser. If you trash a spreadsheet that is shared with others, it will no
#' longer appear in any of their Google Drives. If you delete something by
#' mistake, remain calm, and visit the
#' \href{https://drive.google.com/drive/#trash}{trash in Google Drive}, find the
#' sheet, and restore it.
#' 
#' @param x sheet-identifying information, either a googlesheet object or a 
#'   character vector of length one, giving a URL, sheet title, key or 
#'   worksheets feed; if \code{x} is specified, the \code{regex} argument will 
#'   be ignored
#' @param regex character; a regular expression; sheets whose titles match will
#'   be deleted
#' @param ... optional arguments to be passed to \code{\link{grepl}} when
#'   matching \code{regex} to sheet titles
#' @param verbose logical; do you want informative message?
#'
#' @return tbl_df with one row per specified or matching sheet, a variable
#'   holding spreadsheet titles, a logical vector indicating deletion success
#'
#' @note If there are multiple sheets with the same name and you don't want to
#'   delete them all, identify the sheet to be deleted via key.
#'
#' @examples
#' \dontrun{
#' foo <- new_ss("foo")
#' foo <- edit_cells(foo, input = head(iris))
#' delete_ss("foo")
#' }
#'
#' @export
delete_ss <- function(x = NULL, regex = NULL, verbose = TRUE, ...) {

  ## this can be cleaned up once identify_ss() becomes less rigid

  if(!is.null(x)) {

    ## I set verbose = FALSE here mostly for symmetry with new_ss
    x_ss <- x %>%
      identify_ss(verbose = FALSE)
    # this will throw error if no sheet is uniquely identified; tolerate for
    # now, but once identify_ss() is revised, add something here to test whether
    # we've successfully identified at least one sheet for deletion; to delete
    # multiple sheets or avoid error in case of no sheets, current workaround is
    # to use the regex argument
    if(is.na(x_ss$alt_key)) { ## this is a "new" sheet
      keys_to_delete <-  x_ss$sheet_key
    } else {                     ## this is an "old" sheet
      keys_to_delete <- x_ss$alt_key
    }
    titles_to_delete <- x_ss$sheet_title

  } else {

    if(is.null(regex)) {

      stop("You must specify which sheet(s) to delete.")

    } else {

      ss_df <- list_sheets()
      delete_me <- grepl(regex, ss_df$sheet_title, ...)
      keys_to_delete <-
        ifelse(ss_df$version == "new", ss_df$sheet_key,
               ss_df$alt_key)[delete_me]
      titles_to_delete <- ss_df$sheet_title[delete_me]

      if(length(titles_to_delete) == 0L) {
        if(verbose) {
          sprintf("No matching sheets found.") %>%
            message()
        }
        return(invisible(NULL))
      }
    }
  }

  if(verbose) {
    sprintf("Sheets found and slated for deletion:\n%s",
            titles_to_delete %>%
              paste(collapse = "\n")) %>%
      message()
  }

  the_url <- paste("https://www.googleapis.com/drive/v2/files",
                   keys_to_delete, "trash", sep = "/")

  post <- lapply(the_url, gdrive_POST, body = NULL)
  statii <- post %>% lapluck("status_code")
  sitrep <-
    dplyr::data_frame_(list(ss_title = ~ titles_to_delete,
                            deleted = ~(statii == 200)))

  if(verbose) {
    if(all(sitrep$deleted)) {
      message("Success. All moved to trash in Google Drive.")
    } else {
      sprintf("Oops. These sheets were NOT deleted:\n%s",
              sitrep$ss_title[!sitrep$deleted] %>%
                paste(collapse = "\n")) %>%
        message()
    }
  }

  sitrep %>% invisible()

}


#' Make a copy of an existing spreadsheet
#'
#' You can copy a spreadsheet that you own or a sheet owned by a third party
#' that has been made accessible via the sharing dialog options. If the sheet
#' you want to copy is visible in the listing provided by
#' \code{\link{list_sheets}}, you can specify it by title (or any of the other
#' spreadsheet-identifying methods). Otherwise, you'll have to explicitly
#' specify it by key.
#' 
#' @param from sheet-identifying information, either a googlesheet object or a 
#'   character vector of length one, giving a URL, sheet title, key or 
#'   worksheets feed
#' @param key character string guaranteed to provide unique key of the sheet;
#'   overrides \code{from}
#' @param to character string giving the new title of the sheet; if \code{NULL},
#'   then the copy will be titled "Copy of ..."
#' @param verbose logical; do you want informative message?
#'
#' @note if two sheets with the same name exist in your Google drive then sheet
#'   with the most recent "last updated" timestamp will be copied.
#'
#' @seealso \code{\link{identify_ss}}, \code{\link{extract_key_from_url}}
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "Gapminder_copy")
#' gap_ss
#' }
#'
#' @export
copy_ss <- function(from, key = NULL, to = NULL, verbose = TRUE) {

  if(is.null(key)) { # figure out the sheet from 'from ='
    from_ss <- from %>% identify_ss()
    if(is.na(from_ss$alt_key)) { ## this is a "new" sheet
      key <-  from_ss$sheet_key
    } else {                     ## this is an "old" sheet
      key <- from_ss$alt_key
    }
    title <- from_ss$sheet_title
  } else {           # else ... take key at face value
    title <- key
  }

  the_body <- list("title" = to)

  the_url <-
    paste("https://www.googleapis.com/drive/v2/files", key, "copy", sep = "/")

  req <- gdrive_POST(the_url, body = the_body)

  new_title <- httr::content(req)$title

  ## see new_ss() for why I set verbose = FALSE here
  new_ss <- try(new_title %>% identify_ss(verbose = FALSE), silent = TRUE)

  cannot_find_sheet <- inherits(new_ss, "try-error")

  if(verbose) {
    if(cannot_find_sheet) {
      message("Cannot verify whether spreadsheet copy was successful.")
    } else {
      message(sprintf("Successful copy! New sheet is titled \"%s\".",
                      new_ss$sheet_title))
    }
  }

  if(cannot_find_sheet) {
    invisible(NULL)
  } else {
    new_ss %>%
      register_ss(verbose = verbose) %>%
      invisible()
  }

}

#' Add a new (empty) worksheet to spreadsheet
#'
#' Add a new (empty) worksheet to spreadsheet: specify title and worksheet
#' extent (number of rows and columns). The title of the new worksheet can not
#' be the same as any existing worksheets in the sheet.
#'
#' @param ss a registered Google sheet
#' @param ws_title character string for title of new worksheet
#' @param nrow number of rows (default is 1000)
#' @param ncol number of columns (default is 26)
#' @param verbose logical; do you want informative message?
#'   
#' @return a googlesheet object, resulting from re-registering the host
#'   spreadsheet after adding the new worksheet
#'
#' @examples
#' \dontrun{
#' # get a copy of the Gapminder spreadsheet
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "Gapminder_copy")
#' gap_ss <- add_ws(gap_ss, ws_title = "Atlantis")
#' gap_ss
#' }
#'
#' @export
add_ws <- function(ss, ws_title = "Sheet1",
                   nrow = 1000, ncol = 26, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  ws_title_exist <- ws_title %in% list_ws(ss)

  if(ws_title_exist) {
    stop(sprintf(paste("A worksheet titled \"%s\" already exists, please",
                       "choose a different name."), ws_title))
  }

  the_body <-
    XML::xmlNode("entry",
                 namespaceDefinitions =
                   c("http://www.w3.org/2005/Atom",
                     gs = "http://schemas.google.com/spreadsheets/2006"),
                 XML::xmlNode("title", ws_title),
                 XML::xmlNode("gs:rowCount", nrow),
                 XML::xmlNode("gs:colCount", ncol))

  the_body <- XML::toString.XMLNode(the_body)

  req <- gsheets_POST(ss$ws_feed, the_body)

  ss_refresh <- ss %>% register_ss(verbose = FALSE)

  ws_title_exist <- ws_title %in% list_ws(ss_refresh)

  if(verbose) {
    if(ws_title_exist) {
      message(sprintf("Worksheet \"%s\" added to sheet \"%s\".",
                      ws_title, ss_refresh$sheet_title))
    } else {
      message(sprintf(paste("Cannot verify whether worksheet \"%s\" was added",
                            "to sheet \"%s\"."), ws_title,
                      ss_refresh$sheet_title))
    }
  }

  if(ws_title_exist) {
    ss_refresh %>% invisible()
  } else {
    NULL
  }

}

#' Delete a worksheet from a spreadsheet
#'
#' The worksheet and all of its contents will be removed from the spreadsheet.
#'
#' @inheritParams get_via_lf
#' @param verbose logical; do you want informative message?
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "gap_copy")
#' list_ws(gap_ss)
#' gap_ss <- add_ws(gap_ss, "new_stuff")
#' gap_ss <- edit_cells(gap_ss, "new_stuff", input = head(iris), header = TRUE,
#'                      trim = TRUE)
#' gap_ss
#' gap_ss <- delete_ws(gap_ss, "new_stuff")
#' list_ws(gap_ss)
#' gap_ss <- delete_ws(gap_ss, ws = 3)
#' list_ws(gap_ss)
#' delete_ss(gap_ss)
#' }
#'
#' @export
delete_ws <- function(ss, ws = 1, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  this_ws <- ss %>% get_ws(ws)

  req <- gsheets_DELETE(this_ws$ws_id)

  ss_refresh <- ss %>% register_ss(verbose = FALSE)

  ws_title_exist <- this_ws$ws_title %in% list_ws(ss_refresh)

  if(verbose) {
    if(ws_title_exist) {
      message(sprintf(paste("Cannot verify whether worksheet \"%s\" was",
                            "deleted from sheet \"%s\"."),
                      this_ws$ws_title, ss_refresh$sheet_title))
    } else {
      message(sprintf("Worksheet \"%s\" deleted from sheet \"%s\".",
                      this_ws$ws_title, ss$sheet_title))
    }
  }

  if(ws_title_exist) {
    NULL
  } else {
    ss_refresh %>% invisible()
  }

}

#' Rename a worksheet
#'
#' Give a worksheet a new title that does not duplicate the title of any
#' existing worksheet within the spreadsheet.
#'
#' @param ss a registered Google sheet
#' @param from positive integer or character string specifying index or title, 
#' respectively, of the worksheet
#' @param to character string for new title of worksheet
#' @param verbose logical; do you want informative message?
#'
#' @note Since the edit link is used in the PUT request, the version path in the
#'   url changes everytime changes are made to the worksheet, hence consecutive
#'   function calls using the same edit link from the same sheet object without
#'   'refreshing' it by re-registering results in a HTTP 409 Conflict.
#'
#' @examples
#' \dontrun{
#' gap_key <- "1HT5B8SgkKqHdqHJmn5xiuaC04Ngb7dG9Tv94004vezA"
#' gap_ss <- copy_ss(key = gap_key, to = "gap_copy")
#' list_ws(gap_ss)
#' gap_ss <- rename_ws(gap_ss, from = "Oceania", to = "ANZ")
#' list_ws(gap_ss)
#' gap_ss <- rename_ws(gap_ss, from = 1, to = "I am the first sheet!")
#' list_ws(gap_ss)
#' delete_ss(gap_ss)
#' }
#'
#' @export
rename_ws <- function(ss, from = 1, to, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  this_ws <- ss %>% get_ws(from)
  from_title <- this_ws$ws_title

  req <- modify_ws(ss, from = from, to = to)
  ## req carries updated info about the affected worksheet ... but I find it
  ## easier to just re-register the spreadsheet

  Sys.sleep(1)
  ss_refresh <- ss %>% register_ss(verbose = FALSE)

  from_is_gone <- !(from_title %in% list_ws(ss_refresh))
  to_is_there <- to %in% list_ws(ss_refresh)

  if(verbose) {
    if(from_is_gone && to_is_there) {
      message(sprintf("Worksheet \"%s\" renamed to \"%s\".", from_title, to))
    } else {
      message(sprintf(paste("Cannot verify whether worksheet \"%s\" was",
                            "renamed to \"%s\"."), from_title, to))
    }
  }

  if(from_is_gone && to_is_there) {
    ss_refresh %>% invisible()
  } else {
    NULL
  }

}

#' Resize a worksheet
#'
#' Set the number of rows and columns of a worksheet. We use this function
#' internally during cell updates, if the data would exceed the current
#' worksheet extent. It is possible a user might want to use this directly?
#'
#' @inheritParams get_via_lf
#' @param row_extent integer for new row extent
#' @param col_extent integer for new column extent
#' @param verbose logical; do you want informative message?
#'
#' @note Setting rows and columns to less than the current worksheet dimensions
#'   will delete contents without warning!
#'
#' @examples
#' \dontrun{
#' yo <- new_ss("yo")
#' yo <- edit_cells(yo, input = head(iris), header = TRUE, trim = TRUE)
#' get_via_csv(yo)
#' yo <- resize_ws(yo, ws = "Sheet1", row_extent = 5, col_extent = 4)
#' get_via_csv(yo)
#' yo <- resize_ws(yo, ws = 1, row_extent = 3, col_extent = 3)
#' get_via_csv(yo)
#' yo <- resize_ws(yo, row_extent = 2, col_extent = 2)
#' get_via_csv(yo)
#' delete_ss(yo)
#' }
#'
#' @keywords internal
resize_ws <- function(ss, ws = 1,
                      row_extent = NULL, col_extent = NULL, verbose = TRUE) {

  stopifnot(ss %>% inherits("googlesheet"))

  this_ws <- ss %>% get_ws(ws, verbose)
  
  # if row or col extent not specified, make it the same as before
  if(is.null(row_extent)) {
    row_extent <- this_ws$row_extent
  }
  if(is.null(col_extent)) {
    col_extent <- this_ws$col_extent
  }

  req <-
    modify_ws(ss, ws,
              new_dim = c(row_extent = row_extent, col_extent = col_extent))

  new_row_extent <- req$content$rowCount %>% as.integer()
  new_col_extent <- req$content$colCount %>% as.integer()

  success <- all.equal(c(new_row_extent, new_col_extent),
                       c(row_extent, col_extent))

  if(verbose && success) {
    message(sprintf("Worksheet \"%s\" dimensions changed to %d x %d.",
                    this_ws$ws_title, new_row_extent, new_col_extent))
  }

  if(success) {
    ss %>%
      register_ss(verbose = FALSE) %>%
      invisible()
  } else{
    NULL
  }
}

#' Modify a worksheet's title or size
#'
#' @inheritParams get_via_lf

#' @param ss a registered Google sheet
#' @param from positive integer or character string specifying index or title, 
#' respectively, of the worksheet
#' @param to character string for new title of worksheet
#' @param new_dim list of length 2 specifying the row and column extent of the
#'   worksheet
#'
#' @keywords internal
modify_ws <- function(ss, from, to = NULL, new_dim = NULL) {

    stopifnot(ss %>% inherits("googlesheet"))

    this_ws <- ss %>% get_ws(from, verbose = FALSE)

    # don't want return value converted to a list, keep as XML, make edits,send
    # back via PUT
    req <- gsheets_GET(this_ws$ws_id, to_list = FALSE)
    contents <- req %>%
      httr::content() %>%
      XML::toString.XMLNode()

    if(!is.null(to)) { # our purpose is to rename a worksheet

      if(to %in% list_ws(ss)) {
        stop(sprintf(paste("A worksheet titled \"%s\" already exists in sheet",
                           "\"%s\". Please choose another worksheet title."),
                     to, ss$sheet_title))
      }
      
      ## TO DO: we should probably be doing something more XML-y here, instead
      ## of doing XML --> string --> regex based subsitution --> XML
      title_replacement <- paste0("\\1", to, "\\3")
      the_body <- contents %>%
        sub("(<title type=\"text\">)(.*)(</title>)", title_replacement, .)
    }

    if(!is.null(new_dim)) { # our purpose is to resize a worksheet
      
      row_replacement <- paste0("\\1", new_dim["row_extent"], "\\3")
      col_replacement <- paste0("\\1", new_dim["col_extent"], "\\3")
      
      the_body <- contents %>%
        sub("(<gs:rowCount>)(.*)(</gs:rowCount>)", row_replacement, .) %>%
        sub("(<gs:colCount>)(.*)(</gs:colCount>)", col_replacement, .)
    }

  gsheets_PUT(this_ws$edit, the_body)

}

#' Upload a file and convert it to a Google Sheet
#'
#' Google supports the following file types to be converted to a Google
#' spreadsheet: .xls, .xlsx, .csv, .tsv, .txt, .tab, .xlsm, .xlt, .xltx, .xltm,
#' .ods. The newly uploaded file will appear in the top level of your Google
#' Sheets home screen.
#'
#' @param file the file to upload, if it does not contain the absolute path,
#' then the file is relative to the current working directory
#' @param sheet_title the title of the spreadsheet; optional,
#' if not specified then the name of the file will be used
#' @param verbose logical; do you want informative message?
#'
#' @examples
#' \dontrun{
#' write.csv(head(iris, 5), "iris.csv", row.names = FALSE)
#' iris_ss <- upload_ss("iris.csv")
#' iris_ss
#' get_via_lf(iris_ss)
#' file.remove("iris.csv")
#' delete_ss(iris_ss)
#' }
#'
#' @export
upload_ss <- function(file, sheet_title = NULL, verbose = TRUE) {

  if(!file.exists(file)) {
    stop(sprintf("\"%s\" does not exist!", file))
  }

  ext <- c("xls", "xlsx", "csv", "tsv", "txt", "tab", "xlsm", "xlt",
           "xltx", "xltm", "ods")

  if(!(tools::file_ext(file) %in% ext)) {
    stop(sprintf(paste("Cannot convert file with this extension to a Google",
                       "Spreadsheet: %s"), tools::file_ext(file)))
  }

  if(is.null(sheet_title)) {
    sheet_title <- file %>% basename() %>% tools::file_path_sans_ext()
  }

  req <-
    gdrive_POST(url = "https://www.googleapis.com/drive/v2/files", 
                body = list(title = sheet_title, 
                            mimeType = "application/vnd.google-apps.spreadsheet"))

  new_sheet_key <- httr::content(req)$id

  # append sheet_key to put_url
  put_url <- httr::modify_url("https://www.googleapis.com/",
                              path = paste0("upload/drive/v2/files/",
                                            new_sheet_key))

  gdrive_PUT(put_url, the_body = file)

  ss_df <- list_sheets()
  success <- new_sheet_key %in% ss_df$sheet_key

  if(success) {
    if(verbose) {
      message(sprintf(paste("\"%s\" uploaded to Google Drive and converted",
                            "to a Google Sheet named \"%s\""),
                      basename(file), sheet_title))
    }
  } else {
    stop(sprintf("Cannot confirm the file upload :("))
  }

  new_sheet_key %>%
    register_ss(verbose = FALSE) %>%
    invisible()

}
