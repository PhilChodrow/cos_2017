# Session 2: Data Wrangling and Visualization in R

# This tutorial will cover the following:
# 1. Base R basics
# 2. tidyr and dplyr basics
# 3. ggplot basics
# 4. Deeper with gather/spread and joins

#################
## Base R Basics
#################

### Load the data	(remember to set the working directory)

listings = read.csv('boston-airbnb-open-data/listings.csv')	


### Taking a look	

# The `head` command prints out the first parts of a vector, matrix, table, etc.	
head(listings)	

# It looks like each column is a variable (like "reviews_per_month" or "price") and each row corresponds to a different AirBnB listing.  We can look in Environment and see there's actually 3,585 rows of 95 variables. Some other useful "recon"-ish commands are:  	
str(listings)       # display the structure of an object	
summary(listings)   # give summary statistics	
colnames(listings)  # display just column names	

# A few things to note:	
# - There are different variable types: `int` (integer), `logi` (true/false), `num` (numeric), `chr` (character), `Factor`.  	
# - Factor tends to be anything R can't categorize as one of the other types, and so it gives each unique value (string, number, whatever) its own "factor". We can prevent R from converting string-like or non-number-y values into factors by modifying our csv command with `read.csv(..., stringsAsFactors=FALSE)`.  This usually keeps strings as strings.	
# - Sometimes the variable type that R picks isn't what we expect: check out any of the columns dealing with price (We'll deal with this later).	
# - We have a missing data problem: many columns have an "NA" count (we'll deal with this later too).	
 	
# But there is a lot to process here (95 variables!).  Maybe we want to look at a specific row, or a specific group of columns.  Try out a few of these:	
	
listings[4,]       # row four	
listings[,5]       # column five	
listings[4,5]      # row four, column five	
listings[5]        # also column five	
listings["name"]   # also column five	
listings$name      # also column five	
listings[4,]$name  # column five for row four	
listings[c(3,4),]$name  # column five for row three and four	
listings[c(3,4),c(5,6)] # column five and six for row three and four	
listings[4,5:7]    # row 4, columns five through seven	

# Let's try that `summary` command again, but on just a few columns...	
summary(listings[c('square_feet', 'reviews_per_month')])	

# You might have noticed we snuck in the `c(...)` notation to handle multiple indices, which creates a **vector** of values.  Similar to the numeric/factor/character data types from before, which took a single value, there are several data types that are "array-like" and can hold multiple values.  Some of them are:	
# - Data frame.  Our `listings` object is actually a `data.frame`, since this is the default object returned from the `read.csv` function.  It is basically a table of values, where each column has a particular data type and can be indexed by name.	
# - Vector.  Ordered list of any data type.  For example: `my.vec = c(1, 3, 10)` or `my.vec2 = c('Ann', 'Bob', 'Sue')`.	
# - List.  Un-ordered list of any data type, for example `my.list = list(c(1,3,10))`.	
# - Matrix.  This is just a table of values, where everything is the same data type, and you cannot index by column.  	
 	
# We can usually convert from one data type to another by doing something like `as.numeric()` or `as.matrix()`, but we should always check that our conversion did what we expected.  We'll only use data frames and vectors in this session, but later we'll also see an enhanced version of the data frame type.	
 	
# Another common base R function that gets a lot of mileage, is `table` (although we'll introduce a more flexible alternative later).  `table` provides a quick way to cross-tabulate counts of different variables.  So in our dataset, if we want to see the count of how many listings are listed under each room type, we can just do	
table(listings$room_type)	

# And if we wanted to cross-tabulate this with the number the room accommodates, we can just add that in to the `table` command, like this:	
table(listings$room_type, listings$accommodates)	

# We can even make one of the arguments a "conditional," meaning a statement that can be answered by "true" or "false", like the count of rooms by type that accommodate at least 4 people:	
table(listings$room_type, listings$accommodates >= 4)	

# We'll learn some cleaner (and hopefully more intuitive) ways to **select** and **filter** and **summarize** the data like this later.  But for now, let's try visualizing some of it.	
 	
# How about the distribution of prices? We want to run something like 
hist(listings$price)
# but this gives an error: "price is not numeric".  Why?	
str(listings$price)        # notice it says "Factor w/ 324 Levels"	

# Like we mentioned earlier, when R loads a file into a data table, it automatically converts each column into what it thinks is the right type of data.  For numbers, it converts it into "numeric", and usually for strings (i.e. letters) it converts it into "factors" --- each different string gets its own "factor."  The price column got converted into factors because the dollar signs and commas made R think it was strings.  So each different price is its own different factor.	

# (We would still have a similar problem even if we used `stringAsFactors=FALSE` when we loaded the CSV, just instead of factors, the prices would all be strings, i.e. of type `chr`, but still not a number.)	
 	
# Let's make a new variable that will have the numeric version of price in it:	
listings$nprice = as.numeric(gsub('\\$|,', '', listings$price))	

