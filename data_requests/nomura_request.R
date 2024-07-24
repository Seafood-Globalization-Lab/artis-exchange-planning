# Nomura

library(tidyverse)
library(exploreARTIS)

# Filter custom artis
tuna_scinames <- sciname_metadata %>%
  filter(isscaap == "Tunas, bonitos, billfishes") %>%
  pull(sciname)


artis_request <- artis_custom %>%
  filter(year %in% 2000:2020, 
         importer_iso3c %in% c("FSM", "FJI", "VUT", "SLB", "AUT", "NZL")|
           exporter_iso3c %in% c("FSM", "FJI", "VUT", "SLB", "AUT", "NZL")|
           source_country_iso3c %in% c("FSM", "FJI", "VUT", "SLB", "AUT", "NZL"), 
         sciname %in% tuna_scinames)

write.csv(artis_request, "data_requests/artis_request_nomura.csv", row.names = FALSE)
