# FileIO

[![Build Status](https://travis-ci.org/JuliaIO/FileIO.jl.svg?branch=master)](https://travis-ci.org/JuliaIO/FileIO.jl)
[![Coverage Status](https://coveralls.io/repos/JuliaIO/FileIO.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaIO/FileIO.jl?branch=master)

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

## Help & Quickstart

You can get an API overview by typing `?FileIO` at the REPL prompt.
Individual functions have their own help too, e.g., `?query`.


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
    s = open(f)
    skipmagic(s)  # skip over the magic bytes
    # You can just call the method below...
    load(s)
    # ...or implement everything here instead
end

# You can support streams and add keywords:
function load(s::Stream{format"PNG"}; keywords...)
    # s is already positioned after the magic bytes
    # Do the stuff to read a PNG file
    chunklength = read(s, UInt32)
    ...
end

function save(f::File{format"PNG"}, data)
    s = open(f, "w")
    # Don't forget to write the magic bytes!
    write(s, magic(format"PNG"))
    # Do the rest of the stuff needed to save in PNG format
end
```

## Issues and tricky/interesting cases

**Issues**:
1. Package A and package B can both load format FMT. They both define `FileIO.load(file::File{format"FMT"})`, in which case whichever package gets loaded last "wins."
2. A is better at loading format FMT 80% of the time, but every once in a while A gets partway through the load and realizes it can't handle it. In that case, Package A would like to defer to package B.

**Solution**: A and B should define the non-exported function `load_(file::File{format"FMT"})`, so that users (or A) can call it as `B.load_(file)`. Each package's `load` function should simply call `load_`.

**Issue**:
Package A is a low-level wrapper of some C library, and its `load` function for FMT returns a raw array. Package B sits on top of A and wraps the array in some fancy container. When the user says `load(file)` and `file` has format FMT, which return type should be chosen?

**Solution**: It seems a fair assumption that if B is loaded, users probably want its extra features. However, without B loaded, it seems reasonable to choose A. Consequently, FileIO should register A (the lowest-level package) as the loader for FMT. When users say `using B`, assuming that B has the lines
```
using A, FileIO
function FileIO.load(file::format"FMT")
    obj = A.load_(file)
    BWrapper(obj)
end
```
then B's `load` function, because it will be defined second, will have precedence. 
