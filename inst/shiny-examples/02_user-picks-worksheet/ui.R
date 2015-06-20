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
        h6(a("Click Here to See Code on Github",
             href="https://github.com/jennybc/googlesheets/tree/master/inst/shiny-examples/02_user-picks-worksheet",
             target="_blank")),
        selectInput("ws", "Worksheet",
                    choices = c("Africa", "Americas", "Asia",
                                "Europe", "Oceania"))
      ),
      mainPanel(
        verbatimTextOutput("gap_ss_info"),
        DT::dataTableOutput("the_data")
      )
    )
  ))
