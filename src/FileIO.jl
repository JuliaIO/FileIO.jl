VERSION >= v"0.4.0-dev+6641" && __precompile__()

module FileIO
using Compat

if VERSION < v"0.4.0-dev"
    using Docile
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
       add_mime,
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
function load(s::@compat(Union{AbstractString,IO}), args...; options...)
    q = query(s)
    libraries = applicable_loaders(q)
    last_exception = ErrorException("No library available to load $s")
    for library in libraries
        try
            Library = check_loader(library)
            return Library.load(q, args...; options...)
        catch e
            last_exception = e
        end
    end
    rethrow(last_exception)
end

@doc """
- `save(filename, data...)` saves the contents of a formatted file,
trying to infer the format from `filename`.
- `save(Stream(format"PNG",io), data...)` specifies the format directly, and bypasses inference.
- `save(f, data...; options...)` passes keyword arguments on to the saver.
""" ->
function save(s::@compat(Union{AbstractString,IO}), data...; options...)
    q = query(s)
    libraries = applicable_savers(q)
    last_exception = ErrorException("No library available to save $s")
    for library in libraries
        try
            Library = check_saver(library)
            return Library.save(q, data...; options...)
        catch e
            last_exception = e #TODO, better and standardized exception propagation system
        end
    end
    rethrow(last_exception)
end

# Forced format
function save{sym}(::Type{DataFormat{sym}}, f::AbstractString, data...; options...)
    libraries = sym2saver[sym]
    check_saver(libraries[1])
    save(File(DataFormat{sym}, f), data...; options...)
end

function save{sym}(::Type{DataFormat{sym}}, s::IO, data...; options...)
    libraries = sym2saver[sym]
    check_saver(libraries[1])
    save(Stream(DataFormat{sym}, s), data...; options...)
end

function Base.writemime(io::IO, mime::MIME, x)
    handlers = applicable_mime(mime)
    last_exception = ErrorException("No package available to writemime $mime")
    for (T,pkg) in handlers
        isa(x, T) || continue
        try
            check_mime(pkg)
            return writemime(Stream(DataFormat{pkg}, io), mime, x)
        catch e
            last_exception = e
        end
    end
    rethrow(last_exception)
end

# Fallbacks
load{F}(f::Formatted{F}, args...; options...) = error("No load function defined for format ", F, " with filename ", filename(f))
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
