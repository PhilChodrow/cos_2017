#### Intro stuff to be loaded in during part 1 ####
setwd("~/cos_2017/3_modeling_and_ml")
# install.packages("tidyverse")
library(tidyverse)

# Read in listings data set, and convert price column to numeric
listings = read.csv("../data/listings.csv")
listings$price = as.numeric(gsub('\\$|,','',as.character(listings$price)))

# Read in the reviews data set, making sure to set stringsAsFactors=FALSE
reviews = read.csv("../data/reviews.csv", stringsAsFactors = FALSE)

#### Natural Language Processing ####
# View the data from `reviews.csv`. What does each row represent?


# Display the top 10 most reviewed Airbnb listings using the `reviews` data frame.
# Are the counts consistent with the data in the `listings` data frame?


# Later on, we will want to merge the two data frames: `listings` and `reviews`.
# The ID variables that we will use for this merge operation are
# `listings$id` and `reviews$listing_id`. It is important to understand the
# data structure before performing the analysis. Both data frames have
# 2829 unique listings with >= 1 review - let's confirm this fact.


# We will take `review_scores_rating` as the dependent variable that we
# are trying to predict.  This is the average customer rating of the Airbnb listing,
# on a scale of 0-100. Plot a simple histogram of `review_scores_rating`,
# and count the number of values != NA.


# Next, create a new data frame with just the review scores data from `listings.csv`.
# Filter out rows with `review_scores_rating`=NA.


# **Exercise 2.1:** *Writing a simple function in R*
# The syntax for writing the function f(x) = x^2 is
f <- function(x){
  return(x*x)
}
# Write a function to convert the listing rating from
# a scale of 0-100 to ("Terrible","Low","Mid","High","Perfect").
# Given an integer input rating from 0-100, the function should output:
# "Perfect"   if rating = 100
# "High"      if 95 <= rating < 99
# "Mid"       if 90 <= rating < 94
# "Low"       if 80 <= rating < 89
# "Terrible"  if rating <= 79
# For example: convert_rating(64) should output "Terrible"
# **Solution:**


# Test a few values to make sure that the function works
convert_rating(100)
convert_rating(98)
convert_rating(90)
convert_rating(82)
convert_rating(46)

# To apply the `convert_rating()` function to each element in an array,
# we need to "vectorize" the function first.  Avoid using for-loops
# in R whenever possible because those are slow.


# Test a few values to make sure that the function works.
v_convert_rating(c(100,32,87))

# Compute the new column using a mutate call.

# Take a look

# These groupings look relatively well-balanced, which is desirable.
# For the NLP task, we will try to predict this rating category
# based upon the text data from `reviews.csv`.

# Let's go back to `reviews` data frame.
str(reviews)

# Currently, we have a data frame with 68275 rows.
# We would like to have a data frame with 2829 rows - one per each listing.
# We can use the `group_by()` and `summarize()` functions to transform
# the data frame in this way.


# Check out the updated data frame - 2829 rows.
str(reviews_by_listing)

# View the first listing's comments.
reviews_by_listing$all_comments[1]

# Observations? What are some problems that we might
# run into with bag-of-words?

# *Natural Language Processing slides*

# Now, we are ready to construct the Bag-of-Words
# with Airbnb reviews for the prediction task.
# The following step-by-step procedure for building
# the Bag-of-Words is adapted from MIT EdX - Analytics Edge, Lecture 8.

## **Step 0:** Install and load two packages for pre-processing:
# install.packages("tm")
library(tm)
# install.packages("SnowballC")
library(SnowballC)

## **Step 1:** Convert reviewer comments to a corpus,
##         automatically processing escape characters like "\n".
## **Step 2:** Change all the text to lower case, and convert to
##         "PlainTextDocument" (required after to_lower function).
## **Step 3:** Remove all punctuation.
## **Step 4:** Remove stop words (this step may take a minute).
## **Step 5:** Stem our document.

# Take a look
strwrap(corpus[[1]])[1:3]

# Take a look at tm's stopwords:
stopwords("english")[1:100]

## **Step 6:** Create a word count matrix (rows are reviews, columns are words).

# Take a look
frequencies

## **Step 7:** Account for sparsity.
# Use findFreqTerms to get a feeling for which words appear the most.
# Words that appear at least 10000 times:


