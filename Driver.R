#PrTMS Quality Control Driver Script
#Version 1.0
#Author - Josh Reini (joshua.reini.ctr@usuhs.edu)

#Pull data from REDCap API
source("Read.R")

#Validate raw data against expected values
source("Standards.R")