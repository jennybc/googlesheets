# recording some interactive work conducted prior to archiving this repo on
# 2022-02-03

library(tidyverse)
library(gh)

body <- read_file("internal-projects/90_archiving-announcement.md")

# get PRs
# https://docs.github.com/en/rest/reference/pulls#list-pull-requests
prs <- gh("/repos/jennybc/googlesheets/pulls", state = "open", .limit = Inf)
pr_numbers <- map_int(prs, "number")

# update a PR
# https://docs.github.com/en/rest/reference/pulls#update-a-pull-request
# PATCH /repos/{owner}/{repo}/pulls/{pull_number}

pr_comment_and_close <- function(number) {
  gh(
    "PATCH /repos/jennybc/googlesheets/pulls/{pull_number}",
    pull_number = number,
    body = body,
    state = "closed"
  )
}

out <- map(pr_numbers, pr_comment_and_close)
out %>%
  map("error") %>%
  map_lgl(is.null) %>%
  table()
# all 7 open PRs are successfully closed
# looks like my 'body' didn't show up, but I can live with this

# get open issues
# https://docs.github.com/en/rest/reference/issues#list-repository-issues
issues <- gh("/repos/jennybc/googlesheets/issues", state = "open", .limit = Inf)
length(issues) # 84
issue_numbers <- map_int(issues, "number")

# update an issue
# https://docs.github.com/en/rest/reference/issues#update-an-issue
# PATCH /repos/{owner}/{repo}/issues/{issue_number}

issue_comment_and_close <- function(number) {
  Sys.sleep(4)
  cat("issue", number, "\n")
  gh(
    "PATCH /repos/jennybc/googlesheets/issues/{issue_number}",
    issue_number = number,
    body = body,
    state = "closed"
  )
}

out <- map(issue_numbers, issue_comment_and_close)
out %>%
  map("error") %>%
  map_lgl(is.null) %>%
  table()

# all 84 open issues are successfully closed
# looks like my 'body' didn't show up, but I can live with this
