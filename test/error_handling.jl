context("Not installed") do
	add_format(format"NotInstalled", (), ".not_installed", [:NotInstalled])
	rs, wr = redirect_stdin()
	ref = @async save("test.not_installed")
	println(wr, "y")
	@fact_throws CompositeException wait(ref) #("unknown package NotInstalled")

	ref = @async save("test.not_installed")
	println(wr, "invalid") #test invalid input
	println(wr, "n") # don't install
	wait(ref)
	@fact istaskdone(ref) --> true
end
