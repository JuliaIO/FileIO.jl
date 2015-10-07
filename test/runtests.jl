eval(Base, :(is_interactive = true)) # for interactive error handling
using FileIO
using FactCheck
facts("FileIO") do
	include("query.jl")
	include("loadsave.jl")
	include("error_handling.jl")
end
# make Travis fail when tests fail:
FactCheck.exitstatus()
