## Test environments
* local OS X install, R 3.2.3
* ubuntu 12.04 on travis-ci, R 3.2.3
* win-builder, release 3.2.4 and devel

This update resolves the WARNINGS in CRAN Package Check Results. I needed to adjust to new behavior in the dependency httr (version v1.1.0, released 2016-01-27). I also resolved a minor issue that caused a NOTE on some flavors: I now require R (>= 3.2.0) since I use get0.

## R CMD check results

There were no ERRORs or WARNINGs. 

There is one NOTE:

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

This URL does, in fact, go to the Google Developers Console if and only if user is currently signed in with Google. Otherwise it redirects to a login screen. I assume something about that process is causing CRAN to think the URL is invalid.
