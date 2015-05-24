---
title: "Refresh Token Limit"
output: html_document
---

### Summary 




A token consists of an access token and a refresh token.

|Token         |Lifetime              |Note                                                                                             |
|:-------------|:---------------------|:------------------------------------------------------------------------------------------------|
|Access Token  |3600 seconds (1 hour) |                                                                                                 |
|Refresh Token |A long time ...       |Valid until the user revokes it, token not in use > 6 months, or user exceeded 25 token requests |

According to [Google - Using OAuth 2.0 to Access Google APIs](https://developers.google.com/identity/protocols/OAuth2#expiration), there is a 25 token limit per Google user account. **This limit applies to refresh tokens.** After 25 requests for new tokens, the 26th token will cause the oldest token to be invalidated without any user-visible warning. Using the expired refresh token returns HTTP 400 Bad Request.

---

### Testing this 25 token limit:

To really find out if this limit is valid:
 
1. Revoke all tokens to start with a clean slate. 

2. Get 25 tokens: `httr-oauth_1`, `httr-oauth_2`, ... , `httr_oauth_25`, each containing an access token and refresh token pair. 

3. Get a 26th token: `httr-oauth_26`.


```
## Source: local data frame [25 x 5]
## 
##    Token Refresh_1 Refresh_2 ... Refresh_X
## 1      1       1.1       1.2 ...       1.x
## 2      2       2.1       2.2 ...       2.x
## 3      3       3.1       3.2 ...       3.x
## 4      4       4.1       4.2 ...       4.x
## 5      5       5.1       5.2 ...       5.x
## 6      6       6.1       6.2 ...       6.x
## 7      7       7.1       7.2 ...       7.x
## 8      8       8.1       8.2 ...       8.x
## 9      9       9.1       9.2 ...       9.x
## 10    10      10.1      10.2 ...      10.x
## 11    11      11.1      11.2 ...      11.x
## 12    12      12.1      12.2 ...      12.x
## 13    13      13.1      13.2 ...      13.x
## 14    14      14.1      14.2 ...      14.x
## 15    15      15.1      15.2 ...      15.x
## 16    16      16.1      16.2 ...      16.x
## 17    17      17.1      17.2 ...      17.x
## 18    18      18.1      18.2 ...      18.x
## 19    19      19.1      19.2 ...      19.x
## 20    20      20.1      20.2 ...      20.x
## 21    21      21.1      21.2 ...      21.x
## 22    22      22.1      22.2 ...      22.x
## 23    23      23.1      23.2 ...      23.x
## 24    24      24.1      24.2 ...      24.x
## 25    25      25.1      25.2 ...      25.x
```

#### Result

After getting the 26th token (`.httr-oauth_26`), the access token and refresh token of `.httr-oauth_1` no longer works and returns: 

`Error in refresh_oauth2.0(self$endpoint, self$app, self$credentials) : 
client error: (400) Bad Request`

---

#### Does retrieving access tokens affect this 25 token limit?

After an access token expires, using the refresh token to get a new access token has no effect on the 25 limit, the `.httr-oauth` file just gets updated with the new access token and the refresh token remains the same. This 25 limit is only applied to refresh tokens. You can get as many access tokens as you want. 
