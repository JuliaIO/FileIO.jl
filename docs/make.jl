using Documenter
using FileIO

include("make_docs.jl")

makedocs(
    sitename = "FileIO",
    format = Documenter.HTML(prettyurls = get(ENV, "CI", nothing) == "true"),
    modules = [FileIO],
    pages = [
        "Home" => "index.md",
        "registry.md",
        "registering.md",
        "implementing.md",
        "reference.md",
    ],
)

deploydocs(
    repo = "github.com/JuliaIO/FileIO.jl.git",
    push_preview = true,
)
