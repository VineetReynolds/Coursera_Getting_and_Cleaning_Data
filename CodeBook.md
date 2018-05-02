# Introduction

This CodeBook describes the variables, the data, and any transformations or work that was performed to clean up the originally downloaded data.
It includes the data dictionary of the final tidy data set.

## The original data

The original data is available from https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip
It is based on the publication mentioned in [1].
The data set is also downloaded by the `run_analysis.R` script, so there is no need to download this file separately.

### Description of the original data set

The experiments have been carried out with a group of 30 volunteers within an age bracket of 19-48 years. Each person performed six activities (WALKING, WALKING_UPSTAIRS, WALKING_DOWNSTAIRS, SITTING, STANDING, LAYING) wearing a smartphone (Samsung Galaxy S II) on the waist. Using its embedded accelerometer and gyroscope, we captured 3-axial linear acceleration and 3-axial angular velocity at a constant rate of 50Hz. The experiments have been video-recorded to label the data manually. The obtained dataset has been randomly partitioned into two sets, where 70% of the volunteers was selected for generating the training data and 30% the test data. 

The sensor signals (accelerometer and gyroscope) were pre-processed by applying noise filters and then sampled in fixed-width sliding windows of 2.56 sec and 50% overlap (128 readings/window). The sensor acceleration signal, which has gravitational and body motion components, was separated using a Butterworth low-pass filter into body acceleration and gravity. The gravitational force is assumed to have only low frequency components, therefore a filter with 0.3 Hz cutoff frequency was used. From each window, a vector of features was obtained by calculating variables from the time and frequency domain. See 'features_info.txt' for more details. 

For each record it is provided:
======================================

- Triaxial acceleration from the accelerometer (total acceleration) and the estimated body acceleration.
- Triaxial Angular velocity from the gyroscope. 
- A 561-feature vector with time and frequency domain variables. 
- Its activity label. 
- An identifier of the subject who carried out the experiment.

The dataset includes the following files:
=========================================

- 'README.txt'

- 'features_info.txt': Shows information about the variables used on the feature vector.

- 'features.txt': List of all features.

- 'activity_labels.txt': Links the class labels with their activity name.

- 'train/X_train.txt': Training set.

- 'train/y_train.txt': Training labels.

- 'test/X_test.txt': Test set.

- 'test/y_test.txt': Test labels.

The following files are available for the train and test data. Their descriptions are equivalent. 

- 'train/subject_train.txt': Each row identifies the subject who performed the activity for each window sample. Its range is from 1 to 30. 

- 'train/Inertial Signals/total_acc_x_train.txt': The acceleration signal from the smartphone accelerometer X axis in standard gravity units 'g'. Every row shows a 128 element vector. The same description applies for the 'total_acc_x_train.txt' and 'total_acc_z_train.txt' files for the Y and Z axis. 

- 'train/Inertial Signals/body_acc_x_train.txt': The body acceleration signal obtained by subtracting the gravity from the total acceleration. 

- 'train/Inertial Signals/body_gyro_x_train.txt': The angular velocity vector measured by the gyroscope for each window sample. The units are radians/second. 

Notes: 
======
- Features are normalized and bounded within [-1,1].
- Each feature vector is a row on the text file.

## Variables and Work/Transformations on original data

We now outline the variable created during the course of execution of the `run_analysis.R` script, and the work/transformations that occur on the original data:

### Merging Test and Training sets

The following variables are created during this stage -

* `testingSet` - stores the raw data from the `test/X_test.txt` (test set) file in the original data.
* `trainingSet` - stores the raw data from the `train/X_train.txt` (training set) file in the original data.
* `activityData.merged` - stores the combined test and training set.

The test and training sets are now merged into the `activityData.merged` variable.

### Extract mean and standard deviation measurements

The following variables are created during this stage, some of them after transformations are applied on some existing variables created in the previous steps -