# This command says: in the price column, substitute (sub) the `\\$|,` character out with nothing `''`, then convert everything to type `numeric`, then assign it to this new column called `nprice`.  The `'\\$|,'` character is really some magic that means "the `$` character *or* the `,` character," and there's no need to worry about it too much.  (The `\\` are called "escape characters" because `$` has special meaning otherwise, and the `|` symbol means "or".)  	
# Now let's try again:	
hist(listings$nprice)	

# Well that is a horrible figure, but at least it worked.  Maybe a scatter plot of price vs. reviews?	
plot(listings$review_scores_rating, listings$nprice)	

# That is the ugliest thing I have ever seen.  But there does seem to be some upward trend happening between these variables, so that might be interesting?  Before we start poking around much more, let's rescue ourselves from the Base R trenches by introducing some better tools.	


################
## Introducing the Tidyverse	
################

# Hadley Wickham, a statistician and computer scientist, introduced a suite of packages to give an elegant, unified approach to handling data in R (check out [the paper](http://vita.had.co.nz/papers/tidy-data.html)!).  These data analysis tools, and the philosophy of data handling that goes with them, have become standard practice when using R. 	
	
# The motivating observation is that data *tidying* and *preparation* consumes a majority of the data scientist's time; the underlying concept is then to envision data wrangling in an idiomatic way (as a "grammar"), with a simple set of rules that can unify data structures and data handling everywhere.  	

## Loading the libraries	

# If you did the homework, you already have the packages installed, but if not (shame!) install them now with: 
install.packages('tidyr')
install.packages('dplyr')

# Okay, now we'll load them into our current R session by calling:	
library(tidyr)	
library(dplyr)	

## Some basics	

# Let's try doing some of the basic data recon that we were messing with before, but with tidyr and dplyr.  	

# How about `select`ing a specific column, and looking at the first few rows:	
head(select(listings, reviews_per_month))	

# This is fine, but it's a little awkward having to nest our code like that.  Luckily, there is a nifty operator included with tidyr called the **chaining operator** which looks like `%>%` and serves like a pipeline from one function to another.  Now we can instead do this:	
listings %>% select(reviews_per_month) %>% head()	

# which is much, much nicer.  Notice that the chaining operator feeds in the object on its left as the first argument into the function on its right.	

# Now, let's learn some more verbs.  How about also selecting the name, and `filter`ing out missing entries and low values?  	
listings %>% select(name, reviews_per_month) %>% 	
  filter(!is.na(reviews_per_month), reviews_per_month > 12)	

# Amazing.  It's as if we are speaking to the console in plain English.  The `is.na()` function returns "True" if something is `NA`, so `!is.na()` (read: "*not* is NA") returns the opposite.	
 	
# How many of those NAs are there?  Let's `count` them:	
listings %>% count(is.na(reviews_per_month))	

# Hmm.  Does it have anything to do with just recent listings?  Let's do a table to `summarize` the number of reviews for an NA entry by showing the average number of reviews:	
listings %>%	
  filter(is.na(reviews_per_month)) %>%	
  summarize(avg.num.reviews = mean(number_of_reviews))	

# Ah, so these are just listings without any reviews yet.  That's not alarming.  (**Note to international students:** `summarise` also works!)	
 	
# Now, how about a summary statistic, like the average price for a listing?	
 	
# Well, the first thing we need to do is make sure the price is in a numeric form.  We already dealt with this before by creating a new column using the dollar-sign base R syntax.  Let's instead take a tidy R approach and `mutate` the listings data table by adding this new column right in our chain:  	
listings %>% 	
  mutate(nprice = as.numeric(gsub('\\$|,', '', price))) %>%	
  summarize(avg.price = mean(nprice))	

# This approach has several advantages over the base R way.  One advantage is we can use the column temporarily, as part of our chain, without affecting the data table that we have loaded into memory.  We can even overwrite the original column if we want to keep the same name.  Another advantage is that we can easily convert/add multiple columns at once, like this:	
listings %>%	
  mutate(price = as.numeric(gsub('\\$|,', '', price)),	
         weekly = as.numeric(gsub('\\$|,', '', weekly_price)),	
         monthly = as.numeric(gsub('\\$|,', '', monthly_price))) %>%	
  summarize(avg.price = mean(price),	
            avg.weekly = mean(weekly, na.rm=TRUE),	
            avg.monthly = mean(monthly, na.rm=TRUE))	

# Here we used the argument `na.rm=TRUE` in `mean`, which just removes any NA values from the mean computation --- we could have also chained another filter command with the same result.	
 	
# Another advantage is we can create a new column, and then use those new values immediately in another column!  Let's create a new column that is the "weekly price per day" called `weekly_price_per` by dividing the weekly price by 7.  Then let's use that number and the daily price rate to compute the difference between the two (i.e. the discount by taking the weekly rate).  Then we'll look at the average of this discount across all listings.	
listings %>%	
  mutate(price = as.numeric(gsub('\\$|,', '', price)),	
         weekly = as.numeric(gsub('\\$|,', '', weekly_price)),	
         weekly_price_per = weekly / 7,	
         weekly_discount = price - weekly_price_per) %>%	
  summarize(avg_discount = mean(weekly_discount, na.rm=T))	

