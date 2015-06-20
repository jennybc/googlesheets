library(shiny)
library(shinythemes)
library(DT)

shinyUI(fluidPage(
  theme = shinytheme("flatly"),
  titlePanel("Embed a Google Form"),
    sidebarLayout(
      sidebarPanel(
        htmlOutput("googleForm")
        ),
      mainPanel(
        DT::dataTableOutput("googleFormData"),
        actionButton("refresh", "Refresh Sheet")
      )
    )
  )
)
