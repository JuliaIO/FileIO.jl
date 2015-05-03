immutable Mime
	unique_identifier::Symbol
	ending::Symbol
	magic_number::Vector{Uint8}
	
	const candidates_lookup 	= Dict{Symbol, Vector{Mime}}()
	const magic2mime 			= Dict{Vector{Uint8}, Mime}() # for testing if a magic number is unique
	
	function Mime(unique_identifier, ending, magic_number)
		m 					= new(unique_identifier, ending, magic_number)
		candidate_list 		= get!(candidates_lookup, ending, Mime[])
		mimes_with_no_magic = filter(isempty, map(magicnumber, candidate_list))
		if isempty(magic_number) 
			if !isempty(candidate_list) && !isempty(mimes_with_no_magic)
				error("Ending is not unique and some Mime with the same ending has also no magic number. Conflicting Mime: $(mimes_with_no_magic). Please find some differentiation feature")
			end
			push!(candidate_list, m)
			return m
		end
		if !haskey(magic2mime, magic_number)
			push!(candidate_list, m)
			magic2mime[magic_number] = m
			return m
		end
		mime = magic2mime[magic_number]
		m == mime && return mime # they're the same, which is okay I guess, so we just return the instance we already have.
		# They're different in some attribute, which will result in ambiguities:
		error("You have constructed a mime from a magic number which is not unique. Conflicting Mimes: \n
			$mime\n
			$m\n
		")
	end

	function Mime(io::IO, path::String)
		_, ending 	= splitext(path)
		ending	  	= symbol(lowercase(ending[2:end])) # 2:end => remove dot
		candidates 	= get(candidates_lookup, ending, Mime[])
		isempty(candidates) && return new(ending, ending, b"") # should throw unknown file format?!
		maximum_length = maximum(map(length, map(magicnumber, candidates)))
		maximum_length == 0 && length(candidates) == 1 && return first(candidates)
		magicbuf = zeros(Uint8, maximum_length)
		for i=1:maximum_length
        	eof(io) && break 
        	magicbuf[i] = read(io, Uint8)
    	end
		for candidate in candidates
	        isempty(candidate.magic_number) && continue # doesn't help much to compare empty magic numbers
	        if mem_compare(magicbuf, candidate.magic_number)
	           return candidate # found unique candidate match
	        end
	    end
	    error("Mime not found. Candidates where: $candidates")
	end
end
Mime(f::File) = Mime(open(f), abspath(f))

import Base.(==)
==(a::Mime, b::Mime) = a.unique_identifier == b.unique_identifier && a.ending == b.ending && a.magic_number == b.magic_number
magicnumber(x::Mime) = x.magic_number
function mem_compare(a::Vector{Uint8}, b::Vector{Uint8}) 
	0 == ccall(:memcmp, Int32, (Ptr{Uint8}, Ptr{Uint8}, Int), a, b, min(length(a), length(b))) 
end




# Must be small and leightweight, without any checks. Otherwise, you cannot put down a file path somehwere, create the file at some point, and read it somewhere else
immutable File
	path::UTF8String
end
File(folders...) = File(joinpath(folders...))
macro file_str(path::AbstractString)
	File(path)
end
load(f::File, additions...; options...) 								= load(f, Mime(f), additions...; options...)
save(data, f::File, additions...; mime=defaultmime(data), options...) 	= save(data, f, addition...; mime=mime, options...)

#Registering a file format
const ply_binary = Mime(:ply_binary, :ply, b"ply\nformat binary_little_endian 1.0\n")
const ply_ascii  = Mime(:ply_ascii,  :ply, b"ply\nformat ascii 1.0\n")


@show file"test_ascii.ply"
@show file"test_binary.ply"
@show file"bunny.ply"




