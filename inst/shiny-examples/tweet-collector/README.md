---
title: "Tweet Collector"
output: html_document
---


```r
library(googlesheets)
```

## Description

This app is currently deployed [here](https://joannaz.shinyapps.io/tweet-collector/). 

**Tweet Collector** displays a tweet archive using the magical Google Sheet from [TAGS](https://tags.hawksey.info/get-tags/). This app assumes the user is authorized as some predetermined user, ie. credentials (`.httr-oauth`) are stored along with the app. This app only reads from one sheet. Tweets accumulate based on what hastag you search for. Up to date stats on the number of tweets in the archive are displayed in the side panel and the tweet archive sheet is displayed in the main panel. You can change what tweets you are collecting by entering into the Search box and modifying the max number of tweets to collect. The datatable updates itself every minute. Sometimes it may take a bit longer to update the sheet and collect new tweets based on the new search item. You can also download the archive by clicking the `download` button and the file will be downloaded in csv format.

---

## How to get a Tweet archive set up in Google Sheets

1. Create a copy of the TAGS v6.0ns Google Sheet from [here](https://docs.google.com/spreadsheets/d/1EqFm184RiXsAA0TQkOyWQDsr4eZ0XRuSFryIDun_AA4/edit#gid=8743918).

2. Click on TAGS -> Setup Twitter Access and follow the instructions.

3. Enter the data you want to collect in the sheet and TAGS -> Run Script. 
The time interval between each data retrieval call can be changed by going to Tools -> Script Editor, Resources -> Current Project's Triggers. The default is grabbing tweets every 1 hour. 

4. To use your sheet in this app just change the sheet key in `server.R` to yours.

