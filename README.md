# FileIO

[![Build Status](https://travis-ci.org/SimonDanisch/FileIO.jl.svg?branch=master)](https://travis-ci.org/SimonDanisch/FileIO.jl)

Meta package for FileIO. 
It follows the following principle:
FileIO defines the abstract interface for reading a file:
```Julia
immutable File{Ending}
	abspath::UTF8String
end

macro file_str(path::AbstractString)
	File(path)
end
read{Ending}(f::File{Ending}; options...)  = error("no importer defined for file ending $T in path $(f.abspath), with options: $options")
write{Ending}(f::File{Ending}; options...) = error("no exporter defined for file ending $T in path $(f.abspath), with options: $options")
```
It includes all domain specific IO packages, e.g. ImageIO.
ImageIO defines the type system for the files, and includes all libraries, which can read/write the specific files.
Preferable via Mike Innes [Requires](https://github.com/one-more-minute/Requires.jl) package, so that it doesn't introduce extra load time if not needed.
All the low level IO packages, that do the actual reading, should define the read/write methods, for the file ending they support. 
