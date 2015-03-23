#' Create a new spreadsheet
#' 
#' Create a new (empty) spreadsheet in your Google Drive. The new sheet will 
#' contain 1 default worksheet titled "Sheet1".
#' 
#' @param title the title for the new sheet
#' @param verbose logical; do you want informative message?
#'   
#' @return a partially populated Google spreadsheet object, giving sheet title,
#'   key, and worksheets feed
#'   
#' @export
new_ss <- function(title = "my_sheet", verbose = TRUE) {
  
  the_body <- list(title = title,
                   mimeType = "application/vnd.google-apps.spreadsheet")
  
  req <-
    gdrive_POST(url = "https://www.googleapis.com/drive/v2/files", the_body)
  
  ## I set verbose = FALSE here because it seems weird to message "Spreadsheet
  ## identified!" in this context, esp. to do so *before* message confirming
  ## creation
  ss <- identify_ss(title, verbose = FALSE)
  
  if(verbose) {
    message(sprintf("Sheet \"%s\" created in Google Drive.", ss$sheet_title))
  }
  
  ss %>% register_ss() %>% invisible()
  
}

#' Move spreadsheets to trash on Google Drive
#' 
#' You must own a sheet in order to move it to the trash. If you try to delete a
#' sheet you do not own, a 403 Forbidden HTTP status code will be returned; such
#' shared spreadsheets can only be moved to the trash manually in the web 
#' browser. If you trash a spreadsheet that is shared with others, it will no 
#' longer appear in any of their Google Drives. If you delete something my
#' mistake, visit the \href{https://drive.google.com/drive/#trash}{trash in
#' Google Drive}, find the sheet and restore it.
#' 
#' @param x a regular expression; spreadsheets whose titles match will be moved
#'   to trash
#' @param verbose logical; do you want informative message?
#' @param ... optional arguments to be passed to \code{\link{grepl}}
#'   
#' @return tbl_df with one row per matching sheet, a variable holding
#'   spreadsheet titles, a logical vector indicating deletion success
#'   
#' @export
delete_ss <- function(x, verbose = TRUE, ...) {
  
  ss_df <- list_sheets()
  delete_me <- grepl(x, ss_df$sheet_title, ...)
  keys_to_delete <- ss_df$sheet_key[delete_me]
  titles_to_delete <- ss_df$sheet_title[delete_me]
  
  if(length(keys_to_delete) == 0L) {
    if(verbose) {
      sprintf("No matching sheets found.") %>%
        message()
    }
    return(invisible(NULL))
  }
  
  if(verbose) {
    sprintf("Sheets found and slated for deletion:\n%s",
            titles_to_delete %>%paste(collapse = "\n")) %>%
      message()
  }

  the_url <- paste("https://www.googleapis.com/drive/v2/files",
                   keys_to_delete, "trash", sep = "/")
  
  post <- lapply(the_url, gdrive_POST, the_body = NULL)
  statii <- post %>% lapluck("status_code")
  sitrep <-
    dplyr::data_frame_(list(ss_title = ~ titles_to_delete,
                            deleted = ~(statii == 200)))

  if(verbose) {
    if(all(sitrep$deleted)) {
      message("Success. All moved to trash in Google Drive.")
    } else {
      sprintf("Oops. These sheets were NOT deleted:\n%s",
              sitrep$ss_title[!sitrep$deleted]
              %>% paste(collapse = "\n")) %>%
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
#' @param from sheet-identifying information, either a gspreadsheet object or a 
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
#' @export
copy_ss <- function(from, key = NULL, to = NULL, verbose = TRUE) {
  
  if(is.null(key)) { # figure out the sheet from 'from ='
    from_ss <- from %>% identify_ss()
    key <-  from_ss$sheet_key
    title <- from_ss$sheet_title
  } else {           # else ... take key at face value
    title <- key
  }
  
  the_body <- list("title" = to)

  the_url <-
    paste("https://www.googleapis.com/drive/v2/files", key, "copy", sep = "/")
  
  req <- gdrive_POST(the_url, the_body)
  
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
    new_ss %>% invisible()
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
#' @return a gspreadsheet object, resulting from re-registering the host
#'   spreadsheet after adding the new worksheet
#'   
#' @export
add_ws <- function(ss, ws_title = "Sheet1",
                   nrow = 1000, ncol = 26, verbose = TRUE) { 
  
  stopifnot(ss %>% inherits("gspreadsheet"))
  
  ws_title_exist <- !(match(ws_title, ss$ws[["ws_title"]]) %>% is.na())

  if(ws_title_exist) {
    stop(sprintf("A worksheet titled \"%s\" already exists, please choose a different name.", ws_title))
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
  
  ws_title_exist <- !(match(ws_title, ss_refresh$ws[["ws_title"]]) %>% is.na())
  
  if(verbose) {
    if(ws_title_exist) {
      message(sprintf("Worksheet \"%s\" added to sheet \"%s\".",
                      ws_title, ss_refresh$sheet_title))
    } else {
      message(sprintf("Cannot verify whether worksheet \"%s\" was added to sheet \"%s\".",
                      ws_title, ss_refresh$sheet_title))
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
#' @param ss a registered Google sheet
#' @param ws_title title of worksheet
#' @param verbose logical; do you want informative message?
#' 
#' @export
delete_ws <- function(ss, ws_title, verbose = TRUE) {
  
  stopifnot(ss %>% inherits("gspreadsheet"))
  
  ws_title_position <- match(ws_title, ss$ws$ws_title)
  
  if(is.na(ws_title_position)) {
    stop(sprintf("No worksheet titled \"%s\" found in sheet \"%s\".",
                 ws_title, ss$sheet_title))
  }
  
  req <- gsheets_DELETE(ss$ws$ws_id[ws_title_position])
  
  ss_refresh <- ss %>% register_ss(verbose = FALSE)
  
  ws_title_exist <- !(match(ws_title, ss_refresh$ws[["ws_title"]]) %>% is.na())
  
  if(verbose) {
    if(ws_title_exist) {
      message(sprintf("Cannot verify whether worksheet \"%s\" was deleted from sheet \"%s\".",
                      ws_title, ss_refresh$sheet_title))
    } else {
      message(sprintf("Worksheet \"%s\" deleted from sheet \"%s\".",
                      ws_title, ss$sheet_title))
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
#' @param from character string for current title of worksheet
#' @param to character string for new title of worksheet
#' @param verbose logical; do you want informative message?
#'   
#' @note Since the edit link is used in the PUT request, the version path in the
#'   url changes everytime changes are made to the worksheet, hence consecutive 
#'   function calls using the same edit link from the same sheet object without 
#'   'refreshing' it by re-registering results in a HTTP 409 Conflict.
#'   
#' @export
rename_ws <- function(ss, from, to, verbose = TRUE) {
  
  stopifnot(ss %>% inherits("gspreadsheet"))
  
  ws_title_position <- match(from, ss$ws$ws_title)
  
  if(is.na(ws_title_position)) {
    stop(sprintf("No worksheet titled \"%s\" found in sheet \"%s\".",
                 from, ss$sheet_title))
  }
  
  req <- modify_ws(ss, from = from, to = to)
  ## req carries updated info about the affected worksheet ... but I find it
  ## easier to just re-register the spreadsheet
  
  ss_refresh <- ss %>% register_ss(verbose = FALSE)
  
  from_is_gone <- from %>% match(ss_refresh$ws$ws_title) %>% is.na()
  to_is_there <- !(to %>% match(ss_refresh$ws$ws_title) %>% is.na())
  
  if(verbose) {
    if(from_is_gone && to_is_there) {
      message(sprintf("Worksheet \"%s\" renamed to \"%s\".", from, to))
    } else {
      message(sprintf("Cannot verify whether worksheet \"%s\" was renamed to \"%s\".",
                      from, to))
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
#' Set the number of rows and columns of a worksheet. This function is useful
#' when you need to send a batch update request and the data would exceed 
#' the current worksheet extent. 
#' 
#' This function will probably only be called internally... exporting for now. 
#' 
#' @param ss a registered Google sheet
#' @param ws_title character string for title of worksheet
#' @param row_extent integer for new row extent
#' @param col_extent integer for new column extent
#' @param verbose logical; do you want informative message?
#' 
#' @note Setting rows and columns to less than the current worksheet dimensions 
#' will delete contents without warning.
#' 
#' @export
resize_ws <- function(ss, ws_title,
                      row_extent = NULL, col_extent = NULL, verbose = TRUE) {
  
  stopifnot(ss %>% inherits("gspreadsheet"))
  
  ws_title_position <- match(ws_title, ss$ws$ws_title)
  
  if(is.na(ws_title_position)) {
    stop(sprintf("No worksheet titled \"%s\" found in sheet \"%s\".",
                 ws_title, ss$sheet_title))
  }
  
  # if row or col extent not specified, make it the same as before
  if(is.null(row_extent)) {
    row_extent <- ss$ws$row_extent[ws_title_position]
  }
  if(is.null(col_extent)) {
    col_extent <- ss$ws$col_extent[ws_title_position]
  }
  
  req <-
    modify_ws(ss, ws_title,
              new_dim = c(row_extent = row_extent, col_extent = col_extent))
  
  new_row_extent <- req$content$rowCount %>% as.integer()
  new_col_extent <- req$content$colCount %>% as.integer()
  
  success <- all.equal(c(new_row_extent, new_col_extent),
                       c(row_extent, col_extent))
  
  if(verbose && success) {
    message(sprintf("Worksheet \"%s\" dimensions changed to %d x %d.",
                    ws_title, new_row_extent, new_col_extent))
  }
  
  if(success) {
    ss %>% register_ss(verbose = FALSE) %>% invisible()
  } else{
    NULL
  }

}


#' Modify a worksheet's title or size
#' 
#' @param ss a registered Google sheet
#' @param from character string for current title of worksheet
#' @param to character string for new title of worksheet
#' @param new_dim list of length 2 specifying the row and column extent of the
#'   worksheet
#'   why is this a list? can we use lazy eval here?
#'   
modify_ws <-
  function(ss, from, to = NULL, new_dim = NULL) {

    stopifnot(ss %>% inherits("gspreadsheet"))
    
    ws_title_position <- match(from, ss$ws$ws_title)
    
    # don't want return value converted to a list, keep as XML, make edits,send
    # back via PUT
    req <- gsheets_GET(ss$ws$ws_id[ws_title_position], to_list = FALSE)
    contents <- req %>% httr::content() %>% XML::toString.XMLNode()
    
    if(!is.null(to)) {
      
      to_already_exists <- !(match(to, ss$ws$ws_title) %>% is.na())
      
      if(to_already_exists) {
        stop(sprintf("A worksheet titled \"%s\" already exists in sheet \"%s\". Please choose another worksheet title.",
                     to, ss$sheet_title))
      }
      
      ## TO DO: we should probably be doing something more XML-y here, instead of
      ## doing XML --> string --> regex based subsitution --> XML
      the_body <- contents %>% 
        stringr::str_replace('(?<=<title type=\"text\">)(.*)(?=</title>)', to)
    }
    
    if(!is.null(new_dim)) {
      the_body <- contents %>% 
        stringr::str_replace('(?<=<gs:rowCount>)(.*)(?=</gs:rowCount>)',
                             new_dim["row_extent"]) %>%
        stringr::str_replace('(?<=<gs:colCount>)(.*)(?=</gs:colCount>)',
                             new_dim["col_extent"])         
    }
  
  gsheets_PUT(ss$ws$edit[ws_title_position], the_body)
  
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
#' @export
upload_ss <- function(file, sheet_title = NULL, verbose = TRUE) {
  
  if(!file.exists(file)) {
    stop(sprintf("\"%s\" does not exist!", file))
  }
  
  ext <- c("xls", "xlsx", "csv", "tsv", "txt", "tab", "xlsm", "xlt", 
           "xltx", "xltm", "ods")
  
  if(!(tools::file_ext(file) %in% ext)) {
    stop(sprintf("Cannot convert file with this extension to a Google Spreadsheet: %s",
                 tools::file_ext(file)))
  }
  
  if(is.null(sheet_title)) {
    sheet_title <- file %>% basename() %>% tools::file_path_sans_ext()
  }
  
  req <- gdrive_POST(url = "https://www.googleapis.com/drive/v2/files", 
                     the_body = list(title = sheet_title, 
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
      message(sprintf("\"%s\" uploaded to Google Drive and converted to a Google Sheet named \"%s\"",
                      basename(file), sheet_title))
    }
  } else {
    stop(sprintf("Cannot confirm the file upload :("))
  }
  
  new_sheet_key %>%  register_ss(verbose = FALSE) %>% invisible()
  
}
