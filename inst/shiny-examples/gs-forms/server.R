library(shiny)
library(DT)
library(dplyr)
library(googlesheets)

## ======================
googleform_embed_link <- "https://docs.google.com/forms/d/1nHVBMG24OPij25hSTbL9BMYTGRIfYDC4mg3NIsZXTmg/viewform?embedded=true"
googleform_data_url <- "https://docs.google.com/spreadsheets/d/1K5g_3bxsE33T4ZuwUfxmzGY5RXNvQAAP78vis1EHFps/pubhtml"
## ======================

shinyServer(function(input, output, session) {
  
  ss <- gs_url(googleform_data_url, lookup = FALSE, visibility = "public")
  
  output$googleForm <- renderUI({
    tags$iframe(id = "googleform",
               src = googleform_embed_link,
               width= 400,
               height= 600,
               frameborder=0,
               marginheight=0)
  })

  
  output$googleFormData <- DT::renderDataTable({
    input$refresh
    ss_dat <- get_via_csv(ss) %>% 
      dplyr::select(Timestamp, Name, Age = How.old.are.you.)
    
    DT::datatable(ss_dat)
  })
  

  
})