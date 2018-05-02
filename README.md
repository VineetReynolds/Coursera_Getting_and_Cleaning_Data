# Getting and Cleaning Data

## Course Project

You should create one R script called run_analysis.R that does the following.

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive activity names.
5. Creates a second, independent tidy data set with the average of each variable for each activity and each subject.

## What is in the project ?

* `run_analysis.R` - a single R program that performs the above steps. It is independent can be executed in a console. See the Dependencies section for list of requirements.
* `tidy_data.txt` - the tidy data set created as an output of the final step.
* `CodeBook.md` - a codebook that describes the variables from the original data sets, and the transformations applied on them, with a brief description of the tidy data set produced.

## How to run this project ?

Run `source("run_analysis.R")` in RStudio or in an R console.

It will download the dataset for analysis, unzip it into a `data` sub-directory, and proceed to perform the procedures outlined in the above section.
The tidy data set is written out to `tidy_data.txt` in the working directory.

## Abstract of the analysis

* The original test and training data sets are merged using `rbindlist` into a single variable.
* The list of features is searched for names with `std()` and `mean()` in them, to subset the columns in the combined dataset.
* Activity labels and subjects are read from the original dataset and merged into the combined dataset.
* The column names in the combined dataset are made more descriptive, by providing descriptive column names. The descriptive names are arrived after modifying the original list of features, and expanding any abbreviations.
* The combined dataset is then converted to create a second independent tidy data set with each observation containing a subject and activity and the average of each variable (66 variables in total).

## Dependencies

`run_analysis.R` depends on the following packages -

* `data.table`
* `dplyr` and
* `tidyr`

These are assumed to be installed.