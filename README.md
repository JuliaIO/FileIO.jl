# FileIO

[![Build Status](https://travis-ci.org/JuliaIO/FileIO.jl.svg?branch=master)](https://travis-ci.org/JuliaIO/FileIO.jl)

FileIO aims to provide a common framework for detecting file formats
and dispatching to appropriate readers/writers.  The two core
functions in this package are called `load` and `save`, and offer
high-level support for formatted files (in contrast with julia's
low-level `read` and `write`).  To avoid name conflicts, packages that
provide support for standard file formats through functions named
`load` and `save` are encouraged to extend the definitions here.

## Installation

All Packages in JuliaIO are not registered yet. Please add via `Pkg.clone("git-url").

## Usage

If your format has been registered, it might be as simple as
```jl
using FileIO
obj = load(filename)
```
to read data from a formatted file.  Likewise, saving might be as simple as
```
save(filename, obj)
```

If you just want to inspect a file to determine its format, then
```jl
file = query(filename)
s = query(io)   # io is a stream
```
will return a `File` or `Stream` object that also encodes the detected
file format.

## Adding new formats

You register a new format by calling `add_format(fmt, magic,
extension)`.  `fmt` is a `DataFormat` type, most conveniently created
as `format"IDENTIFIER"`.  `magic` typically contains the magic bytes
that identify the format.  Here are some examples:

```jl
# A straightforward format
add_format(format"PNG", [0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a], ".png")

# A format that uses only ASCII characters in its magic bytes, and can
# have one of two possible file extensions
add_format(format"NRRD", "NRRD", [".nrrd",".nhdr"])

# A format whose magic bytes might not be at the beginning of the file,
# necessitating a custom function `detecthdf5` to find them
add_format(format"HDF5", detecthdf5, [".h5", ".hdf5"])

# A fictitious format that, unfortunately, provides no magic
# bytes. Here we have to place our faith in the file extension.
add_format(format"DICEY", (), ".dcy")
```

You can also declare that certain formats require certain packages for
I/O support:

```jl
add_loader(format"HDF5", :HDF5)
add_saver(format"PNG", :ImageMagick)
```
These packages will be automatically loaded as needed.

Users are encouraged to contribute these definitions to the
`registry.jl` file of this package, so that information about file
formats exists in a centralized location.

## Implementing loaders/savers

In your package, write code like the following:

```jl
using FileIO

function load(f::File{format"PNG"})
    io = open(f)
    skipmagic(io, f)  # skip over the magic bytes
    # Now do all the stuff you need to read a PNG file
end

# You can support streams and add keywords:
function load(s::Stream{format"PNG"}; keywords...)
    io = stream(s)  # io is positioned after the magic bytes
    # Do the stuff to read a PNG file
end

function save(f::File{format"PNG"}, data)
    io = open(f, "w")
    # Don't forget to write the magic bytes!
    write(io, magic(format"PNG"))
    # Do the rest of the stuff needed to save in PNG format
end
```

## Help

You can get an API overview by typing `?FileIO` at the REPL prompt.
Individual functions have their own help too, e.g., `?add_format`.
