#Code book for the final assignment of the Getting and Cleaning Data Course Project (on Coursera)

These are the variables used in the final set of data (as saved in the attached file step5.txt)

* "feature": a description obtained from the short code in the file "features.txt". For example, given the short code "tBodyAcc-mean()-X", the associated value in the column feature is "Time.Body.Acceleration.Mean.In.Direction.X". As requested by the assignment, only the features with "mean" or "std" in the short code are selected. The approach chosen was to first list all the features of the form "mean" (46 features), then all the features of the form "std" (33 features)
* "subject": a number between 1 and 30, identifying a specific subject of the experiment
* "activity": a description of the activity, with 6 possible values: "walking", "walking_upstairs", "walking_downstairs", "sitting", "standing" or "laying"
* "average": a numeric value computed as the average over the original data with fixed values of "feature", "subject" and "activity"

The original data are obtained from the following [link](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)
and are described in the following [link](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

Following the instructions of the assignment, the following operations were performed:

##0) The data were downloaded and extracted and the following libraries were installed/loaded:

* data.table for the melt() command
* tidyr) for the separate() command
* plyr for the mapvalues() command

##1) The training and the test data were merged together

THe file used were "./train/X\_train.txt" and "./test/X\_test.txt", resulting in a data frame of 10299 observations (rows) and 561 variables (columns)

The names of the colums are obtained from the file "features.txt"

Two additional columns with "subject" and "activity" were added to the data frame using the datas in 
*"./train/subject\_train.txt" and "./test/subject\_test.txt" (for the column "subject") and
*"./train/y\_train.txt" and "./test/y\_test.txt" (for the column "activity)

The resulting data frame (called step1) has 10299 rows and 563 columns.

##2) A selection of columns of step1 is made

A data frame called step2 is created by selecting from step1 only the columns whose descriptions contain the words "mean" or "std". We opted for selecting firstly all those of the first type, secondly all those of the second type (even if this permutes the order of the columns of step1).

For selecting the various columns of type "mean", a logical vector is created using the grepl() function, and used for subsetting the data frame step1.

We checked that there are no columns whose description contains both "mean" and "std" (if there were columns of this form, they would have been selected twice instead of just one). Since the data frame step1 has no such problem, we can proceed with 2 logical vectors for selecting separately "mean" and "std"

##3) Descriptive names of activities 

As requested by the assignment, we give descriptive names to the activities in the data set. This is done using the function tolower() on the data obtained from "actity_labels.txt", then using these data as a dictionary for updating the column "activity" of step2 with the function mapvalues().

##4) Descriptive names of features

The columns labeled with the (subset of) data from "features.txt" are not very human readable, since they contain names such as 
"tBodyAcc-mean()-X". In order to have better names, for example "Time.Body.Acceleration.Mean.In.Direction.X", a dictionary is created, linking substrings as "t" to substrings as "time", and the following operations are perfomed (using sapply) on each feature that contains the substrings "mean" or "std:

* white spaces are added before capital letters
* the signs -, ( and ) are removed
* the string is divided in a vector of substrings using the white spaces
* each string in the vector is replaced by the corresponding string in the dictionary (if a correspondance is found)
* the new strings are pasted back using "." as separator

The new strings are used as names of the columns of step3, now called step4.

##5) Computation of average with respect to each activity and each subject

From the data set in step4, we have to create a second, independent tidy data set (step5) with the average of each variable for each activity and each subject.

For this, we split the data.frame step4 according to 2 factors (subject and activity).
The result is a list of 180 data frames (180 = 30 subjects x 6 activities), 
Each resulting data frame contains between 36 and 95 rows (the number of columns is 81, as in step4)

Using sapply we compute the mean of the columns of these data frames, and we obtain a matrix with 180 columns and 79 rows (81 columns of step4, minus the columns corresponding to subject and activity). After transforming the matrix in a data frame, we add a first column replicating the names of the rows (i.e. the names of the features that we selected in step 2) above). Except for the first column, all the remaining ones are 180 columns of the form "subject.activity". We melt the matrix with id.vars=first column, obtaining a matrix with 3 columns: the name of the features, the "subject.activity" pair and the average.

In order to get tidy data, we have to use the function separate(), so that each "subject.activity" pair is separated in its components

##6) Saving and detaching of packages

The resulting tidy data frame step5 is saved to a file and the loaded packages are detached.
