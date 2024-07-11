# FileIO.jl

FileIO aims to provide a common framework for detecting file formats
and dispatching to appropriate readers/writers.  The two core
functions in this package are called `load` and `save`, and offer
high-level support for formatted files (in contrast with julia's
low-level `read` and `write`).  To avoid name conflicts, packages that
provide support for standard file formats through functions named
`load` and `save` are encouraged to register with FileIO.

## Installation

Install FileIO within Julia via

```julia
using Pkg
Pkg.add("FileIO")
```

## Usage

If your format has been registered, it might be as simple as

```julia
using FileIO
obj = load(filename)
```

to read data from a formatted file. FileIO will attempt to find
an installed package capable of reading `filename`; if no such
package is found, it will suggest an appropriate package for you
to add. It doesn't even have to be a file; you can download the Julia logo
with

```jldoctest
julia> using FileIO, HTTP

julia> img = load(HTTP.URI("https://github.com/JuliaLang/julia-logo-graphics/raw/master/images/julia-logo-color.png"));

julia> typeof(img)
Matrix{RGBA{N0f8}} (alias for Array{ColorTypes.RGBA{FixedPointNumbers.Normed{UInt8, 8}}, 2})
```

Likewise, saving might be as simple as

```julia
save(filename, obj)
```

You can also utilize a piping style to save values to files like this

```julia
obj |> save(filename)
```

If you just want to inspect a file to determine its format, then

```julia
file = query(filename)
s = query(io)   # io is a stream
```

will return a `File` or `Stream` object that also encodes the detected
file format.

Sometimes you want to read or write files that are larger than your available
memory, or might be an unknown or infinite length (e.g. reading an audio or
video stream from a socket). In these cases it might not make sense to process
the whole file at once, but instead process it a chunk at a time. For these
situations FileIO provides the `loadstreaming` and `savestreaming` functions,
which return an object that you can `read` or `write`, rather than the file data
itself.

This would look something like:

```julia
using FileIO
audio = loadstreaming("bigfile.wav")
try
    while !eof(audio)
        chunk = read(audio, 4096) # read 4096 frames
        # process the chunk
    end
finally
    close(audio)
end
```

or use `do` syntax to auto-close the stream:

```julia
using FileIO
loadstreaming("bigfile.wav") do audio
    while !eof(audio)
        chunk = read(audio, 4096) # read 4096 frames
        # process the chunk
    end
end
```

Note that in these cases you may want to use `read!` with a pre-allocated buffer
for maximum efficiency.

## Supported formats

The existing supported formats are summarized in the [Registry table](@ref).

## Supporting new formats

If you want to extend FileIO's support for new formats, there are two separate steps:

- [Registering a new format](@ref) with FileIO
- [Implementing loaders/savers](@ref) in your package

These steps can be done in either order.
