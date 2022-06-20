module Grader

export Problem, rungolden!, runstudent!, grade!, pl_JSON

using Parameters
import Random
import JSON

"""
Represents an image with a label and url.
"""
@with_kw mutable struct Image
    label::String = ""
    url::String = ""
end

"""
Represents the result of a `grade!` action.
"""
@with_kw mutable struct TestResult
    name::String = ""
    description::String = ""
    points::Float64 = 0
    max_points::Float64 = 0
    message::String = ""
    output::String = ""
    images::Vector{Image} = []
end

"""
Represent a problem for grading.

Fields:
- Gradable: whether the problem is gradable, i.e. whether the all relavent code
    has executed without any errors
- Score: the score of the problem, as a fraction of the maximum possible score
- Message: Any message associated with the graded problem
- Output: The output of the problem grading
- Images: Any images associated with the problem grading
- Tests: A list of tests associated with the problem
"""
@with_kw mutable struct Problem
    gradable::Bool = true
    score::Float64 = 0
    message::String = ""
    output::String = ""

    images::Vector{Image} = []

    tests::Vector{TestResult} = []
end

"""
Evaluate the provided code string inside a module,
and return the resulting module. May not 
work if expected if the code string already is a module.
"""
function evalasmodule(code::AbstractString)
    mod = "module " * Random.randstring(Random.MersenneTwister(), "abcdefghijklmnopqrstuvwxyz", 20) * "\n" * code * "\nend"
    expr = Meta.parse(mod)
    eval(expr)
end

"""
    rungolden!(p::Problem, goldencode::AbstractString)::Module

Run the provided code string inside a module and return the module. If an error occurs it will be logged in 
`Problem` `p` as a problem with the "golden" code.
"""
function rungolden!(p::Problem, goldencode::AbstractString)::Module
    goldenresult = Module()
    try
        goldenresult = evalasmodule(goldencode)
    catch err
        p.output = p.output * "error running golden code:\n" * sprint(showerror, err, backtrace()) * "\n"
        p.gradable = false
        p.message = "Internal grading error, please notify instructor."
    end
    return goldenresult
end

"""
    runstudent!(p::Problem, studentcode::AbstractString)::Module

Run the provided code string inside a module and return the module. If an error occurs it will be logged in 
`Problem` `p` as a problem with the "student" code.
"""
function runstudent!(p::Problem, studentcode::AbstractString)::Module
    studentresult = Module()
    try
        studentresult = evalasmodule(studentcode)
    catch err
        p.output = p.output * "error running student code:\n" * sprint(showerror, err, backtrace()) * "\n"
        p.gradable = false
        p.message = "There was an error running your code, please see information below."
    end
    return studentresult
end

"""
    grade!(p::Problem, name::String, description::String, points::Real, expr::Expr, msg_if_incorrect::String)

Add a grade for problem `p`. This grade will have the given `name` and `description` in the grader output,
and will be associated with the number of `points`. 

The function will evaluate the given expression `expr`; if it evaluates to true, the given number 
of `points` will be awarded, otherwise zero points will be awarded and `msg_if_incorrect` will be 
logged to the problem `p`.
"""
function grade!(p::Problem, name::String, description::String, points::Real, expr::Expr, msg_if_incorrect::String)
    if !p.gradable 
        return nothing
    end
    
    t = TestResult(max_points=points, name=name, description=description)

    correct = false
    try 
        correct = eval(expr)
    catch err
        t.output = t.output * "\n" * sprint(showerror, err)
    end

    if correct === missing
        t.message = "your answer contains a 'missing' value"
    else
        try
            correct ? t.points = points : t.message = msg_if_incorrect
        catch err
            t.message = msg_if_incorrect
            t.output = t.output * "\n" * sprint(showerror, err)
        end
    end

    append!(p.tests, [t])

    pts = 0
    totalpts = 0
    for t in p.tests
        pts += t.points
    totalpts += t.max_points
    end
    p.score = float(pts) / float(totalpts)
    return nothing
end


"""
    pl_JSON(io::IO, p::Problem)

Write a the contents of the `Problem` `p` to the IO stream `io`
as a [PrairieLearn](https://prairielearn.readthedocs.io/en/latest/)-compatible JSON file.
"""
function pl_JSON(io::IO, p::Problem)
    JSON.print(io, p)
end

end