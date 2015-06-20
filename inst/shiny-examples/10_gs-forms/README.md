---
title: "Google Forms"
output: html_document
---

## Description

This app is currently deployed [here](https://joannaz.shinyapps.io/gs-forms/). 

**Embed a Google Form** embeds a Google Form and displays the responses collected in a Google Sheet that is "published to the web". This sheet is viewable [here](https://docs.google.com/spreadsheets/d/1K5g_3bxsE33T4ZuwUfxmzGY5RXNvQAAP78vis1EHFps/pubhtml). 

---

## To embed a google form

1. Google provides the HTML to embed a google form in a website. 
```
<iframe src="https://docs.google.com/forms/d/SOME_LONG_KEY/viewform?embedded=true" width="760" height="500" frameborder="0" marginheight="0" marginwidth="0">Loading...</iframe>
```
I extracted the src attribute used Shiny's tags$iframe function to set up the HTML. 

```
  output$googleForm <- renderUI({
    tags$iframe(id = "googleform",
               src = googleform_embed_link,
               width= 400,
               height= 600,
               frameborder=0,
               marginheight=0)
```
