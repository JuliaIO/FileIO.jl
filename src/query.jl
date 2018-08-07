### Format registry infrastructure
abstract type OS end
abstract type Unix <: OS end
struct Windows <: OS end
struct OSX <: Unix end
struct Linux <: Unix end

struct LOAD end
struct SAVE end

split_predicates(list) = filter(x-> x <: OS, list), filter(x-> !(x <: OS), list)
applies_to_os(os::Vector) = isempty(os) || any(applies_to_os, os)
applies_to_os(os::Type{O}) where {O <: OS} = false

applies_to_os(os::Type{U}) where {U <: Unix} = Sys.isunix()
applies_to_os(os::Type{Windows}) = Sys.iswindows()
applies_to_os(os::Type{OSX}) = Sys.isapple()
applies_to_os(os::Type{Linux}) = Sys.islinux()

function add_loadsave(format, predicates)
    library = popfirst!(predicates)
    os, loadsave = split_predicates(predicates)
    if applies_to_os(os)
        if isempty(loadsave) || (LOAD in loadsave)
            add_loader(format, library)
        end
        if isempty(loadsave) || (SAVE in loadsave)
            add_saver(format, library)
        end
    end
end

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

const unknown_df = DataFormat{:UNKNOWN}

"""
`unknown(f)` returns true if the format of `f` is unknown.
"""
unknown(::Type{format"UNKNOWN"})    = true
unknown(::Type{DataFormat{sym}}) where {sym} = false

const ext2sym    = Dict{String, Union{Symbol,Vector{Symbol}}}()
const magic_list = Vector{Pair}()     # sorted, see magic_cmp below
const sym2info   = Dict{Symbol,Any}() # Symbol=>(magic, extension)
const magic_func = Vector{Pair}()     # for formats with complex magic #s


function add_format(fmt, magic, extension, load_save_libraries...)
    add_format(fmt, magic, extension)
    for library in load_save_libraries
        add_loadsave(fmt, library)
    end
    fmt
end

"""
`add_format(fmt, magic, extention)` registers a new `DataFormat`.
For example:

    add_format(format"PNG", (UInt8[0x4d,0x4d,0x00,0x2b], UInt8[0x49,0x49,0x2a,0x00]), [".tiff", ".tif"])
    add_format(format"PNG", [0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a], ".png")
    add_format(format"NRRD", "NRRD", [".nrrd",".nhdr"])

Note that extensions, magic numbers, and format-identifiers are case-sensitive.
"""
function add_format(fmt::Type{DataFormat{sym}}, magic::Union{Tuple,AbstractVector,String}, extension) where sym
    haskey(sym2info, sym) && error("format ", fmt, " is already registered")
    m = canonicalize_magic(magic)
    rng = searchsorted(magic_list, m, lt=magic_cmp)
    if !isempty(m) && !isempty(rng)
        error("magic bytes ", m, " are already registered")
    end
    insert!(magic_list, first(rng), Pair(m, sym))  # m=>sym in 0.4
    sym2info[sym] = (m, extension)
    add_extension(extension, sym)
    fmt
end

# for multiple magic bytes
function add_format(fmt::Type{DataFormat{sym}},
                    magics::Tuple{T,Vararg{T}}, extension) where {sym, T <: Vector{UInt8}}
    haskey(sym2info, sym) && error("format ", fmt, " is already registered")
    magics = map(canonicalize_magic, magics)
    for magic in magics
        rng = searchsorted(magic_list, magic, lt=magic_cmp)
        if !isempty(magic) && !isempty(rng)
            error("magic bytes ", magic, " are already registered")
        end
        insert!(magic_list, first(rng), Pair(magic, sym))  # m=>sym in 0.4
    end
    sym2info[sym] = (magics, extension)
    add_extension(extension, sym)
    fmt
end

# For when "magic" is supplied as a function (see the HDF5 example in
# registry.jl)
function add_format(fmt::Type{DataFormat{sym}}, magic, extension) where sym
    haskey(sym2info, sym) && error("format ", fmt, " is already registered")
    push!(magic_func, Pair(magic,sym))  # magic=>sym in 0.4
    sym2info[sym] = (magic, extension)
    add_extension(extension, sym)
    fmt
