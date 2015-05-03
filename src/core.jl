# Type for file representation
immutable File{Ending}
	abspath::UTF8String
end

# Construct File from path string
function File(file::AbstractString)
	#@assert isfile(file) "file string doesn't refer to a file. Path: $file"

	filepath = abspath(file)
	_, ending = splitext(filepath)

	File{symbol(lowercase(ending[2:end]))}(filepath)
end

# Construct File from several strings
File(folders...) = File(joinpath(folders...))

# Macro for file construction using:
#   file"example.ex"
macro file_str(path::AbstractString)
	File(path)
end

# Functions for File manipulation
ending{Ending}(::File{Ending}) = Ending
abspath(x::File)       		= x.abspath
(==)(a::File, b::File) 		= a.abspath == b.abspath
open(x::File, attribs...)   = open(abspath(x), attribs...)
readbytes(x::File)     		= readbytes(abspath(x))
readall(x::File)       		= readbytes(abspath(x))

# Fallback functions
# Will be executed if read/write is not defined for this kind of file
# or if there is no defined backend
read{Ending}(f::File{Ending}; options...)  = error("no importer defined for file ending $Ending in path $(f.abspath), with options: $options")
write{Ending}(f::File{Ending}; options...) = error("no exporter defined for file ending $Ending in path $(f.abspath), with options: $options")
readformats{T}(backend::Val{T})  = error("Read backend $T not found.")
writeformats{T}(backend::Val{T}) = error("Write backend $T not found.") 

#Can't be defined like this, because it's ambigous with every constructor in the whole world!! -.-
#call{T}(::Type{T}, f::File) = read(f, T)