* `features` - stores the raw data from the `features.txt` (test set) file in the original data.
* `filteredCols` - contains transformed features where the presence of `std()` or `mean()` in the feature name ensures that they are filtered out as required columns.
* `activityData.filtered` - contains the transformation from `activityData.merged` (refer the above step), where only the required columns specified in the `filteredCols` variable are retained from the merged data.

### Specify descriptive activity names for the activities in the data set

The following variables are created during this stage, some of them after transformations are applied on some existing variables created in the previous steps -

* `testingLabels` - stores the raw data from the `test/y_test.txt` (corresponding activities for test set) file in the original data.
* `trainingLabels` - stores the raw data from the `train/y_train.txt` (corresponding activities for training set) file in the original data.
* `testingSubjects` - stores the raw data from the `test/subject_test.txt` (corresponding subjects for the test set) file in the original data.
* `trainingSubjects` - stores the raw data from the `train/subject_train.txt` (corresponding subjects for training set) file in the original data.
* `activityLabels` - stores the raw data from the `activity_labels.txt` (descriptive column names of activities) file in the original data.
* `activityData.filtered` - The variable created in the previous step undergoes a transformation where activity data from `Y_test` and `Y_train` are combined and stored in an `activity` column in the `activityData.filtered` variable. The `Activity` column is then made descriptive by replacing the raw activity data with the activity labels. The subject data from `testingSubjects` and `trainingSubjects` are also combined and stored in a separate `subject` column of this variable.
* `description` - a variable that contains the mapped descriptive label for the activity. Not of much significance, since it is eventually stored in the `Activity` column of `activityData.filtered` as part of it's transformation. 

### Label the data set with descriptive variable names

The following variables are created during this stage, some of them after transformations are applied on some existing variables created in the previous steps -

* `filteredColNames` - The descriptive column names obtained from the second column of the `filteredCols` variable. A minor transformation to remove the `BodyBody` typo is performed on the contents of this. A regex `^([tf])(Body|Gravity)(Acc|Gyro)(Jerk)?(Mag)?\\-(mean|std)\\(\\)\\-?([XYZ])?` is used to split the descriptive name into 7 groups. The variable is eventually transformed by expanding the 7 groups into more descriptive variants. Like, t or f in the 1st group is replaced by Time or Frequency. Acc or Gyro in the 3rd group is replaced with `Accelerometer` or `Gyroscope`.
* `nameFragments` - contains the transformed `filteredColNames` descriptions, split as 7 groups:
    * t or f
    * Body or Gravity
    * Acc or Gyro
    * Jerk (optionally present)
	* Mag (optionally present)
	* mean or std
	* X,Y or Z (optionally present)
	
The `filteredColNames` is now used to set the column names of `activityData.filtered`.

### Create an independent tidy data set

The following variables are created during this stage, some of them after transformations are applied on some existing variables created in the previous steps -

* `tidyData` - contains the tidy data set. It is a result of transforming the `activityData.filtered` variable, but not back into the original form. Every measurement of a variable in the long form is grouped by the subject and activity (Id columns), and then it's mean is taken. The mean function is used as the aggregation function that is applied on every subject and activity. Thus, every row contains the subject, activity and the mean values of every 'variable' (66 of them) from the tidy data set. This fulfills the need for the variable to be considered tidy - 
	* Every variable forms a column. In `tidyData` this is true, since every column is subject, activity or a mean of some measurement (some std or mean).
	* Each observation forms a row. In `tidyData` this is true, since every row is a unqiue combination of means of measurements for a subject and activity.
	* Each type of observational unit forms a table. In `tidyData`, this is true, it stores only one form of data - subject, activity and means of measurements.

The column names of `tidyData` are made descriptive to suit the new meaning - they contain means of several standard deviation and mean values. And finally, they are written to the file.