end

"""
`del_format(fmt::DataFormat)` deletes `fmt` from the format registry.
"""
function del_format(fmt::Type{DataFormat{sym}}) where sym
    magic, extension = sym2info[sym]
    del_magic(magic, sym)
    delete!(sym2info, sym)
    del_extension(extension)
    nothing
end

# Deletes multiple magic bytes
del_magic(magic::Tuple, sym) = for m in magic
    del_magic(m, sym)
end
# Deletes single magic bytes
function del_magic(magic::NTuple{N, UInt8}, sym) where N
    rng = searchsorted(magic_list, magic, lt=magic_cmp)
    if length(magic) == 0
        fullrng = rng
        found = false
        for idx in fullrng
            if last(magic_list[idx]) == sym
                rng = idx:idx
                found = true
                break
            end
        end
        found || error("format ", sym, " not found")
    end
    @assert length(rng) == 1
    deleteat!(magic_list, first(rng))
    nothing
end

function del_magic(magic::Function, sym)
    deleteat!(magic_func, something(findfirst(isequal(Pair(magic,sym)), magic_func), 0))
    nothing
end

"""
`info(fmt)` returns the magic bytes/extension information for
`DataFormat` `fmt`.
"""
info(::Type{DataFormat{sym}}) where {sym} = sym2info[sym]


canonicalize_magic(m::NTuple{N,UInt8}) where {N} = m
canonicalize_magic(m::AbstractVector{UInt8}) = tuple(m...)
canonicalize_magic(m::String) = canonicalize_magic(codeunits(m))



function add_extension(ext::String, sym)
    if haskey(ext2sym, ext)
        v = ext2sym[ext]
        if isa(v, Symbol)
            ext2sym[ext] = Symbol[v, sym]
        else
            push!(ext2sym[ext], sym)
        end
        return
    end
    ext2sym[ext] = sym
end
function add_extension(ext::Union{Array,Tuple}, sym)
    for e in ext
        add_extension(e, sym)
    end
end

del_extension(ext::String) = delete!(ext2sym, ext)
function del_extension(ext::Union{Array,Tuple})
    for e in ext
        del_extension(e)
    end
end

# magic_cmp results in magic_list being sorted in order of increasing
# length(magic), then (among tuples with the same length) in
# dictionary order. This ordering has the advantage that you can
# incrementally read bytes from the stream without worrying that
# you'll encounter an EOF yet still have potential matches later in
# the list.
function magic_cmp(p::Pair, t::Tuple)
    pt = first(p)
    lp, lt = length(pt), length(t)
    lp < lt && return true
    lp > lt && return false
    pt < t
end
function magic_cmp(t::Tuple, p::Pair)
    pt = first(p)
    lp, lt = length(pt), length(t)
    lt < lp && return true
    lt > lp && return false
    t < pt
end


abstract type Formatted{F<:DataFormat} end  # A specific file or stream

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

"`magic(fmt)` returns the magic bytes of format `fmt`"
magic(fmt::Type{F}) where {F<:DataFormat} = UInt8[info(fmt)[1]...]

"""
`skipmagic(s)` sets the position of `Stream` `s` to be just after the magic bytes.
For a plain IO object, you can use `skipmagic(io, fmt)`.
"""
skipmagic(s::Stream{F}) where {F} = (skipmagic(stream(s), F); s)
function skipmagic(io, fmt::Type{DataFormat{sym}}) where sym
    magic, _ = sym2info[sym]
    skipmagic(io, magic)
    nothing
