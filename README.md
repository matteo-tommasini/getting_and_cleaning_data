#Final assignment of the Getting and Cleaning Data Course Project (on Coursera)

The description of the assignment can be found at the following [link](https://www.coursera.org/learn/data-cleaning/peer/FIZtT/getting-and-cleaning-data-course-project).

The original data were obtained from the following [link](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip) and are extensively described at the following [link](http://archive.ics.uci.edu/ml/datasets/Human+Activity+Recognition+Using+Smartphones).

After extracting the data, these are the steps requested by the assignment:

1. Merges the training and the test sets to create one data set.
2. Extracts only the measurements on the mean and standard deviation for each measurement.
3. Uses descriptive activity names to name the activities in the data set
4. Appropriately labels the data set with descriptive variable names.
5. From the data set in step 4, creates a second, independent tidy data set with the average of each variable for each activity and each subject.

The final result of step 5 is saved in the attached file [step5.txt](https://github.com/matteo-tommasini/getting_and_cleaning_data/blob/master/step5.txt).

Attached to this repository you will find also the [R script](https://github.com/matteo-tommasini/getting_and_cleaning_data/blob/master/run_analysis.R) used for performing the assignment and the [code book](https://github.com/matteo-tommasini/getting_and_cleaning_data/blob/master/CodeBook.md) containing a description of the variables and of the steps performed in the script.

**If you want to run the script in R/RStudio, please use a working directory containing the downloaded and unzipped folder "FUCI HAR Dataset"**
 (obtained from the already mentioned [link](https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip)).
**If the script does not find this directory, it will firstly try to download and unzip such data** (this takes some times).

When the script ends, all the working data are not canceled on purpose, in order to allow further analysis. Since they are big datasets, you may want to remove them all with the command

```sh
rm("X_train","X_test","bind_of_data","features","subject_train","subject_test","subject","activity_train","activity_test","activity","logical_mean","logical_std","activity_labels","dictionary","list_mean","list_std","s","t","u","step1","step2","step3","step4","step5")
```

