google_token <- readRDS("googlesheets_token.rds")
.state$token <- google_token

## "RAIN DANCE"
## RELIABLY FORCES AUTO-REFRESH OF STALE OAUTH TOKEN
## I DON'T KNOW WHY THIS HELPS BUT IT DOES!
list_sheets()
