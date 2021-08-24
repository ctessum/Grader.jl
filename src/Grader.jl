module Grader

export Problem, rungolden!, runstudent!, grade!, pl_JSON

using Parameters
import Random
import JSON

@with_kw mutable struct Image
    label::String = ""
    url::String = ""
end

@with_kw mutable struct TestResult
    name::String = ""
    description::String = ""
    points::Float64 = 0
    max_points::Float64 = 0
    message::String = ""
    output::String = ""
    images::Vector{Image} = []
end

@with_kw mutable struct Problem
    gradable::Bool = true
    score::Float64 = 0
    message::String = ""
    output::String = ""

    images::Vector{Image} = []

    tests::Vector{TestResult} = []
end

# Evaluate the provided code string inside a module,
# and return the resulting module. May not 
# work if expected if the code string already is a module.
function evalasmodule(code::AbstractString)
    mod = "module "*Random.randstring(Random.MersenneTwister(), "abcdefghijklmnopqrstuvwxyz", 20)*"\n" * code * "\nend"
    expr = Meta.parse(mod)
    eval(expr)
end

function rungolden!(p::Problem, goldencode::AbstractString)::Module
    goldenresult = Module()
    try
        goldenresult = evalasmodule(goldencode)
    catch err
        p.output = p.output * "error running golden code:\n"*sprint(showerror, err, backtrace()) * "\n"
        p.gradable = false
        p.message = "Internal grading error, please notify instructor."
    end
    return goldenresult
end

function runstudent!(p::Problem, studentcode::AbstractString)::Module
    studentresult = Module()
    try
        studentresult = evalasmodule(studentcode)
    catch err
        p.output = p.output * "error running student code:\n"*sprint(showerror, err, backtrace()) * "\n"
        p.gradable = false
        p.message = "There was an error running your code, please see information below."
    end
    return studentresult
end


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
    correct ? t.points = points : t.message = msg_if_incorrect
    
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

function pl_JSON(io::IO, p::Problem)
    JSON.print(io, p)
end

end