# Average discount per day for booking by the week: about 20 bucks! 

# Let's take a deeper look at prices, and we can make our lives easier by just overwriting that price column with the numeric version and saving it back into our `listings` data frame:
listings = listings %>% mutate(price = as.numeric(gsub('\\$|,', '', price)))

# Now --- what if we want to look at mean price, and `group_by` neighborhood?	
listings %>% 	
  group_by(neighbourhood_cleansed) %>%	
  summarize(avg.price = mean(price))	

# Maybe we're a little worried these averages are skewed by a few outlier listings. Let's try	
listings %>%	
  group_by(neighbourhood_cleansed) %>%	
  summarize(avg.price = mean(price),	
            med.price = median(price),	
            num = n())	

# The `n()` function here just gives a count of how many rows we have in each group. Nothing too crazy, but we do notice some red flags to our "mean" approach.  	
# - First, if there are a very small number of listings in a neighborhood compared to the rest of the dataset, we may worry we don't have a representative sample, or that this data point should be discredited somehow (on the other hand, maybe it's just a small neighborhood, like Bay Village, and it's actually outperforming expectation).  	
# - Second, if the *median* is very different than the *mean* for a particular neighborhood, it indicates that we have *outliers* skewing the average.  Because of those outliers, as a rule of thumb, means tend to be a misleading statistic to use with things like rent prices or incomes.  	
# One thing we can do is just filter out any neighborhood below a threshold count:	
listings %>%	
  group_by(neighbourhood_cleansed) %>%	
  summarize(avg.price = mean(price),	
            med.price = median(price),	
            num = n()) %>%	
  filter(num > 200)	

# We can also `arrange` this info (sort it) by the hopefully more meaningful median price:	
listings %>%	
  group_by(neighbourhood_cleansed) %>%	
  summarize(avg.price = mean(price),	
            med.price = median(price),	
            num = n()) %>%	
  filter(num > 200) %>%	
  arrange(med.price)	

# (Descending order would just be `arrange(desc(med.price))`.)  We can also pick a few neighborhoods to look at by using the `%in%` keyword in a `filter` command with a list of the neighborhoods we want:	
listings %>%	
  filter(neighbourhood_cleansed %in% c('Downtown', 'Back Bay', 'Chinatown')) %>%	
  group_by(neighbourhood_cleansed) %>%	
  summarize(avg.price = mean(price),	
            med.price = median(price),	
            num = n()) %>%	
  arrange(med.price)	

# We have now seen: `select`, `filter`, `count`, `summarize`, `mutate`, `group_by`, and `arrange`.  This is the majority of the dplyr "verbs" for operating on a single data table (although [there are many more](https://cran.r-project.org/web/packages/dplyr/dplyr.pdf)), but as you can see, learning new verbs is pretty intuitive. What we have already gives us enough tools to accomplish a large swath of data analysis tasks.	
 	
# But ... we'd really like to visualize some of this data, not just scan summary tables.  Next up, `ggplot`.	




############### 	
## Introducing the Grammar of Graphics	
###############

# We already saw how awful the Base R plotting functions like `plot()` and `hist()` are, straight out of the box, anyway.  We'd like to argue that they aren't just clunky for their aesthetic feel, but the fact that each function is stand-alone, takes different arguments, etc.  We'd like some unifying approach to graphics, similar to what we've begun to see with tidyr.	
 	
# `ggplot` gives us just that.  ggplot was created by Leland Wilkinson with his book [The Grammar of Graphics](https://www.cs.uic.edu/~wilkinson/TheGrammarOfGraphics/GOG.html) (which is the gg in ggplot), and put into code by Hadley Wickham.  We'll see it not only provides a clean way of approaching data visualization, but also nests with the tidyr universe like a hand in a glove.	
 	
## Philosophy	
 	
# What does **grammar of graphics** mean?  A grammar is a set of guidelines for how to combine components (ingredients) to create new things.  One example is the grammar of language: in English, you can combine a noun (like "the dog") and a verb (like "runs") to create a sentence ("the dog runs").  	

# Let's translate this idea to visualization.  Our ingredients are:	
# - **Data**. This is the base of our dish, and is probably a `data.frame` object like we have been using.	
# - **Aes**thetic.  This is the mapping of the parts of the data to chart components. (Like "price on the x-axis".)	
# - **Geom**etry.  The specific visualization shape: a line plot, a point (scatter) plot, bar plot, etc.	
# - **Stat**istical transformation.  How should the data be transformed or aggregated before visualizing?	
# - **Theme**.  This is like flavoring: how do we want the chart to look and feel?	
 	
# In this scheme, our "required ingredients" are the **Data**, the **Aes**thetic, and the **Geom**etry.  	

 	
## Example	

# First, make sure you've got `ggplot2` installed (you only need to run this if you didn't do the homework!)
install.packages('ggplot2')

# and load it into your session 	
library(ggplot2)	

