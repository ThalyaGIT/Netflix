library(data.table)
library(DBI)
library(tidyr)
library(dplyr)
library(lubridate)
library(quanteda)
library(tm)
library(lsa)
library("quanteda.textmodels")
library(ggplot2)

# load data
main <- read.csv(file = 'datasets/view_main_features.csv')
main$plot_combined <- paste(main$plot,main$google_plot)

# Convert data to corpus
corpus <- Corpus(VectorSource(main$plot_combined))

# Remove special characters, case, punctuation and numbers
removeSpecialChars <- function(x) gsub("[^a-zA-Z0-9 ]","",x)
corpus <- tm_map(corpus, removeSpecialChars)
corpus <- tm_map(corpus, removeNumbers)
corpus <- tm_map(corpus, removePunctuation)
corpus <- tm_map(corpus, content_transformer(tolower))


# Remove stop words
corpus <- tm_map(corpus, removeWords, stopwords("english"))

# Remove white space
corpus <- tm_map(corpus, stripWhitespace)

# Stemming
corpus <- tm_map(corpus, stemDocument)

# Term document matrix
tdm <- TermDocumentMatrix(corpus)

# View top 5 most frequently occuring term
tdmMatrix <- as.matrix(tdm)
v <- sort(rowSums(tdmMatrix), decreasing=TRUE)
d <- data.frame(word=names(v),freq=v)
# print(head(d,5))

# Weighting 
tdm2 <- as.textmatrix(as.matrix(tdm))
tdm.weighted <- lw_logtf(tdm2)
print(tdm.weighted)

# Latent Semantic Analysis
lsa <- lsa(tdm.weighted, dims=10)

Tk <- lsa$tk

Sk <- lsa$sk
Dk <- lsa$dk
print("DK")
print(Dk)

# Varimax Rotation
Tk.varimax <- varimax(Tk)

Dk.rotated <- Dk %*% Tk.varimax$rotmat
Tk.rotated <- Tk %*% Tk.varimax$rotmat

# Interreting Term and Document Matrices

sort.loadings.table <- function(x) {
    factor.names <- colnames(x)
    x <- as.data.frame(x)
    x$max.factor <- apply(abs(x),1,which.max)
    x$max.value <- x[cbind(1:nrow(x),x$max.factor)]
    x <- x[order(x$max.factor,-abs(x$max.value)),]
    x$item <- rownames(x)
    rownames(x) <- NULL
    x
}

threshold.loadings.table <- function (x,q=0.1) {
    threshold <- quantile(abs(x$max.value),probs=1-q)
    x <- subset(x,abs(x$max.value)>threshold)
    x
}

Tk.thresholded <- as.data.table(threshold.loadings.table(sort.loadings.table(Tk.rotated),q=0.02))
write.csv(Tk.thresholded[,.(item, max.factor, max.value)], "datasets/tk.csv", row.names=FALSE)

Dk.thresholded <- as.data.table(threshold.loadings.table(sort.loadings.table(Dk.rotated),q=1))
# print(Dk.thresholded[,.(item,max.factor,max.value)])
write.csv(Dk.thresholded[,.(item,max.factor,max.value)],"datasets/dk.csv", row.names=FALSE)

biplot <- function(Tk,Dk,xdim,ydim,Tk.scale=1,...){
    print("made it")
    Tk[,type:="Terms"]
    Dk[,type:="Title"]
    biplot.data <- rbindlist(list(Tk,Dk))
    setnames(biplot.data,xdim,"F1")
    setnames(biplot.data,ydim,"F2")
    biplot.data[type=="Terms",F1:=F1*Tk.scale]
    biplot.data[type=="Terms",F2:=F2*Tk.scale]
    ggplot(biplot.data, aes(x=F1, y=F2, label=item, col=type)) + geom_text()
}

plot(biplot(Tk=Tk.thresholded,Dk=Dk.thresholded, xdim="V1", ydim="V2", Tk.scale=2))