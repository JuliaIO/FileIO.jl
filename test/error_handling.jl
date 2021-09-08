println("these tests will print warnings: ")

module PathError
    import FileIO: File, @format_str
    save(file::File{format"PATHERROR"}, data) = nothing
    load(file::File{format"PATHERROR"}) = nothing
end
add_format(format"PATHERROR", (), ".patherror", [PathError])

@testset "Path errors" begin
    # handling a nonexistent parent directory, during save
    temp_dir = joinpath(mktempdir(), "dir_that_did_not_exist")
    @assert !isdir(temp_dir) "Testing error. This dir shouldn't exist"
    fn = joinpath(temp_dir, "file.patherror")
    save(fn, "test content")
    @test isdir(temp_dir)

    # handling a filepath that's an existing directory, during save
    @test_throws ArgumentError save(format"PATHERROR", mktempdir(), "test content")

    # handling a nonexistent filepath, during load
    @test_throws ArgumentError load(joinpath(mktempdir(), "dummy.patherror"))
end

@testset "Not installed" begin
    # The logging part of this test only works when running under Pkg.test (TODO: fix this)
    @test_logs (:warn, r"supply `pkg` as a Module or `name=>uuid`") @test_throws(ArgumentError, add_format(format"NotInstalled", (), ".not_installed", [:NotInstalled]))
    # Give it a fake UUID
    add_format(format"NotInstalled", (), ".not_installed", [:NotInstalled=>UUID("79e393ae-7a7b-11eb-1530-bf4d98024096")])
    @test_throws CapturedException save("test.not_installed", nothing)

    # Core.eval(Base, :(is_interactive = true)) # for interactive error handling
    # add_format(format"NotInstalled", (), ".not_installed", [:NotInstalled])
    # stdin_copy = stdin
    # stderr_copy = stderr
    # rs, wr = redirect_stdin()
    # rserr, wrerr = redirect_stderr()
    # ref = @async save("test.not_installed", nothing)
    # println(wr, "y")
    # @test_throws ArgumentError fetch(ref) #("unknown package NotInstalled")
    # ref = @async save("test.not_installed", nothing)
    # println(wr, "invalid") #test invalid input
    # println(wr, "n") # don't install
    # fetch(ref)
    # @test istaskdone(ref)

    # close(rs);close(wr);close(rserr);close(wrerr)
    # redirect_stdin(stdin_copy)
    # redirect_stderr(stderr_copy)

    # Core.eval(Base, :(is_interactive = false)) # for interactive error handling

end


# Missing load/save functions
module BrokenIO
    using FileIO
end
add_format(format"BROKEN", (), ".brok", [BrokenIO])

@testset "Absent implementation" begin
    stderr_copy = stderr
    rserr, wrerr = redirect_stderr()
    ex = try load(Stream{format"BROKEN"}(stdin)) catch e e end
    @test isa(ex, CapturedException)
    @test isa(ex.ex, FileIO.LoaderError)
    @test isa(ex.ex.ex, FileIO.SpecError)
    ex = try save(Stream{format"BROKEN"}(stdout), nothing) catch e e end
    @test isa(ex, CapturedException)
    @test isa(ex.ex, FileIO.WriterError)
    @test isa(ex.ex.ex, FileIO.SpecError)
    redirect_stderr(stderr_copy)
    close(rserr);close(wrerr)
end

module BrokenIO2
    using FileIO
    function save(f::File{format"BROKEN2"}, data)
        error("whoops")
    end
end
add_format(format"BROKEN2", (), ".brok2", [BrokenIO2])

@testset "Broken implementation/limit" begin
    io = IOBuffer()
    stderr_copy = stderr
    rserr, wrerr = redirect_stderr()
    ex = try save(Stream{format"BROKEN2"}(stdout), [1:1000;]) catch e e end
    @test isa(ex, CapturedException)
    @test isa(ex.ex, MethodError)
    showerror(io, ex)
    str = String(take!(io))
    @test startswith(str, "MethodError: no method matching save(::Stream{DataFormat{:BROKEN2}")
    exw = FileIO.WriterError("BrokenIO2", "a message", ex.ex)
    showerror(io, exw)
    str = String(take!(io))
    @test startswith(str, "BrokenIO2 writer error: a message\n  due to MethodError(")
    @test !occursin("499", str)   # printing should be with `:limit`
    @test  occursin("…", str)     # printing should be with `:limit`
    ex = try save(File{format"BROKEN2"}(tempname()), [1:1000;]) catch e e end
    @test isa(ex, CapturedException)
    @test ex.ex == ErrorException("whoops")
    showerror(io, ex)
    str = String(take!(io))
    @test !occursin("499", str)   # printing should be with `:limit`
    redirect_stderr(stderr_copy)
    close(rserr);close(wrerr)
end

module MultiError1
    import FileIO: @format_str, File
    load(file::File{format"MultiError"}) = error("1")
end
module MultiError2
    import FileIO: @format_str, File, magic
    load(file::File{format"MultiError"}) = error("2")
end
@testset "multiple errors" begin
    println("this test will print warnings: ")
    add_format(
        format"MultiError",
        (),
        ".multierr",
        [MultiError1],
        [MultiError2]
    )
    tmpfile = joinpath(mktempdir(), "test.multierr")
    open(tmpfile, "w") do io
        println(io, "dummy content")
    end
    ex = try load(tmpfile) catch e e end
    @test isa(ex, CapturedException)
    @test isa(ex.ex, ErrorException)
    rm(dirname(tmpfile), recursive=true)
end

@testset "stacktrace trimming" begin
    sfs = try
        error("whoops")
    catch err
        stacktrace(catch_backtrace())
    end
    n = length(sfs)
    FileIO.trim!(sfs)
    @test length(sfs) < 5 < n
end

module BustedME
using FileIO
load(file, args...) = foo()
add_format(format"BUSTEDME", "BUSTEDME", ".bus", [BustedME])
end
@testset "error accuracy" begin
    tmpfile = joinpath(mktempdir(), "test.bus")
    open(tmpfile, "w") do io
        write(io, magic(format"BUSTEDME"))
        println(io, "dummy content")
    end
    ex = try load(tmpfile) catch e e end
    @test isa(ex, CapturedException)
    @test isa(ex.ex, UndefVarError)
    rm(dirname(tmpfile), recursive=true)
end
