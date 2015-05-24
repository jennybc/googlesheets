---
title: "OAuth Token Encryption for testing"
output: html_document
---

Following [noamross](https://discuss.ropensci.org/t/test-api-wrapping-r-packages-with-oauth-tokens/157) instructions, the steps to obtain an OAuth2.0 token and encrypt it for testing are as follows.

#### 1. Create a token and save it to disk.

```r
# to access environment in which token is stored
devtools::load_all()

gs_auth()

saveRDS(.state$token, file = "tests/testthat/googlesheets_token.rds")
```


#### 2. In a helper file in `tests/testthat`, insert the code to read in the token.


```r
gs_auth(token = "googlesheets_token.rds")
```


#### 3. In command line, encode the token file.

`gem install travis`

Log into your Travis account using your Github username and password.

`travis login`

Encrypt token:

`travis encrypt-file tests/testthat/googlesheets_token.rds --add`

`--add` automatically adds a decrypt command to your .travis.yml file

   *Double check .travis.yml that the directories of `googlesheets_token.rds` and `googlesheets_token.rds.enc` are indeed `tests/testthat`.*

#### 4. Ignore and Commit

Put `tests/testthat/googlesheets_token.rds` in your `*.gitignore*`. 

Put `tests/testthat/googlesheets_token.rds.enc` in your `*.Rbuildignore*`.


> Do not mix these up. You don't want your token file on GitHub, and you don't want the encoded version being distributed into everyone's libraries. If you put token_file.rds in your .Rbuildignore, it will not be copied over into the package.rcheck directory when Travis runs R CMD CHECK, and your tests will fail. Over and over. As you bang your desk trying to figure out what's wrong.


Commit `tests/testthat/googlesheets_token.rds.enc` and your updated `.travis.yml` and push to Github.


Sidenote
---

A token saved via `saveRDS()` vs `httr` is slightly different. A token saved with `saveRDS()` has an underlying `.rds` extension and when read into R using `readRDS()` will be readily available to use as a `Token2.0` object. But a token saved by `httr` and read using `readRDS()` results in a list object and you have to use the long-alphanumeric-hash to access the token object within it.

```
# reading .httr-oauth cached by httr

token <- readRDS(".httr-oauth")

$faa68f85c8290ff6d9f1ac0811d605e3
<environment: 0x102f45030>
attr(,"class")
[1] "Token2.0" "Token"    "R6" 

```
If you save a token using `saveRDS()` and name it `.httr-oauth`, `httr` wont be able to recognize this file as a cached token since the underlying extension is `.rds`. There might be some confusion down the road when the googlesheets functions that requires authentication (reading in `.httr-oauth`) wont work even though you see a `.httr-oauth` file in your working directory.
