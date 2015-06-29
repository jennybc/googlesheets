---
title: "OAuth Token Encryption for Travis"
output: html_document
---

Following [noamross](https://discuss.ropensci.org/t/test-api-wrapping-r-packages-with-oauth-tokens/157) instructions, the steps to obtain an OAuth2.0 token and encrypt it for testing are as follows.

#### 1. Create a token and save it to disk.

```r
# to access environment in which token is stored
devtools::load_all()

token <- gs_auth()

saveRDS(token, file = "tests/testthat/googlesheets_token.rds")
```


#### 2. Prior to tests that require authentication, make sure to read in the token.

```r
gs_auth(token = "googlesheets_token.rds")
```

or, more realistically,

```r
suppressMessages(gs_auth(token = "googlesheets_token.rds", verbose = FALSE))
```

#### 3. In the shell, encode the token file.

`gem install travis`

*Note: I had to do this as sudo.*

Log into your Travis account using your Github username and password.

`travis login`

Encrypt token:

`travis encrypt-file tests/testthat/googlesheets_token.rds --add`

`--add` automatically adds a decrypt command to your .travis.yml file

   *Double check that the token and encrypted token live in `tests/testthat/` and that `.travis.yml` reflects the correct path.*

#### 4. Ignore and Commit

Put `tests/testthat/googlesheets_token.rds` in your `.gitignore`. 

Put `tests/testthat/googlesheets_token.rds.enc` in your `.Rbuildignore`.


> Do not mix these up. You don't want your token file on GitHub, and you don't want the encoded version being distributed into everyone's libraries. If you put `token_file.rds` in your .Rbuildignore, it will not be copied over into the package.rcheck directory when Travis runs `R CMD check`, and your tests will fail. Over and over. As you bang your desk trying to figure out what's wrong.


Commit `tests/testthat/googlesheets_token.rds.enc` and your updated `.travis.yml` and push to Github.

Note
---

2015-06-29 The token we had been using finally fell off the end of the 25-token stack. The instructions above no longer worked for me when attempting to encrypt the new token file. I got this:

```
Jennifers-2015-MacBook-Pro:googlesheets jenny$ travis encrypt-file tests/testthat/googlesheets_token.rds 
repository not known to https://api.travis-ci.com/: jennybc/gspreadr
```

The old name of this repo was somehow blocking me. From [this issue thread](https://github.com/travis-ci/travis-ci/issues/3093) I learned to inspect and correct the Travis slug in `.git/config`.

```
[travis]
	slug = jennybc/googlesheets
```

That allowed me to encrypt a new token file.
