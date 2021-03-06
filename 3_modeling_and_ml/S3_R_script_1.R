
#' # Statistical Modelling and Machine Learning in R: Part 1

#' ## Regression	
#' Within the world of supervised learning, we can divide tasks into two parts. In settings where the response variable is continuous we call the modelling *regression*, and when the response is categorical we call it *classification*. We will begin with regression to understand what factors influence price in the AirBnB data set.	

#' Let's start by loading the data (after first setting the correct working directory). We'll use the 'listings.csv' file for now. Since we'll be wrangling and visualizing, we'll also load the `tidyverse` package. (Instead of `tidyverse`, it also works to load `tidyr`, `dplyr`, and `ggplot2` as we saw last session.)	




#' ### Linear Regression	
#' As a review, we need to change the price column to a numeric form.
listings = listings %>% mutate(price = as.numeric(gsub("\\$|,","",price)))




#' Now, which variables may be predictive of price? We can use `names(listings)` to get a look at all the variable names.	

#' #### Data Preparation	
#' Let's begin by looking at the relationship between `listings$accommodates` and `listings$price`. As a first look:	




#' Looks like there are some outliers on both axes. There are fancier ways to deal with this statistically, but for today let's just get rid of the outliers and fit a model on the cleaner data:	





#' Let's take another look:	





#' You may argue that it's still a bit messy, but let's see what we can do with a linear model. Since we care about prediction accuracy, we'll reserve a portion of our data to be a test set. There are lots of ways to do this. We'll use the `modelr` package, which is part of the `tidyverse`.	




#' The object `listings_for_lm` is now a list with two elements: `train` and `test`.	

#' #### Model Fitting	
#' In R, we specify a model structure and then use the corresponding function to tell R to optimize for the best-fitting model. For linear regression, the function is `lm()`:	





#' Let's check out the lm_price_by_acc object:	



#' The object `lm_price_by_acc` is a list of a bunch of relevant information generated by the `lm()` function call. We can use the `$` to view different elements, for example	



#' So, it stores the function call in one of the list elements. But this isn't the most useful way to check out the model fit. The function `summary()` is overloaded for many different objects and often gives a useful snapshot of the model:	




#' There we go, this is more useful! First, let's look at the section under "Coefficients". Notice that R automatically adds an intercept term unless you tell it not to (we'll see how to do this later). In the "estimate" column, we see that the point estimates for the linear model here say that the price is \$55.20 plus \$37.79 for every person accommodated. Notice the '***' symbols at the end of the "(Intercept)" and "accommodates" rows. These indicate that according to a statistical t-test, both coefficients are extremely significantly different than zero, so things are okay from an inference perspective.	

#' #### Model Evaluation	
#' As another check on inference quality, let's plot the fitted line. There are some nifty functions in the `modelr` package that make interacting with models easy in the `tidyr` and `dplyr` setting. We'll use `modelr::add_predictions()` here.	





#' Nice. We can also remove the linear trend and check the residual uncertainty, which we'll do here using `modelr::add_residuals()`. This is helpful to make sure that the residual uncertainty looks like random noise rather than an unidentified trend.	




#' Since we have finitely many values, maybe box plots tell a better story:	






#' Things are pretty centered around zero, with the exception of 9- & 10-person accommodations. Maybe the model doesn't apply so well here and we could refine it in a later modelling iteration.	

#' Let's now take a look at out-of-sample performance. We'll plot the predictions versus the actuals as we did before, but this time for the test data.	






#' Now, what if we wanted to *quantify* how well the model predicts these out-of-sample values? There are several metrics to aggregate the prediction error. We'll look at two:	

#' *Root Mean-squared Error (RMSE): $\sqrt{\sum_{t=1}^n (\hat{y}_t - y_t)^2/n}$	

#' *Mean Absolute Error (MAE): $\sum_{t=1}^n |\hat{y}_t - y_t|/n$	

#' In both, $\hat{y}_t$ is the predicted value for test observation $t$, $y_t$ is the actual value, and $n$ is the size of the test set.	

#' You could do this pretty easily by hand, and we'll do so later on, but `modelr` has built-in functions to do this for you:	




#' These don't help much on their own, but they come in handy when comparing different models, which we'll do next after a quick review.	

#' ### Other Models - Splines	
#' Now that we've identified the pattern, let's look at another type of model: splines. Without going into all the mathematical details, splines are (roughly) one way of fitting a higher-degree polynomial to the data. Let's look at what happens when we allow a quadratic and cubic fit in the price by accomodation size setting.	




