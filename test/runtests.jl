using FileIO
using FilePathsBase
using Test
using UUIDs

Threads.nthreads() <= 1 && @info "Threads.nthreads() = $(Threads.nthreads()), multithread tests will be disabled"

# Both FileIO and FilePathsBase export filename, but we only want the FileIO definition.
using FileIO: filename

struct MimeSaveTestType
end

@testset "FileIO" begin
    # This threaded test should be put before `CSVFiles` is loaded
    if VERSION >= v"1.3"
        # FIXME: threaded file io is still somehow broken in old Julia versions
        include("threaded_loading.jl")
    end

    include("query.jl")
    include("loadsave.jl")
    include("error_handling.jl")
    include("test_mimesave.jl")
    include("integration.jl")
end
