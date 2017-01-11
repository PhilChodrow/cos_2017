# Data wrangling and Visualization

In this session, we will introduce basic techniques in data wrangling and visualization in R.  Specifically, we will cover some basic tools using out-of-the-box R commands, then introduce the powerful framework of the "tidyverse" (both in wrangling and visualizing data), and finally gain some understanding of the philosophy of this framework to set up deeper exploration of our data.  Throughout, we will be using a publicly available dataset of AirBnB listings. 


## Pre-assignment 1: Keeping current

To ensure that you have the most current versions of all files, please fire up a terminal, navigate to the directory into which you cloned the full set of materials for the course, and run `git pull`.  (Refer back to Session 1 if you're having trouble here.)

Before class, it is recommended to skim through the [online session notes](https://philchodrow.github.io/cos_2017/2_wrangling_and_viz/S2_master.html).

We recommend you follow along in class using the `S2_script.R` and `S2_exercises.R` files, which will allow you to live-code along with the session leader and work through un-solved exercises.  

It may be helpful, however, to also keep handy the `S2_script_full.R` and `S2_exercises_solved.R` files which have all code and exercise answers filled in.

(The `S2_master.Rmd` and `S2_master.html` files creating the [online session notes](https://philchodrow.github.io/cos_2017/2_wrangling_and_viz/S2_master.html) can be ignored.)


## Pre-assignment 2: Installing libraries

We will use three libraries for this session: `tidyr`, `dplyr`, and `ggplot2`.  Before Thursday's session, ensure that you install them, and are able to load them into an R session in RStudio.  You can install them by executing the following commands in the RStudio console:
```
install.packages('dplyr')
install.packages('tidyr')
install.packages('ggplot2')
```

You should test that the libraries will load by then running
```
library(dplyr)
library(tidyr)
library(ggplot2)
```

Then test that dplyr/tidyr work by executing the command:
```
data.frame(name=c('Ann', 'Bob'), number=c(3.141, 2.718)) %>% gather(type, favorite, -name)
```
which should output something like this
```
      name   type favorite
    1  Ann number    3.141
    2  Bob number    2.718
```

Finally, test that ggplot works by executing the command
```
data.frame(x=rnorm(1000), y=rnorm(1000)) %>% ggplot(aes(x,y)) + geom_point()
```
which should produce a cloud of points centered around the origin.

**Please upload a screenshot of these two outputs to Stellar (the table and the scatter plot).**


## Additional Resources

`dplyr` and `tidyr` are well-established packages within the `R` community, and there are many resources to use for reference and further learning. Some of our favorites are below. 

- Tutorials by Hadley Wickham for `dplyr` [basics](https://cran.rstudio.com/web/packages/dplyr/vignettes/introduction.html), [advanced grouped operations](https://cran.r-project.org/web/packages/dplyr/vignettes/window-functions.html), and [database interface](https://cran.r-project.org/web/packages/dplyr/vignettes/databases.html).
- Third-party [tutorial](http://www.dataschool.io/dplyr-tutorial-for-faster-data-manipulation-in-r/) (including docs and a video) for using `dplyr`
- [Principles](http://vita.had.co.nz/papers/tidy-data.pdf) and [practice](https://cran.r-project.org/web/packages/tidyr/vignettes/tidy-data.html) of tidy data using `tidyr`
- (Detailed) [cheatsheet](https://www.rstudio.com/wp-content/uploads/2015/02/data-wrangling-cheatsheet.pdf?version=0.99.687&mode=desktop) for `dplyr` and `tidyr` 
- A useful [cheatsheet](https://stat545-ubc.github.io/bit001_dplyr-cheatsheet.html) for `dplyr` joins
- [Comparative discussion](http://stackoverflow.com/questions/21435339/data-table-vs-dplyr-can-one-do-something-well-the-other-cant-or-does-poorly) of `dplyr` and `data.table`, an alternative package with higher performance but more challenging syntax.  

Some of the infinitude of visualization subjects we did not cover are: heatmaps and 2D histograms, statistical functions, plot insets, ...  And even within the Tidyverse, don't feel you need to limit yourself to `ggplot`.  Here's a good overview of some [2d histogram techniques](http://www.everydayanalytics.ca/2014/09/5-ways-to-do-2d-histograms-in-r.html), a discussion on [overlaying a normal curve over a histogram](http://stackoverflow.com/questions/5688082/ggplot2-overlay-histogram-with-density-curve), a workaround to fit multiple plots in [one giant chart](http://www.cookbook-r.com/Graphs/Multiple_graphs_on_one_page_(ggplot2)/). 

For other datasets and applications, one place to start is data hosting and competition websites like [Kaggle](http://www.kaggle.com), and there many areas like [sports analytics](http://www.footballoutsiders.com), [political forecasting](http://www.electoral-vote.com/evp2016/Info/data.html), [historical analysis](https://t.co/3WCaDxGnJR), and countless others that have [clean](http://http://www.pro-football-reference.com/), [open](http://www.kdnuggets.com/datasets/index.html), and [interesting](https://www.kaggle.com/kaggle/hillary-clinton-emails) data just waiting for you to `read.csv`. 

