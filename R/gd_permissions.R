#' List permissions for a spreadsheet
#'
#' This function lists all the permissions for a spreadsheet, as reported via
#' the
#' \href{https://developers.google.com/drive/v2/reference/permissions}{permissions
#' feed} of the Google Drive API. A simplified view of this information is
#' available in the browser in the sharing dialog of a Google Sheet.
#'
#' The first row corresponds to the owner of the spreadsheet. Permissions for
#' other users or groups, if such exist, follow in additional rows.
#'
#' A permission for a sheet includes the following information: the name for
#' this permission, the email of the user or group the permission refers to, the
#' primary role for the user, any additional roles they have, the type of user
#' they are, the (unique) ID of the user this permission refers to, a link back
#' to this permission, and the ETag of the permission.
#'
#' @template ss
#' @param filter character, optional; the email or unique ID of a user that,
#'   if provided, will be used to filter the results
#'
#' @return a tbl_df, one row per permission
#'
#' @examples
#' \dontrun{
#' foo <- gs_new("foo")
#' gs_perm_ls(foo)
#' gs_delete(foo)
#' }
#'
#' @keywords internal
gs_perm_ls <- function(ss, filter = NULL) {

  url <- file.path(.state$gd_base_url_files_v2, ss$sheet_key, "permissions")
  req <- httr::GET(url, google_token()) %>%
    httr::stop_for_status()
  req <- content_as_json_UTF8(req)

  perm_tbl <- req$items %>%
    dplyr::as.tbl() %>%
    dplyr::rename_(email = ~ emailAddress, perm_id = ~ id)

  if(!is.null(filter)) {
    ind <- ifelse(perm_tbl$email %in% filter,
                  perm_tbl$email %in% filter,
                  perm_tbl$perm_id %in% filter)
    if(any(ind)) {
      perm_tbl <- perm_tbl[ind, ]
    } else {
      spf("No matching permissions found: %s", filter)
    }
  }

  the_vars <- c('email', 'name', 'type', 'role', 'additionalRoles',
                'perm_id', 'domain', 'withLink', 'selfLink', 'etag', 'kind') %>%
    intersect(names(perm_tbl))
  perm_tbl[the_vars]

}

#' Add a permission to a spreadsheet
#'
#' An email will be sent automatically to the entity to notify them of the
#' permission.
#'
#' Commenting is allowed by default for "owners" and "writers".
#' Set commenter = TRUE if you want "readers" to be able to comment.
#'
#' @template ss
#' @param type The value "user", "group", "domain" or "anyone".
#' @param role role
#' @param commenter logical
#' @param with_link logical; whether the link is required for this permission
#' @param send_email logical; do you want to send notification emails when
#' sharing to users or groups?
#' @template verbose
#'
#' @return a tbl_df with information about the newly added permission.
#'
#' @examples
#' \dontrun{
#' foo <- gs_new("foo")
#' gs_perm_ls(foo)
#' # Add anyone as a reader:
#' gs_perm_add(foo, type = "anyone", role = "reader")
#' gs_perm_ls(foo)
#' gs_delete(foo)
#' }
#'
#' @keywords internal
gs_perm_add <- function(ss, email = NULL,
                        type = c("anyone", "user", "domain", "group"),
                        role = c("reader", "writer", "owner"),
                        commenter = FALSE, with_link = TRUE,
                        send_email = TRUE, verbose = TRUE) {

  the_url <- gs_perm_ls(ss)$selfLink %>% dirname() %>% unique()

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

  req <- httr::POST(the_url, google_token(), encode = "json",
                    query = query,
                    body = list("value" = email,
                                "type" = type,
                                "role" = role,
                                "withLink" = with_link,
                                "additionalRoles" = comm))
  httr::stop_for_status(req)
  rc <- content_as_json_UTF8(req)

  perm <- ss %>% gs_perm_ls(filter = rc$id)

  if(perm$type == "anyone") {
    who <- perm$type
  } else {
    if(!is.na(perm$email)) {
      who <- perm$email
    } else {
      who <- paste(perm$type, perm$name, sep = ":")
    }
  }

  if(httr::status_code(req) == 200 && verbose) {
    mpf("Success. New Permission added for \"%s\" as a %s.", who, perm$role)
  }

  invisible(perm)

}


