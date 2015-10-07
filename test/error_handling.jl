context("Not installed") do
	add_format(format"NotInstalled", (), ".not_installed", [:NotInstalled])
	rs, wr = redirect_stdin()
	ref = @async save("test.not_installed")
	println(wr, "y")
	if VERSION < v"0.4.0-dev"
		try
			wait(ref) #("unknown package NotInstalled")
		catch e
			println(e)
			@fact isa(e, ErrorException) --> true
		end
	else
		@fact_throws CompositeException wait(ref) #("unknown package NotInstalled")
	end
	ref = @async save("test.not_installed")
	println(wr, "invalid") #test invalid input
	println(wr, "n") # don't install
	wait(ref)
	@fact istaskdone(ref) --> true
end
