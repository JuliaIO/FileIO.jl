# "Public" types that represent the file formats. These are used
# to communicate results externally, but are generally avoided for
# internal operations because they trigger excessive specialization
# and inference failures.

## DataFormat:
"""
    DataFormat{sym}()

Indicates a known binary or text format of kind `sym`, where `sym`
is always a symbol. For example, a .csv file might have `DataFormat{:CSV}()`.

An easy way to write `DataFormat{:CSV}` is `format"CSV"`.
"""
struct DataFormat{sym} end

macro format_str(s)
    :(DataFormat{$(Expr(:quote, Symbol(s)))})
end

formatname(::Type{DataFormat{sym}}) where sym = sym


abstract type Formatted{F<:DataFormat} end  # A specific file or stream

formatname(::Formatted{F}) where F<:DataFormat = formatname(F)

## File:

"""
    File{fmt}(filename)

Indicates that `filename` is a file of known [`DataFormat`](@ref) `fmt`.
For example, `File{format"PNG"}(filename)` would indicate a PNG file.

!!! compat
    `File{fmt}(filename)` requires FileIO 1.6 or higher. The deprecated syntax `File(fmt, filename)` works
    on all FileIO 1.x releases.
"""
struct File{F<:DataFormat, Name} <: Formatted{F}
    filename::Name
end
File{F}(file::File{F}) where F<:DataFormat = file
File{DataFormat{sym}}(@nospecialize(file::Formatted)) where sym = throw(ArgumentError("cannot change the format of $file to $sym"))
File{F}(file::AbstractString) where F<:DataFormat = File{F,String}(String(file)) # canonicalize to limit type-diversity
File{F}(file) where F<:DataFormat = File{F,typeof(file)}(file)

# The docs are separated from the definition because of https://github.com/JuliaLang/julia/issues/34122
filename(@nospecialize(f::File)) = f.filename
"""
    filename(file)

Returns the filename associated with [`File`](@ref) `file`.
"""
filename(::File)

file_extension(@nospecialize(f::File)) = splitext(filename(f))[2]
"""
    file_extension(file)

Returns the file extension associated with [`File`](@ref) `file`.
"""
file_extension(::File)

## Stream:

"""
    Stream{fmt}(io, filename=nothing)

Indicates that the stream `io` is written in known format [`DataFormat`](@ref)
`fmt`. For example, `Stream{format"PNG"}(io)` would indicate PNG format.
If known, the optional `filename` argument can
be used to improve error messages, etc.

!!! compat
    `Stream{fmt}(io, ...)` requires FileIO 1.6 or higher.
    The deprecated syntax `Stream(fmt, io, ...)` works on all FileIO 1.x releases.
"""
struct Stream{F <: DataFormat, IOtype <: IO, Name} <: Formatted{F}
    io::IOtype
    filename::Name
end

Stream{F,IOtype}(io::IO, filename::AbstractString) where {F<:DataFormat,IOtype} = Stream{F, IOtype, String}(io, String(filename))
Stream{F,IOtype}(io::IO, filename)                 where {F<:DataFormat,IOtype} = Stream{F, IOtype, typeof(filename)}(io, filename)
Stream{F,IOtype}(io::IO)                           where {F<:DataFormat,IOtype} = Stream{F, IOtype}(io, nothing)

Stream{F,IOtype}(file::Formatted{F}, io::IO) where {F<:DataFormat,IOtype} = Stream{F,IOtype}(io, filename(file))
Stream{F,IOtype}(@nospecialize(file::Formatted), io::IO) where {F<:DataFormat,IOtype} =
    throw(ArgumentError("cannot change the format of $file to $(formatname(F)::Symbol)"))

Stream{F}(io::IO, args...) where {F<:DataFormat} = Stream{F, typeof(io)}(io, args...)
Stream{F}(file::File, io::IO) where {F<:DataFormat} = Stream{F, typeof(io)}(file, io)
Stream(file::File{F}, io::IO) where {F<:DataFormat} = Stream{F}(io, filename(file))

stream(@nospecialize(s::Stream)) = s.io
"""
    stream(s)

Returns the stream associated with [`Stream`](@ref) `s`.
"""
stream(::Stream)

filename(@nospecialize(s::Stream)) = s.filename
"""
    filename(stream)

Returns a string of the filename associated with [`Stream`](@ref) `stream`,
or nothing if there is no file associated.
"""
filename(::Stream)

function file_extension(@nospecialize(f::Stream))
    fname = filename(f)
    (fname === nothing) && return nothing
    splitext(fname)[2]
end
"""
    file_extension(file)

Returns a nullable-string for the file extension associated with [`Stream`](@ref) `stream`.
"""
file_extension(::Stream)

# Note this closes the stream. It's useful when you've opened
# the file to check the magic bytes, but don't want to leave
# a dangling stream.
function file!(strm::Stream{F}) where F
    f = filename(strm)
    f === nothing && error("filename unknown")
    close(strm.io)
    File{F}(f)
end

# Implement standard I/O operations for File and Stream
@inline function Base.open(@nospecialize(file::File{F}), @nospecialize(args...)) where F<:DataFormat
    fn = filename(file)
    Stream{F}(open(fn, args...), abspath(fn))
end
Base.close(@nospecialize(s::Stream)) = close(stream(s))

Base.position(@nospecialize(s::Stream)) = position(stream(s))
Base.seek(@nospecialize(s::Stream), offset::Integer) = (seek(stream(s), offset); s)
Base.seekstart(@nospecialize(s::Stream)) = (seekstart(stream(s)); s)
Base.seekend(@nospecialize(s::Stream)) = (seekend(stream(s)); s)
Base.skip(@nospecialize(s::Stream), offset::Integer) = (skip(stream(s), offset); s)
Base.eof(s::Stream) = eof(stream(s))

@inline Base.read(s::Stream, args...)  = read(stream(s), args...)
Base.read!(s::Stream, array::Array) = read!(stream(s), array)
@inline Base.write(s::Stream, args...) = write(stream(s), args...)
# Note: we can't sensibly support the all keyword. If you need that,
# call read(stream(s), ...; all=value) manually
Base.readbytes!(s::Stream, b) = readbytes!(stream(s), b)
Base.readbytes!(s::Stream, b, nb) = readbytes!(stream(s), b, nb)
Base.read(s::Stream) = read(stream(s))
Base.read(s::Stream, nb) = read(stream(s), nb)
Base.flush(s::Stream) = flush(stream(s))

Base.isreadonly(s::Stream) = isreadonly(stream(s))
Base.isopen(s::Stream) = isopen(stream(s))
