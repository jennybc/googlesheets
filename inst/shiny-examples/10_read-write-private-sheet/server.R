library(shiny)
library(googlesheets)

shinyServer(function(input, output, session) {

  observeEvent(
    input$reset,
    gs_edit_cells(ss, input = filler)
  )
  observeEvent(
    input$submit,
    gs_edit_cells(ss, input = input$contents,
                  ## the +1 business is to avoid writing into the header row
                  anchor = cell_limits(c(input$row + 1, input$column),
                                       c(input$row + 1, input$column)))
  )
  the_data <- eventReactive({input$submit | input$reset},
                            gs_read(ss), ignoreNULL = FALSE)
  output$table <- renderTable(the_data())

})
