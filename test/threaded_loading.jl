@testset "Threaded loading" begin
    if Threads.nthreads() > 1
        pkgid = Base.PkgId(FileIO.idCSVFiles.second, "CSVFiles")
        @assert !Base.root_module_exists(pkgid) "threaded loaidng test requires CSVFiles not loaded"
        # When threaded, loading a new backend should be locked
        # https://github.com/JuliaIO/FileIO.jl/issues/336
        files = map(["data.csv", "file.csv"]) do filename
            joinpath(@__DIR__, "files", filename)
        end
        @test_nowarn Threads.@threads for file in files
            load(file)
        end
    end
end
