## let these gestate here, unexported ...

gd_metadata <- function(id, auth = TRUE) {
  ## I learned these fields by using the "Try it!" feature here
  ## https://developers.google.com/drive/v3/reference/files/get
  ## use the fields editor, select all
  ## then copy/paste the fields part of the query
  fields <- c("appProperties", "capabilities", "contentHints", "createdTime",
              "description", "explicitlyTrashed", "fileExtension",
              "folderColorRgb", "fullFileExtension", "headRevisionId",
              "iconLink", "id", "imageMediaMetadata", "kind",
              "lastModifyingUser", "md5Checksum", "mimeType",
              "modifiedByMeTime", "modifiedTime", "name", "originalFilename",
              "ownedByMe", "owners", "parents", "permissions", "properties",
              "quotaBytesUsed", "shared", "sharedWithMeTime", "sharingUser",
              "size", "spaces", "starred", "thumbnailLink", "trashed",
              "version", "videoMediaMetadata", "viewedByMe", "viewedByMeTime",
              "viewersCanCopyContent", "webContentLink", "webViewLink",
              "writersCanShare")
  fields <- paste(fields, collapse = ",")
  the_url <- file.path(.state$gd_base_url_files_v3, id)
  the_url <- httr::modify_url(the_url, query = list(fields = fields))
  req <- httr::GET(the_url, include_token_if(auth)) %>%
    httr::stop_for_status()
  httr::content(req)
}

gd_rename <- function(id, to) {
  stopifnot(is.character(to), length(to) == 1L)
  req <- httr::PATCH(file.path(.state$gd_base_url_files_v3, id),
                     google_token(), encode = "json",
                     body = list(name = to)) %>%
    httr::stop_for_status()
  content_as_json_UTF8(req)
}