# That scatterplot of the price against the review score seemed interesting, we'd like to revisit it.  First let's save the numeric price column into our listings data table, just for convenience (you should have already done this in the previous section, but just in case):
listings = listings %>% mutate(price = as.numeric(gsub('\\$|,', '', price)))	

# Now, we chain this into the `ggplot` function...	
listings %>%	
  ggplot(aes(x=review_scores_rating, y=price)) +	
  geom_point()  	

# Behold: we specify our Data (`listings`), our Aesthetic mapping (`x` and `y` to columns of the data), and our desired Geometry (`geom_point`).  We are gluing each new element together with `+` signs.   Clean, intuitive, and already a little prettier than the Base R version.  But most importantly, this is much more extensible.  Let's see how.  	
 	
# First, let's try grouping listings together if they have the same review score, and take the median within the group, and plot that.  (This is a little weird since the score could take continuous values and we should be binning them... but let's see what happens.)  Oh, and just filter out those pesky NAs.	
listings %>%	
  filter(!is.na(review_scores_rating)) %>%	
  group_by(review_scores_rating) %>%	
  summarize(med.price = median(price)) %>%	
  ggplot(aes(x=review_scores_rating, y=med.price)) +	
  geom_point()	

# Now that is a bit interesting, and definitely easy to see a trend now.  	

### Cleaning it up	

# Let's clean up this chart by coloring the points blue and customizing the axis labels:	
listings %>%	
  filter(!is.na(review_scores_rating)) %>%	
  group_by(review_scores_rating) %>%	
  summarize(med.price = median(price)) %>%	
  ggplot(aes(x=review_scores_rating, y=med.price)) +	
  geom_point(color='blue') +	
  labs(x='Score', y='Median Price', title='Listing Price Trend by Review Score')	

# That's a little better.  (**Note to international students:** `colour` also works!)  Maybe we are worried that some of those dots represent only a few listings, and we want to visually see where the center of mass is for this trend.  Let's add back in that `n()` count from before to our summarize function, and add in an additional aesthetic mapping to govern the *size* of our geometry:	
listings %>%	
  filter(!is.na(review_scores_rating)) %>%	
  group_by(review_scores_rating) %>%	
  summarize(med.price = median(price),	
            num = n()) %>%	
  ggplot(aes(x=review_scores_rating, y=med.price, size=num)) +	
  geom_point(color='blue') +	
  labs(x='Score', y='Median Price', title='Median Price Trend by Review Score')	

# Those blue dots got a little crowded.  Let's put in some transparency by adjusting the alpha level in our geometry, and change the background to white by changing our theme.  Oh, and let's relabel that legend (notice we specify the labels for each aesthetic mapping, so `size=` will set the legend title, since the legend shows the size mapping).	
listings %>%	
  filter(!is.na(review_scores_rating)) %>%	
  group_by(review_scores_rating) %>%	
  summarize(med.price = median(price),	
            num = n()) %>%	
  ggplot(aes(x=review_scores_rating, y=med.price, size=num)) +	
  geom_point(color='blue', alpha=0.5) +	
  labs(x='Score', y='Median Price', size='# Reviews',	
       title='Median Price Trend by Review Score') +	
  theme_bw()	
	
# That looks pretty good if you ask me!  And, like any decent visualization, it tells a story, and raises interesting questions: there appears to be a correlation between the score of a listing and the price --- is this because higher rated listings can ask a higher price on average? or because when you pay top dollar you trick yourself into believing it was a nicer stay?  What is the best predictor of price, or ratings, or other variables?  We'll explore some of these questions in the next session.  	
 	
### Saving a plot	

# By the way, you can flip back through all the plots you've created in RStudio using the navigation arrows, and it's also always a good idea to "Zoom" in on plots.  	
 	
# Also, when you finally get one you like, you can "Export" it to a PDF (recommended), image, or just to the clipboard.  Another way to save a plot is to use `ggsave()`, which saves the last plot by default, for example: 
ggsave('price_vs_score.pdf')

## Other geometries: Line plots, Box plots, and Bars	

# We will now quickly run through a few of the other geometry options available, but truly, we don't need to spend a lot of time here since each follows the same grammar as before --- the beauty of ggplot!	
 	
# For example, let's look at the price by neighborhood again.  First let's save the summary information we want to plot into its own object:	
by.neighbor = listings %>%	
  group_by(neighbourhood_cleansed) %>%	
  summarize(med.price = median(price))	

# We've already seen `geom_point`, now let's try now adding on `geom_line`:	
by.neighbor %>%	
  ggplot(aes(x=neighbourhood_cleansed, y=med.price)) + 	
  geom_point() +	
  geom_line(group=1)	

# This is misleading, since it falsely implies continuity of price between neighborhoods based on the arbitrary alphabetical ordering.  Also, because our `x` is not a continuous variable, but a list of neighborhoods, `geom_line` thinks the neighborhoods are categories that each need their own line --- so we had to specify `group=1` to group everything into one line.  	

