## Policies for testing

## The default testing state is one of: NO AUTHORIZATION.
## Explicitly read a token from .rds at the beginning of each file that
## needs it. Hmm ... we could make that even more local?
## Explicitly suspend authorization at the end of any such files.

## No hardwiring sheet title, key, URL or worksheet feed in a test-xxx.R file.
## Define all of that in helper01_setup-sheets.R and then exploit.

## No test shall modify any existing sheets owned by rpackagetest (unlikely,
## since tests are not run with this authorization) or gspreadr (much higher
## risk!).
## Before any test that does sheet editing, create a copy of some existing sheet
## to work with and edit the copy.
## Use the helper function `p_()` to construct names for any such copies or any
## sheets created de novo via tests.
## The `p_()` helper function is defined in helper02_unique-slug.R.
## Why do we do this?
## So that concurrent testing runs do not interfere with each other.
## So sheets bear the name of the associated user (eg jenny or travis).
## So that the slug can be used to clean out testing sheets en masse.

## Check if the old test sheet is still old before working with it.
## See helper03_check-if-old-sheet-still-old.R.
## 2015-06-15 God willing, old sheets will go away completely soon.

## Don't run anything related to tests on CRAN. Simply putting skip_on_cran()
## inside certain tests is not enough. We have code in test_xxx.R files, outside
## of the tests, that should not run on CRAN. In the end, we will not do
## anything related to testing UNLESS the NOT_CRAN env var is TRUE. devtools
## will set this, so if testing or checking through other means, this might need
## to be set manually.
