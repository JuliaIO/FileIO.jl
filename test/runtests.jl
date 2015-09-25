using FileIO
using FactCheck

facts("FileIO") do
	include("query.jl")
	include("loadsave.jl")
end
# make Travis fail when tests fail:
FactCheck.exitstatus()
