library(DBI)
library(tidyr)
library(dplyr)


# Create an ephemeral in-memory RSQLite database
con <- dbConnect(RSQLite::SQLite(), ":memory:")

netflixData <- read.csv(file = 'datasets/dataset_main.csv')
googleData <- read.csv(file = 'datasets/dataset_googleScrapedData.csv')

dbWriteTable(con, "netflixData", netflixData)
dbWriteTable(con, "googleData", googleData)


# Build Country Mapping Table
query <- "SELECT netflixData.show_id, netflixData.country FROM netflixData"

res <- dbSendQuery(con, query)
temp <- dbFetch(res)
dbClearResult(res)

country_mapping <- temp %>%
    mutate(country = strsplit(as.character(country), ",")) %>%
    unnest(country)

write.csv(country_mapping, "datasets/mapping_country.csv", row.names=FALSE)


# Build Director Mapping Table
query <- "SELECT netflixData.show_id, netflixData.director FROM netflixData"

res <- dbSendQuery(con, query)
temp <- dbFetch(res)
dbClearResult(res)

director_mapping <- temp %>%
    mutate(director = strsplit(as.character(director), ",")) %>%
    unnest(director)

write.csv(director_mapping, "datasets/mapping_director.csv", row.names=FALSE)


# Build Cast Mapping Table
query <- "SELECT netflixData.show_id, netflixData.cast FROM netflixData"

res <- dbSendQuery(con, query)
temp <- dbFetch(res)
dbClearResult(res)

cast_mapping <- temp %>%
    mutate(cast = strsplit(as.character(cast), ",")) %>%
    unnest(cast)

write.csv(cast_mapping, "datasets/mapping_cast.csv", row.names=FALSE)


# Build Listed_in Mapping Table
query <- "SELECT netflixData.show_id, netflixData.listed_in FROM netflixData"

res <- dbSendQuery(con, query)
temp <- dbFetch(res)
dbClearResult(res)

listed_in_mapping <- temp %>%
    mutate(listed_in = strsplit(as.character(listed_in), ",")) %>%
    unnest(listed_in)

write.csv(listed_in_mapping, "datasets/mapping_listedIn.csv", row.names=FALSE)


# Build Language Mapping Table
query <- "SELECT netflixData.show_id, googleData.languages
            FROM netflixData 
            INNER JOIN googleData 
            ON netflixData.show_id = googleData.show_id
            "

res <- dbSendQuery(con, query)
temp <- dbFetch(res)

language_mapping <- temp %>%
    mutate(Languages = strsplit(as.character(Languages), ",")) %>%
    unnest(Languages)

write.csv(language_mapping, "datasets/mapping_language.csv", row.names=FALSE)


# Build Genres Mapping Table
query <- "SELECT netflixData.show_id, googleData.genres
            FROM netflixData 
            INNER JOIN googleData 
            ON netflixData.show_id = googleData.show_id
            "

res <- dbSendQuery(con, query)
temp <- dbFetch(res)
dbClearResult(res)

genre_mapping <- temp %>%
    mutate(Genres = strsplit(as.character(Genres), ",")) %>%
    unnest(Genres)

write.csv(genre_mapping, "datasets/mapping_genre.csv", row.names = FALSE)

dbDisconnect(con)