## Data Dictionary of tidy data set

 [1] "subject"                                                            
 The identifier of the volunteer who undertook the activity.
 
 [2] "activity"                                             
 The descriptive string identifying the activity being recorded.
               
 [3] "mean_Frequency_Body_Accelerometer_Jerk_Magnitude_Mean"    
 Mean of magnitude (calculated using Euclidean norm) of jerk signal in frequency domain, derived from body linear acceleration signal.
           
 [4] "mean_Frequency_Body_Accelerometer_Jerk_Magnitude_Standard_Deviation"
 Standard deviation of magnitude (calculated using Euclidean norm) of jerk signal in frequency domain, derived from body linear acceleration signal.
 
 [5] "mean_Frequency_Body_Accelerometer_Jerk_Mean_X"                      
 Mean of jerk signal in X-axis in frequency domain, derived from body linear acceleration signal.
 
 [6] "mean_Frequency_Body_Accelerometer_Jerk_Mean_Y"                      
 Mean of jerk signal in Y-axis in frequency domain, derived from body linear acceleration signal.
 
 [7] "mean_Frequency_Body_Accelerometer_Jerk_Mean_Z"                      
 Mean of jerk signal in Z-axis in frequency domain, derived from body linear acceleration signal.
 
 [8] "mean_Frequency_Body_Accelerometer_Jerk_Standard_Deviation_X"        
 Standard deviation of jerk signal in X-axis in frequency domain, derived from body linear acceleration signal.
 
 [9] "mean_Frequency_Body_Accelerometer_Jerk_Standard_Deviation_Y"        
 Standard deviation of jerk signal in Y-axis in frequency domain, derived from body linear acceleration signal.

[10] "mean_Frequency_Body_Accelerometer_Jerk_Standard_Deviation_Z"        
 Standard deviation of jerk signal in Z-axis in frequency domain, derived from body linear acceleration signal.

[11] "mean_Frequency_Body_Accelerometer_Magnitude_Mean"                   
 Mean of magnitude (calculated using Euclidean norm) of body acceleration signal in frequency domain.
 
[12] "mean_Frequency_Body_Accelerometer_Magnitude_Standard_Deviation"     
 Standard deviation of magnitude (calculated using Euclidean norm) of body acceleration signal in frequency domain.

[13] "mean_Frequency_Body_Accelerometer_Mean_X"                           
 Mean of body acceleration signal in X-axis, in frequency domain.

[14] "mean_Frequency_Body_Accelerometer_Mean_Y"                  
 Mean of body acceleration signal in Y-axis, in frequency domain.
          
[15] "mean_Frequency_Body_Accelerometer_Mean_Z"                           
 Mean of body acceleration signal in Z-axis, in frequency domain.
 
[16] "mean_Frequency_Body_Accelerometer_Standard_Deviation_X"             
 Standard deviation of body acceleration signal in X-axis, in frequency domain.
 
[17] "mean_Frequency_Body_Accelerometer_Standard_Deviation_Y"             
 Standard deviation of body acceleration signal in Y-axis, in frequency domain.
 
[18] "mean_Frequency_Body_Accelerometer_Standard_Deviation_Z"             
 Standard deviation of body acceleration signal in Z-axis, in frequency domain.
 
[19] "mean_Frequency_Body_Gyroscope_Jerk_Magnitude_Mean"                  
 Mean of magnitude (calculated using Euclidean norm) of body jerk signal, in frequency domain, derived from body angular velocity signal.

[20] "mean_Frequency_Body_Gyroscope_Jerk_Magnitude_Standard_Deviation"    
 Standard deviation of magnitude (calculated using Euclidean norm) of body jerk signal, in frequency domain, derived from body angular velocity signal.
 
[21] "mean_Frequency_Body_Gyroscope_Magnitude_Mean"                       
 Mean of magnitude (calculated using Euclidean norm) of body angular velocity signal, in frequency domain.

[22] "mean_Frequency_Body_Gyroscope_Magnitude_Standard_Deviation"         
 Standard deviation of magnitude (calculated using Euclidean norm) of body angular velocity signal, in frequency domain.
 
[23] "mean_Frequency_Body_Gyroscope_Mean_X"                               
 Mean of magnitude (calculated using Euclidean norm) of body angular velocity signal in X-axis, in frequency domain.

