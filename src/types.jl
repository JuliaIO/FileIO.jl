# The core types that represent the file formats

## DataFormat:
"""
`DataFormat{sym}()` indicates a known binary or text format of kind `sym`,
where `sym` is always a symbol. For example, a .csv file might have
`DataFormat{:CSV}()`.

An easy way to write `DataFormat{:CSV}` is `format"CSV"`.
"""
struct DataFormat{sym} end

macro format_str(s)
    :(DataFormat{$(Expr(:quote, Symbol(s)))})
end



abstract type Formatted{F<:DataFormat} end  # A specific file or stream

## File:

"""
`File(fmt, filename)` indicates that `filename` is a file of known
DataFormat `fmt`.  For example, `File{fmtpng}(filename)` would indicate a PNG
file.
"""
struct File{F<:DataFormat} <: Formatted{F}
    filename::String
end
File(fmt::Type{DataFormat{sym}}, filename) where {sym} = File{fmt}(filename)

"""
`filename(file)` returns the filename associated with `File` `file`.
"""
filename(f::File) = f.filename

"""
`file_extension(file)` returns the file extension associated with `File` `file`.
"""
file_extension(f::File) = splitext(filename(f))[2]

## Stream:

"""
`Stream(fmt, io, [filename])` indicates that the stream `io` is
written in known `Format`.  For example, `Stream{PNG}(io)` would
indicate PNG format.  If known, the optional `filename` argument can
be used to improve error messages, etc.
"""
struct Stream{F <: DataFormat, IOtype <: IO} <: Formatted{F}
    io::IOtype
    filename::Union{String, Nothing}
end

Stream(::Type{F}, io::IO) where {F<:DataFormat} = Stream{F,typeof(io)}(io, nothing)
Stream(::Type{F}, io::IO, filename::AbstractString) where {F<:DataFormat} = Stream{F, typeof(io)}(io, String(filename))
Stream(::Type{F}, io::IO, filename) where {F<:DataFormat} = Stream{F, typeof(io)}(io, filename)
Stream(file::File{F}, io::IO) where {F} = Stream{F, typeof(io)}(io, filename(file))

"`stream(s)` returns the stream associated with `Stream` `s`"
stream(s::Stream) = s.io

"""
`filename(stream)` returns a string of the filename
associated with `Stream` `stream`, or nothing if there is no file associated.
"""
filename(s::Stream) = s.filename

"""
`file_extension(file)` returns a nullable-string for the file extension associated with `Stream` `stream`.
"""
function file_extension(f::Stream)
    fname = filename(f)
    (fname == nothing) && return nothing
    splitext(fname)[2]
end

# Note this closes the stream. It's useful when you've opened
# the file to check the magic bytes, but don't want to leave
# a dangling stream.
function file!(strm::Stream{F}) where F
    f = filename(strm)
    f == nothing && error("filename unknown")
    close(strm.io)
    File{F}(f)
end

# Implement standard I/O operations for File and Stream
@inline function Base.open(file::File{F}, args...) where F<:DataFormat
    fn = filename(file)
    Stream(F, open(fn, args...), abspath(fn))
end
Base.close(s::Stream) = close(stream(s))

Base.position(s::Stream) = position(stream(s))
Base.seek(s::Stream, offset::Integer) = (seek(stream(s), offset); s)
Base.seekstart(s::Stream) = (seekstart(stream(s)); s)
Base.seekend(s::Stream) = (seekend(stream(s)); s)
Base.skip(s::Stream, offset::Integer) = (skip(stream(s), offset); s)
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
