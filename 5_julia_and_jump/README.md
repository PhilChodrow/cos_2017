# Julia, JuMP and Remote Computing

This class is the first part of an introduction to the programming language Julia and the JuMP library.

Julia is a "high-level, high-performance dynamic programming language for technical computing", and JuMP is a library that allows us to easily formulate optimization problems and solve them using a variety of solvers.

We will also present an introduction to remote computing and computing clusters at the end of the class.

## Preassignment - Install Julia and IJulia

The first step is to install a recent version of Julia. The current version is 0.5.0\. Binaries of Julia for all platforms are available [here](http://julialang.org/downloads/).

IJulia is the Julia version of IPython/Jupyter, that provides a nice notebook interface to run julia code, together with text and visualization.

Please follow the instructions [here](https://github.com/stevengj/julia-mit#installing-julia-and-ijulia) to install Julia and set up IJulia.

## Preassignment - Gurobi and JuMP

For this class, we will be using the Gurobi mixed-integer programming solver.

### Installing Gurobi

Gurobi is commercial software, but they have a very permissive (and free!) academic license. If you have an older version of Gurobi (>= 5.5) on your computer, that should be fine.

- Go to [gurobi.com](http://www.gurobi.com) and sign up for an account
- Get an academic license from the website (section 2.1 of the quick-start guide)
- Download and install the Gurobi optimizer (section 3 of the quick-start guide)
- Activate your academic license (section 4.1 of the quick-start guide)
- you need to do the activation step while connected to the MIT network. If you are off-campus, you can use the [MIT VPN](https://ist.mit.edu/vpn) to connect to the network and then activate (get in touch if you have trouble with this).
- Test your license (section 4.6 of the quick-start guide)

### Install the Gurobi and JuMP in Julia

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

## Preassignment - Solving a simple LP

Let's try a simple LP! Enter the following JuMP code in Julia and submit all the output to Stellar.

```jl
using JuMP, Gurobi

m = Model(solver=GurobiSolver()) # replace this line by "m = Model()"" if Gurobi does not work
@variable(m, 0 <= x <= 2 )
@variable(m, 0 <= y <= 30 )

@objective(m, Max, 5x + 3*y )
@constraint(m, 1x + 5y <= 3.0 )

print(m)

status = solve(m)

println("Objective value: ", getobjectivevalue(m))
println("x = ", getvalue(x))
println("y = ", getvalue(y))
```

## Preassignment - Connect to a remote computer

For the remote-computing part of this class, we will use the Sloan computing cluster **Engaging** as an example. If you are an ORC or a Sloan affiliate, please verify that you have access to the Sloan Research Computing wiki page [here](https://wikis.mit.edu/confluence/display/sloanrc/Engaging+Platform)

If you have access to this page, please follow the "How to access eo" paragraph to request an Engaging account (just send an email to the email address given in this page, stating who you are and asking for an Engaging account).

If you are not ORC or Sloan affiliated, you can still follow this class using Athena. Please verify that you can SSH to the athena dialup:

```console
ssh username@athena.dialup.mit.edu
```

If you do not know how to connect to a server through SSH, or feel a little rusty with terminal and git please go through the material of [Lecture 1](https://github.com/PhilChodrow/cos_2017/tree/master/1_terminal_and_git) as a pre-assignment.

## Questions?

Email semartin@mit.edu or huchette@mit.edu
