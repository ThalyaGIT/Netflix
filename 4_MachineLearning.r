#Get top 100 actors and actress from IMDB list
library(data.table)
library(DBI)
library(tidyr)
library(dplyr)
library(lubridate)


# Feature engineering - categories actors based on how popular they are 
main <- read.csv(file = 'datasets/view_main_features.csv')

main$date_added <- as.Date(as.character(main$date_added))


main = subset(main, select = -c(plot,google_plot,id,title,scoreClass,duration_units))

row.number <- sample(1:nrow(main), 0.5*nrow(main))
train = main[row.number,]
test = main[-row.number,]

print("running regression.....")
model1 = lm(log(score)~., data=train)
# model1 = lm(scoreClass, data=train)
print(summary(model1))
# par(mfrow=c(2,2))
# plot(model1)