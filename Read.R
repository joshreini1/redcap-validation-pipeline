#Set up, pull in raw data from REDCap API
#Version 1.0
#Author - Josh Reini (joshua.reini.ctr@usuhs.edu)

#Set path for package library
myPaths <- .libPaths()
myPaths <- c('//WRNMDFPISISMBD1/DeptShares$/Dept5/CRSR_data/RLib')
.libPaths(myPaths)

#load packages
library(readr)
library(RCurl)
library(redcapAPI)

redcap_api_read <- function(keypath) {
  
  #Initialize USUHS REDCap URI
  redcap_uri <- "https://redcap.usuhs.edu/api/"
  
  #Load in API key saved as .txt file
  prtms_token <- readChar(keypath, file.info(keypath)$size)
  
  #establish redcap connection
  rcon <- redcapConnection(
    url = redcap_uri,
    token = prtms_token
  )
  
  #pull all data
  exportRecords(rcon)
}

redcap_api_eventmapping <- function(keypath) {
  
  #Initialize USUHS REDCap URI
  redcap_uri <- "https://redcap.usuhs.edu/api/"
  
  #Load in API key saved as .txt file
  prtms_token <- readChar(keypath, file.info(keypath)$size)
  
  #establish redcap connection
  rcon <- redcapConnection(
    url = redcap_uri,
    token = prtms_token
  )
  
  #pull all data
  exportMappings(rcon)
}

raw_data <- redcap_api_read("C:/Users/josh.reini/API_Keys/PrTMS.txt")
raw_data <- transform(raw_data, subject_id = as.numeric(subject_id))

instruments <- redcap_api_eventmapping("C:/Users/josh.reini/API_Keys/PrTMS.txt")
instruments <- subset(instruments, select = -c(arm_num))