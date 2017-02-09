using FileIO
using Base.Test

@testset "FileIO" begin
    include("query.jl")
    include("loadsave.jl")
    include("error_handling.jl")
end
