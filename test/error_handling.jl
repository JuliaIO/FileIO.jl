println("these tests will print warnings: ")
context("Not installed") do
    eval(Base, :(is_interactive = true)) # for interactive error handling

    add_format(format"NotInstalled", (), ".not_installed", [:NotInstalled])
    stdin_copy = STDIN
    stderr_copy = STDERR
    rs, wr = redirect_stdin()
    rserr, wrerr = redirect_stderr()
    ref = @async save("test.not_installed")
    println(wr, "y")
    if VERSION < v"0.4.0-dev"
        @fact_throws ErrorException wait(ref) #("unknown package NotInstalled")
    else
        @fact_throws CompositeException wait(ref) #("unknown package NotInstalled")
    end
    ref = @async save("test.not_installed")
    println(wr, "invalid") #test invalid input
    println(wr, "n") # don't install
    wait(ref)
    @fact istaskdone(ref) --> true

    close(rs);close(wr);close(rserr);close(wrerr)
    redirect_stdin(stdin_copy)
    redirect_stderr(stderr_copy)

    eval(Base, :(is_interactive = false)) # for interactive error handling

end


# Missing load/save functions
module BrokenIO
using FileIO
end
add_format(format"BROKEN", (), ".brok", [:BrokenIO])

context("Absent implementation") do
    stderr_copy = STDERR
    rserr, wrerr = redirect_stderr()
    @fact_throws FileIO.LoaderError load(Stream(format"BROKEN", STDIN))
    @fact_throws FileIO.WriterError save(Stream(format"BROKEN", STDOUT))
    redirect_stderr(stderr_copy)
end

module MultiError1
import FileIO: @format_str, File
load(file::File{format"MultiError"}) = error("1")
end
module MultiError2
import FileIO: @format_str, File, magic
load(file::File{format"MultiError"}) = error("2")
end
context("multiple errors") do
    println("this test will print warnings: ")
    add_format(
        format"MultiError",
        (),
        ".multierr",
        [:MultiError1],
        [:MultiError2]
    )
    ret = @test_throws ErrorException load("test.multierr")
    @test ret.value.msg == "1"
end
