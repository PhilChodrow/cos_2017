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

prices %>% 
	head(2000) %>% 
	ggplot() + 
	aes(x = date, 
		y = price_per, 
		group = listing_id) +
	geom_line() + 
	facet_wrap(~listing_id, 
			   ncol = 1, 
			   scales = 'free_y') +
	theme(strip.text.x = element_blank())

# EXERCISE: It might be easier to get a big-picture view by plotting the average
# over time. Working with the person next to you, construct a visualization of 
# the mean over time. 
# 	- Use group_by(date) %>% summarise() to create a data frame holding the mean
# 	- You probably want geom_line() again

mean_plot <- prices %>% 
	group_by(date) %>% 
	summarise(mean_pp = mean(price_per, na.rm = T)) %>% 
	ggplot() + 
	aes(x = date, y = mean_pp) +
	geom_line() 
mean_plot 


# Modeling ----------------------------------------------------------------

# We've already discussed how to fit a single LOESS model (and many other 
# models) to data. Now we want to fit a LOESS model to EACH listing id. Start by
# creating prices_nested, where the nesting variable is the listing_id: 

prices_nested <- prices %>% 
	nest(-listing_id)

# Now we define our LOESS modeling function. Remember, its first argument must
# be a data frame. 

my_loess <- function(data, span){
	loess(price_per ~ as.numeric(date),
	data = data, 
	span = span)
}

# Our next step is to use purrr::map to model each of the data frames in the 
# data column of prices_nested. 

prices_with_models <- prices_nested %>% 
	mutate(model = map(data, my_loess, span = .25))

# Just like there are data frames in the data column, there are statistical 
# models in the model column. You may want to inspect that column, for example: 
#     prices_with_models$model[[1]] %>% summary()
# Once you're comfortable with that, it's time to extract predictions from 
# the models. We'll use purrr::map2 and broom::augment to do this. map2 is just
# like map, but it iterates over two lists simultaneously. We do this because
# the augment function requires both the model and the original data 

prices_with_preds <- prices_with_models %>%
	mutate(preds = map2(model,data, augment))

# Hey look, another list column of data frames! You may want to inspect this 
# column too, for example: 
# 	prices_with_preds$preds[[1]] %>% head()
# Now we're ready to get out of bizarro land. 

prices_modeled <- prices_with_preds %>% 
	unnest(preds) 

# The first three columns are exactly where we started, but the last three are 
# new: they give the model predictions (and prediction uncertainty) that we've
# generated. Let's rename the .fitted column "trend" instead:

prices_modeled <- prices_modeled %>% 
	rename(trend = .fitted) 

# EXERCISE: Now, working with a partner, please visualize the model predictions
# against the actual data for the first 2000 rows. Use geom_line() for both. 
# You'll need to use geom_line() twice, with a different y aesthetic in each,
# and you should consider using facet_wrap to show each listing and its model
# in a separate plot. 

prices_modeled %>% 
	head(2000) %>% 
	ggplot(aes(x = date, group = listing_id)) +
	geom_line(aes(y = price_per)) +
	geom_line(aes(y = trend), color = 'red') +
	facet_wrap(~listing_id, ncol = 1, scales = 'free_y') + 
	theme(strip.text.x = element_blank())


# Isolating the Signal ----------------------------------------------------

# Our next step is to begin isolating the April signal. We can think of the 
# LOESS models we've fit as expressing the signal of long-term, seasonal 
# variation. Next, we should capture the short-term, periodic signal. While
# there are packages that can do this in a systematic way, we don't actually
# need to use them, because we know the period of the signal -- the 7-day week. 
# Our strategy is simple: we'll compute the average residual associated with 
# each weekday. This is easy with a little help lubridate: 

prices_modeled <- prices_modeled %>% 
	mutate(weekday = wday(date, label = TRUE)) %>% # compute the weekday
	group_by(listing_id, weekday) %>% 
	mutate(periodic = mean(.resid)) %>% 
	ungroup()

# Now we can construct a new column for the part of the signal that's not 
# captured by either the long-term trend or the periodic oscillation:  

prices_modeled <- prices_modeled %>% 
	mutate(remainder = price_per - trend - periodic)

# It's a good exercise in using tidyr::gather to plot all four of these columns
# in the same visualization: 

