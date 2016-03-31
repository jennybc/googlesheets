---
output: github_document
---

Parking some command line stuff from recent conversations with Craig Citro. Sometimes it's nice to cut R and `httr` out of the picture entirely. Or at least eavesdrop.

## curl

`googlesheets` has unexported and equivalent functions that reveal current access token (do this in R, obviously):

```r
## library(googlesheets)
## gs_auth() or whatever's necessary to get into auth state w/ correct user
googlesheets:::access_token()
```

Get info about the user associated with current access token:

```
curl -H 'Authorization: Bearer ACCESS_TOKEN_GOES_HERE' https://www.googleapis.com/drive/v2/about
```

Reveal the scopes associated with an access token:

```
curl 'https://www.googleapis.com/oauth2/v2/tokeninfo?access_token=ACCESS_TOKEN_GOES_HERE'
```

## netcat

Use this if you want to see exactly what `httr` is sending out.

I had convinced myself that Google tokens were being sent as query string parameters, versus the recommended header method. I was wrong and Craig showed me how to check this for myself.

In the shell

```
nc -l 8080
```

which opens netcat, listening on port 8080.

Back in R

```r
httr::GET('http://127.0.0.1:8080/any/path/here',
          config = c(token = get_google_token()))
```

The GET call will hang until you hit ctrl-c in the netcat terminal, but you'll see the whole request there.
