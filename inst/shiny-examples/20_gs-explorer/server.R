library(shiny)
library(googlesheets)
library(plyr)
library(dplyr)
library(DT)

## ===================== CHANGE THIS DEPENDING ON WHERE YOU ARE DEPLOYING APP
##
## For local testing, you can accept the default values for the options related
## to client ID, secret and the redirect URI.
## For example, by default the googlesheets.webapp.redirect_uri option is
## http://127.0.0.1:4642
## This implies you'll need to run and inspect your app like so:
## runApp(port = 4642)
##
## If the app is deployed elsewhere, you will need to get your app its own
## client ID and secret and set up the redirect URI. Read the documentation on
## googlesheets::gs_webapp_auth_url for more details.
## To declare the redirect URI, uncomment and modify one of these lines:
# options("googlesheets.webapp.redirect_uri" = "http://daattali.com/shiny/gs-explorer/")
# options("googlesheets.webapp.redirect_uri" = "https://jozhao.shinyapps.io/gs-explorer/")
## ======================

shinyServer(function(input, output, session) {

  ## Make a button to link to Google auth screen
  ## If auth_code is returned then don't show login button
  output$loginButton <- renderUI({
    if (is.null(isolate(access_token()))) {
      tags$a("Authorize App",
             href = gs_webapp_auth_url(),
             class = "btn btn-default")
    } else {
      return()
    }
  })

  output$logoutButton <- renderUI({
    if (!is.null(access_token())) {
      # Revoke the token too? use access_token$revoke()
      tags$a("Logout",
            href = getOption("googlesheets.webapp.redirect_uri"),
            class = "btn btn-default")
    } else {
      return()
    }
  })

  ## Get auth code from return URL
  access_token  <- reactive({
    ## gets all the parameters in the URL. The auth code should be one of them.
    pars <- parseQueryString(session$clientData$url_search)

    if (length(pars$code) > 0) {
      ## extract the authorization code
      gs_webapp_get_token(auth_code = pars$code)
    } else {
      NULL
    }
  })

  gsLs <- reactive({
    gs_ls()
  })

  output$listSheets <- DT::renderDataTable({
    validate(
      need(!is.null(access_token()),
           message =
             paste("Click 'Authorize App' to redirect to a Google page where",
                   "you will authenticate yourself and authorize",
                   "this app to access your Google Sheets and Google Drive."))
    )

    dat <- gsLs() %>% select(1:6)
    DT::datatable(dat)
  })

  # Sheet selector
  output$selectSheet <- renderUI({
    validate(
      need(!is.null(access_token()), message = FALSE)
    )

    all_sheets <- gsLs()
    titles <- c(" ", all_sheets$sheet_title) %>%
      stringr::str_sort() %>%
      as.list()

    selectInput("selectSheet", label = "Pick a Spreadsheet",
                choices = titles, selected = NULL)
  })

  ## Worksheet selector
  output$selectWs <- renderUI({
    ss <- sheet()
    # default selected would be " "
    ws_titles <- c(" ", ss$ws$ws_title %>% as.list())

    selectInput("selectWs", label = "Select a worksheet",
                choices = ws_titles, selected = NULL)
  })

  sheet <- reactive({
    validate(
      need(!is.null(access_token()), message = FALSE),
      need(input$selectSheet != " ", message = FALSE)
    )

    ss <- gs_title(input$selectSheet)
    ss
  })

  output$sheetInfo <- DT::renderDataTable({
    ss <- sheet()

    ss_info <- data_frame(
      x = c("Spreadsheet title",
            "Spreadsheet author",
            "Date of googlesheets registration",
            "Date of last spreadsheet update",
            "Visibility", "Permissions", "Version"),
      y = c(ss$sheet_title, ss$author,
            ss$reg_date %>% format.POSIXct(usetz = TRUE) %>% as.character(),
            ss$updated %>% format.POSIXct(usetz = TRUE) %>% as.character(),
            ss$visibility, ss$perm, ss$version))

    DT::datatable(ss_info, rownames = FALSE,
                  colnames = c("", ""),
                  filter = "none",
                  options = list(paging = FALSE, searching = FALSE,
                                 ordering = FALSE, info = FALSE))
  })

  output$sheetWsInfo <- DT::renderDataTable({
    ss <- sheet()

    ss_ws_info <- data_frame("Worksheet" = ss$ws$ws_title,
                             "Row Extent" = ss$ws$row_extent,
                             "Column Extent" = ss$ws$col_extent)

    DT::datatable(ss_ws_info, options = list(paging = FALSE))
  })

  user_info <- reactive({
    validate(
      need(!is.null(access_token()), message = FALSE)
    )
    gs_user()
  })

  output$currentUser <- renderUI({
    validate(
      need(!is.null(access_token()),
           message = "No user is currently authorized.")
    )

    x <- user_info()
    line1 <- paste("displayName:", x$displayName)
    line2 <- paste("emailAddress:", x$emailAddress)
    line3 <- paste("date:", format(x$date, usetz = TRUE))

    HTML(paste(line1, line2, line3, sep = "</br><h>"))
  })



  output$greeting <- renderText({
    paste("Hello,  ", user_info()$displayName, ":)", sep = "\n")
  })

  output$plotSheet <- renderPlot({
    validate(
      need(input$selectWs != " ", message = FALSE)
    )

    ss <- sheet()
    ws <- gs_read_csv(ss, input$selectWs)
    gs_inspect(ws)
  })

  ## Update tab panel when sheet is selected
  observe({
    if (is.null(input$selectSheet)) {
      updateTabsetPanel(session, "panel", selected = "All Sheets")
    } else {
      if (input$selectSheet != " ") {
        updateTabsetPanel(session, "panel", selected = "Sheet Info")
      } else {
        updateTabsetPanel(session, "panel", selected = "All Sheets")
      }
    }
  })

})
