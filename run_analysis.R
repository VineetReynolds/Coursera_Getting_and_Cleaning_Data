library(data.table)
library(dplyr)
library(tidyr)

# Download the dataset for analysis into the 'data' directory
dataDir <- "data"
if(!file.exists(dataDir)){
  zipFile <- "./data/UCI_HAR_Dataset.zip"
  dir.create(dataDir)
  fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
  download.file(fileUrl, destfile = zipFile)
  unzip(zipFile, exdir = dataDir)
}

# 1. Merges the training and the test sets to create one data set.
## 1.1 Read in the training and testing datasets
testingSet <- fread("data/UCI HAR Dataset/test/X_test.txt")
trainingSet <- fread("data/UCI HAR Dataset/train/X_train.txt")

## 1.2 Merge the training and testing datasets
activityData.merged <- rbindlist(list(testingSet, trainingSet))

# 2. Extract measurement data corresponding to mean and standard deviation for each measurement
## 2.1 Read in the feature vector names
features <- fread("data/UCI HAR Dataset/features.txt")

## 2.2 Filter features, based on presence of std() or mean() in names
filteredCols <- features %>% 
  filter(grepl("std\\(\\)|mean\\(\\)", V2))
## 2.3 Subset columns in activity dataset based on columns with std() or mean() in names
activityData.filtered <- activityData.merged[, filteredCols$V1, with = FALSE]

# 3. Use descriptive activity names.

## 3.1 Read in the labels for test and training data set and merge them
testingLabels <- fread("data/UCI HAR Dataset/test/y_test.txt")
trainingLabels <- fread("data/UCI HAR Dataset/train/y_train.txt")
activityLabels.merged <- rbindlist(list(testingLabels, trainingLabels))
## 3.2 Add an 'activity' column, with value set to the activity label
activityData.filtered <- activityData.filtered %>%
  mutate(activity = activityLabels.merged$V1)

## 3.3 Read in the subjects for test and training data set and merge them
testingSubjects <- fread("data/UCI HAR Dataset/test/subject_test.txt")
trainingSubjects <- fread("data/UCI HAR Dataset/train/subject_train.txt")
subjects.merged <- rbindlist(list(testingSubjects, trainingSubjects))
## 3.4 Add a 'subject' column, with value set to the subject whose activity is being measured
activityData.filtered <- activityData.filtered %>%
  mutate(subject = subjects.merged$V1)

## 3.5 Read in the activity labels, and set the column names for the data table
## to 'activity' and 'description, to make it easier to merge in 3.6.
activityLabels <- fread("data/UCI HAR Dataset/activity_labels.txt")
names(activityLabels) <- c("activity", "description")

## 3.6 Merge the dataset with the activity labels, by the common column name -
## "activity". Then, select 'description' and assign it to 'activity' to convert Ids to labels.
## Drop 'description' since we don't need it.
activityData.filtered <- merge(activityData.filtered, activityLabels) %>%
  mutate(activity = description) %>%
  select(-description)

activityData.filtered <- activityData.filtered %>%
  mutate(activity = as.factor(activity), subject = as.factor(subject))

# 4. Appropriately labels the data set with descriptive variable names.
filteredColNames <- filteredCols$V2

## 4.1 Replace BodyBody appearing in some of the column names since it is a typo
filteredColNames <- gsub("BodyBody", "Body", filteredColNames)

## 4.2 Use a regex to parse the column name into 7 groups - 
## * t or f
## * Body or Gravity
## * Acc or Gyro
## * Jerk (optionally present)
## * Mag (optionally present)
## * mean or std
## * X,Y or Z (optionally present)
## Replace the original name with an underscore separated group;
## we use underscore to help with splitting the name to obtain the individual 
## fragments for describing them later.
filteredColNames <- gsub("^([tf])(Body|Gravity)(Acc|Gyro)(Jerk)?(Mag)?\\-(mean|std)\\(\\)\\-?([XYZ])?", "\\1_\\2_\\3_\\4_\\5_\\6_\\7_", filteredColNames)

## 4.3 Split on underscore; this yields a list of character vectors.
## Every vector is of length 7 containing the individual components of the name 
## (like "t" "Body" "Acc") and sometimes empty strings.
## Every component can now be described and then combined later to produce 
## a descriptive name.
nameFragments <- strsplit(filteredColNames, "_")

## 4.4 Apply a function on the list to obtain descriptive names.
## This yields a character vector
filteredColNames <- sapply(nameFragments, function(nameFragments) {
  prettyName <- character()
  # Expand Time or Frequency (t/f)
  if(nameFragments[1] == "t") {
    prettyName <- "Time"
  } else {
    prettyName <- "Frequency"
  }
  ## Loop through the rest of the fragments and add them to pretty_name, 
  ## after optionally describing them
  for(i in 2:7) {
    ## Don't describe Body or Gravity - they're already descriptive.
    ## Describe Acceleration, Gyroscope optionally with Jerk (already descriptive)
    ## and Magnitude, followed by mean or standard deviation, and the 
    ## optional axis (already descriptive).
    if(nameFragments[i] == "Acc") {
      nameFragments[i] <- "Accelerometer"
    } else if (nameFragments[i] == "Gyro") {
      nameFragments[i] <- "Gyroscope"
    } else if (nameFragments[i] == "Mag") {
      nameFragments[i] <- "Magnitude"
    } else if (nameFragments[i] == "mean") {
      nameFragments[i] <- "Mean"
    } else if (nameFragments[i] == "std") {
      nameFragments[i] <- "Standard_Deviation"
    } else if (nameFragments[i] == "") {
      # Skip combining empty strings, since we dont want unnecessary underscores.
      next
    }
    # Combine the fragment with the rest, separating with underscore
    prettyName <- paste(prettyName, nameFragments[i], sep = "_")
  }
  prettyName
})

## 4.5 Set the column names on the filtered data with the descriptive names.
## Use make.names to ensure that the column names are syntatically valid in R,
## while ensuring that the column names are unique.
## We do not want to overwrite the column names for Subject and Activity,
## hence we subset colnames by indices of columns that do not have Subject or Activity in their name.
colnames(activityData.filtered)[which(!names(activityData.filtered) %in% c("subject","activity"))] <- make.names(filteredColNames, unique = TRUE)


# 5. From the data set in step 4, creates a second, independent tidy data set 
# with the average of each variable for each activity and each subject.

## 5.1 Take all columns except subject and activity and reshape them into two columns -
## 'feature' which is the name of the feature and 'measurement' which is the value
tidyData <- activityData.filtered %>%
  gather(feature, measurement, -c("subject","activity")) %>%
  # Group by subject, activity and feature, so we can compute mean
  group_by(subject,activity, feature) %>%
  # Compute average of each variable/feature for every grouping of subject and activity
  summarize(mean = mean(measurement)) %>%
  # Ungroup, so that we can convert back to the wide form
  ungroup() %>%
  spread(feature, mean)

## 5.2 Add 'mean' to the column names, indicate that the values are a mean, and not raw data
## Obviously omit this for subject and activity
measurementColNames <- colnames(tidyData)[which(!names(tidyData) %in% c("subject","activity"))]
colnames(tidyData)[which(!names(tidyData) %in% c("subject","activity"))] <- paste("mean", measurementColNames, sep = "_")

## 5.3 Write the tidy data out to a file
write.table(tidyData, "tidy_data.txt", row.names = FALSE)