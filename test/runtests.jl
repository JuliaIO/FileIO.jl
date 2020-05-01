using FileIO
using FilePathsBase
using Test

# Both FileIO and FilePathsBase export filename, but we only want the FileIO definition.
using FileIO: filename

struct MimeSaveTestType
end

@testset "FileIO" begin
    include("query.jl")
    include("loadsave.jl")
    include("error_handling.jl")
    include("test_mimesave.jl")
end
