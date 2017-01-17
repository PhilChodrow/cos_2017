# -------------------------------------------------------------------------
# CASE STUDY: Advanced Topics in Data Science
# By Phil Chodrow
# January 19th, 2017
# -------------------------------------------------------------------------

# This is the script for following along with our case-study analysis of trends 
# in per-person rental prices. Following along with the case study is highly 
# recommended. 


# Load libraries ----------------------------------------------------------

library(tidyverse) # includes dplyr, tidyr, ggplot2, purrr
library(broom)     # for retrieving model predictions
library(lubridate) # for manipulating dates and times

# Load data ---------------------------------------------------------------
# You may need to manually set your working directory before running the 
# following commands. Do this by clicking Session -> Set Working Directory -> 
# To Source File Location in the RStudio menu. 

source('load_data.R')

# Take a moment to inspect the data by typing the name of each data frame 
# (prices and listings)  in the terminal. By now these should look pretty 
# familiar. 

# Preliminary Exploration -------------------------------------------------

# EXERCISE: Time to take a look at the data we have what we have. 
# Working with your partner, construct a visualization of the first 2000 rows of
# the prices data frame using ggplot2. 
# 	- The date should be on the x-axis
# 	- The price_per should be on the y-axis
# 	- The group aesthetic should be the listing_id
# 	- geom_line() is probably the way to go. 
# 	- You might want to distinguish the series by either using 
# 	  aes(color = listing_id) or facet_wrap(~listing_id)
# 	- You can use the head(nrows) function to extract a data frame with just the
# 	  first nrows of data. 


# EXERCISE: It might be easier to get a big-picture view by plotting the average
# over time. Working with the person next to you, construct a visualization of 
# the mean over time. 
# 	- Use group_by(date) %>% summarise() to create a data frame holding the mean
# 	- You probably want geom_line() again



# Modeling ----------------------------------------------------------------

# We've already discussed how to fit a single LOESS model (and many other 
# models) to data. Now we want to fit a LOESS model to EACH listing id. Start by
# creating prices_nested, where the nesting variable is the listing_id: 


# Now we define our LOESS modeling function. Remember, its first argument must
# be a data frame. 



# Our next step is to use purrr::map to model each of the data frames in the 
# data column of prices_nested. 


# Just like there are data frames in the data column, there are statistical 
# models in the model column. You may want to inspect that column, for example: 
#     prices_with_models$model[[1]] %>% summary()
# Once you're comfortable with that, it's time to extract predictions from 
# the models. We'll use purrr::map2 and broom::augment to do this. map2 is just
# like map, but it iterates over two lists simultaneously. We do this because
# the augment function requires both the model and the original data 


# Hey look, another list column of data frames! You may want to inspect this 
# column too, for example: 
# 	prices_with_preds$preds[[1]] %>% head()
# Now we're ready to get out of bizarro land. 


# The first three columns are exactly where we started, but the last three are 
# new: they give the model predictions (and prediction uncertainty) that we've
# generated. Let's rename the .fitted column "trend" instead:


# EXERCISE: Now, working with a partner, please visualize the model predictions
# against the actual data for the first 2000 rows. Use geom_line() for both. 
# You'll need to use geom_line() twice, with a different y aesthetic in each,
# and you should consider using facet_wrap to show each listing and its model
# in a separate plot. 



# Isolating the Signal ----------------------------------------------------

# Our next step is to begin isolating the April signal. We can think of the 
# LOESS models we've fit as expressing the signal of long-term, seasonal 
# variation. Next, we should capture the short-term, periodic signal. While
# there are packages that can do this in a systematic way, we don't actually
# need to use them, because we know the period of the signal -- the 7-day week. 
# Our strategy is simple: we'll compute the average residual associated with 
# each weekday. This is easy with a little help lubridate: 


# Now we can construct a new column for the part of the signal that's not 
# captured by either the long-term trend or the periodic oscillation:  


# It's a good exercise in using tidyr::gather to plot all four of these columns
# in the same visualization: 



# EXERCISE: Now we can also take a look at the overall trend in what part of the
# signal we've failed to capture. Working with your partner, construct a simple 
# visualization of the mean of the remainder column over time. What do you see?


# We haven't done a perfect modeling job, but we have made considerable progress
# toward isolating the signal in April. 


# Back to K-Means ---------------------------------------------------------

# Our motivating problem is: while the signal is apparent on average, not every 
# individual raises their prices in April. How can we identify individual 
# listings who did? There are plenty of ways to approach this, but we are going 
# to practice our modeling skills by returning to k-means. 

# Our first step is to prepare the data. Since we know the phenomenon we are
# interested in is in April, we'll focus only on the data in that month. We'll
# also just pick the columns we'll need. 


# We also need to filter out anyone who has any data missing, including 
# implicitly missing (row absent from the data frame). 


# EXERCISE: As you may remember, R's implementation of k-means requires that 
# the data be stored as a matrix. Use tidyr::spread to convert april_prices into 
# "wide" format, where the rows correspond to individual listings and there's a 
# separate column for each date. Then, remove the listing_id column with 
# select, and convert the result to a matrix with as.matrix()


# Now we'll fit 10 models for each of k = 1...10, for a total of 100 models.
# As before, map makes this easy. Note that an equivalent and more concise
# approach would be 
# cluster_models <- data_frame(k = rep(1:10, 10)) %>% 
# 	mutate(kclust = map(k, ~ kmeans(prices_for_clustering, .)))


# How do we know how many clusters to use? One way is to extract a summary of 
# each model using broom::glance. 


# EXERCISE: Extract the model summary using glance for each model, and then 
# convert the result into a "well-behaved" data frame called cluster_performance 
# with no nesting. 


# EXERCISE: Compute the mean tot.withinss for each value of k and plot the
# results, with k on the x-axis and the mean tot.withinss on the y-axis. What
# value of k should we use? 


# We really only need one cluster, so let's extract the first one with our 
# chosen value of k. 


# Let's inspect the clustered series. To do this, we need to add the 
# predictions to prices_for_clustering and use gather: 


# We've isolated the signal: users in one group have large spikes at the 
# specific week in April; users in the other don't. Now we're ready to visualize
# where these listings are located

# Let's pull down a map...

# ...and plot the results

# Does this map support or testify against our hypothesis?
