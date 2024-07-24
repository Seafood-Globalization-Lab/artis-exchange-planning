# Orofino

library(tidyverse)
library(exploreARTIS)

# 1996-2020 all HS versions
# For sample 2017-2020 for all HS versions

# elasmobrachii

# territories falling within countries
shark_scinames <- sciname_metadata %>%
  filter(class == "elasmobranchii") %>%
  pull(sciname)

artis_request <- artis %>%
  filter(year %in% 2017:2020, 
         sciname %in% shark_scinames)


artis_request %>%
  plot_map(flow_arrows = TRUE)


artis_request %>%
  plot_sankey(cols = c("sciname", "source_country_iso3c", "importer_iso3c"),
              prop_flow_cutoff = 0.04)

write.csv(artis_request, "data_requests/artis_request_orofino.csv", row.names = FALSE)
