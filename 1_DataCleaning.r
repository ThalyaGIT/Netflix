library(DBI)
library(tidyr)
library(dplyr)
library(data.table)
library(lubridate)


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
NA_Count <- data.frame(feature, NA_Count)

# 4. Transform google_language and google_genre feature into present/absent because it was not scrappable
df$google_language <- ifelse(df$google_language =="", "absent", "present")
view <- df %>% group_by(google_language) %>% summarise(count = n())  # Show categories and count by each category

df$google_genre <- ifelse(df$google_genre =="", "absent", "present")
view <- df %>% group_by(google_genre) %>% summarise(count = n())


# See if type needs cleaning
view <- df %>% group_by(type) %>% summarise(count = n()) # Show types and count by each type

# See if director needs cleaning
view <- df %>% group_by(director) %>% summarise(count = n()) # Show directors and count by each director group
# setDT(view)
# View(view)
# Some of the rows have more than one director (will make maping tables)


# See if cast needs cleaning
view <- df %>% group_by(cast) %>% summarise(count = n()) # Show cast and count by each cast group
# setDT(view)
# View(view)
# Many of the rows have more than one cast (will make maping tables)

# See if country needs cleaning
view <- df %>% group_by(country) %>% summarise(count = n()) # Show country and count by each country group
# setDT(view)
# View(view)
# Many of the rows have more than one country (will make maping tables)

# See if date_added needs cleaning
view <- df %>% group_by(data_added) %>% summarise(count = n()) # Show data_added and count by each data_added
# setDT(view)
# View(view)
# Change to date format
df$data_added <- mdy(df$data_added)

# See if release year needs cleaning
view <- df %>% group_by(release_year) %>% summarise(count = n()) # Show release_year and count by each release_year
# setDT(view)
# View(view)

# See if rating needs cleaning
view <- df %>% group_by(rating) %>% summarise(count = n()) # Show release_year and count by each release_year
# setDT(view)
# View(view)

# See if duration needs cleaning
view <- df %>% group_by(duration) %>% summarise(count = n()) # Show duration and count by each release_year

# convert blanks to NA
df$duration[df$duration ==""] <- NA
df <- separate(df, duration, c("duration", "duration_units"))

# Convert duration to numeric
df <- transform(df, duration = as.numeric(duration))

# See if genre needs cleaning
view <- df %>% group_by(genre) %>% summarise(count = n()) # Show genre and count by each genre
# setDT(view)
# View(view)

# See if plot needs cleaning
view <- df %>% group_by(plot) %>% summarise(count = n()) # Show plot and count by each plot
# setDT(view)
# View(view)

# See if score needs cleaning
view <- df %>% group_by(score) %>% summarise(count = n()) # Show score and count by each score
# setDT(view)
# View(view)

# Remove % and convert to numeric type
df$score<-gsub("%","",as.character(df$score))
df <- transform(df, score = as.numeric(score))


# See if google_plot needs cleaning
view <- df %>% group_by(google_plot) %>% summarise(count = n()) # Show google_plot and count by each google_plot
setDT(view)
View(view)

print(summary(df))

write.csv(df, "datasets/view_main_cleaned.csv", row.names=FALSE)

dbDisconnect(con)
