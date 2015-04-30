#' Get a listing of permissions for a spreadsheet
#'
#' This function returns the information available from the 
#' \href{https://developers.google.com/drive/v2/reference/permissions}{permissions
#' feed} of the Google Drive API.
#' 
#' This listing gives the user all the permissions for a spreadsheet. A 
#' simplified viewing is available in the sharing dialog of a Google Sheet. 
#' 
#' The first row will always be the permission for the owner of the spreadsheet. 
#' Any additional permissions follow. 
#' 
#' A permission for a sheet includes the following information: the name for 
#' this permission, the email of the user or group the permission refers to, the 
#' primary role for the user, any additional roles they have, the type of user 
#' they are, the (unique) ID of the user this permission refers to, a link 
#' back to this permission, and the ETag of the permission.
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
  
  tbl <- req$content$items %>% 
    plyr::ldply(function(x) dplyr::as_data_frame(x))
  
  if(is.null(tbl$additionalRoles)) {
    
    perm_tbl <- tbl %>% 
      dplyr::select_(~ name, email = ~ emailAddress, ~ domain, ~ type, 
                     ~ role, perm_id = ~ id, ~ selfLink, ~ etag, ~ kind) 
    
  } else {
    
    add_roles <- plyr::ldply(tbl$additionalRoles, 
                             function(x) ifelse(is.null(x), x <- NA, x))
    
    perm_tbl <- tbl %>% 
      dplyr::bind_cols(add_roles) %>%
      dplyr::select_(~ name, email = ~ emailAddress, ~ domain, ~ type, ~ role,
                     add_roles = ~ V1, perm_id = ~ id, 
                     ~ selfLink, ~ etag, ~ kind)
  }
  
  perm_tbl %>% dplyr::tbl_df()

}


#' Add a permission to a spreadsheet
#' 
#' An email will be sent automatically to the entity to notify them of the 
#' permission. 
#' 
#' Commenting is allowed by default for "owners" and "writers". 
#' Set commenter = TRUE if you want "readers" to be able to comment.
#' 
#' @inheritParams edit_perm
#' @param type The value "user", "group", "domain" or "anyone".
#' @param with_link logical; whether the link is required for this permission
#' @param send_email logical; do you want to send notification emails when 
#' sharing to users or groups?
#' 
#' @return a tbl_df with information about the newly added permission.
#' 
#' @examples
#' \dontrun{
#' foo <- new_ss("foo")
#' 
#' # Add anyone as a writer/reader:
#' add_perm(foo, email = NULL, type = "anyone", role = "writer")
#' add_perm(foo, email = NULL, type = "anyone", role = "reader")
#' }
#' 
#' @export 
add_perm <- function(ss, email = NULL, type = NULL, role = NULL, 
                     commenter = FALSE, with_link = TRUE, 
                     send_email = TRUE, verbose = TRUE) {
  
  the_url <- list_perm(ss)$selfLink %>% dirname() %>% unique()
  
  stopifnot(length(the_url) == 1L)
  
  if(send_email) {
    query <- list("sendNotificationEmails" = send_email)
  } else {
    query <- NULL
  }
  
  if(commenter) {
    comm <- "commenter"
  } else {
    comm <- NULL
  }
  
  req <- gdrive_POST(the_url, query = query,
                     body = list("value" = email, 
                                 "type" = type,
                                 "role" = role,
                                 "withLink" = with_link,
                                 "additionalRoles" = comm))
  
  new_perm_id <- req %>% httr::content() %>% '[['("id")
  
  perm <- ss %>% get_perm(new_perm_id, verbose = FALSE)
  
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
  
  perm
}


#' Update an existing permission
#'
#' Assign a new role to an existing user permission. This function is useful
#' when you want to change roles for an entity from "writer" to a "reader" and 
#' vice versa.
#' 
#' @param ss a registered Google Spreadsheet
#' @param email The email address or domain name for the entity.
#' @param perm_id The ID for the permission.
#' @param role The primary role for this user. Allowed values are "owner", 
#' "reader", and "writer".
#' @param commenter logical; allow the user to comment? This is only effective 
#' if role = "reader".
#' @param verbose logical; do you want informative messages?
#' 
#' @export
edit_perm <- function(ss, email = NULL, perm_id = NULL, 
                      role = "reader", commenter = FALSE, verbose = TRUE) {
  
  if(!is.null(perm_id)) {
    perm <- get_perm(ss, perm_id)
  } else {
    perm <- get_perm(ss, email)
  }
  
  if(commenter) {
    comm <- "commenter"
  } else {
    comm <- NULL
  }
  
  # updates a permission
  req <- gdrive_PUT(perm$selfLink,  
                    body = list("role" = role,
                                "additionalRoles" = comm), 
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
#' Identify the permission to be deleted via email or permission ID.  
#' 
#' @inheritParams edit_perm
#' 
#' @examples
#' \dontrun{
#' foo <- new_ss("foo")
#' add_perm(foo, email = NULL, type = "anyone", role = "reader")
#' delete_perm(foo, email = NA)
#' }
#' 
#' @export
delete_perm <- function(ss, email = NULL, perm_id = NULL, verbose = TRUE) {
  
  if(!is.null(perm_id)) {
    perm <- ss %>% get_perm(perm_id)
    the_url <- perm$selfLink
  } else {
    if(!is.null(email)) {
      perm <- ss %>% get_perm(email)
      perm_id <- perm$perm_id
      the_url <- perm$selfLink
    } else {
      stop("Need one of email or permission id to identity the permission to delete")
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
      sprintf("Success. Permissions for \"%s\" have been deleted.", email))
  }
}


#' Retrieve a permission from a spreadsheet
#' 
#' @param ss a registered Google Spreadsheet
#' @param id identifying info, should be either email or permission ID
#' @param verbose logical; do you want informative messages?
#' 
#' @keywords internal
get_perm <- function(ss, info, verbose = TRUE) {
  
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
      if(verbose) {
        message(sprintf("Identifying permission by %s.", info_type))
      }
    }
    
  } else {
    if(verbose) {
      message(sprintf("Identifying permission by %s.", info_type))
    }
  }
  
  ss_perm[ind, ]
}