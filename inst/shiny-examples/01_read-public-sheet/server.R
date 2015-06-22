library(shiny)
library(googlesheets)
library(DT)

gap_ss <- gs_gap()

gap_data <- gs_read(gap_ss)

shinyServer(function(input, output, session) {

  output$the_data <- renderDataTable({

    datatable(gap_data)

  })

})