#' We can again look inside these model objects using `summary()`:	



#' We can also plot the out-of-sample performance of each separately:	




#' To plot the linear, quadratic, and cubic models all at once, we'll use `gather_predictions()`. This function makes a big long column of predictions, with another column to tell which model generated which prediction (so that the data is in *long* or *tidy* format):	






#' In this case, all the models look reasonable. Let's compare the RMSE and MAE:	





#' All values are roughly the same. The higher-order models give a bit of advantage, but not much. The fact that we only gain slightly from a more complex model isn't surprising, given that we only have data for 10 distinct values of the `accommodates` variable. In fact, in some cases more complex models perform *worse* since they overfit to the data in the training set.	

#' ## Model Selection and Tuning: Penalized Regression	
#' Let's work a bit harder on predicting price, this time using more than one predictor. In fact, we'll add a bunch of predictors to the model and see what happens.	

#' As one set of predictors, the column listings$amenities looks interesting:	



#' This could be good predictive information if we can separate out which listing has which amenity. Our goal here is to turn the amenities column into many columns, one for each amenity, and with logical values indicating whether each listing has each amenity. This is just a bit tricky, so I've written a function called `clean_amenities` that will do this for us. We need to `source()` the file that has this function in it, and then we'll call it on the `listings` data frame.	




#' In total, we'll use all of these predictors:	

#' * accommodates	
#' * property_type	
#' * review_scores_rating	
#' * neighbourhood_cleansed	
#' * accommodates*room_type	
#' * property_type*neighbourhood_cleansed 	
#' * review_scores_rating*neighbourhood_cleansed 	
#' * accommodates*review_scores_rating	
#' * All columns created from the amenities column	

#' Note that whenever we include a non-numeric (or categorical) variable, R is going to create one indicator variable for all but one unique value of the variable. We'll see this in the output of `lm()`.	

#' First, let's clean up the data by getting rid of missing values and outliers. For categorical variables, we will remove all categories with only a few observations. Finally, we'll separate again into training and test sets.	

listings_big = listings %>%	
  filter(!is.na(review_scores_rating),	
         accommodates <= 10,	
         property_type %in% c("Apartment","House","Bed & Breakfast","Condominium","Loft","Townhouse"),	
         !(neighbourhood_cleansed %in% c("Leather District","Longwood Medical Area")),	
         price <= 1000) %>%	
  select(price,accommodates,room_type,property_type,review_scores_rating,neighbourhood_cleansed,starts_with("amenity"))	
	



#' To get R to learn the model, we need to pass it a formula. We don't want to write down all those amenity variables by hand. Luckily, we can use the `paste()` function to string all the variable names together, and then the `as.formula()` function to translate a string into a formula.	



	
big_formula = as.formula(paste("price ~ accommodates + accommodates*room_type + property_type + neighbourhood_cleansed + property_type*neighbourhood_cleansed + review_scores_rating*neighbourhood_cleansed + accommodates*review_scores_rating",amenities_string,sep="+"))	

#' Now we can use the `lm()` function:	




#' We won't look at the summary because there are so many predictors. What happens when we compare in-sample and out-of-sample prediction performance?	




#' We've got an overfitting problem here, meaning that the training error is smaller than the test error. The model is too powerful for the amount of data we have. Note that R recognizes this by giving warnings about a "rank-deficient fit."	

#' ### Regularized/Penalized Regression	
#' But is there still a way to use the info from all these variables without overfitting? Yes! One way to do this is by regularized, or penalized, regression.	

#' Mathematically, we add a term to the optimization problem that we're solving when fitting a model, a term which penalizes models that get too fancy without enough data. If we call $\beta$ the coefficient vector that we'd like to learn about for linear regression, then the regular regression we've worked with looks like	
#' $$	
#' \min_\beta \sum_{t=1}^n (y_t-x_t^T\beta)^2,	
#' $$	
#' but penalized regression looks like	
#' $$	
#' \min_\beta \sum_{t=1}^n (y_t-x_t^T\beta)^2 + \lambda ||\beta||.	
#' $$	

#' There are two types of flexibility within this framework that I'll mention:	

#' * Choice of norm, a structural decision, and	
#' * Choice of $\lambda$, a parametric decision.	

