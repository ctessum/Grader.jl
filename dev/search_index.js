var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = Grader","category":"page"},{"location":"#Grader.jl-Documentation","page":"Home","title":"Grader.jl Documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Grader is an assignment autograder for Julia. It has been designed to be used with the PrairieLearn learning system,  but it could also be used with any other learning system.","category":"page"},{"location":"#Examples","page":"Home","title":"Examples","text":"","category":"section"},{"location":"#Simple-example","page":"Home","title":"Simple example","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Here is a simple example of how to use Grader:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Grader \n\n# This is the code with the correct answer:\ngoldencode = \"\"\"\nx=2\ny = x * 3\n\"\"\"\n\n# This is the code with the student's answer:\nstudentcode = \"\"\"\nx=2\ny = x + x + x\n\"\"\"\n\np = Problem()\ngolden = @rungolden! p goldencode\nstudent = @runstudent! p studentcode\n\ngrade!(p, \"y\", \"check y\", 2, :($student.y ≈ $golden.y), \"y is incorrect\")\np\n\n# output\n\nProblem\n  gradable: Bool true\n  score: Float64 1.0\n  message: String \"\"\n  output: String \"\"\n  images: Array{Grader.Image}((0,))\n  tests: Array{Grader.TestResult}((1,))","category":"page"},{"location":"#Example-with-incorrect-answer","page":"Home","title":"Example with incorrect answer","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Here's an example of what it looks like when the student gets the wrong answer:","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Grader\n\n# This is the code with the correct answer:\ngoldencode = \"\"\"\nx=2\ny = x * 3\n\"\"\"\n\n# This is the code with the student's answer:\nstudentcode = \"\"\"\nx=2\ny = x + x + 2x\n\"\"\"\n\np = Problem()\ngolden = @rungolden! p goldencode\nstudent = @runstudent! p studentcode\n\ngrade!(p, \"y\", \"check y\", 2, :($student.y ≈ $golden.y), \"y is incorrect\")\np.tests[1]\n\n# output\nGrader.TestResult\n  name: String \"y\"\n  description: String \"check y\"\n  points: Float64 0.0\n  max_points: Float64 2.0\n  message: String \"y is incorrect\"\n  output: String \"\"\n  images: Array{Grader.Image}((0,))","category":"page"},{"location":"","page":"Home","title":"Home","text":"We can also forbid students from using certain symbols (e.g libraries):","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Grader\n\nstudentcode = \"\"\"\nusing LinearAlgebra\nx=2\ny = x + x + 2x\n\"\"\"\n\np = Problem()\n@runstudent! p studentcode [:LinearAlgebra]\n\np.output[1:63]\n\n# output\n\"error running student code:\\nUsing LinearAlgebra is not allowed.\"\n","category":"page"},{"location":"#Example-with-plot","page":"Home","title":"Example with plot","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"This is a more complex example that grades a plot and writes out the output as JSON.","category":"page"},{"location":"","page":"Home","title":"Home","text":"using Grader\nusing LinearAlgebra, JSON\n\nstudentcode = \"\"\"\nusing Plots\nx=1:10\ny = x.^2\nxy = plot(x,y)\n\"\"\"\n\np = Problem()\nstudent = @runstudent! p studentcode\n\ngrade!(p, \"XY Plot\", \"Data length\", 1, \n    quote\n        xlen = length($student.xy[1][1][:x])\n        ylen = length($student.xy[1][1][:y])\n        xlen == ylen == 10\n    end, \n    \"the number of data points in x or y is incorrect\")\n\ngrade!(p, \"XY Plot\", \"Y values\", 3, \n    quote\n        ynorm = $norm($student.xy[1][1][:y])\n        ynorm ≈ 159.16343801262903\n    end, \n    \"The Y values are not correct\")\n\n# Output to JSON and print the result\nb = IOBuffer()\npl_JSON(b, p)\nJSON.print(JSON.parse(String(take!(b))), 4)\n\n# output\n{\n    \"images\": [],\n    \"score\": 1.0,\n    \"output\": \"\",\n    \"message\": \"\",\n    \"gradable\": true,\n    \"tests\": [\n        {\n            \"images\": [],\n            \"name\": \"XY Plot\",\n            \"points\": 1.0,\n            \"output\": \"\",\n            \"message\": \"\",\n            \"max_points\": 1.0,\n            \"description\": \"Data length\"\n        },\n        {\n            \"images\": [],\n            \"name\": \"XY Plot\",\n            \"points\": 3.0,\n            \"output\": \"\",\n            \"message\": \"\",\n            \"max_points\": 3.0,\n            \"description\": \"Y values\"\n        }\n    ]\n}","category":"page"},{"location":"#API-Documentation","page":"Home","title":"API Documentation","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [Grader]","category":"page"},{"location":"#Grader.Image","page":"Home","title":"Grader.Image","text":"Represents an image with a label and url.\n\n\n\n\n\n","category":"type"},{"location":"#Grader.Problem","page":"Home","title":"Grader.Problem","text":"Represent a problem for grading.\n\nFields:\n\nGradable: whether the problem is gradable, i.e. whether the all relavent code   has executed without any errors\nScore: the score of the problem, as a fraction of the maximum possible score\nMessage: Any message associated with the graded problem\nOutput: The output of the problem grading\nImages: Any images associated with the problem grading\nTests: A list of tests associated with the problem\n\n\n\n\n\n","category":"type"},{"location":"#Grader.TestResult","page":"Home","title":"Grader.TestResult","text":"Represents the result of a grade! action.\n\n\n\n\n\n","category":"type"},{"location":"#Grader.asmodexpr-Tuple{AbstractString}","page":"Home","title":"Grader.asmodexpr","text":"Return an expression representing the given code inside of a module.\n\n\n\n\n\n","category":"method"},{"location":"#Grader.fill_answers-Tuple{AbstractString, Dict}","page":"Home","title":"Grader.fill_answers","text":"fill_answers(code::AbstractString, answerkey::Dict)::String\n\nFill the answer key into a code template and return the resulting code string.\n\nFor example, consider the code template below, that gives the radius of a circle and asks the student to fill in the area and perimeter. In the  template, the area and perimeter are given as variables a and p  with values missing, and the student is meant to replace missing with the actual answer.\n\ncode = \"# Calculate the area and perimeter of a circle with radius 2.\\n\"*\n\"r = 2\\n\"*\n\"a = missing # Area\\n\"*\n\"p = missing # Perimeter\\n\"\n\nanswer_code = fill_answers(code, Dict(\n    :(a = missing) => :(a = π * r^2),\n    :(p = missing) => :(p = 2π * r)));\n\n\np = Problem()\nanswer = @runstudent! p answer_code\ngrade!(p, \"area\", \"calculate area\", 1, :($answer.a ≈ 4π), \"area is incorrect\")\ngrade!(p, \"perimeter\", \"calculate perimeter\", 1, :($answer.p ≈ 4π), \"perimeter is incorrect\")\n\nprintln(\"Answer key score is $(p.score).\")\n\n# output\nAnswer key score is 1.0.\n\n\n\n\n\n","category":"method"},{"location":"#Grader.grade!-Tuple{Problem, String, String, Real, Expr, String}","page":"Home","title":"Grader.grade!","text":"grade!(p::Problem, name::String, description::String, points::Real, expr::Expr, msg_if_incorrect::String)\n\nAdd a grade for problem p. This grade will have the given name and description in the grader output, and will be associated with the number of points. \n\nThe function will evaluate the given expression expr; if it evaluates to true, the given number  of points will be awarded, otherwise zero points will be awarded and msg_if_incorrect will be  logged to the problem p.\n\n\n\n\n\n","category":"method"},{"location":"#Grader.pl_JSON-Tuple{IO, Problem}","page":"Home","title":"Grader.pl_JSON","text":"pl_JSON(io::IO, p::Problem)\n\nWrite a the contents of the Problem p to the IO stream io as a PrairieLearn-compatible JSON file.\n\n\n\n\n\n","category":"method"},{"location":"#Grader.@rungolden!-Tuple{Any, Any}","page":"Home","title":"Grader.@rungolden!","text":"rungolden! p::Problem goldencode::AbstractString\n\nRun the provided code string inside a module and return the module. If an error occurs it will be logged in  Problem p as a problem with the \"golden\" code.\n\n\n\n\n\n","category":"macro"},{"location":"#Grader.@runstudent!","page":"Home","title":"Grader.@runstudent!","text":"@runstudent! p::Problem studentcode::AbstractString\n\nRun the provided code string inside a module and return the module. If an error occurs it will be logged in  Problem p as a problem with the \"student\" code.\n\n\n\n\n\n","category":"macro"}]
}
