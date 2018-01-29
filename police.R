library(jsonlite)
library(tidyverse)
library(here)

api_root <- "https://data.police.uk/api"
paste_url <- function(...) { URLencode(paste(..., sep = "/")) }

api <-
  fromJSON(paste0(api_root, "/forces")) %>%
  as_tibble() %>%
  rename(force_id = id,
         force_name = name) %>%
  mutate(force_url = pmap_chr(list(api_root, force_id, "neighbourhoods"),
                              paste_url),
         neighbourhoods = map(force_url, fromJSON)) %>%
  unnest(neighbourhoods) %>%
  rename(neighbourhood_id = id,
         neighbourhood_name = name) %>%
  mutate(neighbourhood_url = pmap_chr(list(api_root,
                                           force_id,
                                           neighbourhood_id),
                                      paste_url))

neighbourhoods <-
  api %>%
  mutate(neighbourhood = map(neighbourhood_url,
                             function(.x) {
                               cat(.x, "\n")
                               fromJSON(.x)
                             }))

neighbourhoods %>%
  unnest(neighbourhood)

locations <-
  neighbourhoods %>%
  mutate(locations = map(neighbourhood, ~ .x$locations)) %>%
  filter(map_int(locations, length) != 0) %>%
  select(force_id, neighbourhood_id, neighbourhood_name, locations) %>%
  unnest(locations)

# Most locations are stations, hundreds are undefined, a handful are other types
locations %>%
  count(type)
# # A tibble: 6 x 2
#   type                     n
#   <chr>                <int>
# 1 headquarters             1
# 2 police-office           10
# 3 police-station          46
# 4 rural-police-station     1
# 5 station               2201
# 6 NA                     715

# Many locations each serve several neighbourhoods
locations %>%
  distinct(neighbourhood_id, name) %>%
  count(name, sort = TRUE) %>%
  filter(!is.na(name)) %>%
  ggplot(aes(n)) +
  geom_histogram(binwidth = 1, centre = 0)

# Most stations have coordinates and postcodes
locations %>%
  filter(str_detect(type, "station")) %>%
  mutate(has_lat_lon = !is.na(longitude) & !is.na(latitude),
         has_postcode = !is.na(postcode)) %>%
  count(has_lat_lon, has_postcode)
# # A tibble: 4 x 3
#   has_lat_lon has_postcode     n
#   <lgl>       <lgl>        <int>
# 1 F           F              306
# 2 F           T              658
# 3 T           F               23
# 4 T           T             1261

# Write forces, neighbourhoods and stations to files
api %>%
  distinct(force_id, force_name, force_url) %>%
  write_tsv(here("lists", "force.tsv"))
api %>%
  distinct(force_id, neighbourhood_id, neighbourhood_name, neighbourhood_url) %>%
  write_tsv(here("lists", "neighbourhood.tsv"))

locations %>%
  filter(str_detect(type, "station")) %>%
  select(force_id,
         neighbourhood_id,
         station_name = name,
         latitude,
         longitude,
         postcode,
         address) %>%
  mutate(address = str_replace_all(address, "\n", " ")) %>%
  write_tsv(here("lists", "station.tsv"), na = "")

# Save the big objects that take ages to query from the API
saveRDS(api, here("lists", "api.Rds"))
saveRDS(neighbourhoods, here("lists", "neighbourhoods.Rds"))
saveRDS(locations, here("lists", "locations.Rds"))
