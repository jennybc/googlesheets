## Test environments
* local OS X install, R 3.2.1
* ubuntu 12.04 on travis-ci, R 3.2.1
* win-builder, devel and release 3.2.1

## R CMD check results

There were no ERRORs or WARNINGs. 

There is a NOTE from winbuilder, both R 3.2.1 and R Under development (unstable):

* checking re-building of vignette outputs ... NOTE
Error in re-building vignettes:
  ...
Quitting from lines 309-313 (basic-usage.Rmd) 
Error: processing vignette 'basic-usage.Rmd' failed with diagnostics:
Failed to open file C:\Users\CRAN\Documents\tmp\gapminder-africa.csv.
Execution halted

The vignette uses my package with OAuth2 to read and write via the Google Sheets API. Since I cannot upload the necessary token to CRAN, it seems inevitable that my vignette cannot be rebuilt by CRAN. I do rebuild it regularly on Travis-CI, where I can upload the token as an encrypted file.
