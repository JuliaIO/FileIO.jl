module FileIO
import Base: read
import Base: write
import Base: (==)
import Base: open
import Base: abspath
import Base: readbytes
import Base: readall
# package code goes here


immutable File{Ending}
	abspath::UTF8String
end

function File(file)
	@assert !isdir(file) "file string refers to a path, not a file. Path: $file"
	file 	= abspath(file)
	path 	= dirname(file)
	name 	= file[length(path):end]
	ending 	= rsearch(name, ".")
	ending  = isempty(ending) ? "" : name[first(ending)+1:end]
	File{symbol(ending)}(file)
end
macro file_str(path::AbstractString)
	File(path)
end
File(folders...) = File(joinpath(folders...))
ending{Ending}(::File{Ending}) = Ending
(==)(a::File, b::File) = a.abspath == b.abspath
open(x::File)       = open(abspath(x))
abspath(x::File)    = x.abspath
readbytes(x::File)  = readbytes(abspath(x))
readall(x::File)    = readbytes(abspath(x))

read{Ending}(f::File{Ending}; options...)  = error("no importer defined for file ending $T in path $(f.abspath), with options: $options")
write{Ending}(f::File{Ending}; options...) = error("no exporter defined for file ending $T in path $(f.abspath), with options: $options")


export ending
export File
export @file_str

end # module
