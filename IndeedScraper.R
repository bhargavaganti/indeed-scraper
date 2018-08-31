library(rvest)

URL = "https://www.indeed.co.uk/jobs?q=data+scientist&l=london&start=20"

joblist <- read_html(URL)

jobtitles <- joblist %>%
  html_nodes(".jobtitle") %>%
  html_text()

location <- joblist %>%
  html_nodes(".location") %>%
  html_text()

company <- joblist %>%
  html_nodes(".company") %>%
  html_text()

jobs = cbind.data.frame(jobtitles, location , company)

