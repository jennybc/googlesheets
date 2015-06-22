library(shiny)
library(shinythemes)
library(googlesheets)

shinyUI(
  fluidPage(
    theme = shinytheme("cosmo"),
    titlePanel("Read a public Google Sheet"),
    sidebarLayout(
      sidebarPanel(
        h6(paste("This app is hard-wired to read a single, public Google",
                 "Sheet.")),
        h6("Visit the Sheet in the browser:", a("HERE", href = gs_gap_url(),
                                                target="_blank")),
        h6(paste("Since there is no user input, it defaults to reading",
                 "the first worksheet in the spreadsheet."))
      ),
      mainPanel(
        DT::dataTableOutput("the_data")
      )
    )
  ))
