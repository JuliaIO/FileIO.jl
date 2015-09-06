using FileIO
using FactCheck

include("query.jl")
include("loadsave.jl")

# make Travis fail when tests fail:
FactCheck.exitstatus()
