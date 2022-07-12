```@meta
CurrentModule = Grader
```

# Grader.jl Documentation

[Grader](https://github.com/ctessum/Grader.jl) is an assignment autograder for Julia.
It has been designed to be used with the [PrairieLearn](https://prairielearn.readthedocs.io/en/latest/) learning system, 
but it could also be used with any other learning system.


# Examples

## Simple example

Here is a simple example of how to use Grader:

```jldoctest
using Grader 

# This is the code with the correct answer:
goldencode = """
x=2
y = x * 3
"""

# This is the code with the student's answer:
studentcode = """
x=2
y = x + x + x
"""

p = Problem()
golden = rungolden!(p, goldencode)
student = runstudent!(p, studentcode)

grade!(p, "y", "check y", 2, :($student.y ≈ $golden.y), "y is incorrect")
p

# output

Problem
  gradable: Bool true
  score: Float64 1.0
  message: String ""
  output: String ""
  images: Array{Grader.Image}((0,))
  tests: Array{Grader.TestResult}((1,))
```

## Example with incorrect answer

Here's an example of what it looks like when the student gets the wrong answer:

```jldoctest
using Grader

# This is the code with the correct answer:
goldencode = """
x=2
y = x * 3
"""

# This is the code with the student's answer:
studentcode = """
x=2
y = x + x + 2x
"""

p = Problem()
golden = rungolden!(p, goldencode)
student = runstudent!(p, studentcode)

grade!(p, "y", "check y", 2, :($student.y ≈ $golden.y), "y is incorrect")
p.tests[1]

# output
Grader.TestResult
  name: String "y"
  description: String "check y"
  points: Float64 0.0
  max_points: Float64 2.0
  message: String "y is incorrect"
  output: String ""
  images: Array{Grader.Image}((0,))
```

We can also forbid students from using certain symbols (e.g libraries):

```jldoctest
using Grader

studentcode = """
using LinearAlgebra
x=2
y = x + x + 2x
"""

p = Problem()
runstudent!(p, studentcode, [:LinearAlgebra])

p.output[1:63]

# output
error running student code:\nUsing LinearAlgebra is not allowed.

```

## Example with plot

This is a more complex example that grades a plot and writes out the output as JSON.

```jldoctest
using Grader
using LinearAlgebra, JSON

studentcode = """
using Plots
x=1:10
y = x.^2
xy = plot(x,y)
"""

p = Problem()
student = runstudent!(p, studentcode)

grade!(p, "XY Plot", "Data length", 1, 
    quote
        xlen = length($student.xy[1][1][:x])
        ylen = length($student.xy[1][1][:y])
        xlen == ylen == 10
    end, 
    "the number of data points in x or y is incorrect")

grade!(p, "XY Plot", "Y values", 3, 
    quote
        ynorm = $norm($student.xy[1][1][:y])
        ynorm ≈ 159.16343801262903
    end, 
    "The Y values are not correct")

# Output to JSON and print the result
b = IOBuffer()
pl_JSON(b, p)
JSON.print(JSON.parse(String(take!(b))), 4)

# output
┌ Warning: Package Grader does not have Plots in its dependencies:
│ - If you have Grader checked out for development and have
│   added Plots as a dependency but haven't updated your primary
│   environment's manifest file, try `Pkg.resolve()`.
│ - Otherwise you may need to report an issue with Grader
└ Loading Plots into Grader from project dependency, future warnings for Grader are suppressed.
{
    "images": [],
    "score": 1.0,
    "output": "",
    "message": "",
    "gradable": true,
    "tests": [
        {
            "images": [],
            "name": "XY Plot",
            "points": 1.0,
            "output": "",
            "message": "",
            "max_points": 1.0,
            "description": "Data length"
        },
        {
            "images": [],
            "name": "XY Plot",
            "points": 3.0,
            "output": "",
            "message": "",
            "max_points": 3.0,
            "description": "Y values"
        }
    ]
}
```

# API Documentation

```@index
```

```@autodocs
Modules = [Grader]
```
