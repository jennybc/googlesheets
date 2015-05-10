gs_auth(token = "googlesheets_token.rds")

## "RAIN DANCE"
## RELIABLY FORCES AUTO-REFRESH OF STALE OAUTH TOKEN
## I DON'T KNOW WHY THIS HELPS BUT IT DOES!
gs_ls()
