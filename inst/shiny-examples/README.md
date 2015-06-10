<!-- README.md is generated from README.Rmd. Please edit that file -->
Using `googlesheets` in Shiny
=============================

------------------------------------------------------------------------

There are many cool ways to feed data into a Google Sheet:

-   scrape the web
    -   built-in functions such as `importxml`, `importfeed` and `importhtml`
    -   Google Apps scripts -- possibly written by others and baked into Google Sheet "templates" you can copy then customize
-   crowdsource data via Google Forms or direct Sheet editing, on a small or large scale
-   automated data collection based on web services, such as [ifttt.com](https://ifttt.com)

Here are examples of using Google Sheets as an online datastore from Amit Argawal's [blog](http://www.labnol.org/tag/guide/):

-   [GMail Scheduler](http://www.labnol.org/internet/schedule-gmail-send-later/24867/)

-   [Amazon Price Tracker](http://www.labnol.org/internet/amazon-price-tracker/28156/)

-   [Save Tweets for any Twitter Hashtag](http://www.labnol.org/internet/save-twitter-hashtag-tweets/6505/)

-   [Scrape Google Search results](http://www.labnol.org/internet/google-web-scraping/28450/)

Shiny App Examples
==================

------------------------------------------------------------------------

### 1. [My Google Sheets Explorer](gs-explorer)

This app requires the user to login using their Google account. After authorization, the user is presented with a listing of their sheets, the option to view details of each spreadsheet and inspect the worksheets contained in a spreadsheet.

### 2. [Craigslist Lost and Found](craigslist-lost-and-found)

This app reads from a public spreadsheet that utilizes the Google Sheet function `importxml` to read data from Craigslist's Lost and Found listing. Users do not have to log in.

### 3. [Embed a Google Form](gs-forms)

This app embeds a Google Form and shows the underlying Google Sheet that stores the responses. Users do not have to log in.

### 4. [Tweet Collector](tweet-collector)

This app is presented to the user as if they are logged in as the owner of the spreadsheet (not published to the web). Credentials are baked in the app and the user is allowed to write to the spreadsheet using the given input options presented. The user is also able to download the spreadsheet.
