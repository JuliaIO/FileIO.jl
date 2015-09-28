using FileIO
using FactCheck

facts("FileIO") do
	include("query.jl")
	include("loadsave.jl")
	include("writemime.jl")
end
# make Travis fail when tests fail:
FactCheck.exitstatus()
