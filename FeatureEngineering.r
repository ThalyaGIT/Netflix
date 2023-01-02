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

View(popularActors)

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

View(popularActresses)

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

View(popularDirectors)

write.csv(popularDirectors, "datasets/view_popular_directors.csv", row.names=FALSE)


