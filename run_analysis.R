# For this script we will need the packages data.table, tidyr and plyr
# We install (and load them) if they are not installed yet
if(!"data.table" %in% rownames(installed.packages())) install.packages(data.table)
if(!"tidyr" %in% rownames(installed.packages())) install.packages("tidyr")
if(!"plyr" %in% rownames(installed.packages())) install.packages("plyr")

# In the next lines we will use the suppressMessages() function
# (it is ok since at the end of the script we detach these loaded packages)

suppressMessages(library(data.table))
# needed for the melt() command in the next lines
suppressMessages(library(tidyr))
# needed for the separate() command in the next lines
suppressMessages(library(plyr))
# needed for the mapvalues() command in the next lines

# STEP 0) Download and unzip the file
fileUrl <- "https://d396qusza40orc.cloudfront.net/getdata%2Fprojectfiles%2FUCI%20HAR%20Dataset.zip"
if(!file.exists("FUCI HAR Dataset.zip")){ download.file(fileUrl, destfile = "FUCI HAR Dataset.zip")}
unzip("FUCI HAR Dataset.zip")

# saves old directory, and sets temporary directory
oldDir <- getwd()
setwd("UCI HAR Dataset")

# STEP 1) Merges the training and the test sets to create one data set

# STEP 1A) Gets the "main" sets of data in the folders "train" and "test"
# The next 2 instructions may take a while to exectute

X_train <- read.table("./train/X_train.txt")
# dim = 7352 x 561
X_test <- read.table("./test/X_test.txt")
# dim = 2947 x 561

# Now we can bind the two data.frames.
# The order of X_train and X_test is not important, I simpy chose one.
# It is important to stick with this order also in the next constructions,
bind_of_data <- rbind(X_train, X_test)
# dim = 10299 x 561

# STEP 1B)
# In this moment the names of the columns of bind_of_data are not very intuitive:
# apart from the first and second column, the remaining have identifiers "V1" ... "V561"
# We replace these identifiers with the names coming from the "features.txt" file

# reads the list of features (corresponding to numbers from 1 to 561)
features <- read.table("features.txt")

# updates the colums
names(bind_of_data) <- as.character(features$V2)

# STEP 1C)
# In order to have a decent data.frame, we must add the values of "subject" and "activity"
# to the "bind_of_data" data.frame.
# First of all, we create a vector of subjects by joining the data in
# "./train/subject_train.txt" and in "./test/subject_test.txt".

subject_train <- scan("./train/subject_train.txt")
# length 7352 (matches n. of rows of X_train)

subject_test <- scan("./test/subject_test.txt")
# length 2947 (matches n. of rows of X_test)

subject <- c(subject_train, subject_test)
# length = 7352 + 2947 = 10299

# Analogous procedure for the additional vector with values of "activity"
activity_train <- scan("./train/y_train.txt")

activity_test <- scan("./test/y_test.txt")

activity <- c(activity_train, activity_test)
# length = 7352 + 2947 = 10299

# STEP 1D)
# We creates the "step1" data.frame by adding the columns for "subject" and "activity" to
# the data.frame "bind_of_data".

step1 <- cbind(subject, activity, bind_of_data)
# rows = 7352 + 2947 = 10299
# columns = 1 + 1 + 561 = 563

# STEP 2) Extracts only the measurements on the mean and standard deviation for each measurement.

# STEP 2A)
# Creates a logical vector "logical_mean", so that logical_mean[i]==TRUE
# if and only if features[i,2] contains the string "mean"
logical_mean <- grepl("mean",features[,2])
# 46 values TRUE + 515 values FALSE (total 561 = n. of columns of bind_of_data)

# Analogously for the "std" string.
logical_std <- grepl("std",features[,2])
# 33 values TRUE + 528 values FALSE (total 561 = n. of columns of bind_of_data)

# NOTE: I could have created a logical vector with "mean" OR "std".
# However, I prefer to create 2 separate vectors.
# In this way, the data.frame that I construct below
# will have firstly all the columns with "mean", then all the columns with "std".

# NOTE: with a couple of commands like
#    logical_std_mean <- grepl(^"std|mean",features[,2])
#    table(logical_std_mean)
# we get firstly a logical vector with TRUE in position i if and only if
# features[i,2] contains "std" and/or "mean. With table() we get that this vector
# contains exactly 79 TRUE values. This is equal to the TRUE values in
# logical_std (33) + the TRUE values in logical_mean (46).
# Therefore there is no object where both "std" and "mean" appear, hence it is completely
# safe to use logical_std and logical_mean to select the std and mean columns
# (no intersections between these 2 sets, so each "right" column will be selected exactly once).

# STEP 2B)
# We construct a data.frame "step2" that
# contains all the columns of "step1" such that:
# -- either they are the first or second column of "step1" (containing subject and activity name)
# -- or their description contains the string "mean"
# -- or their description contains the string "std"
step2 <- cbind(step1[,1:2],
               step1[,c(FALSE,FALSE,logical_mean)],
               step1[,c(FALSE,FALSE,logical_std)])

# NOTE: in order to select only the columns with "mean",
# we have to ignore the first 2 columns, that contain the subject and activity names.
# Therefore we have to use the logical vector "logical_mean" translated by 2
# (the first 2 values must be FALSE,FALSE,
# so that we don't select the first 2 rows a second time).
# rows = rows of step1 = 10299
# columns =    2 (first & second column of step1)
#           + 46 (columns whose description contains "mean")
#           + 33 (columns whose description contains "std)
#           = 81

