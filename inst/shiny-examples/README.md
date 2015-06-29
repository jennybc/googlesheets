<!-- README.md is generated from README.Rmd. Please edit that file -->
Using `googlesheets` in Shiny
=============================

------------------------------------------------------------------------

There are many cool ways to feed data into a Google Sheet ... and then use in a Shiny app:

-   scrape the web
    -   built-in functions such as `importxml`, `importfeed` and `importhtml`
    -   Google Apps scripts -- possibly written by others and baked into Google Sheet "templates" you can copy then customize
-   crowdsource data via Google Forms or direct Sheet editing, on a small or large scale
-   automated data collection based on web services, such as [ifttt.com](https://ifttt.com)

Sample apps
-----------

We've built a few simple apps to get you started in some important use cases:

-   No authentication/authorization:
    -   [01\_read-public-sheet](01_read-public-sheet): simply read a public sheet. See it deployed [here](https://jennybc.shinyapps.io/01_read-public-sheet).
    -   [02\_user-picks-worksheet](02_user-picks-worksheet): read a public sheet but allow the app user to specify which worksheet is being inspected. See it deployed [here](https://jennybc.shinyapps.io/02_user-picks-worksheet).
    -   [03\_craigslist-lost-and-found](03_craigslist-lost-and-found): reads from a public spreadsheet that utilizes the Google Sheet function `importxml` to read data from Vancouver's Craigslist's Lost and Found listings.
-   Credentials are baked into the app:
    -   [10\_gs-forms](10_gs-forms): a Google Form is embedded in the app, allowing user to enter data with native Google Form/Sheets functionality. App also displays the underlying Sheet, allowing user to see the just-entered data.
    -   [11\_tweet-collector](11_tweet-collector): app presents a private (not published to the web!) Sheet to app user. App user is allowed to write into the Sheet through constrained input handled by the Shiny app. App user allowed to download the Sheet throught the app. Uses a third party magic Sheet template.
-   User provides Google credentials via the app:
    -   [20\_gs-explorer](20_gs-explorer): app requires the user to authenticate with Google and authorize the app to deal on their behalf. After authorization, the user is presented with a listing of their Sheets, the option to view details of each spreadsheet and inspect the worksheets contained in a spreadsheet.

Dean Attali also includes a Google Sheets + `googlesheets` example in his blog post [Persistent data storage in Shiny apps](http://deanattali.com). *not published yet but will be soon*

More inspiration for feeding Google Sheets:
-------------------------------------------

Here are examples of using Google Sheets as an online datastore from Amit Argawal's [blog](http://www.labnol.org/tag/guide/):

-   [GMail Scheduler](http://www.labnol.org/internet/schedule-gmail-send-later/24867/)

-   [Amazon Price Tracker](http://www.labnol.org/internet/amazon-price-tracker/28156/)

-   [Save Tweets for any Twitter Hashtag](http://www.labnol.org/internet/save-twitter-hashtag-tweets/6505/)

-   [Scrape Google Search results](http://www.labnol.org/internet/google-web-scraping/28450/)