# All 45645 terms will not be useful to us. Might as well get rid of some of them - why?
# Solution: only keep terms that appear in x% or more of the reviews
# 5% or more (142 or more)


# How many did we keep? (1136 terms, compared to 45645 previously)
sparse
colnames(sparse)

## **Step 8:** Create data frame.


# View data frame (rows are reviews, columns are words)


# Drop columns that include numbers


# We have finished building the term frequency data frame `commentsTM`.
# Next, we need to merge the two data frames `commentsTM` (features) and
# `listings_scores` (labels) before we can run our machine learning
# algorithms on this data.  This will be a full-join by `LISTING_ID`.
str(listings_scores)
str(commentsTM,list.len=10)

# Add our dependent variable:


# Remove all rows with NA's


# View the first few data frame columns
# Note: Column names corresponding to word frequencies are lowercase,
# while all other column names are uppercase.
names(commentsTM)[1:10]

# **Exercise 2.2:** Your own Bag-of-Words
# Following steps 0-8, build a Bag-of-Words data frame
# on the listings description data.  Add price as the dependent variable,
# name it "PRICE", remove the rows with price=NA,
# and move this column to the front of the new data frame.
# (Hint: Construct the term-matrix listingsTM by modifying
# the NLP code in the file **bonus.R**.)
# **Solution:**

# Up to here, we have just pre-processed and prepared our data.
# Now, we are ready to build models.

## Building a CART model using Bag-of-Words
# Next, we will use our Bag-of-Words to build a CART model to predict
# review scores.  How could a model like this be useful in practice?
# We will follow the same cross-validation procedure as we did before
# to select the cp parameter for our CART model.
# The only difference is that now our features will be word counts,
# and our predictions will be the discrete values:
# ("Terrible","Low","Mid","High","Perfect")

# To begin, convert `RATING_TEXT` to a factor variable, and set the order
# of the level values so that they appear properly in our confusion matrix

str(commentsTM$RATING_TEXT)

# Split data into training and testing sets
# install.packages("caTools")
library(caTools)
set.seed(123)

# Let's use CART! Why CART?
# install.packages("rpart")
library(rpart)
# install.packages("rpart.plot")
library(rpart.plot)

# First, train the model using the default parameter values (cp=0.01)
# Of course, we cannot include `RATING` or `LISTING_ID`
# as predictive variables - why not?


# Display decision tree.  Does it make intuitive sense?


# Next, let's perform cross-validation on our
# Bag-of-Words CART model to tune our choice for cp.
# Useful resource for cross-validation of cp in rpart:
# <https://cran.r-project.org/web/packages/rpart/vignettes/longintro.pdf>

# **Step 1:** Begin by constructing a tree with a small cp parameter
set.seed(2222)


# **Step 2:** View the cross-validated error vs. cp
# In the `printcp()` table:
# "nsplit"    = number of splits in tree
# "rel error" = scaled training error
# "xerror"    = scaled cross-validation error
# "xstd"      = standard deviation of xerror


# In the `plotcp()` plot:
# size of tree = (number of splits in tree) + 1
# dashed line occurs at 1 std. dev. above the minimum xerror
# Rule of Thumb: select the model size which first
#                goes below the dotted line


# **Step 3:** Prune the tree, and take a look


# **Step 4:** Evaluate model in-sample and out-of-sample accuracy,
# using a confusion matrix (because this is a classification problem).
# CART on training set:

# Accuracy?

# Predictions on test set

# Accuracy?


# Question: How much worse would we have done if we didn't use
# cross-validation, and just stuck with the default cp value (0.01)?

# **Step 5:** Compare model to the baseline.  
# Most frequent response variable in training set is "High"
# => Baseline accuracy is 0.2720


# Can we improve the accuracy of our model in any way?  Let's try
# adding a few more features from the `listings` data frame.
str(listings)


str(commentsTM,list.len=10)

# Rerun the CART model with the following code, and check the out-of-sample performance.
# Does it improve?  Why or why not?
set.seed(123)
spl = sample.split(commentsTM$RATING_TEXT, SplitRatio = 0.7)
commentsTrain = subset(commentsTM, spl==TRUE)
commentsTest = subset(commentsTM, spl==FALSE)
commentsCART = rpart(RATING_TEXT ~ . - RATING - LISTING_ID,
                     data=commentsTrain,
                     method="class")
