library(rvest)
library(stringr)

URL = "https://www.indeed.co.uk/jobs?q=data+scientist&l=london&start="

######### get total positions ######### 

maxJobs <- joblist %>%
  html_nodes("#searchCount") %>%
  html_text() %>%
  str_extract("[0-9],[0-9]+|[0-9]{3}") %>%
  str_replace(",","") %>%
  str_replace("of ","") %>%
  as.numeric()

######### loop through pages ######### 

jobs = data.frame()

for (n in seq(0, 500, by=10)) {
  URL = paste(URL, n, sep="")
  scrapeJobsFromPage(URL)
}

scrapeJobsFromPage <- function(url){

  joblist <- read_html(url)
  
  # get list of jobtitles 
  jobtitles <- joblist %>%
    html_nodes(".jobtitle") %>%
    html_text()
  
  # get list of locations 
  location <- joblist %>%
    html_nodes(".location") %>%
    html_text()
  
  # get list of companies 
  company <- joblist %>%
    html_nodes(".company") %>%
    html_text()
  
  jobs_temp <<- cbind.data.frame(jobtitles, location , company)
  
  jobs <<- rbind.data.frame(jobs,jobs_temp)
}


