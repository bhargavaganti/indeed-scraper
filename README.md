# Indeed.co.uk - Job Description Scraper

### Description

R script that scrapes job descriptions from Indeed.co.uk for a given location and position, and saves the result to csv.

---

#### Load packages

```r
library(rvest)
library(stringr)
library(dplyr)
```

#### Construct URL

```r
location <- "London" %>%
  tolower()

search_term <- "Data Scientist" %>%
  str_replace(" ","+") %>%
  tolower()

URL <- str_c("https://www.indeed.co.uk/jobs?q=",search_term,"&l=",location,"&start=")
```

#### Get total number of listings

```r
joblist <- read_html(URL) 

maxJobs <- joblist %>%
  html_nodes("#searchCount") %>%
  html_text() %>%
  str_extract("[0-9],[0-9]+|[0-9]{3}") %>%
  str_replace(",","") %>%
  str_replace("of ","") %>%
  as.numeric()
```  
#### Scrape data from result page

```r
  scrapeJobsFromPage <- function(url_p){

  joblist <<- read_html(url_p)
  
  # get list of jobtitles 
  jobtitles <- joblist %>%
    html_nodes(".jobtitle") %>%
    html_text()
  
  # get list of locations 
  location <- joblist %>%
    html_nodes(".location") %>%
    html_text()
  
  # get list of companies 
  company <<- joblist %>%
    html_nodes(".company") %>%
    html_text()
  
  # get list of hrefs 
  hrefs <<- joblist %>%
    html_nodes("#resultsCol .jobtitle") %>%
    str_extract('href=".+" (title|target=)') %>% str_extract("^\\S*") %>%
    str_replace('href=\"',"") %>% 
    str_replace_all("amp;","") %>%
    str_replace('\"',"") 
  
  descriptions = vector()
  
  for (href in hrefs) {
    
    if (is.na(href)) {
      descriptions <- c(descriptions, "NA")
    } else {

      description <<- read_html(paste("https://www.indeed.co.uk", href, sep = "")) %>%
        html_nodes(".icl-u-xs-mt--md") %>%
        html_text()
      
      if (length(description) == 0) {

        shouldMoveOn = TRUE
        
        while ((shouldMoveOn)) {
          
          description_attempt <<- read_html(paste("https://www.indeed.co.uk", href, sep = "")) %>%
            html_nodes(".icl-u-xs-mt--md") %>%
            html_text()
        
          if (!is.na(nchar(description_attempt[1]))) {
            shouldMoveOn = FALSE
            descriptions <- c(descriptions, description_attempt[1])
          }
        }
      } else {
        descriptions <- c(descriptions, description[1])
      }
    }
  }
  
  jobs_temp <<- cbind.data.frame(jobtitles, location , company,descriptions)
  
  jobs <<- rbind.data.frame(jobs,jobs_temp)

}
``` 
#### Loop through pages

```r
for (n in seq(0, 2000, by=10)) {
  URL_new = paste(URL, n, sep="")
  print(paste("scraping jobs from",URL_new))
  scrapeJobsFromPage(URL_new)
}
``` 

#### Save to csv

```r
jobs[] <- lapply(jobs, gsub, pattern='\n', replacement='')
jobs$company = str_trim(jobs$company)
jobs$jobtitles = str_trim(jobs$jobtitles)

write.csv(jobs, "data/listings.csv", row.names = FALSE)
``` 