prices_modeled %>% 
	head(1500) %>% 
	select(-.se.fit, -.resid, -weekday) %>% 
	gather(metric, value, -listing_id, -date) %>% 
	mutate(metric = factor(metric, c('price_per', 
									 'trend', 
									 'periodic', 
									 'remainder'))) %>% 
	ggplot() + 
	aes(x = date, 
		y = value, 
		group = listing_id, 
		color = as.character(listing_id)) + 
	geom_line() + 
	facet_grid(metric~., scales = 'free_y') +
	guides(color = FALSE)


# EXERCISE: Now we can also take a look at the overall trend in what part of the
# signal we've failed to capture. Working with your partner, construct a simple 
# visualization of the mean of the remainder column over time. What do you see?

prices_modeled %>% 
	group_by(date) %>% 
	summarise(mean_remainder = mean(remainder, na.rm = T)) %>% 
	ggplot() + 
	aes(x = date, y = mean_remainder) + 
	geom_line()

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

april_prices <- prices_modeled %>% 
	filter(month(date, label = T) == 'Apr') %>% 
	select(listing_id, date, remainder)

# We also need to filter out anyone who has any data missing, including 
# implicitly missing (row absent from the data frame). 

april_prices <- april_prices %>% 
	complete(listing_id, date) %>% 
	group_by(listing_id) %>% 
	filter(sum(is.na(remainder)) == 0) %>% 
	ungroup()

# EXERCISE: As you may remember, R's implementation of k-means requires that 
# the data be stored as a matrix. Use tidyr::spread to convert april_prices into 
# "wide" format, where the rows correspond to individual listings and there's a 
# separate column for each date. Then, remove the listing_id column with 
# select, and convert the result to a matrix with as.matrix()

prices_to_cluster<- april_prices %>% 
	spread(key = date, value = remainder) 

prices_matrix <- prices_to_cluster %>% 
	select(-listing_id) %>% 
	as.matrix()

# Now we'll fit 10 models for each of k = 1...10, for a total of 100 models.
# As before, map makes this easy. Note that an equivalent and more concise
# approach would be 
# cluster_models <- data_frame(k = rep(1:10, 10)) %>% 
# 	mutate(kclust = map(k, ~ kmeans(prices_for_clustering, .)))

my_kmeans <- function(k){
	kmeans(prices_matrix, k)
}

cluster_models <- data_frame(k = rep(1:10, 10)) %>%
	mutate(kclust = map(k, my_kmeans))

# How do we know how many clusters to use? One way is to extract a summary of 
# each model using broom::glance. 

cluster_models$kclust[[1]] %>% glance()

# EXERCISE: Extract the model summary using glance for each model, and then 
# convert the result into a "well-behaved" data frame called cluster_performance 
# with no nesting. 

cluster_performance <- cluster_models %>% 
	mutate(summary = map(kclust, glance)) %>% 
	unnest(summary)

# EXERCISE: Compute the mean tot.withinss for each value of k and plot the
# results, with k on the x-axis and the mean tot.withinss on the y-axis. What
# value of k should we use? 

cluster_performance %>% 
	group_by(k) %>%
	summarise(withinss = mean(tot.withinss)) %>%
	ggplot() + 
	aes(x = k, y = tot.withinss) +
	geom_point() 

# We really only need one cluster, so let's extract the first one with our 
# chosen value of k. 

chosen_model <- cluster_models$kclust[cluster_models$k == 2][[1]]

# Let's inspect the clustered series. To do this, we need to add the 
# predictions to prices_for_clustering and use gather: 

prices_clustered <- prices_for_clustering %>% 
	mutate(cluster = chosen_model$cluster) %>% 
	gather(key = date, value = price, -cluster, -listing_id) %>% 
	mutate(date = as.Date(date))

prices_clustered %>% 
	ggplot() + 
	aes(x = date, y = price, group = listing_id) + 
	geom_line() + 
	facet_wrap(~cluster)

# We've isolated the signal: users in one group have large spikes at the 
# specific week in April; users in the other don't. Now we're ready to visualize
# where these listings are located

listings_to_plot <- prices_clustered %>% 
	filter(cluster == 1) %>% 
	select(listing_id) %>% 
	unique()

locations_to_plot <- listings %>% 
	filter(id %in% listings_to_plot$listing_id)

# Let's pull down a map...

m <- ggmap::get_map('Copley Square', zoom = 14)

# ...and plot the results

ggmap(m) + 
	geom_point(aes(x = longitude, 
				   y = latitude), data = locations_to_plot)

# Does this map support or testify against our hypothesis?