# STEP 3) Uses descriptive activity names to name the activities in the data set

# STEP 3A)
# Reads the activity labels and sets to lower cases the description of each activity
activity_labels <- read.table("activity_labels.txt")
activity_labels$V2 <- tolower(activity_labels$V2)

# STEP 3B)
# Uses a dictionary to replace the numeric identifier of every activity with its description
# We want to preserve the values of each step, so we create a new data.frame
# instead of updating the existing one
step3 <- step2
step3$activity <- mapvalues(as.character(step3$activity),
                            from=as.character(activity_labels$V1),
                            to=as.character(activity_labels$V2))

# STEP 4) Appropriately labels the data set with descriptive variable names.

# STEP 4A)
# Since the identifiers in the data.frame feature (that replicates "features.txt") are too concise,
# we set up a dictionary to be used for "translations" later on.
# source strings
dictionary     =    c("t", "f", "Acc",  "Mag", "mean", "std",
                      "mad", "max", "min",
                      "Freq","Gyro", "BodyBody", "X", "Y", "Z")
# target strings
names(dictionary) = c("Time","Frequency", "Acceleration",  "Magnitude", "Mean", "Standard.Deviation",
                      "Median.Absolute.Deviation", "Largest.Value.In.Array", "Smallest.Value.In.Array",
                      "Of.Frequency", "Gyroscope", "Body", "In.Direction.X", "In.Direction.Y", "In.Direction.Z")
# STEP 4B)
# Given any feature containing "mean", we rewrite it in a more understandable way.
# We save all these rewritten features in list_mean
# For doing this:
# - we subset features$V2 (containg all features) by the logical vector logical_mean
# - we use sapply on the result.
# The (anonymous) function that we apply does the following operations
# on any string given as argument:
# - adds white spaces before capital letters
# - removes the signs -, ( and )
# - divides the string in a vector of substrings using the spaces
# - replaces string using the dictionary above
# - pastes the strings back together, using "." as separator.
list_mean <- sapply(features$V2[logical_mean], function(foo){
  foo <- gsub("([A-Z]|[-])", " \\1", foo)
  foo <- gsub('\\(|-|\\)','',foo)
  foo <- strsplit(foo, "\\s+")[[1]]
  suppressMessages(foo <- mapvalues(foo, from=dictionary, to=names(dictionary)))
  foo <- paste0(foo,collapse = ".")
  # an alternative is to collapse using "" or "-" as separator
})

# STEP 4C)
# Analogous to STEP 4C), but with the list of features that contain "std"
list_std <- sapply(features$V2[logical_std], function(foo){
  foo <- gsub("([A-Z]|[-])", " \\1", foo)
  foo <- gsub('\\(|-|\\)','',foo)
  foo <- strsplit(foo, "\\s+")[[1]]
  suppressMessages(foo <- mapvalues(foo, from=dictionary, to=names(dictionary)))
  foo <- paste0(foo,collapse = ".")
})

# STEP 4D)
# As above, we prefer to keep track of the various steps, so we create
# a new data.frame instead of updating the existing one
step4 <- step3

# The data.frame step4 = step3 contains already the data that we want.
# We have only to update the names of the columns, so that they are more descriptive
names(step4) <- c("subject", "activity", list_mean, list_std)

# STEP 5) From the data set in step4, creates a second, independent tidy data set
# with the average of each variable for each activity and each subject.

# STEP 5A)
# We split the data.frame step4 according to 2 factors (subject and activity)
# The result is a list of 180 data.frames (180 = 30 subjects x 6 activities)
s <- split(step4, list(step2$subject, step2$activity))
# Each data.frame in s contains between 36 and 95 rows.
# The number of columns is 81, as in step4

# STEP 5B)
# We compute the mean on each column of each object of the list s
# We remove the first and second column since they contain subject and activity identifiers
# (that are constant on each object of s, because of the construction of s above)

t <- sapply(s, function(foo) colMeans(foo[,-c(1,2)]))
# t is a matrix with 79 rows (all features with "mean" or "std")
# and 180 columns (all combinations of 30 subjects nad 180 activities)

# STEP 5C)
# t is a matrix, we need to transform it in a data.frame in order to use melt() on it
t <- as.data.frame(t)
# Now t is a data.frame (easier to deal with)

# STEP 5D)
# In order to use correctly melt() below, we need to add to t a first column,
# that replicates the names of the rows of t
# (this row will be used as "id.vars" argument of melt())
t <- cbind(feature = row.names(t), t)
# So now t has 79 rows and 181=(1+180) columns

# STEP 5E)
# In this moment the columns of t are as follows:
# - the first column contains feature names
# - the second column is called "1.walking" or something similar
# - analogously for all the remainign columns
# We want to have a data.frame with
# - the same first column
# - a second column containing the type of combination "subject.activity"
# - a third column containng the corresponding average value
# The function melt() does exactly this.
u <- melt (t, id.vars = "feature", variable.name = "subject.activity", value.name = "average")

# STEP 5F)
# Finally, we want to obtain a data frame where the second column is replaced by a pair
# of columns containing respectively "subject" and "activity"
step5 <- separate(data = u, col = subject.activity, into = c("subject","activity"))

# STEP 5G)
# We save the data of step5 into a txt file
write.table(step5, file = "step5.txt", row.name=FALSE)

# At the end, we set again the working directory as the user's working directory
# and we unload the loaded packages
setwd(oldDir)
detach("package:data.table")
detach("package:tidyr")
detach("package:plyr")
