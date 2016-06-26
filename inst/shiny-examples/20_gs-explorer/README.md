My Google Sheets Explorer
================

``` r
library(googlesheets)
```

Description
-----------

This app is currently deployed [here](https://jennybc.shinyapps.io/20_gs-explorer).

**My Google Sheets Explorer** allows any user to log in using their Google account. After authorization, the user is presented with a listing of all their Google Sheets. The user is allowed to select a Sheet of interest and additional details about the Sheet will be presented in the `Sheet Info` tab. The user is also allowed to quickly inspect the worksheets that live in the selected Sheet by going to the `Sheet Inspection` tab. Simply select a worksheet and a visual representation of the worksheet is displayed.

------------------------------------------------------------------------

Running app locally
-------------------

`googlesheets` currently has set up web application credentials in Google Developer Console. If you are creating an app locally, default app credentials are built into `googlesheets`, **but remember to run your app using `runApp(port = 4642)`**. Credentials are accessible through:

``` r
getOption("googlesheets.webapp.client_id")
```

    ## [1] "178989665258-mbn7q84ai89if6ja59jmh8tqn5aqoe3n.apps.googleusercontent.com"

``` r
getOption("googlesheets.webapp.client_secret")
```

    ## [1] "UiF2uCHeMiUH0BeNbSAzzBxL"

``` r
getOption("googlesheets.webapp.redirect_uri")
```

    ## [1] "http://127.0.0.1:4642"

Two functions are used to get authorization working: `gs_webapp_auth_url()` and `gs_webapp_get_token()`.

The general flow is:

1.  User clicks a button that will take them to the URL formed by `gs_webapp_auth_url`.

``` r
# looks like this
gs_webapp_auth_url()
```

    ## [1] "https://accounts.google.com/o/oauth2/auth?response_type=code&client_id=178989665258-mbn7q84ai89if6ja59jmh8tqn5aqoe3n.apps.googleusercontent.com&redirect_uri=http%3A%2F%2F127.0.0.1%3A4642&scope=https%3A%2F%2Fspreadsheets.google.com%2Ffeeds%20https%3A%2F%2Fdocs.google.com%2Ffeeds&state=securitytoken&access_type=online&approval_prompt=auto"

1.  User authenticates is redirected back to app. An authorization code also gets returned in the url, which it can be extracted using `parseQueryString(session$clientData$url_search)$code`.

2.  Use `gs_webapp_get_token()` to extract the authorization code, make a POST request to exchange for an access token, and put the token in the internal `googlesheets` environment for use in subsequent API requests.

Setting up authorization in your own app
----------------------------------------

You must create your own web application in [Google Developer's Console](https://console.developers.google.com/). Obtain the client ID, client secret and set the redirect URI to some static local url ie. `http://127.0.0.1:4642` (for testing so every time you would run `runApp(port = 4642)` ). Depending on where you will deploy your app, you will later come back and add that destination as another redirect uri.

After setting up the web application, in your `server.R` set client ID and secret, and redirect uri specific to your project by:

    options("googlesheets.webapp.client_id" = MY_CLIENT_ID)
    options("googlesheets.webapp.client_secret" = MY_CLIENT_SECRET)
    options("googlesheets.webapp.redirect_uri" = MY_REDIRECT_URI)
