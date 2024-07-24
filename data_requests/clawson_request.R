# Clawson request

library(tidyverse)
library(exploreARTIS)

# Filter custom artis
artis_request <- artis_custom %>%
  filter(year %in% 2015:2020, 
         importer_iso3c %in% c("AUS"),
         hs6 == "230120")

write.csv(artis_request, "data_requests/artis_request_clawson.csv", row.names = FALSE)


artis_request %>%
  plot_sankey(cols = c("sciname", "source_country_iso3c", "exporter_iso3c", "importer_iso3c"))
