library(shiny)
library(googlesheets)
library(plyr)
library(dplyr)
library(DT)

## =====================
# CHANGE THIS DEPENDING ON WHERE YOU ARE DEPLOYING APP
options("googlesheets.shiny.redirect_uri" = "http://daattali.com/shiny/gs-explorer/")
# FOR LOCAL TESTING - use runApp(port = 4642)
#options("googlesheets.shiny.redirect_uri" = "http://127.0.0.1:4642")
## ======================


shinyServer(function(input, output, session) {
  
  ## Make a button to link to Google auth screen
  ## If auth_code is returned then dont show login button
  output$loginButton <- renderUI({
    if(is.null(isolate(access_token()))) {
      actionButton("loginButton", 
                   label = a("Authorize App", 
                             href = gs_shiny_get_url()))
    } else {
      return()
    }
  })
  
  ## Get auth code from return URL
  access_token  <- reactive({
    ## gets all the parameters in the URL. Your authentication code should be one of them
    pars <- parseQueryString(session$clientData$url_search) 
    
    if(length(pars$code) > 0) {
      ## extract the authorization code
      gs_shiny_get_token(auth_code = pars$code)
    } else {
      NULL
    }
  })
  
  
  ## If access_token was obtained and ok, show list sheets button
  output$listButton <- renderUI({
    if(!is.null(access_token())) { 
      actionButton("listButton", label = "List Sheets")
    } else {
      return()
    }
  })
  
  output$selectSheet <- renderUI({
    validate(
      need(!is.null(access_token()), message = FALSE)
    )
    
    all_sheets <- gsLs()
    
    titles <- c("", all_sheets$sheet_title) %>% as.list()
    
    selectInput("selectSheet", label = "Pick a Spreadsheet", 
                choices = titles, selected = NULL)
    
  })
  
  sheet <- reactive({
    validate(
      need(!is.null(access_token()), message = FALSE),
      need(input$selectSheet != "", message = FALSE)
    )
    
    ss <- gs_title(input$selectSheet)
    ss
  })
  
  output$sheetInfo <- DT::renderDataTable({
    ss <- sheet()
    
    ss_info <- data_frame(
      x = c("Spreadsheet Title", 
            "Date of googlesheets registration",
            "Date of last spreadsheet update",
            "Visibility", "Permissions", "Version"),
      y = c(ss$sheet_title, ss$reg_date %>% as.character(), 
            ss$updated %>% as.character(), 
            ss$visibility, ss$perm, ss$version))
    
    DT::datatable(ss_info, rownames = FALSE, colnames = c("", ""), filter = "none",
                  options = list(paging = FALSE, searching = FALSE, ordering = FALSE,
                                 info = FALSE))
    
  })
  
  output$sheetWsInfo <- DT::renderDataTable({
    ss <- sheet()
    
    ss_ws_info <- data_frame("Worksheet" = ss$ws$ws_title, 
                             "Row Extent" = ss$ws$row_extent, 
                             "Column Extent" = ss$ws$col_extent)
    
    DT::datatable(ss_ws_info, options = list(paging = FALSE))
    
  })
  
  
  observe({
    
  if(is.null(input$selectSheet)) {
      updateTabsetPanel(session, "panel", selected = "All Sheets")
  } else {
    if(input$selectSheet != "") {
      updateTabsetPanel(session, "panel", selected = "Sheet Info")
    } else {
      updateTabsetPanel(session, "panel", selected = "All Sheets")
    }
  }

  })
  
  output$logoutButton <- renderUI({
    if(!is.null(access_token())) { 
      # TODO: revoke the token upon login
      #access_token$revoke()
      actionButton("logoutButton", 
                   label = a("Logout", href = getOption("googlesheets.shiny.redirect_uri"))) 
    } else {
      return()
    }
  })
  
  user_info <- reactive({
    validate(
      need(!is.null(access_token()), message = FALSE)
    )
    gs_user()
  })
  
  output$currentUser <- renderUI({
    validate(
      need(!is.null(access_token()), message = "No user is currently authorized.")
    )
    
    x <- user_info()
    x <- gs_user()
    line1 <- paste("Display Name:", x$displayName)
    line2 <- paste("Email:", x$emailAddress)
    line3 <- paste("Time of session authorization:", x$auth_date)
    
    HTML(paste(line1, line2, line3, sep = "</br><h>"))
  })
  
  ## No auth_code has been returned
  output$introInfo <- renderText({
    if(isolate(is.null(access_token()))) {
      paste("Click 'Authorize this App' to redirect to Google's authorization",
            "screen where this app requests authorization to access your",
            "Google Sheets and Google Drive. By authorizing, additional",
            "googlesheets functions that requires user authorization,",
            "can be utilized in your Shiny app.")
    }
  })
  
  output$greeting <- renderText({
    paste("Hello,  ", user_info()$displayName, ":)", sep = "\n")
  })
  
  
  gsLs <- reactive({
    validate(
      need(!is.null(access_token), message = FALSE)
    )
    
    gs_ls()
    
  })
  
  output$plotSheet <- renderPlot({
    ss <- sheet()
    validate(
      need(input$selectWs != "", message = FALSE)
    )
    ws <- get_via_csv(ss, input$selectWs)
    gs_inspect(ws)
  })
  
  
  output$selectWs <- renderUI({
    ss <- sheet()
    
    ws_titles <- c("", ss$ws$ws_title %>% as.list())
    
    selectInput("selectWs", label = "Select a worksheet", 
                choices = ws_titles, selected = NULL)
  })
  
})
