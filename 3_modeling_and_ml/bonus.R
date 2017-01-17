#### Bonus Code for Modeling and Machine Learning ####
setwd("~/cos_2017/3_modeling_and_ml")

# Here, we demonstrate two more machine learning
# methods in R: Random Forest and SVM.  For these two
# examples, we will try to predict the binary outcome
# whether or not an Airbnb listing got a "Perfect" (100/100)
# average review score.  We will use the Bag-of-Words constructed
# in "script_2.R" to be the features.  

#### Bonus Part 1: Prepare the binary classification problem ####
## Load the data set for the labels
listings = read.csv("../data/listings.csv")
reviews = read.csv("../data/reviews.csv", stringsAsFactors = FALSE)

## Create the data frame for the labels
# 1) Select the relevant columns
# 2) Remove rows with review_scores_rating=NA
# 3) Create a new column which is TRUE if review_scores_rating=100,
#    and FALSE otherwise
# 4) Select the columns ID and PERFECT_RATING
library(tidyverse)
listings_bonus = listings %>%
  select(LISTING_ID=id, review_scores_rating) %>%
  na.omit() %>%
  mutate(PERFECT_RATING=(review_scores_rating==100)) %>%
  select(LISTING_ID, PERFECT_RATING)
str(listings_bonus)

## Create the data frame for the features, as done in "script_2.R"
# 1) Combine the review comments by listing
reviews_by_listing = reviews %>%
  select(listing_id,comments) %>%
  group_by(listing_id) %>%
  summarize(all_comments=paste(comments,collapse=" "))
# 2) Follow Steps 0-8 to construct the Bag-of-Words term matrix:

## Step 0: Load two packages for pre-processing:
library(tm)
library(SnowballC)
## Steps 1-5: Convert reviewer comments to a corpus,
## perform operations and stem document.  
corpus = Corpus(VectorSource(reviews_by_listing$all_comments)) %>%
  tm_map(tolower) %>%
  tm_map(PlainTextDocument) %>%
  tm_map(removePunctuation) %>%
  tm_map(removeWords, stopwords("english")) %>%
  tm_map(stemDocument)
## Step 6: Create a word count matrix (rows are reviews, columns are words).
frequencies = DocumentTermMatrix(corpus)
## Step 7: Account for sparsity. (Use a bit more sparsity)
sparse = removeSparseTerms(frequencies, 0.95)
## Step 8: Create data frame.
commentsTM_bonus = as.data.frame(as.matrix(sparse))
commentsTM_bonus = commentsTM_bonus[,!grepl("[0-9]",names(commentsTM_bonus))]

## Add our dependent variable, and convert it to a factor variable
# NOTE: Random Forest requires outcome variables to be factors
commentsTM_bonus$LISTING_ID = reviews_by_listing$listing_id
commentsTM_bonus = full_join(listings_bonus, commentsTM_bonus)
commentsTM_bonus$PERFECT_RATING = as.factor(commentsTM_bonus$PERFECT_RATING)
str(commentsTM_bonus)

## Split data into training and testing sets
# install.packages("caTools")
library(caTools)
set.seed(123)
spl = sample.split(commentsTM_bonus$PERFECT_RATING, SplitRatio = 0.7)
commentsTrain_bonus = subset(commentsTM_bonus, spl==TRUE)
commentsTest_bonus = subset(commentsTM_bonus, spl==FALSE)

#### Bonus Part 2: Random Forest ####
# Install package randomForest and load the library
# install.packages("randomForest")
library(randomForest)

# Fit the forest with 200 trees, using the first (400 - 2) words alphabetically
# Technical Note: The random forest function complains if we try to include
# variable names with non-alphanumeric characters, so that is why
# we restrict our model to the first 400 words, which happen to be
# formatted correctly.  
Airbnb.forest = randomForest(PERFECT_RATING ~ . - LISTING_ID,
                              data = commentsTrain_bonus[,1:400],
                              ntree = 200)

# Make predictions on the test set
Airbnb.forestPred = predict(Airbnb.forest, newdata = commentsTest_bonus)
table(commentsTest_bonus$PERFECT_RATING, Airbnb.forestPred)

# Check accuracy
(table(commentsTest_bonus$PERFECT_RATING, Airbnb.forestPred) %>% diag %>% sum) / nrow(commentsTest_bonus)


#### Bonus Part 3: SVM with cross-validation ####
# Install package e1071 and load the library
# install.packages("e1071")
library(e1071)

# Because we have many features, let's do SVM with a linear kernel.
# This method is significantly faster for large problems,
# when the dimension of the feature space is large, gives similar results.
# Let's use cross-validation to tune the cost parameter C.
# For instructions on how to do cross-validation
# using the "tune" function, see:
# https://cran.r-project.org/web/packages/e1071/e1071.pdf
# The method defaults to 10-fold cross-validation.
Airbnb.SVM_cv = tune(svm, PERFECT_RATING ~ . - LISTING_ID,
    data = commentsTrain_bonus[,1:400],
    cost=10^c(-2:2),
    kernel="linear")
Airbnb.SVM_cv

# Make predictions on the test set
Airbnb.SVMPred = predict(Airbnb.SVM_cv$best.model, newdata = commentsTest_bonus)
table(commentsTest_bonus$PERFECT_RATING, Airbnb.SVMPred)

# Check accuracy
(table(commentsTest_bonus$PERFECT_RATING, Airbnb.SVMPred) %>% diag %>% sum) / nrow(commentsTest_bonus)

# Also, for nice visualizations of SVM, including the support vectors,
# see Jerry's code from last year's course:
# https://github.com/joehuchette/OR-software-tools-2016/blob/master/5-excel/5b-4.R