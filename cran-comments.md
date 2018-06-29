This is an update in response to Kurt Hornik's emails dated 2018-05-17 and 2018-06-18 re: packages with "undeclared package dependencies in their unit test code".

Previously googlesheets called `tibble::tibble()` in its tests, where tibble is an indirect dependency of googlesheets. Now I use `dplyr::data_frame()` instead. dplyr is a direct Import of googlesheets.

## Test environments

* local OS X install, R 3.4.3 and R 3.5.0
* Ubuntu 14.04.5 LTS (trusty) via travis-ci, R 3.5
* Windows, R 3.4.4, 3.5.0, Under development (unstable) (2018-06-20 r74924) via win-builder

## R CMD check results

There were no ERRORs or WARNINGs or NOTEs.
