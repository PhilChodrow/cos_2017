# Exercises

# FIRST SET OF EXERCISES: Linear Regression
# 1. Regress price on review_scores_rating. Plot the regression line and the actual training 
# points, and find the out-of-sample RMSE. (Read below for more details if you need them.)

# DETAILS:
# -Remove rows where review_scores_rating is NA
# -Create a new train/test split using `resample_partition()`
# -Use `lm()` to learn the linear relationship
# -Use `add_predictions()` and ggplot tools for the plotting
# -Calculate RMSE on the test data






# 2. Try to beat the out-of-sample performance of the price ~ accommodates model by adding other
# variables. You can use `names(listings)` to explore potential predictors. If you start getting 
# errors or unexpected behavior, make sure the predictors are in the format you think they are.
# You can check this using the `summary()` and `str()` functions on listings$<row of interest>.
 




# Median Regression. Since we're dealing with data on price, we expect that there will be high
# outliers. While least-squares regression is reliable in many settings, it has the property 
# that the estimates it generates depend quite a bit on the outliers.
# One alternative, median regression, minimizes *absolute* error rather than squared error.
# This has the effect of regressing on the median rather than the mean, and is more robust to outliers.
# In R, it can be implemented using the `quantreg` package.

# 3. Install the quantreg package, and compare the behavior of the median regression fit (using the `rq())
# function) to the least squares fit from `lm()` on the original listings data which includes all the
# price outliers. You can enter ?rq for info on the rq function.

# (More details: One easy way to compare the quantitative behavior is by plotting the two regression
# lines together. You can use the `gather_predictions()` function as we did in class.)








# SECOND SET OF EXERCISES: glmnet
# 1. The glmnet package is actually more versatile than just LASSO regression. It also does ridge regression
# (with the l2 norm), and any mixture of LASSO and ridge. The mixture is controlled by the parameter
# alpha: alpha=1 is the default and corresponds to LASSO, alpha=0 is ridge, and values
# in between are mixtures between the two. One could use cross validation to choose this
# parameter as well. For now, try just a few different values of alpha on the model we
# built for LASSO using `cv.glmnet()` (which does not cross-validate for alpha
# automatically). How do the new models do on out-of-sample RMSE?







# THIRD SET OF EXERCISES (time permitting): Classification
# 1. Try to beat the out-of-sample performance for logistic regression of elevators
# on price by adding new variables.

