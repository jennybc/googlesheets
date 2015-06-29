library(shiny)
library(shinythemes)
library(DT)

shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("Embed a Google Form"),
    sidebarLayout(
      sidebarPanel(
        h6(a("Click Here to See Code on Github",
             href="https://github.com/jennybc/googlesheets/tree/master/inst/shiny-examples/04_embedded-google-form",
             target="_blank")),
        htmlOutput("googleForm")
        ),
      mainPanel(
        DT::dataTableOutput("googleFormData"),
        actionButton("refresh", "Refresh Sheet")
      )
    )
  )
)