# So we've seen a line, but its not appropriate for our visualization purpose here.  Let's switch to a bar chart, i.e. `geom_bar`.  Oh, and let's rotate the labels on the x-axis so we can read them:	
by.neighbor %>%	
  ggplot(aes(x=neighbourhood_cleansed, y=med.price)) + 	
  geom_bar(stat='identity') +	
  theme(axis.text.x=element_text(angle=60, hjust=1))	

# Again, notice we are separating thematic (non-content) adjustments like text rotation, from geometry, from aesthetic mappings.  (Try playing around with the settings!) 	

# Also notice we added an argument to `geom_bar`: `stat='identity'`.  This tells `geom_bar` that we want the height of the bar to be equal to the `y` value (identity in math means "same as" or "multiplied by one").  We could have instead told it to set the height of the bar based on an aggregate count of different x values, or by binning similar values together --- we'll cover this idea of binning more in the next subsection.	

# For now, let's follow-through on this idea and clean up this plot a bit:	
by.neighbor %>%	
  ggplot(aes(x=reorder(neighbourhood_cleansed, -med.price), y=med.price)) + 	
  geom_bar(fill='dark blue', stat='identity') +	
  theme(axis.text.x=element_text(angle=60, hjust=1)) +	
  labs(x='', y='Median price', title='Median daily price by neighborhood')	

# Only new tool here is the `reorder` function we used in the `x` aesthetic, which simply reorders the first argument in order by the last argument, which in our case was the (negative) median price (so we get a descending order).	
 	
# Again we have an interesting visualization because it raises a couple questions: 	
# - What explains the steep dropoff from "North End" to "Jamaica Plain"?  (Is this a central-Boston vs. peripheral-Boston effect? What would be some good ways to visualize that?)  	
# - Does this ordering vary over time, or is the Leather District always the most high end?  	
# - What is the distribution of prices in some of these neighborhoods? -- we have tried to take care of outliers by using the median, but we still have a hard time getting a feel for a neighborhood with just a single number.	
 	
# Toward the first two observations/questions, we'll see how to incorporate maps into our visualizations in Session 2 and 3, and we'll see some ways to approach "time series" questions in Session 3.	
 	
# For now, let's pick out a few of these high end neighborhoods and plot a more detailed view of the distribution of price using `geom_boxplot`.  We also need to pipe in the full dataset now so we have the full price information, not just the summary info.	
listings %>%	
  filter(neighbourhood_cleansed %in% c('South Boston Waterfront', 'Bay Village', 	
                                       'Leather District', 'Back Bay', 'Downtown')) %>%	
  ggplot(aes(x=neighbourhood_cleansed, y=price)) +	
  geom_boxplot()	

# A boxplot shows the 25th and 75th percentiles (top and bottom of the box), the 50th percentile or median (thick middle line), the max/min values (top/bottom vertical lines), and outliers (dots).  By simply changing our geometry command, we now see that although the medians were very similar, the distributions were quite different (with Bay Village especially having a "heavy tail" of expensive properties), and there are many extreme outliers ($3000 *a night*?!).	
 	
# Another slick way to visualize this is with a "violin plot".  We can just change our geometry to `geom_violin` and voila!	
listings %>%	
  filter(neighbourhood_cleansed %in% c('South Boston Waterfront', 'Bay Village', 	
                                       'Leather District', 'Back Bay', 'Downtown')) %>%	
  ggplot(aes(x=neighbourhood_cleansed, y=price)) +	
  geom_violin()	

### Histograms, Palettes, and Multiple plots	

# Near the beginning of this session we did a histogram of the price in base R, which shows the count of the number of values that occur within sequential intervals (the intervals are called "bins" and the process of counting how many occurrences belong in each interval is called "binning").  We can easily do this with ggplot using `geom_histogram`.  Let's try bin widths of 50 (dollars):	
listings %>%	
  ggplot(aes(x=price)) +	
  geom_histogram(binwidth=50)	

# This is okay but let's trim off those outliers, clean up the colors, and add labels.  We also want to make sure each bar is `centered` in the middle of the interval, which we expect to be 0-50, 51-100, etc.  We can do this by setting the `center=` argument in `geom_histogram`, like so:
listings %>%	
  filter(price < 500) %>%	
  ggplot(aes(x=price)) +	
  geom_histogram(binwidth=50, center=25, fill='cyan', color='black') +	
  labs(x='Price', y='# Listings')	

# (Reality-check it with 
listings %>% filter(price <= 50) %>% count()

# Another way to represent this information is using lines (instead of bars):	
listings %>%	
  filter(price < 500) %>%	
  ggplot(aes(x=price)) +	
  geom_freqpoly(binwidth=50, color='black') +	
  labs(x='Price', y='# Listings')	

# Let's say we want to compare this distribution of price for different room types.  We can set the fill color of the histogram to map to the room type:	
listings %>%	
  filter(price < 500) %>%	
  ggplot(aes(x=price, fill=room_type)) +	
  geom_histogram(binwidth=50, center=25) +	
  labs(x='Price', y='# Listings', fill='Room type')	

# Hmmm, this is a little hard to interpret because there are very different numbers of listings for the different types of room. It's also stacked, not overlaid.  	
 	
