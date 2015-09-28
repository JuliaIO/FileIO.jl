Base.writemime(s::Stream{format"FileIO"}, ::MIME"test/floatvector", v::Vector{Float32}) = print(stream(s), v)
context("writemime") do 
	add_mime(MIME("test/floatvector"), Vector{Float32}, :FileIO)
	io = IOBuffer()
	t = rand(Float32, 88)
	writemime(io, MIME("test/floatvector"), t)
	@fact takebuf_string(io) --> string(t)
	close(io)
end
