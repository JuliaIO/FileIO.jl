using Documenter
using FileIO

include("populate_registry.jl")

makedocs(
    sitename = "FileIO",
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [FileIO],
    pages = [
        "Home" => "index.md",
        "registry.md",
        "registering.md",
        "implementing.md",
        "world_age_issue.md",
        "reference.md",
    ],
    checkdocs = :exports,
)

deploydocs(
    repo = "github.com/JuliaIO/FileIO.jl.git",
    push_preview = true,
)
