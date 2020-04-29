using FileIO
using FilePathsBase
using Test

# Because both FileIO and FilePathsBase export filename, but for our tests we only want the
# FileIO definition.
filename(x) = FileIO.filename(x)

struct MimeSaveTestType
end

@testset "FileIO" begin
    include("query.jl")
    include("loadsave.jl")
    include("error_handling.jl")
    include("test_mimesave.jl")
end
