library(shiny)
library(shinythemes)

shinyUI(
  fluidPage(
    theme = shinytheme("cosmo"),
    titlePanel("Read and write a private Google Sheet"),
    sidebarLayout(
      sidebarPanel(
        h6(paste("This app is hard-wired to target a private Google Sheet.")),
        h6(paste("You can't visit the Sheet in the browser, because it's",
                 "private. Which is the whole point of this example.")),
        h6("Fail to browse the Sheet: ",
           a("HERE", href = ss$browser_url, target="_blank")),
        h6(a("Click Here to See Code on Github",
             href="https://github.com/jennybc/googlesheets/tree/master/inst/shiny-examples/10_read-write-private-sheet",
             target="_blank")),
        sliderInput("row", "Row", min = 1, max = n, value = 1, step = 1,
                    ticks = FALSE),
        selectInput("column", "Column",
                    choices = stats::setNames(seq_len(n), colnames(filler))),
        selectInput("contents", "Cell contents",
                    choices = c("apple", "grape", "banana")),
        actionButton("submit", "Submit", class = "btn-primary"),
        actionButton("reset", "Reset", class = "btn-primary")
      ),
      mainPanel(
        tableOutput("table")
      )
    )
  ))
