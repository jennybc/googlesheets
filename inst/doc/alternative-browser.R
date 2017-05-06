## ------------------------------------------------------------------------
getOption("browser")

## ----eval = FALSE--------------------------------------------------------
#  library(googlesheets)
#  
#  op <- options(browser = "/usr/bin/open -a '/Applications/Google Chrome.app'")
#  #op <- options(browser = "/usr/bin/open -a '/Applications/Safari.app'")
#  gs_auth()
#  options(op)

## ----eval = FALSE--------------------------------------------------------
#  library(withr)
#  library(googlesheets)
#  
#  with_options(
#    #  list(browser = "/usr/bin/open -a '/Applications/Safari.app'"),
#    list(browser = "/usr/bin/open -a '/Applications/Google Chrome.app'"),
#    gs_auth()
#  )

