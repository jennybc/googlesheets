## Test environments

* local OS X install, R 3.3.0
* ubuntu 12.04 on travis-ci, R 3.3.0
* win-builder, release 3.3.1 and devel

This is an update to accomodate xml2 1.0.0, which was just released.

## R CMD check results

There were no ERRORs or WARNINGs. 

There is one NOTE. It is the same NOTE as I have had in the past, with the same explanation.

NOTE
Maintainer: ‘Jennifer Bryan <jenny@stat.ubc.ca>’

License components with restrictions and base license permitting such:
  MIT + file LICENSE
File 'LICENSE':
  YEAR: 2016
  COPYRIGHT HOLDER: Jennifer Bryan, Joanna Zhao
Found the following (possibly) invalid URLs:
  URL: https://console.developers.google.com
    From: man/gs_auth.Rd
          man/gs_webapp_auth_url.Rd
    Status: 404
    Message: Not Found

This URL goes to the Google Developers Console if and only if user is
currently signed in with Google. Otherwise it redirects to a login
screen. I assume something about that process is causing CRAN to think
the URL is invalid.

## Downstream dependencies

There aren't any.
