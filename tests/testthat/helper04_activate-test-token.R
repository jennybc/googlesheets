## puts the test token into force

activate_test_token <- function(rds_file = test_path("googlesheets_token.rds")) {
  suppressMessages(
    gs_auth(token = rds_file, verbose = FALSE)
  )
}
