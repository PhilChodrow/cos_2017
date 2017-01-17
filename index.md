# About

Welcome to the course repository for the 2017 offering of 15.S60, Computing in Optimization and Statistics. This is an advanced course offered by and for practicing researchers in fields relating to operations research, computer science, applied mathematics, and computational engineering. For an overview of the course, including logistics and session content, please consult the [syllabus](https://philchodrow.github.io/cos_2017/syllabus.pdf). Advanced users may wish to access the [course repository](https://github.com/PhilChodrow/cos_2017) directly. Below, you can learn more about each of the sessions and access primary materials. 

In 2017, 15.S60 was organized by [Brad Sturt](https://github.com/brad-sturt) and [Phil Chodrow](https://philchodrow.github.io/).

# Course Materials

## 1. Introduction -- *Jackie Baek and Brad Sturt*
Introduces foundational concepts and computing tools, including terminal navigation and basic commands; version control with `git` and GitHub; and elementary data inspection and manipulation in `R`. 

**Slides**

1. [Introduction to Terminal](https://philchodrow.github.io/cos_2017/1_terminal_and_git/Introduction to terminal.pdf)
2. [Introduction to git and GitHub](https://philchodrow.github.io/cos_2017/1_terminal_and_git/Introduction to git.pdf)

**Code and Data**

- [Introduction to `R`](https://philchodrow.github.io/cos_2017/1_terminal_and_git/intro.R)
- [Sample Data Set](https://philchodrow.github.io/cos_2017/1_terminal_and_git/taxi_data.csv), courtesy of the [New York City Taxi and Limousine Commission](http://www.nyc.gov/html/tlc/html/about/trip_record_data.shtml)

## 2. Data Wrangling and Visualization -- [*Steve Morse*](http://web.mit.edu/stmorse/www/)
This session will introduce basic techniques in data wrangling and visualization in R.  Specifically, we will cover some basic tools using out-of-the-box R commands, then introduce the powerful framework of the "tidyverse" (both in wrangling and visualizing data), and finally gain some understanding of the philosophy of this framework to set up deeper exploration of our data.  Throughout, we will be using a publicly available dataset of AirBnB listings.

Sessions 2-4 all use a data set of Boston AirBnB rentals, provided courtesy of [AirBnB and Kaggle](https://www.kaggle.com/airbnb/boston). You can download each of the three components by clicking the links below: 

- [`listings.csv`](https://philchodrow.github.io/cos_2017/data/listings.csv)
- [`calendar.csv`](https://philchodrow.github.io/cos_2017/data/calendar.csv)
- [`reviews.csv`](https://philchodrow.github.io/cos_2017/data/reviews.csv)

1. [Session Notes](https://philchodrow.github.io/cos_2017/2_wrangling_and_viz/S2_master.html).
2. [Practice Script](https://philchodrow.github.io/cos_2017/2_wrangling_and_viz/S2_script.R) and [with code filled-in](https://philchodrow.github.io/cos_2017/2_wrangling_and_viz/S2_script_full.R).
3. [Exercises](https://philchodrow.github.io/cos_2017/2_wrangling_and_viz/S2_exercises.R) and [solutions](https://philchodrow.github.io/cos_2017/2_wrangling_and_viz/S2_exercises_solved.R).

## 3. Statistical Modeling and Machine Learning -- *Clark Pixton and Colin Pawlowski*

This session introduces basic concepts of machine learning and their implementation in `R`. Topics include elementary regression; regularization and model selection; natural language processing; and model diagnostics. Throughout the session, students use data manipulation and exploration skills to visualize and evaluate models. 

### Presentation Materials

- **Slides:** [Machine Learning](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/Machine Learning.pdf)
and [Natural Language Processing](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/Natural Language Processing.pdf)
- **Notes:** [Part 1 - Regression and Splines](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/S3_R_script_1.html) and
[Part 2 - Bag-of-Words, CART, and Clustering](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/script_2_complete.html)

### R Code

- **Part 1:** Script for [in-class](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/S3_R_script_1.R)
 and [with code filled-in](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/S3_R_script_1_full.R), and [clean_amenities.R](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/clean_amenities.R)
- [Exercises](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/S3_Exercises_1.R) and [solutions](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/S3_Exercises_1_solved.R) for Part 1
- **Part 2:** Script for [in-class](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/script_2_inclass.R) and [with code filled-in](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/script_2_complete.R)
- [**Bonus code**](https://philchodrow.github.io/cos_2017/3_modeling_and_ml/bonus.R) with more machine learning examples on random forest and SVM.  

## 4. Advanced Topics in Data Science -- [*Phil Chodrow*](https://philchodrow.github.io/)
Data science is rarely cut-and-dried; each analysis typically provides answers but also raises new questions. This makes the data scientific process fundamentally cyclical:

<img src="https://ismayc.github.io/moderndiver-book/images/tidy1.png" alt="The Data Science Pipeline" style="width: 500px;"/>

*Image credit: Hadley Wickham*

A skilled analyst needs to be able to smoothly transition from data manipulation to visualization to modeling and back. In this session, we focus on using the `tidyverse` set of packages to smoothly navigate the Cycle of Data Science. Topics covered include:

1. Reinforcement of Session 2 tools like `dplyr` and `tidyr`.
2. Efficient, tidy iteration with `purrr` and `map`. 
3. Tidy model inspection and selection with `broom`. 

While learning these tools, we work a complex case study that will require multiple iterations of manipulation, visualization, and modeling to test a data scientific hypothesis. 

- **Slides**: [Presentation](https://philchodrow.github.io/cos_2017/4_advanced_topics/slides.Rmd) and [source](https://philchodrow.github.io/cos_2017/4_advanced_topics/slides.html).
- **Case Study**: [Student script](cos_2017/4_advanced_topics/case_study_student.R) for the session, [complete script](cos_2017/4_advanced_topics/case_study_complete.R) for reference, and readable [writeup](https://philchodrow.github.io/cos_2017/4_advanced_topics/notes.html) with [source](https://github.com/PhilChodrow/cos_2017/blob/master/4_advanced_topics/notes.Rmd). 

## 5. Introduction to Julia and JuMP, Linear Optimization, and Engaging -- *Sebastien Martin and Joey Huchette*
*Focuses on....*


## 6. Nonlinear and Integer Optimization in JuMP --  *Miles Lubin and Yee Sian Ng*
*Focuses on....*

## 7. Excel for Operations Research -- *Charlie Thraves*
*Focuses on....*

## 8. Deep Learning in TensorFlow Python -- *Eli Gutin and Brad Sturt*
*Focuses on....*

