library(data.table)
library(tidyr)

con <- dbConnect(RSQLite::SQLite(), ":memory:")

main <- read.csv(file = 'datasets/view_main_features.csv')
lsa <- read.csv(file = 'datasets/lsa_2.csv')

lsa$item <- sub("^", "s", lsa$item )


dbWriteTable(con, "main", main)
dbWriteTable(con, "lsa", lsa)



query <- "SELECT m.*, l.*
                FROM main m
                LEFT JOIN lsa l ON m.id = l.item"
res <- dbSendQuery(con, query)
df <- dbFetch(res)
dbClearResult(res)
setDT(df)
View(df)

write.csv(df, "datasets/view_main_lsa.csv", row.names=FALSE)

dbDisconnect(con)