# We can overlay the bars by setting the `position=` argument to `identity` (i.e. don't change the position of any bars), although we should then also add in a little transparency.  We would also like to "normalize" the values --- divide each bar height by the total sum of all the bars --- so that each bar represents the fraction of listings with that price range, instead of the count.  We can do that with a special mapping in `aes` to make `y` a "density", like so:	
listings %>%	
  filter(price < 500) %>%	
  ggplot(aes(x=price, y=..density.., fill=room_type)) +	
  geom_histogram(binwidth=50, center=25, position='identity', alpha=0.5, color='black') +	
  labs(x='Price', y='Frac. of Listings', fill='Room type')	

# Maybe we'd prefer to have the histogram bars adjacent, not stacked, so we'll tell `geom_histogram` to set each bar's position by `dodge`ing the others:	
listings %>%	
  filter(price < 500) %>%	
  ggplot(aes(x=price, y=..density.., fill=room_type)) +	
  geom_histogram(binwidth=50, center=25, position='dodge', color='black') +	
  labs(x='Price', y='Frac. of Listings', fill='Room type')	

# Now I'm not crazy about any of this since the default color scheme (or **palette**) involves green and red, and I am red-green colorblind.  Woe is me and my fellow colorblind peoples.  But this is just a matter of specifying our palette, and fortunately there is a colorblind-friendly palette which we can load into our session as a list of hexadecimal color codes:	
cbbPalette = c("#E69F00", "#56B4E9", "#009E73", 	
               "#F0E442", "#0072B2", "#D55E00", "#CC79A7")	

# (There are dozens of palettes, find more [here](http://www.cookbook-r.com/Graphs/Colors_(ggplot2)/).)  Now we can tack on the thematic command `scale_fill_manual` which will `manual`ly set the `values` of our `fill` from this palette (i.e. list of colors), and we get:	
listings %>%	
  filter(price < 500) %>%	
  ggplot(aes(x=price, y=..density.., fill=room_type)) +	
  geom_histogram(binwidth=50, center=25, position='dodge', color='black') +	
  labs(x='Price', y='Frac. of Listings', fill='Room type') +	
  scale_fill_manual(values=cbbPalette)	

# Ahhhh.  There are many other ways of setting colors (for fill or lines) this way, even without specifying a custom palette: gradient valued, continuous, etc.  You can check them out in the help by typing `?scale_fill_` or `?scale_color_` and selecting from the inline menu.	
 	
# This is still a little hard to read because the bars are right next to each other ... maybe we could try `geom_freqpoly` again?	
listings %>%	
  filter(price < 500) %>%	
  ggplot(aes(x=price, y=..density.., color=room_type)) +	
  geom_freqpoly(binwidth=50) +	
  labs(x='Price', y='Frac. of Listings', color='Room type') +	
  scale_color_manual(values=cbbPalette)	

# Compare the changes we made to the aesthetic mapping and palette command from the previous plot to this one --- we are mapping the palette to line color, not fill, so we had to make a few tweaks.  	
 	
# Importantly, it is now easy to see that "shared room" listings run cheaper more often than other room types, and almost all the pricey rooms are "entire home/apt".  Nothing surprising here, but good to be able to check our intuitions in the actual data.	

## Statistical fanciness	

# The only major feature of ggplot we have not yet covered is the *statistical transformation* ability.  This allows you to slap a statistical treatment on a base visualization --- for example, a linear regression over a scatter plot, or a normal distribution over a histogram.  We will show a few examples of this feature, but it is an extremely powerful addition and we leave deeper treatment for future sessions.	
	
# Let's fit a trend line to that scatter plot of average price vs review score by adding a `geom_smooth` call.	
listings %>%	
  filter(!is.na(review_scores_rating)) %>%	
  group_by(review_scores_rating) %>%	
  summarize(med.price = median(price),	
            num = n()) %>%	
  ggplot(aes(x=review_scores_rating, y=med.price, size=num)) +	
  geom_point(color='blue', alpha=0.5) +	
  labs(x='Score', y='Median Price', size='# Reviews',	
       title='Median Price Trend by Review Score') +	
  geom_smooth()	

# Note that all we did was take our previous plot commands, and added the `geom_smooth` command.  The default is to use a "loess" fit (locally weighted scatterplot smoothing), which is a bit overcomplicated for our data.  We can instead specify the model, for example to just fit a line (linear regression) we say	
listings %>%	
  filter(!is.na(review_scores_rating)) %>%	
  group_by(review_scores_rating) %>%	
  summarize(med.price = median(price),	
            num = n()) %>%	
  ggplot(aes(x=review_scores_rating, y=med.price, size=num)) +	
  geom_point(color='blue', alpha=0.5) +	
  labs(x='Score', y='Median Price', size='# Reviews',	
       title='Median Price Trend by Review Score') +	
  geom_smooth(method='lm')	

# If you're curious, [here is some discussion](https://groups.google.com/forum/#!topic/ggplot2/1TgH-kG5XMA) on how to also extract and plot the estimated parameters of this fit.	

