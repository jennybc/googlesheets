## Test environments

* local OS X install, R 3.3.2
* Ubuntu precise (12.04.5 LTS) on travis-ci, R 3.4.0
* win-builder, release 3.4.0 and devel
* r-hub, various combinations of OS and R

This is an update to accomodate purrr 0.2.2.1, which is soon to be released.

## R CMD check results

There were no ERRORs or WARNINGs. 

There is one NOTE. I have changed my email address from jenny@stat.ubc.ca to jenny@rstudio.com.

There is also this, which is not new and I am giving the same explanation:

Found the following (possibly) invalid URLs:
  URL: https://console.developers.google.com
    From: man/gs_auth.Rd
          man/gs_webapp_auth_url.Rd
    Status: 404
    Message: Not Found
    
This URL goes to the Google Developers Console if and only if user is currently signed in with Google. Otherwise it redirects to a login screen. I assume something about that process is causing CRAN to think the URL is invalid.

## Downstream dependencies

There aren't any.