[24] "mean_Frequency_Body_Gyroscope_Mean_Y"                               
 Mean of magnitude (calculated using Euclidean norm) of body angular velocity signal in Y-axis, in frequency domain.

[25] "mean_Frequency_Body_Gyroscope_Mean_Z"                               
 Mean of magnitude (calculated using Euclidean norm) of body angular velocity signal in Z-axis, in frequency domain.

[26] "mean_Frequency_Body_Gyroscope_Standard_Deviation_X"                 
 Standard deviation of body angular velocity signal in X-axis, in frequency domain.

[27] "mean_Frequency_Body_Gyroscope_Standard_Deviation_Y"                 
 Standard deviation of body angular velocity signal in Y-axis, in frequency domain.
 
[28] "mean_Frequency_Body_Gyroscope_Standard_Deviation_Z"                 
 Standard deviation of body angular velocity signal in Z-axis, in frequency domain.
 
[29] "mean_Time_Body_Accelerometer_Jerk_Magnitude_Mean"                   
Mean of magnitude (calculated using Euclidean norm) of body acceleration signal, in time domain.

[30] "mean_Time_Body_Accelerometer_Jerk_Magnitude_Standard_Deviation"     
Standard deviation of magnitude (calculated using Euclidean norm) of body acceleration signal, in time domain.

[31] "mean_Time_Body_Accelerometer_Jerk_Mean_X"                           
Mean of jerk signal in X-axis, in time domain, derived from body linear acceleration signal.

[32] "mean_Time_Body_Accelerometer_Jerk_Mean_Y"                           
Mean of jerk signal in Y-axis, in time domain, derived from body linear acceleration signal.

[33] "mean_Time_Body_Accelerometer_Jerk_Mean_Z"                           
Mean of jerk signal in Z-axis, in time domain, derived from body linear acceleration signal.

[34] "mean_Time_Body_Accelerometer_Jerk_Standard_Deviation_X"             
Standard deviation of jerk signal in X-axis, in time domain, derived from body linear acceleration signal.

[35] "mean_Time_Body_Accelerometer_Jerk_Standard_Deviation_Y"             
Standard deviation of jerk signal in Y-axis, in time domain, derived from body linear acceleration signal.

[36] "mean_Time_Body_Accelerometer_Jerk_Standard_Deviation_Z"             
Standard deviation of jerk signal in Z-axis, in time domain, derived from body linear acceleration signal.

[37] "mean_Time_Body_Accelerometer_Magnitude_Mean"                        
Mean of magnitude (calculated using Euclidean norm) of body acceleration signal, in time domain.

[38] "mean_Time_Body_Accelerometer_Magnitude_Standard_Deviation"          
Standard deviation of magnitude (calculated using Euclidean norm) of body acceleration signal, in time domain.

[39] "mean_Time_Body_Accelerometer_Mean_X"                                
Mean of body acceleration signal in X-axis, in time domain.

[40] "mean_Time_Body_Accelerometer_Mean_Y"                                
Mean of body acceleration signal in Y-axis, in time domain.

[41] "mean_Time_Body_Accelerometer_Mean_Z"                 
Mean of body acceleration signal in Z-axis, in time domain.
               
[42] "mean_Time_Body_Accelerometer_Standard_Deviation_X"                  
Standard deviation of body acceleration signal in X-axis, in time domain.

[43] "mean_Time_Body_Accelerometer_Standard_Deviation_Y"                  
Standard deviation of body acceleration signal in Y-axis, in time domain.

[44] "mean_Time_Body_Accelerometer_Standard_Deviation_Z"                 
Standard deviation of body acceleration signal in Z-axis, in time domain.
 
[45] "mean_Time_Body_Gyroscope_Jerk_Magnitude_Mean"                       
Mean of magnitude (calculated using Euclidean norm) of jerk signal, in time domain, derived from body angular velocity signal.

[46] "mean_Time_Body_Gyroscope_Jerk_Magnitude_Standard_Deviation"         
Standard deviation of magnitude (calculated using Euclidean norm) of jerk signal, in time domain, derived from body angular velocity signal.

