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

summary(listings$review_scores_rating)
listings_pr_by_rev = listings %>%
  filter(!is.na(review_scores_rating)) %>%
  resample_partition(c(train=0.7,test=0.3))
lm_price = lm(price ~ review_scores_rating,data=listings_pr_by_rev$train)
as.data.frame(listings_pr_by_rev$train) %>%
  add_predictions(lm_price) %>%
  ggplot(aes(x=review_scores_rating)) + geom_line(aes(y=pred)) + geom_point(aes(y=price),color="dark blue")

# 2. Try to beat the out-of-sample performance of the price ~ accommodates model by adding other
# variables. You can use `names(listings)` to explore potential predictors. If you start getting 
# errors or unexpected behavior, make sure the predictors are in the format you think they are.
# You can check this using the `summary()` and `str()` functions on listings$<row of interest>.
 
better_lm = lm(price ~ accommodates + neighbourhood_cleansed,data=listings_for_lm$train)
rmse(lm_price_by_acc,listings_for_lm$test)
rmse(better_lm,listings_for_lm$test)

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

install.packages("quantreg")
library(quantreg)
mr_model = rq(price ~ accommodates, data=listings)
lm_model = lm(price ~ accommodates, data=listings)
summary(mr_model)
summary(lm_model)

listings %>%
  gather_predictions(mr_model,lm_model) %>%
  filter(price <=750) %>%
  ggplot(aes(x=accommodates,group=model)) +
  geom_line(aes(y=pred,color=model)) + geom_point(aes(y=price))

# SECOND SET OF EXERCISES: glmnet
# 1. The glmnet package is actually more versatile than just LASSO regression. It also does ridge regression
# (with the l2 norm), and any mixture of LASSO and ridge. The mixture is controlled by the parameter
# alpha: alpha=1 is the default and corresponds to LASSO, alpha=0 is ridge, and values
# in between are mixtures between the two. One could use cross validation to choose this
# parameter as well. For now, try just a few different values of alpha on the model we
# built for LASSO using `cv.glmnet()` (which does not cross-validate for alpha
# automatically). How do the new models do on out-of-sample RMSE?

pen_mod_0 = cv.glmnet(x,y,alpha=0)
listings_big %>%
  mutate(is_test = 1:nrow(listings_big) %in% listings_big_lm$test$idx,
         pred = as.vector(predict.cv.glmnet(pen_mod_0,newx=x_all))) %>%
  group_by(is_test) %>%
  summarize(rmse = sqrt(1/length(price)*sum((price-pred)^2)))

pen_mod_half = cv.glmnet(x,y,alpha=0.5)
listings_big %>%
  mutate(is_test = 1:nrow(listings_big) %in% listings_big_lm$test$idx,
         pred = as.vector(predict.cv.glmnet(pen_mod_half,newx=x_all))) %>%
  group_by(is_test) %>%
  summarize(rmse = sqrt(1/length(price)*sum((price-pred)^2)))

# THIRD SET OF EXERCISES (time permitting): Classification
# 1. Try to beat the out-of-sample performance for logistic regression of elevators
# on price by adding new variables.

l.glm_2 = glm(amenity_Elevator_in_Building ~ price + neighbourhood_cleansed,family="binomial",data=listings)
summary(l.glm_2)

listings$pred = predict(l.glm_2,type="response")
preds = prediction(listings$pred,listings$amenity_Elevator_in_Building)
perf = performance(preds,'tpr','fpr')
performance(preds,'auc')
plot(perf)
