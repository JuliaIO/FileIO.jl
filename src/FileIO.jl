module FileIO
import Base: read, write 
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

read{Ending}(f::File{Ending}; options...)  = error("no importer defined for file ending $T in path $(f.abspath), with options: $options")
write{Ending}(f::File{Ending}; options...) = error("no exporter defined for file ending $T in path $(f.abspath), with options: $options")

importall MeshIO
importall ImageIO


end # module