#' Two natural choices of norm are the Euclidean 1- and 2-norms. When we use the 2-norm, it's often called "ridge regression." We'll focus today on the 1-norm, or "LASSO regression". On a very simple level, both types of regression shrink all the elements of the unconstrained $\beta$ vector towards zero, some more than others in a special way. LASSO shrinks the coefficients so that some are equal to zero. This feature is nice because it helps us interpret the model by getting rid of the effects of many of the variables.	

#' To do LASSO, we'll use the `glmnet` package. Of note, this package doesn't work very elegantly with the `tidyverse` since it uses matrix representations of the data rather than data frame representations. However, it does what it does quite well, and will give us a chance to see some base R code. Let's load the package and check out the function `glmnet()`. We can see the documentation from the command line using `?glmnet`.	




#' Notice that `glmnet()` doesn't communicate with the data via formulas. Instead, it wants a matrix of predictor variables and a vector of values for the variable we're trying to predict, including all the categorical variables that R automatically expanded into indicator variables. Fortunately, R has a `model.matrix()` function which takes a data frame and gets it into the right form for `glmnet()` and other functions with this type of input.	

#' Notice also that there's a way to specify lambda manually. Since we haven't discussed choosing lambda yet, let's just accept the default for now and see what we get.	


x = model.matrix(~ .-price + accommodates*room_type + property_type*neighbourhood_cleansed + review_scores_rating*neighbourhood_cleansed + accommodates*review_scores_rating,data=as.data.frame(listings_big_lm$train))	




#' This time the `summary()` function isn't quite as useful:	




#' It does give us some info, though. Notice that "lambda" is a vector of length 88. The `glmnet()` function has defined 88 different values of lambda and found the corresponding optimal beta vector for each one! We have 88 different models here. Let's look at some of the coefficients for the different models. We'll start with one where lambda is really high:	




#' Here the penalty on the size of the coefficients is so high that R sets them all to zero. Moving to some smaller lambdas:	




#' And, to see the whole path of lambdas:	




#' Here, each line is one variable. The plot is quite messy with so many variables, but it gives us the idea. As lambda shrinks, the model adds more and more nonzero coefficients.	

#' ### Cross Validation	
#' How do we choose which of the 88 models to use? Or in other words, how do we "tune" the $\lambda$ parameter? We'll use a similar idea to the training-test set split called cross-validation.	

#' The idea behind cross-validation is this: what if we trained our family of models (in this case 88) on only some of the training data and left out some other data points? Then we could use those other data points to figure out which of the lambdas works best out-of-sample. So we'd have a training set for training all the models, a validation set for choosing the best one, and a test set to evaluate performance once we've settled on a model.	

#' There's just one other trick: since taking more samples reduces noise, could we somehow take more validation set samples? Here's where *cross*-validation comes in. We divide the training data into groups called *folds*, and then for each fold repeat the train-validate procedure on the remaining training data and then use the current fold as a validation set. We then average the performance of each model on each fold and pick the best one.	

#' This is a very common *resampling* method that applies in lots and lots of settings. Lucky for us the glmnet package has a very handy function called `cv.glmnet()` which does the entire process automatically. Let's look at the function arguments using `?cv.glmnet`.	

#' The relevant arguments for us right now are	

#' * x, the matrix of predictors	

#' * y, the response variable	

#' * nfolds, the number of ways to split the training set (defaults to 10)	

#' * type.measure, the metric of prediction quality. It defaults to mean squared error, the square of RMSE, for linear regression	

#' Let's do the cross-validation:	




#' Notice the "lambda.min". This is the best lambda as determined by the cross validation. "lambda.1se" is the largest lambda such that the "error is within 1 standard error of the minimum."	

#' There's another automatic plotting function for `cv.glmnet()` which shows the error for each model:	



#' The first vertical dotted line shows `lambda.min`, and the second is `lambda.1se`. The figure illustrates that we cross-validate to find the "sweet spot" where there's not too much bias (high lambda) and not too much noise (low lambda). The left-hand side of this graph is flatter than we'd sometimes see, meaning that the unpenalized model may not be too bad. However, increasing lambda increases interpretability at close to no loss in prediction accuracy!	

#' Let's again compare training and test error. Since the `predict()` function for `glmnet` objects uses matrices, we can't use the `rmse` function like we did before.	

x_all = model.matrix(~ .-price + accommodates*room_type + property_type*neighbourhood_cleansed + review_scores_rating*neighbourhood_cleansed + accommodates*review_scores_rating,data=listings_big) # Matrix form for combined test and training data	
	


