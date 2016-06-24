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
                width = 400,
                height = 625,
                frameborder = 0,
                marginheight = 0)
  })


  output$googleFormData <- DT::renderDataTable({
    input$refresh
    ss_dat <- gs_read(ss) %>%
      mutate(Timestamp = Timestamp %>%
               as.POSIXct(format = "%m/%d/%Y %H:%M:%S", tz = "PST8PDT")) %>%
      select(Timestamp, Name, Age = `How old are you?`) %>%
      arrange(desc(Timestamp))

    DT::datatable(ss_dat)
  })



})
