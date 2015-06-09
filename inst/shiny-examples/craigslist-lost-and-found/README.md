---
title: "Craigslist Lost and Found"
output: html_document
---

## Description

This app is currently deployed [here](
https://joannaz.shinyapps.io/craigslist-lost-and-found/). 

**Craigslist Lost and Found** is a simple app that reads from a Google Sheet that is "published to the web" and can be found [here](https://docs.google.com/spreadsheets/d/1qtvN-PKWvIbmTJ-RSmga1m2iGn7Mze4w_yRg9ZJx2TU/pubhtml). This Google Sheet uses the built-in function [`IMPORTXML`](https://support.google.com/docs/answer/3093342?hl=en) to scrape [Craigslist's Lost and Found](http://vancouver.craigslist.ca/search/laf) listing. You can view the posts listed for any one day and also see the overall number and type of posts.

---

## Setting up the Google Sheet

1. Find the URL for the web page that you want to collect data from.
2. Get the XPath expression to scrape the elements you want from the page. It is useful to see the HTML of the page ( eg. in Chrome you can right click -> Inspect Element) to determine how to construct the XPath expression.
  * Some Resources:
      * [Web Scraping with Google Sheets and XPath](http://vancouverdata.blogspot.ca/2011/02/how-to-web-scraping-xpath-html-google.html)
      
      * [Feeding Google Spreadsheets](https://mashe.hawksey.info/2012/10/feeding-google-spreadsheets-exercises-in-import/)
      
3. Use `=IMPORTXML(URL, XPATH_QUERY)` in a cell, make sure there is a good amount of blank cells to the left or else the data may not fit and an error is thrown. If all goes well, a table of data populates to the right of the formula cell. 