# There is also `stat_smooth` and others, and endless ways to specify the complexity, paramaterization, and visualization properties of the model --- we will cover more of this in the next two sessions.	



############# 	
## Going Wider and Deeper	
#############


# The unifying philosophy of the Tidyverse is:	
# >- ***Each row is an observation***	
# >- ***Each column is a variable***	
# >- ***Each table is an observational unit***	

# Simple, right?  Yet a lot of data isn't formed that way.  Consider the following table	

# |Company  | Qtr.1  |  Qtr.2  |  Qtr.3  |  Qtr.4  |	
# |---------|--------|---------|---------|---------|	
# |ABC      |$134.01 |$256.77  |$1788.23 |$444.37  |	
# |XYZ      |$2727.11|$567.23  |$321.01  |$4578.99 |	
# |GGG      |$34.31  |$459.01  |$123.81  |$5767.01 |	
 	
# This looks completely acceptable, and is a compact way of representing the information.  However, if we are treating "quarterly earnings" as the observed value, then this format doesn't really follow the tidy philosophy: notice that there are multiple prices (observations) on a row, and there seems to redundancy in the column headers... 	
 	
# In the tidyverse, we'd rather have the table represent "quarterly earning," with each row giving a single observation of a single quarter for a single company, and columns representing the company, quarter, and earning.  Something like this:	
 	
# |Company  | Quarter |  Earnings  |	
# |---------|---------|------------|	
# |ABC      |Qtr.1    |$134.01     |	
# |ABC      |Qtr.2    |$256.77     |	
# |ABC      |Qtr.3    |$1788.23    |	
# |...      |...      |...         |	
 	
# This is also called the **wide** vs. the **long** format, and we will soon see why it is such a crucial point.	

 	
## Changing data between wide and long	

# Think about our `listings` dataset.  Earlier, we plotted the distribution of daily prices for different room types.  This was easy because this particular slice of the data happened to be tidy: each row was an observation of price for a particular listing, and each column was a single variable, either the room type or the price.	
 	
# But what if we want to compare the distributions of daily, weekly, and monthly prices?  Now we have a similar situation to the quarterly earnings example from before: now we want each row to have single price, and have one of the columns specify which kind of price we're talking about.	
 	
# To gather up **wide** data into a **long** format, we can use the `gather` function.  This needs us to specify the desired new columns in standardized form, and the input columns to create those new ones.  First let's make sure our listings data has the converted prices:	
listings = listings %>%	
  mutate_at(c('price', 'weekly_price', 'monthly_price'),	
            funs(as.numeric(gsub('\\$|,', '', .))))	

# Now let's take a look at what `gather` looks like:	
long.price = listings %>%	
  select(id, name, price, weekly_price, monthly_price) %>%	
  gather(freq, tprice, price, weekly_price, monthly_price) %>%	
  filter(!is.na(tprice))	
	
long.price %>% head()  # take a peek	

# Cool.  Notice that we left in the unique ID for each listing --- this will help us keep track of how many unique listings we have, since the names are not necessarily unique, and are a little harder to deal with.  Also notice that we filtered for NAs, but we did it *after* the `gather` command.  Otherwise we would remove a whole listing even if it was just missing a weekly or monthly price.  	
 	
# Now this `head` command is only showing us the daily prices but if we don't trust that it worked we can always open it up, or check something like 
long.price %>% filter(freq=='weekly_price') %>% head()
 	
# To spread it back out into the original wide format, we can use `spread`	
long.price %>%	
  spread(freq, tprice) %>%	
  head()	


## Visualizing long data	

# Now what was the point of all that, you may ask?  One reason is to allow us to cleanly map our data to a visualization.  Let's say we want the distributions of daily, weekly, and monthly price, with the color of the line showing which type of price it is.  Before we were able to do this with room type, because each listing had only one room type.  But with price, we would need to do some brute force thing like ... `y1=price, y2=weekly_price, y3=monthly_price`? And `color=` ... ?  This looks like a mess, and it's not valid ggplot commands anyway.	
 	
# But with the long format data, we can simply specify the color of our line with the `freq` column, which gives which type of observation it is.	
long.price %>%	
  filter(tprice < 1000) %>%	
  ggplot(aes(x=tprice, y=..density.., color=freq)) +	
  geom_freqpoly(binwidth=50, size=2, center=25) +	
  scale_color_manual(values=cbbPalette)	

# There are lots of times we need this little "trick," so you should get comfortable with it --- sometimes it might even be easiest to just chain it in.  Let's plot a bar chart showing the counts of listings with different numbers of bedrooms and bathrooms (we'll filter out half-rooms just to help clean up the plot):	
listings %>%	
  select('Bedrooms'=bedrooms, 'Bathrooms'=bathrooms) %>%	
  gather(type, number, Bedrooms, Bathrooms) %>%	
  filter(!is.na(number), number %% 1 == 0) %>%	
  ggplot(aes(x=number, fill=type)) +	
  geom_bar(stat='count', position='dodge', color='black') +	
  scale_fill_manual(values=cbbPalette) +	
  labs(x='# Rooms', y='# Listings', fill='Room type')	

