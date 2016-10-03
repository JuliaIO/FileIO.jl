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
