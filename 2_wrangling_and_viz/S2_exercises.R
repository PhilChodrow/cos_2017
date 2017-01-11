# Exercises for Session 2

###########
### Base R Exercises	
###########

# **Exercise 1. Conditional statements.**  Earlier we did a `table` by looking at rooms that accommodated "at least 4" (`>= 4`).  We can also look at "at most 4" (`<= 4`), "exactly 4" (`== 4`), or "anything but 4" (`!= 4`) people, and of course "strictly less than 4" (`<`) and "strictly more than 4" (`>`).  We can also join conditional statements together by saying "at most 4 OR exactly 7" (`accommodates <= 4 | accommodates == 7`) where we used the OR operator `|`, or a similar statement using the AND operator `&`.  	

# How could we do a table of listing counts by room type comparing how many are/are not in the Back Bay neighborhood? 	

# *ANSWER:*	



# **Exercise 2. The `%in%` operator.**  What if we wanted to check if the listing was in one of several neighborhoods, like the North End/West End/Beacon Hill strip?  We can put the neighborhoods in a vector (or list) and check if the listing is `%in%` the vector, for example `listings$neighbourhood %in% c('North End', 'West End', 'Beacon Hill')`.  	

# How could we check the number of listings by room type that accommodate either 2, 4, or 7 AND have at least 2 bedrooms?	

# *ANSWER:*	


# (What happens if we keep passing `table()` more and more arguments, like `table(..., listings$accommodates==2, listings$accommodates==4, ...)` ?)	


# **Exercise 3. Converting dates and times.**  We often have date/time information we need to use in our data, but which are notoriously tricky to handle: different formats, different time zones, ... blech.  R provides a data type (`Date`) to handle dates in a cleaner way.  We can usually take our raw dates (like "2016-01-12") and convert by doing `as.Date(my.table$raw.date, '%Y-%m-%d')`.  The second argument is a formatting string that tells `as.Date` how the input raw data is formatted.  This example uses `%Y` (meaning 4-digit year), `%m` and `%d` (meaning 2-digit month and day).  There are similar strings for other formats (see for example [here](https://www.r-bloggers.com/date-formats-in-r/)).	

# Try creating a new column in `listings` named "last_review_date" that has the "last_review" column in `Date` format.	

# *ANSWER:*	


# This allows us to treat dates like numbers, and R will do all the conversion and math "behind the scenes" for us.  Use `min()`, `max()`, and `mean()` to find the earliest, last, and average date a host became a host.  Or how about: how many days between the 3rd and 4th listings' hosts dates?  	

# *ANSWER:*	


# There is a ton more to learn here, if you are interested.  `Date` can handle any format, including numeric formats (like Excel generates or UNIX time stamps), but sometimes the difficulty is something like handling dates that are formatted in different ways in the same column, or contain errors ("Marhc 27th") ...	


# ***Exercise 4. Text handling.***  We have seen the `chr` data type, which can be single characters or strings of characters.  We can get substrings of a string using `substr()`; for example `substr("I love R", start=1, stop=4)` gives "I lo".  We can paste two strings together using `paste()`; for example `paste("Hello", "there")` gives "Hello there" (single space is default).  We can substitute one string into another using `sub()`; for example `sub("little", "big", "Mary had a little lamb")` gives "Mary had a big lamb".  (We used `gsub()` earlier, which just allows multiple substitutions, not just the first occurrence.)	

# Try creating a new column with the first 5 letters of the host name followed by the full name of the listing without spaces.	

# *ANSWER:*	


# We are not going to cover **escape characters**, **string formatting**, or the more general topic of **regular expressions** ("regex"), but we have seen some of these topics already.  When converting price to numeric, we used the string `\\$|,` to represent "any dollar sign OR comma", which is an example of escape characters and regular expressions.  When converting dates, we used strings like `%Y` to represent 4-digit year; this is an example of string formatting.	





#############
### Tidyverse Exercises	
#############

# We'll now introduce a few new tricks for some of the dplyr verbs we covered earlier, but this is by no means a comprehensive treatment.  	


# **Exercise 1. More with `select`.**  In addition to selecting columns, `select` is useful for temporarily renaming columns.  We simply do an assignment, for example `select('New colname'=old_col_name)`.  This is helpful for display purposes when our column names are hideous.  Try generating the summary table of median price by room type but assigning some nicer column labels.	
# *ANSWER:*	


# Another useful trick with select (and other functions in R) is to include *all but* a column by using the minus `-` sign before the excluded column.  For example `listings %>% select(-id)` selects every column *except* the listing ID.	


# **Exercise 2. More with `group_by`.**  We can group by multiple columns, and dplyr will start cross-tabulating the information within each group.  For example, let's say we want the count of listings by room type and accommodation, we could do	
listings %>% group_by(room_type, accommodates) %>% count()	

# This is the same information we got earlier using a `table` command (although in an interestingly *longer* format, which we will talk about later).  Try finding the median daily price of a listing, grouped by number of bedrooms and number of bathrooms:	

# *ANSWER:*	



# **Exercise 3. More with `mutate`.**  The code block earlier with multiple mutation commands got a little repetitive, and we are lazy.  We would rather have a verb so we can select some columns, and apply some function to `mutate_all` of them:	
listings %>%	
  select(price, weekly_price, monthly_price) %>%	
  mutate_all(funs(numversion = as.numeric(gsub('\\$|,', '', .)))) %>%	
  head()	