# Or group by neighborhood and listing type (which will give us a tidy formatted table), get the median daily price, and plot tiles shaded according to that price value using `geom_tile`:	
listings %>%	
  group_by(neighbourhood_cleansed, room_type) %>%	
  summarize(med.price = mean(price)) %>%	
  ggplot(aes(x=reorder(neighbourhood_cleansed, -med.price), y=room_type, fill=med.price)) +	
  geom_tile() +	
  scale_fill_gradient(low = "white", high = "steelblue") +	
  theme_minimal() +	
  theme(axis.text.x=element_text(angle=60, hjust=1)) +	
  labs(x='', y='', fill='Median price')	
	
# which shows that "private room" trends and "entire home" trends are not identical: why is Bay Village a high-end entire apartment location but low-end private rooms?  (Small rooms?)  Why are the shared rooms in the South End so much?	
 	
# Or spread the same data out into a wide format for easy tabular viewing:	
listings %>%	
  group_by(neighbourhood_cleansed, room_type) %>%	
  summarize(med.price = mean(price)) %>%	
  filter(neighbourhood_cleansed %in% c('Beacon Hill', 'Downtown', 'Fenway',	
                                       'Back Bay', 'West End')) %>%	
  spread(room_type, med.price)	

## Joining datasets	

# Our last topic will be how to **join** two data frames together.  We'll introduce the concept with two toy data frames, then apply it to our AirBnB data. 	
 	
### Join together, right now, over me...	

# (The following example adapted from [here](https://rpubs.com/bradleyboehmke/data_wrangling).)  Let's say `table1` is	
table1 = data.frame(name=c('Paul', 'John', 'George', 'Ringo'),	
                    instrument=c('Bass', 'Guitar', 'Guitar', 'Drums'),	
                    stringsAsFactors=F)	
table1  # take a look	

# and `table2` is	
table2 = data.frame(name=c('John', 'George', 'Jimi', 'Ringo', 'Sting'),	
                    member=c('yes', 'yes', 'no', 'yes', 'no'),	
                    stringsAsFactors=F)	
table2	

# then we might want to join these datasets so that we have a `name`, `instrument`, and `member` column, and the correct information filled in from both datasets (with NAs wherever we're missing the info).  This operation is called a `full_join` and would give us this:	
full_join(table1, table2, by='name')	

# Notice we have to specify a **key** column, which is what column to join `by`, in this case `name`.	
 	
# We might also want to make sure we keep all the rows from the first table (the "left" table) but only add rows from the second ("right") table if they match existing ones from the first.  This called a `left_join` and gives us	
left_join(table1, table2, by='name')	

# since "Jimi" and "Sting" don't appear in the `name` column of `table1`.  	
 	
# Left and full joins are both called "outer joins" (you might think of merging two circles of a Venn diagram, and keeping all the non-intersecting "outer" parts).  However, we might want to use only rows whose key values occur in both tables (the intersecting "inner" parts) --- this is called an `inner_join` and gives us	
inner_join(table1, table2, by='name')	

# There is also `semi_join`, `anti_join`, ways to handle coercion, ways to handle different column names ... we don't have time to cover all the variations here, but let's try using some basic concepts on our AirBnB data.	

 	
### Applying joins	

# Let's say we have a tidy table of the number of bathrooms and bedrooms for each listing, which we get by doing	
rooms = listings %>%	
  select(name, bathrooms, bedrooms) %>%	
  gather(room.type, number, bathrooms, bedrooms)	

# But we may also want to look at the distribution of daily prices, which we can store as	
prices = listings %>%	
  select(name, price) %>%	
  mutate(price = as.numeric(gsub('\\$|,', '', price)))	

# Now, we can do a full join to add a `price` column.	
rooms.prices = full_join(rooms, prices, by='name')	

# This gives us a table with the number of bed/bathrooms separated out in a tidy format (so it is amenable to ggplot), but also prices tacked on each row (so we can incorporate that into the visualization).  Let's try a boxplot of price, by number of rooms, and use facets to separate out the two different types of room.  (We will also filter out half-rooms just to help clean up the plot.)	
rooms.prices %>%	
  filter(!is.na(number), number %% 1 == 0) %>%	
  mutate(number = as.factor(number)) %>%	
  ggplot(aes(x=number, y=price, fill=room.type)) +	
  geom_boxplot() +	
  facet_grid(~room.type) +	
  labs(x='# of Rooms', y='Daily price', fill='Room type')	

# This allows us to easily use the `room.type` column (created in the gather before) to set our fill color and facet layout, but still have access to all the price information from the original dataset.  This visualization shows us that there is a trend of increasing price with increasing number of bathrooms and bedrooms, but it is not a strict one, and seems to taper off at around 2 bedrooms for example.	
 	
# In the next sessions, we will need data from the `listings.csv` file and the other datasets `calendar.csv` and `reviews.csv`, so we will use these joins again.	

