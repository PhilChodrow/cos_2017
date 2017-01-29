# Nonlinear and Mixed-integer optimization

This class will cover computational aspects of **convex and nonlinear optimization**, drawing from motivating examples in statistical regression and machine learning models. Please follow the installation instructions below before the class. The preassignment at the end is a check that everything is installed correctly.

## Install Julia packages

In addition to the installation instructions from [the previous session](https://github.com/PhilChodrow/cos_2017/blob/f307a3bf268130f4350cc3347ca6cfac65f905b7/5_julia_and_jump/README.md), we will use the following packages:
- Convex
- Distributions
- PyPlot

Install each one by running ``Pkg.add("xxx")`` where ``xxx`` is the package name
from a Julia prompt or notebook.

## Preassignment

In a blank IJulia notebook, paste the following code into a cell:

```julia
using Convex
using Gurobi
x = Variable(Positive())
solve!(minimize(x), GurobiSolver())
evaluate(x)
```

The result should be some iteration output from Gurobi and then the value zero.

If you have some free time, look at [dcp.stanford.edu](http://dcp.stanford.edu/home) and play the [DCP quiz](http://dcp.stanford.edu/quiz). As part of the class, we will learn how to solve convex nonlinear optimization problems by writing them down in DCP form.

## Questions?
Email yeesian@mit.edu or mlubin@mit.edu
