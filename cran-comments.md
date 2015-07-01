## Test environments
* local OS X install, R 3.2.1
* ubuntu 12.04 on travis-ci, R 3.2.1
* win-builder, devel and release 3.2.1

This is a resubmission. In the previous submission, Kurt remarked on the fact that CRAN could not re-build the vignette outputs, since the vignette uses the package to make authenticated calls to the Google Sheets API. However, there is no way to securely provide an access token to CRAN. Therefore I have followed his advice to conditionally suppress evaluation of these specific chunks. This has cleared the NOTE about the vignette.

## R CMD check results

There were no ERRORs or WARNINGs. 

There is one NOTE:

Note #1:

* checking CRAN incoming feasibility ... NOTE
Maintainer: 'Jennifer Bryan <jenny@stat.ubc.ca>'
New submission

License components with restrictions and base license permitting such:
  MIT + file LICENSE
File 'LICENSE':
  YEAR: 2015
  COPYRIGHT HOLDER: Jennifer Bryan, Joanna Zhao
