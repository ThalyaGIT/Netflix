library(DBI)
library(tidyr)
library(dplyr)
# We have two datasets
# 1. main dataset (Kaggle)
# 2. google scraped data (Refer to python file)
# We will join them and clean the data

# Create an ephemeral in-memory RSQLite database
con <- dbConnect(RSQLite::SQLite(), ":memory:")

netflixData <- read.csv(file = 'datasets/dataset_main.csv')
googleData <- read.csv(file = 'datasets/dataset_googleScraped.csv')


dbWriteTable(con, "netflixData", netflixData)
dbWriteTable(con, "googleData", googleData)

# Joining two tables and excluding repeated columns
query <- "SELECT netflixData.show_id
        , netflixData.type
        , netflixData.title
        , netflixData.director
        , netflixData.cast
        , netflixData.country
        , netflixData.date_added
        , netflixData.release_year
        , netflixData.rating
        , netflixData.duration
        , netflixData.listed_in
        , netflixData.description
        , googleData.Likes
        , googleData.Languages
        , googleData.Genres
        , googleData.Descriptions
        FROM netflixData left join googleData 
        ON netflixData.show_id= googleData.show_id"
res <- dbSendQuery(con, query)
df <- dbFetch(res)

dbClearResult(res)

# 1. Rename columns
new_names <- c("id" 
        , "type"
        , "title"
        , "director"
        , "cast"
        , "country"
        , "data_added"
        , "release_year"
        , "rating"
        , "duration"
        , "genre"
        , "plot"
        , "score"
        , "google_language"
        , "google_genre"
        , "google_plot")
df <- setNames(df, new_names)


# 2. Remove rows which do not have a google score, since this is what we want to predict
df <- df[grep("%", df$score),]


# 3. Count blanks in each column
count_blanks <- function(feature) {
    string1 <- feature
    string2 <- '== ""'
    subset = paste(string1, string2)
    subset <- subset(df, eval(parse(text=subset)))
    count <- count(subset)
  return(count)
}

feature <- new_names # retrieving all the column names

NA_Count <- c(
 toString(count_blanks('id'))
, toString(count_blanks('type'))
, toString(count_blanks('title'))
, toString(count_blanks('director'))
, toString(count_blanks('cast'))
, toString(count_blanks('country'))
, toString(count_blanks('data_added'))
, toString(count_blanks('release_year'))
, toString(count_blanks('rating'))
, toString(count_blanks('duration'))
, toString(count_blanks('genre'))
, toString(count_blanks('plot'))
, toString(count_blanks('score'))
, toString(count_blanks('google_language'))
, toString(count_blanks('google_genre'))
, toString(count_blanks('google_plot')))
print(NA_Count)

NA_Count <- data.frame(feature, NA_Count)

# 4. Transform google_language and google_genre feature into present/absent because it was not scrappable
df$google_language <- ifelse(df$google_language =="", "absent", "present")
view <- df %>% group_by(google_language) %>% summarise(count = n())  # Show categories and count by each category

df$google_genre <- ifelse(df$google_genre =="", "absent", "present")
view <- df %>% group_by(google_genre) %>% summarise(count = n()) 


# view <- df %>% group_by(type) %>% summarise(count = n()) # Show types and count by each type
# #
# view <- count(subset(df, country == "")) # Show number rows with no Country Information 

# view <- count(subset(df, data_added == "")) # Show number rows with no Date Added Information

# print("-----")
# print(summary(df))
print(view)

dbDisconnect(con)