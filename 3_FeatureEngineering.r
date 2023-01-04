#Get top 100 actors and actress from IMDB list
library(data.table)

# Feature engineering - categories actors based on how popular they are 
popularActors <- read.csv(file = 'datasets/dataset_popular_actors.csv')

# Create new column and set default value to "top 1000"
popularActors$rank_category <- "top 1000"
setDT(popularActors)

popularActors$rank_category[popularActors$Position < 501 ] <- "top 500"
popularActors$rank_category[popularActors$Position < 201 ] <- "top 200"
popularActors$rank_category[popularActors$Position < 101 ] <- "top 100"
popularActors$rank_category[popularActors$Position < 51 ] <- "top 50"
popularActors$rank_category[popularActors$Position < 21 ] <- "top 20"
popularActors$rank_category[popularActors$Position < 11 ] <- "top 10"

# Get points from actresses
popularActors <- separate(popularActors, Description, c("Points", "Description"))
popularActors <- transform(popularActors, Points = as.numeric(Points))

# View(popularActors)

write.csv(popularActors, "datasets/view_popular_actors.csv", row.names=FALSE)


# Feature engineering - categories actors based on how popular they are 
popularActresses <- read.csv(file = 'datasets/dataset_popular_actresses.csv')

# Create new column and set default value to "top 1000"
popularActresses$rank_category <- "top 1000"
setDT(popularActresses)

popularActresses$rank_category[popularActresses$Position < 501 ] <- "top 500"
popularActresses$rank_category[popularActresses$Position < 201 ] <- "top 200"
popularActresses$rank_category[popularActresses$Position < 101 ] <- "top 100"
popularActresses$rank_category[popularActresses$Position < 51 ] <- "top 50"
popularActresses$rank_category[popularActresses$Position < 21 ] <- "top 20"
popularActresses$rank_category[popularActresses$Position < 11 ] <- "top 10"

# Get points from actresses
popularActresses <- separate(popularActresses, Description, c("Points", "Description"))
popularActresses <- transform(popularActresses, Points = as.numeric(Points))

# View(popularActresses)

write.csv(popularActresses, "datasets/view_popular_actresses.csv", row.names=FALSE)


# Feature engineering - categories actors based on how popular they are 
popularDirectors <- read.csv(file = 'datasets/dataset_popular_directors.csv')

# Create new column and set default value to "top 1000"
popularDirectors$rank_category <- "top 1000"
setDT(popularDirectors)

popularDirectors$rank_category[popularDirectors$Position < 501 ] <- "top 500"
popularDirectors$rank_category[popularDirectors$Position < 201 ] <- "top 200"
popularDirectors$rank_category[popularDirectors$Position < 101 ] <- "top 100"
popularDirectors$rank_category[popularDirectors$Position < 51 ] <- "top 50"
popularDirectors$rank_category[popularDirectors$Position < 21 ] <- "top 20"
popularDirectors$rank_category[popularDirectors$Position < 11 ] <- "top 10"

#Get points from directors
popularDirectors <- separate(popularDirectors, Description, c("Points", "Description"))
popularDirectors <- transform(popularDirectors, Points = as.numeric(Points))

# View(popularDirectors)

write.csv(popularDirectors, "datasets/view_popular_directors.csv", row.names=FALSE)



library(DBI)
library(tidyr)
library(dplyr)
library(data.table)
library(lubridate)


# Create an ephemeral in-memory RSQLite database
con <- dbConnect(RSQLite::SQLite(), ":memory:")

main <- read.csv(file = 'datasets/view_main_trimmed.csv')
cast <- read.csv(file = 'datasets/mapping_cast.csv')
actorsPoints <- read.csv(file = 'datasets/view_popular_actors.csv')
actressesPoints <- read.csv(file = 'datasets/view_popular_actresses.csv')
directorsPoints <- read.csv(file = 'datasets/view_popular_directors.csv')

dbWriteTable(con, "main", main)
dbWriteTable(con, "cast", cast)
dbWriteTable(con, "actorsPoints", actorsPoints)
dbWriteTable(con, "actressesPoints", actressesPoints)
dbWriteTable(con, "directorsPoints", directorsPoints)


# Attach the points to the mapping table
query <- "SELECT c.id
                ,c.cast
                ,CASE WHEN a.Points IS NOT NULL THEN a.Points
                WHEN b.Points IS NOT NULL THEN b.Points 
                ELSE 0 END AS points
                FROM cast c
                LEFT JOIN actorsPoints a ON c.cast = a.Name
                LEFT JOIN actressesPoints b ON c.cast = b.Name"
res <- dbSendQuery(con, query)
castPointsMapping <- dbFetch(res)
dbClearResult(res)

dbWriteTable(con, "castPointsMapping", castPointsMapping)

query <- "SELECT a.*
        , CASE WHEN points IS NOT NULL THEN max(points)
        ELSE 0 END AS points
        FROM main a 
        LEFT JOIN castPointsMapping b ON a.id = b.id 
        GROUP BY a.id"
res <- dbSendQuery(con, query)
df <- dbFetch(res)
dbClearResult(res)
# print(df)

write.csv(df, "datasets/view_features_main.csv", row.names=FALSE)

dbDisconnect(con)
