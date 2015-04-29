#' Get a listing of permissions for a spreadsheet
#'
#' This function returns the information available from the 
#' \href{https://developers.google.com/drive/v2/reference/permissions}{permissions
#' feed} of the Google Drive API.
#' 
#' This listing gives the user all permissions for a spreadsheet. 
#' The first row will always be the permission for the owner of the spreadsheet.
#' Any additional permissions follow. 
#' 
#' @param ss a registered Google spreadsheet
#' 
#' @return a tbl_df, one row per permission
#' 
#' @examples
#' \dontrun{
#' foo <- new_ss("foo")
#' list_perm(foo)
#' }
#' 
#' @export
list_perm <- function(ss) {
  
  the_url <- paste("https://www.googleapis.com/drive/v2/files", ss$sheet_key, 
                   "permissions", sep = "/")
  
  req <- gdrive_GET(the_url)
  
  req$content$items %>% 
    plyr::ldply(function(x) dplyr::as_data_frame(x)) %>% 
    dplyr::tbl_df() %>%
    dplyr::select_(~ name, email = ~ emailAddress, ~ role, ~ type, 
                   perm_id = ~ id, ~ selfLink, ~ kind, ~ etag, ~ domain)
}


#' Add a permission to a spreadsheet
#' 
#' An email will be sent automatically to the subject to notify them of the 
#' permission. 
#' 
#' @param name The email address or domain name for the entity.
#' @param type The account type. Allowed values "user", "group", "domain", or 
#'    "anyone".
#' @param role The primary role for this user. Allowed values are: "owner", 
#'    "writer", or "reader".
#' @param with_link boolean, whether the link is required for this permission
#' @param verbose logical, do you want informative messages?
#' 
#' @return Information about newly added permission
#' 
#' @examples
#' \dontrun{
#' foo <- new_ss("foo")
#' 
#' # Add someone as a writer/reader:
#' add_perm(foo, value = "someone@@gmail.com", type = "user", role = "writer")
#' add_perm(foo, value = "someone@@gmail.com", type = "user", role = "reader")
#' 
#' # Add anyone as a writer/reader:
#' add_perm(foo, value = NULL, type = "anyone", role = "writer")
#' add_perm(foo, value = NULL, type = "anyone", role = "reader")
#' 
#' # Add a domain as reader:
#' add_perm(foo, value = "hotmail.com", type = "domain", role = "reader")
#' 
#' # Add a group as reader/writer:
#' add_perm(foo, value = "some_cool_group@@googlegroups.com", type = "group", role = "reader")
#' add_perm(foo, value = "some_cool_group@@googlegroups.com", type = "group", role = "writer")
#' 
#' }
#' 
#' @export 
add_perm <- function(ss, name = NULL, type = NULL, role = NULL,
                     with_link = TRUE, verbose = TRUE) {
  
  the_url <- list_perm(ss)$selfLink %>% dirname() %>% unique()
  
  stopifnot(length(the_url) == 1L)
  
  # inserts a permission for a file
  req <- gdrive_POST(the_url,
                     body = list("value" = name, 
                                 "type" = type,
                                 "role" = role,
                                 "withLink" = with_link))
  
  new_perm_id <- req %>% httr::content() %>% '[['("id")
  
  perm <- ss %>% get_perm(new_perm_id)
  
  if(perm$type == "anyone") {
    who <- perm$type
  } else {
    if(!is.na(perm$email)) {
      who <- perm$email
    } else {
      who <- paste(perm$type, perm$name, sep = ":")
    }
  }
  
  if(req$status_code == 200 & verbose) {
    message(sprintf("Success. New Permission added for %s as a %s.", 
                    who, perm$role))
  }
  
  # cant think of why with_link would be FALSE ...
  if(with_link) {
    share_link <- paste(ss$links$href[1] %>% dirname(), "edit?usp=sharing", sep = "/")
    message(sprintf("Sharing Link: %s", share_link)) 
  }
  
  perm
}


#' Update an existing permission
#'
#' Assign a new role to an existing user permission. This function is used when 
#' you want to change "writer" to a "reader" and vice versa.
#' 
#' @param ss a registered Google Spreadsheet
#' @param perm_id The ID for the permission.
#' @param role The primary role for this user. Allowed values are "owner", 
#' "reader", and "writer".
#' @param verbose logical; do you want informative messages?
#' 
#' @export
edit_perm <- function(ss, perm_id = NULL , role = "reader", verbose = TRUE) {
  
  perm <- get_perm(ss, perm_id)
  
  # updates a permission
  req <- gdrive_PUT(perm$selfLink,  
                    body = list("role" = role), 
                    encode = "json")
  
  if(is.na(perm$email) && perm$type == "anyone") {
    who <- perm$type
  } else {
    who <- perm$email
  }
  
  if(req$status_code == 200 & verbose) {
    message(sprintf("Success. Permission updated for %s from %s to %s.", 
                    who, perm$role, role))
  }
}


#' Delete a permission from a spreadsheet
#' 
#' @param email The email address or domain name for the entity.
#' @param perm_id The permission ID
#' @param verbose logical; do you want informative messages?
#' 
#' @export
delete_perm <- function(ss, value = NULL, perm_id = NULL, verbose = TRUE) {
  
  if(!is.null(perm_id)) {
    perm <- ss %>% get_perm(perm_id)
    the_url <- perm$selfLink
  } else {
    if(!is.null(value)) {
      perm <- ss %>% get_perm(value)
      perm_id <- perm$perm_id
      the_url <- perm$selfLink
    } else {
      stop("Need one of email or permission id to identity permission to delete")
    }
  }
  
  gsheets_DELETE(the_url)
  
  if(perm_id %in% list_perm(ss)$perm_id) {
    message("Permission was not deleted, something went wrong.")
  } else {
    ok <- TRUE
  }
  
  if(verbose & ok) {
    message(
      sprintf("Success. Permissions for \"%s\" have been deleted.", 
              value))
  }
}


#' Retrieve a permission from a spreadsheet
#' 
#' @keywords internal
get_perm <- function(ss, info) {
  
  ss_perm <- ss %>% list_perm()
  
  # is info email?
  ind <- match(info, ss_perm$email) %>% as.integer()
  info_type <- "email"
  
  # info is not email, is info perm_id?
  if(is.na(ind)) {
    ind <- match(info, ss_perm$perm_id) %>% as.integer()
    info_type <- "perm_id"
    # info is neither email or perm_id
    if(is.na(ind)) {
      stop(sprintf("Identifying permission by %s: %s not found.", 
                   info_type, info))
    } else {
      message(sprintf("Identifying permission by %s", info_type))
    }
    
  } else {
    message(sprintf("Identifying permission by %s", info_type))
  }
  
  ss_perm[ind, ]
}