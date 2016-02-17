stop_for_content_type <- function(req, expected) {
  actual <- req$headers$`Content-Type`
  if (actual != expected) {
    stop(
      sprintf(
        paste0("Expected content-type:\n%s",
               "\n",
               "Actual content-type:\n%s"),
        expected, actual
      )
    )
  }
  invisible(NULL)
}