[47] "mean_Time_Body_Gyroscope_Jerk_Mean_X"                               
Mean of jerk signal in X-axis, in time domain, derived from body angular velocity signal.

[48] "mean_Time_Body_Gyroscope_Jerk_Mean_Y"                               
Mean of jerk signal in Y-axis, in time domain, derived from body angular velocity signal.

[49] "mean_Time_Body_Gyroscope_Jerk_Mean_Z"                               
Mean of jerk signal in Z-axis, in time domain, derived from body angular velocity signal.

[50] "mean_Time_Body_Gyroscope_Jerk_Standard_Deviation_X"                 
Standard deviation of jerk signal in X-axis, in time domain, derived from body angular velocity signal.

[51] "mean_Time_Body_Gyroscope_Jerk_Standard_Deviation_Y"                 
Standard deviation of jerk signal in Y-axis, in time domain, derived from body angular velocity signal.

[52] "mean_Time_Body_Gyroscope_Jerk_Standard_Deviation_Z"                 
Standard deviation of jerk signal in Z-axis, in time domain, derived from body angular velocity signal.

[53] "mean_Time_Body_Gyroscope_Magnitude_Mean"                            
Mean of magnitude (calculated using Euclidean norm) of body angular velocity signal, in time domain.

[54] "mean_Time_Body_Gyroscope_Magnitude_Standard_Deviation"              
Standard deviation of magnitude (calculated using Euclidean norm) of body angular velocity signal, in time domain.

[55] "mean_Time_Body_Gyroscope_Mean_X"             
Mean of body angular velocity signal in X-axis, in time domain.
                       
[56] "mean_Time_Body_Gyroscope_Mean_Y"                                    
Mean of body angular velocity signal in Y-axis, in time domain.

[57] "mean_Time_Body_Gyroscope_Mean_Z"                                    
Mean of body angular velocity signal in Z-axis, in time domain.

[58] "mean_Time_Body_Gyroscope_Standard_Deviation_X"                      
Standard deviation of body angular velocity signal in X-axis, in time domain.

[59] "mean_Time_Body_Gyroscope_Standard_Deviation_Y"                      
Standard deviation of body angular velocity signal in Y-axis, in time domain.

[60] "mean_Time_Body_Gyroscope_Standard_Deviation_Z"                      
Standard deviation of body angular velocity signal in Z-axis, in time domain.

[61] "mean_Time_Gravity_Accelerometer_Magnitude_Mean"                     
Mean of magnitude (calculated using Euclidean norm) of gravity acceleration signal, in time domain.

[62] "mean_Time_Gravity_Accelerometer_Magnitude_Standard_Deviation"       
Standard deviation of magnitude (calculated using Euclidean norm) of gravity acceleration signal, in time domain.

[63] "mean_Time_Gravity_Accelerometer_Mean_X"                             
Mean of gravity acceleration signal in X-axis, in time domain.

[64] "mean_Time_Gravity_Accelerometer_Mean_Y"                             
Mean of gravity acceleration signal in Y-axis, in time domain.

[65] "mean_Time_Gravity_Accelerometer_Mean_Z"                             
Mean of gravity acceleration signal in Z-axis, in time domain.

[66] "mean_Time_Gravity_Accelerometer_Standard_Deviation_X"               
Standard deviation of gravity acceleration signal in X-axis, in time domain.

[67] "mean_Time_Gravity_Accelerometer_Standard_Deviation_Y"               
Standard deviation of gravity acceleration signal in Y-axis, in time domain.

[68] "mean_Time_Gravity_Accelerometer_Standard_Deviation_Z"
Standard deviation of gravity acceleration signal in Z-axis, in time domain.

[1] Davide Anguita, Alessandro Ghio, Luca Oneto, Xavier Parra and Jorge L. Reyes-Ortiz. Human Activity Recognition on Smartphones using a Multiclass Hardware-Friendly Support Vector Machine. International Workshop of Ambient Assisted Living (IWAAL 2012). Vitoria-Gasteiz, Spain. Dec 2012