end
skipmagic(io, magic::Function) = nothing
skipmagic(io, magic::NTuple{N,UInt8}) where {N} = seek(io, length(magic))
function skipmagic(io, magic::Tuple)
    lengths = map(length, magic)
    all(x-> lengths[1] == x, lengths) && return seek(io, lengths[1]) # it doesn't matter what magic bytes get skipped as they all have the same length
    magic = [magic...]
    sort!(magic, lt = (a,b)-> length(a) >= length(b)) # start with longest first, to avoid overlapping magic bytes
    seekend(io)
    len = position(io)
    seekstart(io)
    filter!(x-> length(x) <= len, magic) # throw out magic bytes that are longer than IO
    tmp = read(io, length(first(magic))) # now, first is both the longest and guaranteed to fit into io, so we can just read the bytes
    for m in magic
        if magic_equal(m, tmp)
            seek(io, length(m))
            return nothing
        end
    end
    error("tried to skip magic bytes of an IO that does not contain the magic bytes of the format. IO: $io")
end
function magic_equal(magic, buffer)
    for (i,elem) in enumerate(magic)
        buffer[i] != elem && return false
    end
    true
end


unknown(::File{F}) where {F} = unknown(F)
unknown(::Stream{F}) where {F} = unknown(F)

"""
`query(filename)` returns a `File` object with information about the
format inferred from the file's extension and/or magic bytes.
"""
function query(filename::AbstractString)
    _, ext = splitext(filename)
    if haskey(ext2sym, ext)
        sym = ext2sym[ext]
        no_magic = !hasmagic(sym)
        if lensym(sym) == 1 && (no_magic || !isfile(filename)) # we only found one candidate and there is no magic bytes, or no file, trust the extension
            return File{DataFormat{sym}}(filename)
        elseif !isfile(filename) && lensym(sym) > 1
            return File{DataFormat{sym[1]}}(filename)
        end
        if no_magic && !hasfunction(sym)
            error("Some formats with extension ", ext, " have no magic bytes; use `File{format\"FMT\"}(filename)` to resolve the ambiguity.")
        end
    end
    !isfile(filename) && return File{unknown_df}(filename) # (no extension || no magic byte) && no file
    # Otherwise, check the magic bytes
    file!(query(open(filename), abspath(filename)))
end

lensym(s::Symbol) = 1
lensym(v::Vector) = length(v)

hasmagic(s::Symbol) = hasmagic(sym2info[s][1])
hasmagic(v::Vector) = any(hasmagic, v)

hasmagic(t::Tuple) = !isempty(t)
hasmagic(::Any) = false   # for when magic is a function

hasfunction(s::Symbol) = hasfunction(sym2info[s][1])
hasfunction(v::Vector) = any(hasfunction, v)
hasfunction(s::Any) = true #has function
hasfunction(s::Tuple) = false #has magic

"""
`query(io, [filename])` returns a `Stream` object with information about the
format inferred from the magic bytes.
"""
query(io::IO, filename) = query(io, String(filename))

function query(io::IO, filename::Union{Nothing, String} = nothing)
    magic = Vector{UInt8}()
    pos = position(io)
    for p in magic_list
        m = first(p)
        length(m) == 0 && continue
        while length(m) > length(magic)
            if eof(io)
                seek(io, pos)
                return Stream{unknown_df, typeof(io)}(io, filename)
            end
            push!(magic, read(io, UInt8))
        end
        if iter_eq(magic, m)
            seek(io, pos)
            return Stream{DataFormat{last(p)},typeof(io)}(io, filename)
        end
    end
    if seekable(io)
        for p in magic_func
            seek(io, pos)
            f = first(p)
            try
                if f(io)
                    return Stream{DataFormat{last(p)},typeof(io)}(seek(io, pos), filename)
                end
            catch e
                println("There was an error in magick function $f")
                println("Please open an issue at FileIO.jl. Error:")
                println(e)
            end
        end
        seek(io, pos)
    end
    Stream{unknown_df,typeof(io)}(io, filename)
end

seekable(io::IOBuffer) = io.seekable
seekable(::IOStream) = true
seekable(::Any) = false

function iter_eq(A, B)
    length(A) == length(B) || return false
    i,j = 1,1
    for _=1:length(A)
        a=A[i]; b=B[j]
        a == b && (i+=1; j+=1; continue)
        a == UInt32('\r') && (i+=1; continue) # this seems like the shadiest solution to deal with windows \r\n
        b == UInt32('\r') && (j+=1; continue)
        return false #now both must be unequal, and no \r windows excemption any more
    end
    true
end
