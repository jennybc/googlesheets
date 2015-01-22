library(devtools)

# Load source_GitHubData
# The functions' gist ID is 4466237
source_gist("4466237")
url_address <- "https://raw.githubusercontent.com/jennybc/gapminder/master/inst/gapminder.tsv"

gapminder <- source_GitHubData(url = url_address, sep = "\t")

# ---- Gapminder spreadsheet for README and vignette
# found at https://docs.google.com/spreadsheets/d/1hS762lIJd2TRUTVOqoOP7g-h4MDQs6b2vhkTzohg8bE/pubhtml

gapminder_by_cont <- dlply(gapminder, "continent")

# Sort by year
gapminder_by_year <- llply(gapminder_by_cont, 
                           function(x) arrange(x, desc(year)))

# Create a new spreadsheet
add_spreadsheet("Gapminder")

# Open the spreadsheet
sheet <- open_spreadsheet("Gapminder")

# Make a new worksheet for every continent
l_ply(gapminder_by_year, 
      function(x) add_worksheet(sheet, unique(x$continent)))

# Clean up extra worksheet
del_worksheet(sheet, "Sheet1")

# Open the spreadsheet again to "refresh"
sheet <- open_spreadsheet("Gapminder")

# Get a list of worksheet objects
wks <- open_worksheets(sheet)

# Dump in data for each worksheet
l_ply(wks, function(x) { 
  dat <- gapminder_by_year[[x$title]]
  update_cells(x, "A1", dat, header = TRUE)
})
