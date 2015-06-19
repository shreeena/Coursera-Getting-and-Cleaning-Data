#### Downloads and unzips data

## url <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
## download.file(url,destfile="UCI HAR Dataset.zip","internal") 
## unzip("UCI HAR Dataset.zip")

library("dplyr")
library("plyr")
library(reshape2)

#### Read files in folder and fixed variable names
activity_labels <- read.table("UCI HAR Dataset/activity_labels.txt")
activity_labels[,"V2"]<-as.character(activity_labels[,"V2"])

features <- read.table("UCI HAR Dataset/features.txt")
features[,"V2"] <- as.character(features[,"V2"])
features[,"V2"] <- gsub("-mean", "Mean", features[,"V2"])
features[,"V2"] <- gsub("-std", "STD", features[,"V2"])
features[,"V2"] <- gsub("[-()]", "", features[,"V2"])

subject_test <- read.table("UCI HAR Dataset/test/subject_test.txt")
X_test <- read.table("UCI HAR Dataset/test/X_test.txt")
Y_test <- read.table("UCI HAR Dataset/test/y_test.txt")


subject_train <- read.table("UCI HAR Dataset/train/subject_train.txt")
X_train <- read.table("UCI HAR Dataset/train/X_train.txt")
Y_train <- read.table("UCI HAR Dataset/train/y_train.txt")


### create test data frame
test_activity<-join(Y_test,activity_labels) # matches Y_test with its descriptive activity name
test <- cbind(X_test, subject_test, test_activity)


### create train data frame
train_activity<-join(Y_train,activity_labels) # matches Y_train with its descriptive activity name
train <- cbind(X_train, subject_train, train_activity)


### Combined train and test data 
data<-rbind(train, test)


### extracted the relevant feature names that contained mean and std
### took out the features that had meanfreq
relFeatures<-grep("Mean|STD",features[,"V2"])
mfFeatures<-grep("MeanFreq", features[,"V2"])
relFeatures<-relFeatures[! relFeatures %in% mfFeatures]

### extracted the relevant columns while keeping subject and activity
relCols<-c(relFeatures,562,564)
data<-data[,relCols]

### added the column names to the data frame
colnames(data)<-c(features[relFeatures,"V2"], "Subject", "Activity")


### changed the subject and activity columns to factors
data$Subject<-as.factor(data$Subject)
data$Activity<-as.factor(data$Activity)


data.melted <- melt(data, id = c("Subject", "Activity"))
data.mean <- dcast(data.melted, Subject + Activity ~ variable, mean)


write.table(data.mean, "tidy.txt", row.names=FALSE, quote=FALSE)
