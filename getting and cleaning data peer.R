# Get the Data:
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
download.file(fileUrl,destfile="Dataset.zip")

#Unzip the file
unzip(zipfile="Dataset.zip",exdir="./data")
fold <- file.path("./data" , "UCI HAR Dataset")
fold
files<-list.files(fold, recursive=TRUE)
files

#read files
dataActivityTest  <- read.table(file.path(fold, "test" , "Y_test.txt" ),header = FALSE)
dataActivityTrain <- read.table(file.path(fold, "train", "Y_train.txt"),header = FALSE)
dataSubjectTrain <- read.table(file.path(fold, "train", "subject_train.txt"),header = FALSE)
dataSubjectTest  <- read.table(file.path(fold, "test" , "subject_test.txt"),header = FALSE)
dataFeaturesTest  <- read.table(file.path(fold, "test" , "X_test.txt" ),header = FALSE)
dataFeaturesTrain <- read.table(file.path(fold, "train", "X_train.txt"),header = FALSE)
str(dataActivityTest)
str(dataActivityTrain)
str(dataSubjectTrain)
str(dataSubjectTest)
str(dataFeaturesTest)
str(dataFeaturesTrain)

#rbind data
dataSubject <- rbind(dataSubjectTrain, dataSubjectTest)
dataActivity<- rbind(dataActivityTrain, dataActivityTest)
dataFeatures<- rbind(dataFeaturesTrain, dataFeaturesTest)

#set variable Names
names(dataSubject)<-c("subject")
names(dataActivity)<- c("activity")
dataFeaturesNames <- read.table(file.path(fold, "features.txt"),head=FALSE)
names(dataFeatures)<- dataFeaturesNames$V2
combdat <- cbind(dataSubject, dataActivity)
Data <- cbind(dataFeatures, combdat)

#Desc. Stats on subset
FeaturesNames<-dataFeaturesNames$V2[grep("mean\\(\\)|std\\(\\)", dataFeaturesNames$V2)]

#subset by "subject" and "activity"
selectedNames<-c(as.character(FeaturesNames), "subject", "activity" )
Data<-subset(Data,select=selectedNames)
str(Data)

#read activity_labels.txt
activityLabels <- read.table(file.path(fold, "activity_labels.txt"),header = FALSE)

#factorize "activity" in the "Data" df
Data$activity<-factor(Data$activity);
Data$activity<- factor(Data$activity,labels=as.character(activityLabels$V2))

#gsub names
names(Data)<-gsub("^t", "time", names(Data))
names(Data)<-gsub("^f", "frequency", names(Data))
names(Data)<-gsub("Acc", "Accelerometer", names(Data))
names(Data)<-gsub("Gyro", "Gyroscope", names(Data))
names(Data)<-gsub("Mag", "Magnitude", names(Data))
names(Data)<-gsub("BodyBody", "Body", names(Data))
names(Data)

#create clean data set
library(plyr)
Cleandat<-aggregate(. ~subject + activity, Data, mean)
Cleandat<-Cleandat[order(Cleandat$subject, Cleandat$activity),]
write.table(Cleandat, file = "tidydata.txt",row.name=FALSE)
