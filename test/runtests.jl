using FileIO
using FactCheck

include("fileio_packages.jl")

include("query.jl")
include("loadsave.jl")

# make Travis fail when tests fail:
FactCheck.exitstatus()