#' Edit an existing permission
#'
#' Assign a new role to an existing user permission. This function is useful
#' when you want to change roles for an entity, e.g., from "writer" to "reader"
#' or vice versa.
#'
#' @template ss
#' @param email The email address or domain name for the entity.
#' @param perm_id The ID for the permission.
#' @param role The primary role for this user. Allowed values are "owner",
#'   "reader", and "writer".
#' @param commenter logical; allow the user to comment? This is only effective
#'   if role = "reader".
#' @template verbose
#'
#' @examples
#' \dontrun{
#' foo <- gs_new("foo")
#' gs_perm_ls(foo)
#' # Add anyone as a reader:
#' gs_perm_add(foo, type = "anyone", role = "reader")
#' gs_perm_ls(foo)
#' # Change anyone to a writer:
#' gs_perm_edit(foo, perm_id = "anyoneWithLink", role = "writer")
#' gs_perm_ls(foo)
#' gs_delete(foo)
#' }
#'
#' @keywords internal
gs_perm_edit <- function(ss, email = NULL, perm_id = NULL,
                         role = "reader", commenter = FALSE, verbose = TRUE) {

  stopifnot(inherits(ss, "googlesheet"),
            !is.null(email) || !is.null(perm_id))

  if(!is.null(perm_id)) {
    perm <- ss %>% gs_perm_ls(perm_id)
  } else {
    perm <- gs_perm_ls(ss, email)
  }

  if(commenter) {
    comm <- "commenter"
  } else {
    comm <- NULL
  }

  # updates a permission
  req <- httr::PUT(perm$selfLink, google_token(),
                   body = list("role" = role,
                               "additionalRoles" = comm),
                   encode = "json") %>%
    httr::stop_for_status()

  if(verbose) {
    if(is.na(perm$email) && perm$type == "anyone") {
      who <- perm$type
    } else {
      who <- perm$email
    }
    if(req$status_code == 200) {
      mpf("Success. Permission updated for %s from %s to %s.",
          who, perm$role, role)
    }
  }

  req$status_code == 200

}


#' Delete a permission from a spreadsheet
#'
#' Identify the permission to be deleted via email or permission ID.
#'
#' @inheritParams gs_perm_edit
#'
#' @examples
#' \dontrun{
#' foo <- gs_new("foo")
#' gs_perm_ls(foo)
#' # Add anyone as a reader:
#' gs_perm_add(foo, type = "anyone", role = "reader")
#' gs_perm_ls(foo)
#' # Remove the permission for anyone
#' gs_perm_delete(foo, perm_id = "anyoneWithLink")
#' gs_delete(foo)
#' }
#'
#' @keywords internal
gs_perm_delete <- function(ss, email = NULL, perm_id = NULL, verbose = TRUE) {

  stopifnot(inherits(ss, "googlesheet"),
            !is.null(email) || !is.null(perm_id))

  if(!is.null(perm_id)) {
    perm <- ss %>% gs_perm_ls(perm_id)
  } else {
    perm <- gs_perm_ls(ss, email)
  }

  req <- httr::DELETE(perm$selfLink, google_token()) %>%
    httr::stop_for_status()

  status <- !(perm$perm_id %in% gs_perm_ls(ss)$perm_id)

  if(verbose) {
    if(status) {
      if(is.na(perm$email) && perm$type == "anyone") {
        who <- perm$type
      } else {
        who <- perm$email
      }
      message(
        sprintf("Success. Permissions for \"%s\" have been deleted.", who))
    } else {
      message("Unable to delete permission.")
    }
  }

  status

}