prp(commentsCART)

# CART on training set
PredictCARTTrain = predict(commentsCART, type="class")
confusionMatrixTrain = table(commentsTrain$RATING_TEXT, PredictCARTTrain)
# Accuracy?
sum(diag(confusionMatrixTrain))/nrow(commentsTrain)

# Predictions on test set
PredictCART = predict(commentsCART, newdata=commentsTest, type="class")
confusionMatrix = table(commentsTest$RATING_TEXT, PredictCART)
# Accuracy?
sum(diag(confusionMatrix))/nrow(commentsTest)

# **Exercise 2.3:** *Bag-of-Words + LASSO*
# Using the Bag-of-Words constructed in Exercise 2.3, build a LASSO model
# to predict price based upon listing descriptions only.
# (Hint: To build the LASSO model, follow the instructions in part 1 of this module.)
# **Solution:**

# Can you improve the performance of this Lasso model further?

# *k-means Clustering slides*

#### Unsupervised Learning ####
# Thus far, our machine learning task has been to predict labels,
# which were either continuous-valued (for regression) or
# discrete-valued (for classification).  To do this, we input
# to the ML algorithms some known (feature, label) examples
# (the training set), and the ML algorithm outputs a function
# which enables us to make predictions for some unknown (feature, ?)
# examples (the testing set).  This problem setup is
# known as **Supervised Learning**.

# Next, we consider **Unsupervised Learning**, where we are
# not given labelled examples, and we simply run ML algorithms
# on (feature) data, with the purpose of finding interesting
# structure and patterns in the data.  Let's run one of the
# widely-used unsupervised learning algorithms,
# **k-means clustering**, on the `listings` data frame
# to explore the Airbnb data set.

# First, let's look at help page for the function `k-means()`:
help(kmeans)

# View the data.frame `listings`:
str(listings, list.len=5)

# Let's create a new data.frame `listings_numeric` which
# has the subset of columns that we wish to cluster on.  For the
# `k-means()` function, all of these columns must be numeric.
listings_numeric = listings %>% select(id,latitude,longitude,
                                       accommodates, bathrooms, 
                                       bedrooms, review_scores_rating,
                                       price) %>%
  na.omit()
str(listings_numeric)

# Next, run the **k-means** algorithm on the numeric data.frame,
# with `k = 5` cluster centroids:
set.seed(1234)
kmeans_clust = kmeans(listings_numeric[,-1:-3],5, iter.max=1000, nstart=100)
kmeans_clust

# Look at the average values within the clusters.  
# What are the characteristics of these 5 groups?  
# How many listings are in each cluster?
kmeans_clust$centers
table(kmeans_clust$cluster)

# Finally, let's display the clusters geographically using the 
# (latitude, longitude) data.  First, use `ggmap` to obtain a 
# map of Boston.
# Adapted from <https://www.r-bloggers.com/drug-crime-density-in-boston/>
# install.packages("ggmap")
# devtools::install_github("dkahle/ggmap")
library(ggmap)
# requires internet connection
bos_plot=ggmap(get_map('Boston, Massachusetts',zoom=13,source='google',maptype='terrain'))
bos_plot

# To get good color schemes, use `RColorbrewer`.
# install.packages("RColorbrewer")
library(RColorBrewer)
display.brewer.all()

# Plot maps and Airbnb locations using the `ggplot` syntax.
bos_plot +
  geom_point(data=listings_numeric,aes(x=longitude,y=latitude,colour=factor(kmeans_clust$cluster)),
             alpha=.5,size=1) +
  xlab("Longitude") + ylab("Latitude") +
  scale_colour_brewer("Cluster", palette = "Set1")

# Can you see where the clusters are?  Also, what is the proper number of clusters?
# We will revisit this in the next session, because it requires some more
# advanced tidyverse tools.  Stay tuned!

# In this module, we have covered examples of machine learning methods
# for linear regression, LASSO, CART, and k-means.  This is just the
# tip of the iceberg.  There are tons more machine learning methods
# which can be easily implemented in R.  We provide some bonus R code
# for random forest, regularized logistic regression, and SVM applied
# to the Airbnb data set in the file **bonus.R**.