# This is fairly straightforward, with two "tricks": `funs()` is a convenience function we have to use to tell dplyr to apply the transformation to multiple columns, and the period `.` serves as a stand-in for the column we're on.  Note also we have created new columns which tack on "_numversion" to the older columns, but if we leave out that assignment in `funs()` we just overwrite the previous columns.  If we want to be able to specify which columns we want to `mutate_at`, we can do:	
listings %>%	
  select(name, price, weekly_price, monthly_price) %>%	
  mutate_at(c('price', 'weekly_price', 'monthly_price'),  # specify a list of cols	
            funs(as.numeric(gsub('\\$|,', '', .)))) %>%   # specify the transformation	
  head()	

# This time also notice that we actually didn't make new columns, we mutated the existing ones.  	 	
# (There is also a variation for conditional operations (`mutate_if`) and analogous versions of all of this for summarize (`summarize_all`, ...).  We don't have time to cover them all, but if you ever need it, you know it's out there!)	

# Try using one of these methods to convert all the date columns to `Date` (fortunately they all use the same formatting).	

# *ANSWER:*	





############
## ggplot Exercises	
############


# **Exercise 1. Multi-`facet`ed.**  Besides changing colors, another easy way to display different groups of plots is using facets, a simple addition to the end of our `ggplot` chain.  For example, using the price by room type example, let's plot each histogram in its own facet:	
listings %>%	
  filter(price < 500) %>%	
  ggplot(aes(x=price, y=..density.., fill=room_type)) +	
  geom_histogram(binwidth=50, center=25, position='dodge', color='black') +	
  labs(x='Price', y='Frac. of Listings', fill='Room type') +	
  scale_fill_manual(values=cbbPalette) +	
  facet_grid(.~room_type)	

# If we interpret the facet layout as an x-y axis,the `.~room_type` formula means layout nothing (`.`) on the y-axis, against `room_type` on the x-axis.  Sometimes we have too many facets to fit on one line, and we want to let ggplot do the work of wrapping them in a nice way.  For this we can use `facet_wrap()`.  Try plotting the distribution of price, faceted by how many the listing accommodates, using `facet_wrap()`.  Note that now we can't have anything on the y-axis (since we are just wrapping a long line of x-axis facets), so we drop the period from the `~` syntax.	

# *ANSWER:*	


# Note that if you tried to use the colorblind palette again, you probably ran out of colors and ggplot complained!  (You can use a larger palette, a gradient palette, ...)	


# **Exercise 2. `geom_tile`**  A useful geometry for displaying heatmaps in `ggplot` is `geom_tile`.  This is typically used when we have data grouped by two different variables, and so we need visualize in 2d.  For example, in an exercise for the last section we looked at median price grouped by # bedrooms and bathrooms.  Try visualizing this table with the `geom_tile` geometry.	

# *ANSWER:*	


# BONUS: We can enforce that the color scale runs between two colors by adjusting a `scale_fill_gradient` theme, like this:	
listings %>%	
  mutate(price = as.numeric(gsub('\\$|,','',price))) %>%	
  group_by(bedrooms, bathrooms) %>%	
  summarize(med = median(price)) %>%	
  ggplot(aes(x=bedrooms, y=bathrooms, fill=med)) +	
  geom_tile() +	
  scale_fill_gradient(low = "white", high = "steelblue") +	
  theme_minimal() +	
  labs(x='Bedrooms', y='Bathrooms', fill='Median price')	


# **Exercise 3. Getting Dodgy.**  The earlier example where we plotted the histograms grouped by room type is a little hard to read since each set of bars is right next to each other, and maybe we didn't like the `geom_freqpoly` approach.  Another way would be to put a little separation between each threesome of bars.  We can do these kind of tweaks by adjusting the `position=` argument in the histogram geometry.  Instead of just `position='dodge'`, try reproducing the plot using `position=position_dodge(...)`.  (Check out the documentation by typing `?position_dodge` into the console.)	

# *ANSWER:*	


# This is still a little awkward having the bars overlap though, and also misleading to have separation between bar when the bins are continous...  check out and try a few of the other position adjustments (for example in the "See Also" of the documentation for position_dodge).	


# **Exercise 4. Count em up: `geom_count`.**  A common desire in plotting scatters is to have points which occur more often to appear larger (instead of just plotting them on top of each other).  ggplot provides this functionality built-in with `geom_count`.  Try plotting our price vs review score scatter using `geom_count` instead of `geom_point`.  Don't group by score, just plot every listing.  Try also playing around with alpha settings, and fitting a linear regression.	

# *ANSWER:*	


# **(Optional) The Director's Cut.**  Recall we weren't crazy about the way we grouped by a continuous variable in that price vs. review score scatter plot earlier.  We could be a little more precise by doing a histogram simultaneously on price AND score, and plotting the median of each 2d bin.  For more on this, see "Additional Reading" below.  Another way to get around this problem would be to just create a new variable with an approximate, or binned, score rating, like low/medium/high (giving us a factor, instead of a continuous variable) by `cut`ting the continuous variable into bins.  	

# For example, with score, we could create a column `listings$scorecut = cut(listings$review_scores_rating, breaks=3)` that would evenly divide all scores into 3 categories, or cuts.  In our case, we might want to cut the scores by every 5, so we would specify `breaks=seq(0,100,by=5)` which means `breaks=[0,5,10,...,100]`.  Let's try piping that in instead:	
listings %>%	
  filter(!is.na(review_scores_rating)) %>%	
  mutate(scorecut = cut(review_scores_rating, breaks=seq(0,100,by=5))) %>%	
  group_by(scorecut) %>%	
  summarize(medprice = median(price)) %>%	
  ggplot(aes(x=scorecut, y=medprice)) +	
  geom_point(color='blue')	

# Perfect --- we still see the trend (possibly clearer?) and we are not worried about weird effects from small bins.	

