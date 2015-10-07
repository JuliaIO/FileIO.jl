context("Not installed") do
	add_format(format"NotInstalled", (), ".not_installed", [:NotInstalled])
	stdin_copy = STDIN
	rs, wr = redirect_stdin()
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
	redirect_stdin(stdin_copy)
	close(rs);close(wr);
end
