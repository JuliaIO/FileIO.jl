println("these tests will print warnings: ")

@testset "Not installed" begin
    add_format(format"NotInstalled", (), ".not_installed", [:NotInstalled])
    @test_throws ArgumentError save("test.not_installed", nothing)

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
add_format(format"BROKEN", (), ".brok", [:BrokenIO])

@testset "Absent implementation" begin
    stderr_copy = stderr
    rserr, wrerr = redirect_stderr()
    @test_throws FileIO.LoaderError load(Stream(format"BROKEN",stdin))
    @test_throws FileIO.WriterError save(Stream(format"BROKEN",stdout), nothing)
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
        [:MultiError1],
        [:MultiError2]
    )
    ret = @test_throws ErrorException load("test.multierr")
    #@test ret.value.msg == "1" # this is 0.5 only
end
