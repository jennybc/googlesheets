library(shiny)
library(googlesheets)
library(DT)

gap_ss <- gs_gap()

shinyServer(function(input, output, session) {

  output$gap_ss_info <- renderPrint(print(gap_ss))

  worksheet <- reactive({
    input$ws
  })

  output$the_data <- renderDataTable({

    gap_data <- gs_read(gap_ss, ws = worksheet())

    datatable(gap_data)

  })

})