#' The overfitting problem has gotten better, but hasn't yet gone away completely. I added a bunch variables for dramatic effect that we could probably screen out before running the LASSO if we really wanted a good model.	

#' One more note on cross-validation: the `glmnet` package has built-in functionality for cross-validation. In situations where that's not the case, `modelr::crossv_kfold()` will prepare data for cross validation in a nice way.	

#' ## Classification	
#' So far we've looked at models which predict a continuous response variable. There are many related models which predict categorical outcomes, such as whether an email is spam or not, or which digit a handwritten number is. We'll take a brief look at two of these: logistic regression and classification trees.	

#' ### Logistic Regression	
#' Logistic regression is part of the class of generalized linear models (GLMs), which build directly on top of linear regression. These models take the linear fit and map it through a non-linear function. For logistic regression this function is the logistic function, $f(x) = \exp(x)/(1+\exp(x))$.

#' Since the function stays between zero and one, it can be interpreted as a mapping from predictor values to a probability of being in one of two classes.	

#' Let's apply this model to the `listings` data. Let's try to predict which listings have elevators in the building by price. To make sure we're asking a sensible question, we'll only consider apartments. We'll also filter out price outliers.	





#' Instead of the `lm()` function, we'll now use `glm()`, but the syntax is almost exactly the same:	




#' Again, we can add predictions to the data frame and plot these along with the actuals, although the result doesn't look nearly as clean:	




#' One way to get a more informative plot is by using the `logi.hist.plot()` function in the `popbio` package.	

#' In the meantime, we can explore out-of-sample performance. Ultimately, we want to predict whether or not a listing has an elevator. However, logistic regression gives us something a bit different: a probability that each listing has an elevator. This gives us flexibility in the way we predict. The most natural thing would be to predict that any listing with predicted probability above 0.5 *has* an elevator, and any listing with predicted probability below 0.5 *does not have* an elevator. But what if I use a wheelchair and I want to be really confident that there's going to be an elevator? I may want to use a cutoff value of 0.9 rather than 0.5. In fact, we could choose any cutoff value and have a corresponding prediction model.	

#' There's a really nice metric that measures the quality of all cutoffs simultaneously: *AUC*, for "Area Under the receiver operating characteristic Curve." That's a mouthful, but the idea is simpler: For every cutoff, we'll plot the *false positive rate* against the *true positive rate* and then take the area under this curve. (A *positive* in our case is a listing that has an elevator. So a *true positive* is a listing that we predict has an elevator and really does have an elevator, while a *false positive* is a listing that we predict has an elevator and does *not* actually have an elevator.)	

#' As the cutoff shrinks down from 1 to 0, the rate of total positives will increase. If the rate of true positives increases faster than the rate of false positives, this is one indication that the model is good. This is what AUC measures.	

#' The `ROCR` package is one implementation that allows us to plot ROC curves and calculate AuC. Here's an example (make sure to install the packages first using `install.packages("ROCR"))`:	





	


#' As you can see, the `performance()` function in the `ROCR` package is versatile and allows you to calculate and plot a bunch of different performance metrics.	

#' In our case, this model gives an AUC of 0.7. The worst possible is 0.5 - random guessing. We're definitely better than random here, and could likely improve by adding more predictors.	

#' We've covered basic logistic regression, but just as with linear regression there are many, many extensions. For example, we could add higher-order predictor terms via splines. We could also do LASSO logistic regression if we wanted to use many predictors, using the `glmnet` package.	

#' ### Classification Trees	
#' We will briefly explore classification trees (often referred to as CART, for Classification And Regression Trees), and then in the second half of the session we'll take a deeper dive.	

#' A (binary) classification tree makes predictions by grouping similar observations and then assigning a probability to each group using the proportion of observations within that group that belong to the positive class. Groups can be thought of as nodes on a tree, and tree branches correspond to logical criteria on the predictor variables. There's a lot of neat math that goes into building the trees, but we won't get into that today. For now let's get familiarized by looking at a simple example. We need the `rpart` library.	




#' The model construction step follows the same established pattern. We use the modelling function `rpart()`, which takes a formula and a data frame (and optional parameters) as arguments.	



#' This is another case when the `summary()` function is less helpful. We can, however, plot the resulting tree:	




#' The neighbourhood_cleansed variable names are a bit hard to read, but other than that the model is clear and simple. While logistic regression is a continuous, global method, classification trees is a piecewise constant, local method. In the next section we'll look at a much fancier classification tree and discuss performance evaluation.	


