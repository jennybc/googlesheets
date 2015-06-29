library(shiny)
library(googlesheets)
library(dplyr)
library(ggplot2)
library(stringr)

shinyServer(function(input, output, session) {

  craig_ss <-
    gs_key("1qtvN-PKWvIbmTJ-RSmga1m2iGn7Mze4w_yRg9ZJx2TU", lookup = FALSE)

  ## All the data
  craig_all <- gs_read(craig_ss) %>%
    select(-URL) %>%
    mutate(DATE = as.Date(DATE, format = "%m/%d/%Y"),
           DESCRIPTION = tolower(DESCRIPTION))

  ## Count number of Lost/found/stolen in each day
  craig_daily_types <- craig_all %>%
    mutate(Type =
             ifelse(str_detect(DESCRIPTION, "lost|missing"), "Lost",
                    ifelse(str_detect(DESCRIPTION, "found"), "Found",
                           ifelse(str_detect(DESCRIPTION, "stolen"),
                                  "Stolen", "Unknown")))) %>%
    mutate(Type = Type %>% factor(c("Lost", "Found", "Stolen", "Unknown"))) %>%
    group_by(DATE) %>%
    count(DATE, Type)

  ## max/min dates for date selectors
  min_date <- min(craig_all$DATE)
  max_date <- max(craig_all$DATE)

  output$selectedDate <- renderUI({
    dateInput("selectedDate", "Pick a date", min = min_date,
              max = max_date, format = "yyyy-mm-dd")
  })

  output$dateRange <- renderUI({
    dateRangeInput("dateRange", "Pick a date range", start = min_date,
                   end = max_date, min = min_date, max = max_date,
                   format = "yyyy-mm-dd", startview = "month",
                   separator = " to ")
  })

  dataInput1 <- reactive({
    validate(
      need(length(input$selectedDate) > 0, message = "Loading")
    )

    craig_data <- craig_all %>%
      dplyr::filter(DATE == input$selectedDate)

    craig_data

  })

  output$dataForDay <- DT::renderDataTable({

    DT::datatable(dataInput1())

  })

  # Get data between dates and count number of posts
  dataInput2 <- reactive({

    validate(
      need(length(input$dateRange) > 0, message = "Loading")
    )

    craig_subset <- craig_all %>%
      filter(DATE %>% between(input$dateRange[1], input$dateRange[2])) %>%
      mutate(COUNT = 1) %>%
      group_by(DATE) %>%
      summarise(count = sum(COUNT))

    craig_daily <-
      craig_daily_types[between(craig_daily_types$DATE,
                                input$dateRange[1],
                                input$dateRange[2]),]

    list(craig_subset, craig_daily)
  })

  basePlot <- reactive({
    validate(
      need(dataInput2(), message = "Loading Data")
      )

    dat <- dataInput2()[[1]]

    ggplot(dat, aes(x = DATE, y = count)) +
      geom_bar(stat="identity", alpha = 0.5) +
      scale_y_continuous(expand = c(0, 0)) +
      labs(x = "", y = "Number of Posts")
  })

  output$plotDataCount <- renderPlot({

    if(input$postTypes == FALSE) {
      basePlot()
    } else {

      dat_daily_type <- dataInput2()[[2]]

      p <- basePlot() +
        geom_line(data = dat_daily_type, aes(x = DATE, y = n, group = Type)) +
        facet_grid(~Type)

      p
    }

  })

  output$plotDailyData <- renderPlot({
    validate(
      need(length(input$selectedDate) > 0, message = "Loading")
    )
    dat <- craig_daily_types %>% filter(DATE == input$selectedDate)

    ggplot(dat, aes(x = Type, y = n)) +
      geom_bar(stat="identity") +
      scale_y_continuous(expand = c(0, 0)) +
      labs(x = "", y = "Number of Posts")
  })

})
