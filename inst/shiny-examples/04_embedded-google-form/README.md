---
title: "Google Forms"
output: html_document
---

## Description

This app is currently deployed [here](https://jennybc.shinyapps.io/04_embedded-google-form).

This Sheet is not world writable, but the app works without authentication since data input is handled via the embedded native Google Form. The accumulating data can also be displayed in the app without authentication since the Sheet is "published to the web".

The associated Sheet is viewable [here](https://docs.google.com/spreadsheets/d/1K5g_3bxsE33T4ZuwUfxmzGY5RXNvQAAP78vis1EHFps/pubhtml). 

---

## To embed a Google Form in a Shiny app

When you create a Google form ([instuctions here](https://support.google.com/docs/answer/87809?hl=en)), Google provides the HTML to embed the form in a website. 
```
<iframe src="https://docs.google.com/forms/d/SOME_LONG_KEY/viewform?embedded=true" width="760" height="500" frameborder="0" marginheight="0" marginwidth="0">Loading...</iframe>
```
You can wrap that with `HTML()` in `ui.R`, or reconstruct the HTML using Shiny's `tags$iframe` function. 

```
tags$iframe(id = "googleform",
            src = "https://docs.google.com/forms/d/SOME_LONG_KEY/viewform?embedded=true",
            width = 400,
            height = 600,
            frameborder = 0,
            marginheight = 0)
```
**Note that when you run the app locally, you must use "Open in Browser" in order to see the embedded Google Form!**
