using FileIO
if VERSION >= v"0.5.0-dev+7720"
    using Base.Test
else
    using BaseTestNext
    const Test = BaseTestNext
end
@testset "FileIO" begin
	include("query.jl")
	include("loadsave.jl")
	include("error_handling.jl")
end

# make Travis fail when tests fail:
