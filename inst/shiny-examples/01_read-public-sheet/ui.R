library(shiny)
library(googlesheets)

shinyUI(
  fluidPage(
    titlePanel("Read a public Google Sheet"),
    sidebarLayout(
      sidebarPanel(
        h6(paste("This app is hard-wired to read a single, public Google",
                 "Sheet.")),
        h6("Visit the Sheet in the browser:", a("HERE", href = gs_gap_url(),
                                                target="_blank")),
        h6(paste("Since there is no user input, it defaults to reading",
                 "the first worksheet in the spreadsheet.")),
        h6(a("Click Here to See Code on Github",
             href="https://github.com/jennybc/googlesheets/tree/master/inst/shiny-examples/01_read-public-sheet",
             target="_blank"))
      ),
      mainPanel(
        DT::dataTableOutput("the_data")
      )
    )
  ))
