library(shiny)
library(googlesheets)
library(DT)
library(dplyr)

## =====================
# change the sheet key to point to a different TAGS sheet
## ======================

shinyServer(function(input, output, session) {

  ss <- gs_key("1QdgEHN_iSk43N-3s_Lxm8nw97LzQRrFDLOUdBDPTLcI")

  ## refreshing every minute
  refresh_sheet <- reactiveTimer(60000, session)
  
  currentWs <- reactive({
    refresh_sheet()
    ws <- get_via_csv(ss, ws = 2)
  })
  
  output$numTweets <- renderUI({
    num_tweets <- get_cells(ss, ws = 1, "B16")[["cell_text"]] %>% as.integer()

    textInput("numTweets", label = "Max # of Tweets to collect",
              value = num_tweets)
  })

  observeEvent(input$searchBtn, {
    validate(
      need(input$search != "", message = FALSE),
      need(input$numTweets > 0, message = "Not collecting any tweets?")
    )

    if(input$numTweets != 100) {
      ss <- edit_cells(ss, input = input$numTweets, anchor = "B16")
    }

    ss <- edit_cells(ss, input = input$search, anchor = "B9")

    updateTextInput(session, "search", label = NULL, value = "")
  })
  
  output$tweetsTable <- DT::renderDataTable({
    
    dat <- currentWs()
    
    new_dat <- dat %>% 
      dplyr::select(User = from_user, Text = text, "Time" = time, 
                    Followers = user_followers_count, Friends = user_friends_count)
    
    DT::datatable(new_dat, rownames = FALSE)
  })

  output$tweetStats <- DT::renderDataTable({
    refresh_sheet()
    dat <- get_cells(ss, ws = 1, "A19:B22") %>% reshape_cf(header = FALSE)
    DT::datatable(dat, rownames = FALSE, 
                  colnames = c("", ""), 
                  filter = "none",
                  options = list(paging = FALSE, searching = FALSE, 
                                 ordering = FALSE, info = FALSE))
  })

  output$download <- downloadHandler(
    filename = paste('tweets-', Sys.Date(), '.csv', sep=''),
    content = function(file) {
      gs_download(ss, ws = 2, to = file, overwrite = TRUE)
    }
  )

})
