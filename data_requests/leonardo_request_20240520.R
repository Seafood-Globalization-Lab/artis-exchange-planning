# Load database data

# Load packages
library(tidyverse)
library(countrycode)
library(exploreARTIS)
library(DBI)

# Codes of interest
focal_codes <- c("030292", "030392", "030281", "030381", "160418", "030571", 
                 "160561", "030819", "030812", "030811", "160557", "160590", 
                 "030799", "030791", "030281", "030265", "160419")

# Initial database pulls

# Database connection
con <- dbConnect(RPostgres::Postgres(),
                 dbname=Sys.getenv("HEROKU_DB_NAME"),
                 host=Sys.getenv("HEROKU_HOST"),
                 port=Sys.getenv("HEROKU_DB_PORT"),
                 user=Sys.getenv("HEROKU_DB_USERNAME"),
                 password=Sys.getenv("HEROKU_DB_PW"))

# Check that connection is established by checking which tables are present
dbListTables(con)

# ARTIS dataframe
artis <- dbGetQuery(con, "SELECT * FROM snet") %>%
  select(-record_id) %>%
  mutate(hs6 = case_when(
    str_length(hs6) == 5 ~ paste("0", hs6, sep = ""),
    TRUE ~ hs6
  )) 

# Close database connection
dbDisconnect(con)
rm(list = c("con"))


# USE LOCAL CONNECTION FOR NOW
# Database connection
con <- dbConnect(RPostgres::Postgres(),
                 dbname=Sys.getenv("DB_NAME"),
                 host="localhost",
                 port="5432",
                 user=Sys.getenv("DB_USERNAME"),
                 password=Sys.getenv("DB_PASSWORD"))

# Check that connection is established by checking which tables are present
dbListTables(con)

# Load raw Baci data
baci <- dbGetQuery(con, "SELECT * FROM baci") %>%
  select(-record_id)

# Species metadata
sciname_metadata <- dbGetQuery(con, "SELECT * FROM sciname") %>%
  select(-record_id)

# Load product descriptions
products <- dbGetQuery(con, "SELECT * FROM products") %>%
  select(-record_id) %>% 
  filter(hs6 %in% focal_codes) %>%
  select(classification, hs6, description) %>%
  distinct()

# Close database connection
dbDisconnect(con)
rm(list = c("con"))

# Scientific names in Elasmobranchii and Holothuroidea
sciname_list <- sciname_metadata %>% 
  filter(class %in% c("elasmobranchii", "holothuroidea")) %>%
  pull(sciname) %>%
  unique()

artis_request <- artis %>%
  filter(sciname %in% sciname_list | 
         hs6 %in% focal_codes)

baci_request <- baci %>%
  filter(hs6 %in% focal_codes)

write.csv(artis_request, "data_requests/artis_request_feitosa.csv", row.names = FALSE)

holothuroidea_scinames <- sciname_metadata %>% 
  filter(class %in% c("holothuroidea")) %>%
  pull(sciname) %>%
  unique()

artis_request %>%
  filter(sciname %in% holothuroidea_scinames) %>%
  plot_ts(artis_var = "hs6", plot.type = "stacked")


artis_request %>%
  filter(hs6 == "160590") %>%
  plot_ts(artis_var = "sciname", plot.type = "stacked")
