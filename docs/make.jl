using Grader
using Documenter

DocMeta.setdocmeta!(Grader, :DocTestSetup, :(using Grader); recursive=true)

makedocs(;
    modules=[Grader],
    authors="Christopher Tessum and contributors",
    repo="https://github.com/ctessum/Grader.jl/blob/{commit}{path}#{line}",
    sitename="Grader.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://ctessum.github.io/Grader.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/ctessum/Grader.jl",
)
