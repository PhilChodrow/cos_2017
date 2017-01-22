# Nonlinear and Mixed-integer optimization

## Preassignment

For this class, we will be using the Gurobi mixed-integer programming solver, and JuMP to easily formulate optimization problems and solve them using a variety of solvers. The instructions for installing them are the same as before.

### Installing Gurobi

Gurobi is commercial software, but they have a very permissive (and free!) academic license. If you have an older version of Gurobi (>= 5.5) on your computer, that should be fine.

- Go to [gurobi.com](http://www.gurobi.com) and sign up for an account
- Get an academic license from the website (section 2.1 of the quick-start guide)
- Download and install the Gurobi optimizer (section 3 of the quick-start guide)
- Activate your academic license (section 4.1 of the quick-start guide)
- you need to do the activation step while connected to the MIT network. If you are off-campus, you can use the [MIT VPN](https://ist.mit.edu/vpn) to connect to the network and then activate (get in touch if you have trouble with this).
- Test your license (section 4.6 of the quick-start guide)

### Install the Gurobi and JuMP packages in Julia

Installing packages in Julia is easy with the Julia package manager. Just open Julia and enter the following command:

```jl
julia> Pkg.add("Gurobi")
```

If you don't have an academic email or cannot get access for Gurobi for another reason, you should be able to follow along with the open source solver GLPK for much of the class. To install, simply do.

```jl
julia> Pkg.add("GLPKMathProgInterface")
```

Also install the JuMP package:

```jl
julia> Pkg.add("JuMP")
```

### Test the installation

How about a simple knapsack problem? In the next cell, enter the following JuMP code and submit all the output to Stellar.

```julia
using JuMP, Gurobi
m = Model(solver=GurobiSolver(Presolve=0)) # turn presolve off to make it a lil more interesting
N = 100
@variable(m, x[1:N], Bin)
@constraint(m, dot(rand(N), x) <= 5)
@objective(m, Max, dot(rand(N), x))
solve(m)
```

## Questions?
Email yeesian@mit.edu or mlubin@mit.edu
