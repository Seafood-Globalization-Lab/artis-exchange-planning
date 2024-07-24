# Load database data

# Load packages
library(tidyverse)
library(countrycode)
library(exploreARTIS)
library(DBI)

# Initial database pulls

# Database connection
con <- dbConnect(RPostgres::Postgres(),
                 dbname=Sys.getenv("DB_NAME"),
                 host="localhost",
                 port="5432",
                 user=Sys.getenv("DB_USERNAME"),
                 password=Sys.getenv("DB_PASSWORD"))

# Check that connection is established by checking which tables are present
dbListTables(con)

# ARTIS dataframe
artis <- dbGetQuery(con, "SELECT * FROM snet") %>%
  select(-record_id) %>%
  mutate(hs6 = case_when(
    str_length(hs6) == 5 ~ paste("0", hs6, sep = ""),
    TRUE ~ hs6
  )) 

artis_custom <- artis %>%
  # Filter to custom TS
  filter(
    # Use HS96 from 1996-2003 (inclusive)
    ((hs_version == "HS96") & (year <= 2003)) |
      # Use HS02 from 2004-2009 (inclusive)
      ((hs_version == "HS02") & (year >= 2004 & year <= 2009)) |
      # Use HS07 from 2010-2012 (inclusive)
      ((hs_version == "HS07") & (year >= 2010 & year <= 2012)) |
      # Use HS12 from 2013-2019 (inclusive)
      ((hs_version == "HS12") & (year >= 2013 & year <= 2020))
  ) 


# consumption dataframe
consumption <- dbGetQuery(con, "SELECT * FROM consumption") %>%
  select(-record_id) 

# Production dataframe
prod <- dbGetQuery(con, "SELECT * FROM production") %>%
  select(-record_id) 

# SAU Production dataframe
prod_sau <- dbGetQuery(con, "SELECT * FROM sau_production") %>%
  select(-record_id) 

# Species metadata
sciname_metadata <- dbGetQuery(con, "SELECT * FROM sciname") %>%
  select(-record_id)

# Maximum taxa resolution 
code_max_resolved_taxa <- dbGetQuery(con, "SELECT * FROM code_max_resolved_taxa") %>%
  select(-record_id) %>%
  mutate(hs6 = case_when(
    str_length(hs6) == 5 ~ paste("0", hs6, sep = ""),
    TRUE ~ hs6
  )) %>%
  mutate(hs_version = case_when(
    str_length(hs_version) == 1 ~ paste("0", hs_version, sep = ""),
    TRUE ~ hs_version
  )) %>%
  mutate(hs_version = paste("HS", hs_version, sep = ""))

pop <- dbGetQuery(con, "SELECT * FROM population") %>%
  select(-record_id) 

# Close database connection
dbDisconnect(con)
rm(list = c("con"))
