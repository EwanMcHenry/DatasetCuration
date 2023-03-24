##------ Wed Jun  8 09:42:51 2022 ------##
# Ewan McHenry

# dataset from https://use-land-property-data.service.gov.uk/datasets/inspire/download#download
# used bulk link downloader extension in google chrome to speed up download
## im sure a better hacker would do it easier
##https://chrome.google.com/webstore/detail/batch-link-downloader/aiahkbnnpafepcgnhhecilboebmmolnn
# used 7zip to bulk unzip

# libraries ----
library(tidyverse)
library(sf) # for gis

# personal functiosn and specifications - you wont need these, used in my specification
source("D:\\Users\\Ewan McHenry\\OneDrive - the Woodland Trust\\GIS\\Ewans functions.R")
source("D:\\Users\\Ewan McHenry\\OneDrive - the Woodland Trust\\GIS\\Ewans gis specifications.R")


# set wds and paths ----
main.wd = "D:\\Users\\Ewan McHenry\\OneDrive - the Woodland Trust\\GIS\\Data"
path.downloads = "\\Ownership\\downloaded data\\INSPIRE"
path.curated = "\\Ownership\\curated\\INSPIRE"
setwd(main.wd)

# specifications ----

landscapes <- st_read("Treescape boundaries\\Ewan TS_priority_v1.01gbgrid01.shp") # your landscapes: an sf with a different polygon for each landscape
landscape.names <- landscapes$name # vector of names for landscapes you want to cut to
landscape.names.for.filepath <- ts.lcm.names # vector: names of landscapes as you want them in filepath of curated inspire

# create paths for downloads and curated dataset ----
dir.create(paste0(main.wd,path.downloads ))
dir.create(paste0(main.wd,path.curated ))

# curation -----
## load and combine all inspire data into list ----
## list names of unzipped folders 
admin.areas.path = list.dirs(path = paste0(main.wd,path.downloads ), full.names = TRUE, recursive = TRUE) #[1:8]#for test
## read the .gml within each to a list
inspire.list = lapply(2:length(admin.areas.path),FUN = function(i) {
  if.eng.wales.file.name = paste0(admin.areas.path[i], "\\Land_Registry_Cadastral_Parcels.gml")
  if.scot.file.name = paste0(admin.areas.path[i], "\\", list.files(admin.areas.path[i], pattern = "bng.shp"))
  if(file.exists(if.eng.wales.file.name)){
    st_read(if.eng.wales.file.name)
  } else{
    if(file.exists(if.scot.file.name)){
      st_read(if.scot.file.name)
    }
  }
  })
save(inspire.list, file = paste0(main.wd, path.curated, "\\inspire.list.RData"))

# by landscape ----
## intersect with the target landscape ----
## ID which within target landscape 
# load list of inspire data
load( file = paste0(main.wd, path.curated, "\\inspire.list.RData"))


lapply(1:length(landscape.names), function(x){ # for all target landscapes
  target = landscapes %>% # whichever landscape interested in
    filter(name == landscape.names[x])
  
  intersects.target = sapply(1:length(inspire.list), FUN = function(i) {
    
    length(st_intersection(st_make_grid(inspire.list[[i]], n = 1), st_make_grid(target , n = 1)
    ))>0})
  
  if(sum(intersects.target)>0){
    landscape.inspire = do.call(rbind, inspire.list[intersects.target]) %>% 
      st_intersection(target)
    
    save(landscape.inspire, file =  paste0(main.wd, path.curated, "\\", landscape.names.for.filepath[x], "_inspire.RData") )
    }
    
  })
  
  ## - [ ] combine into one sf?


