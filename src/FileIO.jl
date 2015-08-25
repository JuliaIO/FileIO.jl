module FileIO

if VERSION < v"0.4.0-dev"
    using Docile, Compat
    immutable Pair{A,B}
        first::A
        second::B
    end
    Base.first(p::Pair) = p.first
    Base.last(p::Pair) = p.second
end

export DataFormat,
       File,
       Formatted,
       Stream,

       @format_str,

       add_format,
       del_format,
       add_loader,
       add_saver,
       filename,
       file_extension,
       info,
       load,
       magic,
       query,
       save,
       skipmagic,
       stream,
       unknown

include("query.jl")
include("loadsave.jl")
include("registry.jl")


@doc """
- `load(filename)` loads the contents of a formatted file, trying to infer
the format from `filename` and/or magic bytes in the file.
- `load(strm)` loads from an `IOStream` or similar object. In this case,
the magic bytes are essential.
- `load(File(format"PNG",filename))` specifies the format directly, and bypasses inference.
- `load(f; options...)` passes keyword arguments on to the loader.
""" ->
function load(s::Union(AbstractString,IO), args...; options...)
    q = query(s)
    check_loader(q)
    load(q, args...; options...)
end

@doc """
- `save(filename, data...)` saves the contents of a formatted file,
trying to infer the format from `filename`.
- `save(Stream(format"PNG",io), data...)` specifies the format directly, and bypasses inference.
- `save(f, data...; options...)` passes keyword arguments on to the saver.
""" ->
function save(s::Union(AbstractString,IO), data...; options...)
    q = query(s)
    check_saver(q)
    save(q, data...; options...)
end

# default load for packages which only define load on streams
load(fn::File, args...; options...) = open(fn) do s
    skipmagic(s)
    load(s, args...; options...)
end

# Fallbacks
load{F}(f::Formatted{F}; options...) = error("No load function defined for format ", F, " with filename ", filename(f))
save{F}(f::Formatted{F}, data...; options...) = error("No save function defined for format ", F, " with filename ", filename(f))


end # module

if VERSION < v"0.4.0-dev"
    using Docile
end

@doc """
`FileIO` API (brief summary, see individual functions for more detail):

- `format"PNG"`: specifies a particular defined format
- `File{fmt}` and `Stream{fmt}`: types of objects that declare that a resource has a particular format `fmt`

- `load([filename|stream])`: read data in formatted file, inferring the format
- `load(File(format"PNG",filename))`: specify the format manually
- `save(filename, data...)` for similar operations involving saving data

- `io = open(f::File, args...)` opens a file
- `io = stream(s::Stream)` returns the IOStream from the query object `s`

- `query([filename|stream])`: attempt to infer the format of `filename`
- `unknown(q)` returns true if a query can't be resolved
- `skipmagic(io, fmt)` sets the position of `io` to just after the magic bytes
- `magic(fmt)` returns the magic bytes for format `fmt`
- `info(fmt)` returns `(magic, extensions)` for format `fmt`

- `add_format(fmt, magic, extension)`: register a new format
- `add_loader(fmt, :Package)`: indicate that `Package` supports loading files of type `fmt`
- `add_saver(fmt, :Package)`: indicate that `Package` supports saving files of type `fmt`
""" -> FileIO
