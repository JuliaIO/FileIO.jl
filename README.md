# FileIO

[![Build Status](https://travis-ci.org/JuliaIO/FileIO.jl.svg?branch=master)](https://travis-ci.org/JuliaIO/FileIO.jl)
[![Build status](https://ci.appveyor.com/api/projects/status/j02repoyo75mtyjn/branch/master?svg=true)](https://ci.appveyor.com/project/SimonDanisch/fileio-jl-t5dw5/branch/master)
[![Coverage Status](https://coveralls.io/repos/JuliaIO/FileIO.jl/badge.svg?branch=master&service=github)](https://coveralls.io/github/JuliaIO/FileIO.jl?branch=master)

FileIO aims to provide a common framework for detecting file formats
and dispatching to appropriate readers/writers.  The two core
functions in this package are called `load` and `save`, and offer
high-level support for formatted files (in contrast with julia's
low-level `read` and `write`).  To avoid name conflicts, packages that
provide support for standard file formats through functions named
`load` and `save` are encouraged to extend the definitions here.
[Supported Files](docs/registry.md)

## Installation

Install FileIO via `Pkg.add("FileIO")`.

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

You register a new format by adding `add_format(fmt, magic,
extension)` to the [registry](https://github.com/JuliaIO/FileIO.jl/blob/master/src/registry.jl). To do so, please just open a pull request (you can just edit the file in Github).
`fmt` is a `DataFormat` type, most conveniently created
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
You can also define the loaders and savers in a short form like this:
```jl
add_format(format"OFF", "OFF", ".off", [:MeshIO])
```
This means MeshIO supports loading and saving of the `off` format.
You can add multiple loaders and specifiers like this:
```jl
add_format(
    format"BMP",
    UInt8[0x42,0x4d],
    ".bmp",
    [:OSXNativeIO, LOAD, OSX],
    [:ImageMagick]
)
```
This means, OSXNative has first priority (gets loaded first) and only supports loading `bmp` on `OSX`.
So on windows, `OSXNativeIO` will be ignored and `ImageMagick` has first priority.
You can add any combination of `LOAD`, `SAVE`, `OSX`, `Unix`, `Windows` and `Linux`.

Users are encouraged to contribute these definitions to the
`registry.jl` file of this package, so that information about file
formats exists in a centralized location.

Handling MIME outputs is similar, except that one also provides the
type of the object to be written:
```jl
mimewritable(::MIME"image/png", img::AbstractArray) = ndims(img) == 2
add_mime(MIME("image/png"), AbstractArray, :ImageMagick)
```

In cases where the type is defined in Base julia, such declarations
can by included in FileIO's `registry` file.  In contrast, when the
type is defined in a package, that package should call them. Note that
`add_mime` should be called from the package's `__init__` function.

## Implementing loaders/savers

In your package, write code like the following:

```jl
using FileIO

function load(f::File{format"PNG"})
    open(f) do s
        skipmagic(s)  # skip over the magic bytes
        # You can just call the method below...
        ret = load(s)
        # ...or implement everything here instead
    end
end

# You can support streams and add keywords:
function load(s::Stream{format"PNG"}; keywords...)
    # s is already positioned after the magic bytes
    # Do the stuff to read a PNG file
    chunklength = read(s, UInt32)
    ...
end

function save(f::File{format"PNG"}, data)
    open(f, "w") do s
        # Don't forget to write the magic bytes!
        write(s, magic(format"PNG"))
        # Do the rest of the stuff needed to save in PNG format
    end
end
```

Note that `load(::File)` and `save(::File)` should close any streams
they open.  (If you use the `do` syntax, this happens for you
automatically even if the code inside the `do` scope throws an error.)
Conversely, `load(::Stream)` and `save(::Stream)` should not close the
input stream.

For MIME output, you would implement a method like this:
```jl
function Base.writemime(s::Stream{format"ImageMagick"}, ::MIME"image/png", x)
    io = stream(s)
    # Do the stuff needed to create the output
end
```

It's perfectly acceptable to also create a `Base.writemime(s::IO,
::MIME"image/png", x)` method.  Such methods will generally take
precedence over FileIO's generic fallback `writemime` function, and
therefore in some cases might improve performance.

## Help

You can get an API overview by typing `?FileIO` at the REPL prompt.
Individual functions have their own help too, e.g., `?add_format`.
