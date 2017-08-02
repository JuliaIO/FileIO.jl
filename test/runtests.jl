using FileIO
using Base.Test

immutable MimeSaveTestType
end

@testset "FileIO" begin
    include("query.jl")
    include("loadsave.jl")
    include("error_handling.jl")
    include("test_mimesave.jl")
end
