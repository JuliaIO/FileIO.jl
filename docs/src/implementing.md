# Implementing loaders/savers

## Principle of operation: module qualification

When FileIO detects that a file or stream should be handled by a particular package, it will try to call *private* methods in that package for processing the request.
For example, suppose you have created a package called `MyFileFormat` to handle files of a particular format; then `load("somefile.myfmt")` for a suitable file will cause FileIO to:

- attempt to load your package `MyFileFormat` using `Base.require(id::PkgId)`, where a `PkgId` combines the name and `UUID` that you supplied via `add_format`
- call `MyFileFormat.load(file)` where `file` is [`File`](@ref).

A crucial point is that **`MyFileFormat.load` does not extend `FileIO.load`: it is a private function defined in module `MyFileFormat`**. This is important for ensuring that single formats can be supported by multiple packages; if two or more packages specialized `File.load` for `file::File{format"MYFORMAT"})`, then

```julia
using Pkg1, Pkg2   # two packages both inappropriately extending FileIO.load
```

would cause all such loads to be handled by `Pkg2`, but

```julia
using Pkg2, Pkg1
```

would cause them to be handled by `Pkg1`.
This would make loading incredibly brittle.
For that reason, it is essential to keep `load` private to your package and let FileIO call it by module-qualification.

The same applies to `save`, `loadstreaming`, and `savestreaming`.

If you run into a naming conflict with the `load` and `save` functions
(for example, you already have another function in your package that has
one of these names), you can instead name your loaders `fileio_load`,
`fileio_save` etc. Note that you cannot mix and match these styles: either
all your loaders have to be named `load`, or all of them should be called
`fileio_load`, but you cannot use both conventions in one module.

## All-at-once I/O: implementing `load` and `save`

In your package, write code like the following:

```julia
module MyFileFormat

using FileIO

# Again, this is a *private* `load` function, do not extend `FileIO.load`!
function load(f::File{format"PNG"})
    open(f) do s
        skipmagic(s)  # skip over the magic bytes
        # You can just call the `load(::Stream)` method below...
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

end # module MyFileFormat
```

`load(::File)` and `save(::File)` should close any streams
they open.  (If you use the `do` syntax, this happens for you
automatically even if the code inside the `do` scope throws an error.)
Conversely, `load(::Stream)` and `save(::Stream)` should not close the
stream argument.

## Implementing streaming I/O

`loadstreaming` and `savestreaming` use the same query mechanism, but return a
decoded stream that users can `read` or `write`. You should also implement a
`close` method on your reader or writer type. Just like with `load` and `save`,
if the user provided a filename, your `close` method should be responsible for
closing any streams you opened in order to read or write the file. If you are
given a `Stream`, your `close` method should only do the clean up for your
reader or writer type, not close the stream.

```julia
struct WAVReader
    io::IO
    ownstream::Bool
end

function Base.read(reader::WAVReader, frames::Int)
    # read and decode audio samples from reader.io
end

function Base.close(reader::WAVReader)
    # do whatever cleanup the reader needs
    reader.ownstream && close(reader.io)
end

# FileIO has fallback functions that make these work using `do` syntax as well,
# and will automatically call `close` on the returned object.
loadstreaming(f::File{format"WAV"}) = WAVReader(open(f), true)
loadstreaming(s::Stream{format"WAV"}) = WAVReader(s, false)
```

If you choose to implement `loadstreaming` and `savestreaming` in your package,
you can easily add `save` and `load` methods in the form of:

```julia
function save(q::Formatted{format"WAV"}, data, args...; kwargs...)
    savestreaming(q, args...; kwargs...) do stream
        write(stream, data)
    end
end

function load(q::Formatted{format"WAV"}, args...; kwargs...)
    loadstreaming(q, args...; kwargs...) do stream
        read(stream)
    end
end
```

where `Formatted` is the abstract supertype of `File` and `Stream`.
