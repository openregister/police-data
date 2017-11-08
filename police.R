library(jsonlite)
library(tidyverse)
library(stringr)
forces <- fromJSON("https://data.police.uk/api/forces")


urls <- paste0("https://data.police.uk/api/" ,forces$id,"/neighbourhoods")

neighbourhood <- 
  map_df(urls, fromJSON, .id = "force") %>%
  mutate(force = forces$id[as.integer(force)])

neighbourhood <- neighbourhood[c(2,3,1)]

write_tsv(forces, "data/police-force/police-force.tsv")
#write_tsv(neighbourhood, "data/police-neighbourhood/police-neighbourhood.tsv")
