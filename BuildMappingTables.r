library(tidyr)
library(dplyr)

# Create an ephemeral in-memory RSQLite database

df <- read.csv(file = 'datasets/view_cleaned_main.csv')

# Build Country Mapping Table
country_mapping <- df %>%
    mutate(country = strsplit(as.character(country), ",")) %>%
    unnest(country)

country_mapping = subset(country_mapping, select = c(id, country))
country_mapping$country <- trimws(country_mapping$country, which = c("left"))

write.csv(country_mapping, "datasets/mapping_country.csv", row.names=FALSE)


# # Build Director Mapping Table
director_mapping <- df %>%
    mutate(director = strsplit(as.character(director), ",")) %>%
    unnest(director)

director_mapping = subset(director_mapping, select = c(id, director))
director_mapping$director <- trimws(director_mapping$director , which = c("left"))
write.csv(director_mapping, "datasets/mapping_director.csv", row.names=FALSE)


# # Build Cast Mapping Table
cast_mapping <- df %>%
    mutate(cast = strsplit(as.character(cast), ",")) %>%
    unnest(cast)

cast_mapping = subset(cast_mapping, select = c(id, cast))
cast_mapping$cast <- trimws(cast_mapping$cast, which = c("left"))
write.csv(cast_mapping, "datasets/mapping_cast.csv", row.names=FALSE)


# # Build Genre Mapping Table
genre_mapping <- df %>%
    mutate(genre = strsplit(as.character(genre), ",")) %>%
    unnest(genre)

genre_mapping = subset(genre_mapping, select = c(id, genre))
genre_mapping$cast <- trimws(genre_mapping$genre, which = c("left"))
write.csv(genre_mapping, "datasets/mapping_genre.csv", row.names=FALSE)


# Trim dataset for better performance
df <- read.csv(file = 'datasets/view_cleaned_main.csv')
df = subset(df, select = -c(country,director,cast,genre) )

write.csv(df, "datasets/view_trimmed_main.csv", row.names=FALSE)