# Reads the base sets (files with begining by X) in an optimal way
# * filePath: path of the file
# * filteredFeatures: ids of the features to be extracted
# * features: all features names

setwd("C:/Users/yzc01/Documents/getdata%2Fprojectfiles%2FUCI HAR Dataset/UCI HAR Dataset")
list("UCI HAR Dataset")
library(plyr)
library(data.table)

# Reads an additional file (other than the base sets). Used for subjects and labels.
# * dataDirectory: directory of data
# * filePath: relative path of the file. For instance if its value is "subject" it
#   will read "UCI HAR Dataset/test/subject_test.txt" and
# "UCI HAR Dataset/train/subject_train.txt", and merge them
subjecttrain <- read.table('./train/subject_train.txt',header = FALSE)
Xtrain <- read.table('./train/X_train.txt', header = FALSE)
ytrain <- read.table('./train/y_train.txt', header = FALSE)

subjectTest <- read.table('./test/subject_test.txt', header = FALSE)
Xtest <- read.table('./train/X_train.txt', header = FALSE) 
ytest <- read.table('./train/y_train.txt', header = FALSE) 

xdataset <- rbind(Xtrain, Xtest)
ydataset <- rbind(ytrain, ytest) 
subjectdataset <- rbind(subjecttrain, subjectTest) 

#xData subset based on the logical vector to keep only desired columns, i.e. mean() and std()"
xDataSet_mean_std <- xdataset[, grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2])]
names(xDataSet_mean_std) <- read.table("features.txt")[grep("-(mean|std)\\(\\)", read.table("features.txt")[, 2]), 2] 
View(xDataSet_mean_std)
dim(xDataSet_mean_std)

ydataset[, 1] <- read.table("activity_labels.txt")[ydataset[,1],2]

# Adding activities
names(ydataset) <- "Activity"
View(ydataset)

# Adding subjects
names(subjectdataset) <- "subject"

# Organizing and combining all data sets into single one.
n <- max(length(xDataSet_mean_std[,1]),length(ydataset[,1]),length(subjectdataset[,1]))
length(xDataSet_mean_std)<- n
length(ydataset) <- n
length(subjectdataset) <- n
singleDataSet <- cbind(xDataSet_mean_std, ydataset, subjectdataset)

# Defining descriptive names for all variables.
names(singleDataSet) <- make.names(names(singleDataSet))
names(singleDataSet) <- make.names(names(singleDataSet))
names(singleDataSet) <- gsub('Acc',"Acceleration",names(singleDataSet))
names(singleDataSet) <- gsub('GyroJerk',"AngularAcceleration",names(singleDataSet))
names(singleDataSet) <- gsub('Gyro',"AngularSpeed",names(singleDataSet))
names(singleDataSet) <- gsub('Mag',"Magnitude",names(singleDataSet))
names(singleDataSet) <- gsub('^t',"TimeDomain.",names(singleDataSet))
names(singleDataSet) <- gsub('^f',"FrequencyDomain.",names(singleDataSet))
names(singleDataSet) <- gsub('\\.mean',".Mean",names(singleDataSet))
names(singleDataSet) <- gsub('\\.std',".StandardDeviation",names(singleDataSet))
names(singleDataSet) <- gsub('Freq\\.',"Frequency.",names(singleDataSet))
names(singleDataSet) <- gsub('Freq$',"Frequency",names(singleDataSet))

names(singledataset)

#creates a new dataset called "tidydata.txt"
Data2<-aggregate(. ~subject + Activity, singleDataSet, mean, na.action = na.pass)
Data2<-Data2[order(Data2$Subject,Data2$Activity),]
write.table(Data2, file = "tidydata.txt",row.name=FALSE)
