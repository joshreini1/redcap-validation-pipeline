#Validate raw data from REDCap API against standards
#Version 1.0
#Author - Josh Reini (joshua.reini.ctr@usuhs.edu)

#Set path for package library
myPaths <- .libPaths()
myPaths <- c('//WRNMDFPISISMBD1/DeptShares$/Dept5/CRSR_data/RLib')
.libPaths(myPaths)

#load packages
library(pointblank)
library(dplyr)
library(htmltools)

#load in form prefix matching
prefix <- read.csv("form_prefix_mapping.csv",header=TRUE)

#join prefixes onto instruments
event_instrument_prefix <- inner_join(instruments,prefix,by = c("form"="form"))

#create list of all events
events <- unique(event_instrument_prefix$unique_event_name)

#create folder to store outputs
dir.create("standards_output")

#loop through every event
for (event in 1:length(events)) {
    
  #filter raw data to rows with each event
  temp <- raw_data
  temp <- filter(temp,redcap_event_name == events[event])
  temp <- filter(temp,is.na(redcap_repeat_instrument))
  
  #filter columns to only required variables for each event
  prefixtemp <- event_instrument_prefix
  prefixtemp <- filter(prefixtemp,  unique_event_name == events[event])
  prefixtemp <- unique(prefixtemp$prefix)
  
  #start table 
  start_subjects <- data.frame("subject_id"=as.numeric(unique(raw_data$subject_id)))
  
  #loop through each instrument required for this event
  for (prefix in 1:length(prefixtemp)) {
    #select variables if they start with the prefix for the instrument in this loop
    prefixdata <- temp %>% select(subject_id, subject_treatgroup, starts_with(as.character(prefixtemp[prefix])))
    #join those fields on to the data from the last loop
    start_subjects <- left_join(start_subjects,prefixdata)
    print(prefixtemp[prefix])
  }
  
  #write a csv with the data for this event
  write.csv(start_subjects,paste0("./standards_output/",as.character(events[event]),".csv"))
  
  #create agent using pointblank package
  #test if treatment group is randomized, required instruments are marked complete
  agent <- 
    start_subjects %>%
    create_agent(actions = action_levels(stop_at = 0.001)) %>%
    col_vals_in_set(subject_treatgroup, c("A","B")) %>%
    col_vals_in_set(ends_with("complete"),c("Complete","Opted Out")) %>%
    interrogate()
  
  agent_report <-
    agent %>%
    get_agent_report()
  
  #export agent report into output folder
  save_html(agent_report,
            paste0(getwd(),"./standards_output/",as.character(events[event]),".html"),
            background = "white",
            libdir = "/standards_output"
            )
  }