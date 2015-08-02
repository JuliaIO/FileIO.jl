### Format registry infrastructure

@doc """
`DataFormat{sym}()` indicates a known binary or text format of kind `sym`,
where `sym` is always a symbol. For example, a .csv file might have
`DataFormat{:CSV}()`.

An easy way to write `DataFormat{:CSV}` is `format"CSV"`.
""" ->
immutable DataFormat{sym} end

macro format_str(s)
    :(DataFormat{$(Expr(:quote, symbol(s)))})
end

const unknown_df = DataFormat{:UNKNOWN}

@doc """
`unknown(f)` returns true if the format of `f` is unknown.""" ->
unknown(::Type{format"UNKNOWN"}) = true
unknown{sym}(::DataFormat{sym}) = unknown(sym)
unknown(::Any) = false

const ext2sym = Dict{ASCIIString,Union(Symbol,Vector{Symbol})}()
const magic_list = Array(Pair, 0)    # sorted, see magic_cmp below
const sym2info = Dict{Symbol,Any}()  # Symbol=>(magic, extension)
const magic_func = Array(Pair, 0)    # for formats with complex magic #s

@doc """
`addformat(fmt, magic, extention)` registers a new `DataFormat`.
For example:

    addformat(format"PNG", [0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a], ".png")
    addformat(format"NRRD", "NRRD", [".nrrd",".nhdr"])
""" ->
function addformat{sym}(fmt::Type{DataFormat{sym}}, magic::Union{Tuple,AbstractVector,ByteString}, extension)
    m = canonicalize_magic(magic)
    rng = searchsorted(magic_list, m, lt=magic_cmp)
    isempty(rng) || error("magic bytes ", m, " are already registered")
    haskey(sym2info, sym) && error("format ", fmt, " is already registered")
    insert!(magic_list, first(rng), m=>sym)
    sym2info[sym] = (m, extension)
    add_extension(extension, sym)
    fmt
end

# For when "magic" is supplied as a function (see the HDF5 example in
# registry.jl)
function addformat{sym}(fmt::Type{DataFormat{sym}}, magic, extension)
    haskey(sym2info, sym) && error("format ", fmt, " is already registered")
    push!(magic_func, magic=>sym)
    sym2info[sym] = (magic, extension)
    add_extension(extension, sym)
    fmt
end

@doc """
`delformat(fmt::DataFormat)` deletes `fmt` from the format registry.
""" ->
function delformat{sym}(fmt::Type{DataFormat{sym}})
    magic, extension = sym2info[sym]
    rng = searchsorted(magic_list, magic, lt=magic_cmp)
    @assert length(rng) == 1
    deleteat!(magic_list, first(rng))
    delete!(sym2info, sym)
    del_extension(extension)
    nothing
end

@doc """
`info(fmt)` returns the magic bytes/extension information for
`DataFormat` `fmt`.""" ->
Base.info{sym}(::Type{DataFormat{sym}}) = sym2info[sym]

canonicalize_magic{N}(m::NTuple{N,UInt8}) = m
canonicalize_magic(m::AbstractVector{UInt8}) = tuple(m...)
canonicalize_magic(m::ByteString) = canonicalize_magic(m.data)

function add_extension(ext::ASCIIString, sym)
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
function add_extension(ext::Union(Array,Tuple), sym)
    for e in ext
        add_extension(e, sym)
    end
end

del_extension(ext::ASCIIString) = delete!(ext2sym, ext)
function del_extension(ext::Union(Array,Tuple))
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


abstract Formatted{F<:DataFormat}   # A specific file or stream

@doc """
`File(fmt, filename)` indicates that `filename` is a file of known
DataFormat `fmt`.  For example, `File{fmtpng}(filename)` would indicate a PNG
file.""" ->
immutable File{F<:DataFormat} <: Formatted{F}
    filename::UTF8String
end
File(fmt::DataFormat, filename) = File{fmt}(filename)

@doc """
`filename(file)` returns the filename associated with `File` `file`.
""" ->
filename(f::File) = f.filename

@doc """
`Stream(fmt, io, [filename])` indicates that the stream `io` is
written in known `Format`.  For example, `Stream{PNG}(io)` would
indicate PNG format.  If known, the optional `filename` argument can
be used to improve error messages, etc.""" ->
immutable Stream{F<:DataFormat,IOtype<:IO} <: Formatted{F}
    io::IOtype
    filename::Nullable{UTF8String}
end

Stream(fmt::DataFormat, io::IO) = Stream{typeof(fmt),typeof(io)}(io, Nullable{UTF8String}())
Stream(fmt::DataFormat, io::IO, filename) = Stream{typeof(fmt),typeof(io)}(io,utf8(filename))

@doc """
`filename(stream)` returns a nullable-string of the filename
associated with `Stream` `stream`.""" ->
filename(s::Stream) = s.filename

function file!{F}(strm::Stream{F})
    f = filename(strm)
    if isnull(f)
        error("filename unknown")
    end
    close(strm.io)
    File{F}(get(f))
end

unknown{F}(::File{F}) = unknown(F)
unknown{F}(::Stream{F}) = unknown(F)

@doc """
`query(filename)` returns a `File` object with information about the
format inferred from the file's extension and/or magic bytes.""" ->
function query(filename::AbstractString)
    _, ext = splitext(filename)
    if haskey(ext2sym, ext)
        sym = ext2sym[ext]
        len = lenmagic(sym)
        if length(len) == 1 && all(x->x==0, len)
            # If there are no magic bytes, trust the extension
            return File{DataFormat{sym}}(filename)
        end
        if any(x->x==0, len)
            error("Some formats with extension ", ext, " have no magic bytes; use `File{format\"FMT\"}(filename)` to resolve the ambiguity.")
        end
    end
    # Otherwise, check the magic bytes
    file!(query(open(filename), filename))
end

lenmagic(s::Symbol) = lenm(sym2info[s][1])
lenmagic(v::Vector) = map(lenmagic, v)

lenm(t::Tuple) = length(t)
lenm(::Any) = -1   # for when magic is a function

@doc """
`query(io, [filename])` returns a `Stream` object with information about the
format inferred from the magic bytes.""" ->
query(io::IO, filename) = query(io, Nullable(utf8(filename)))

function query(io::IO, filename::Nullable{UTF8String}=Nullable{UTF8String}())
    magic = Array(UInt8, 0)
    pos = position(io)
    for p in magic_list
        m = first(p)
        length(m) == 0 && continue
        while length(m) > length(magic)
            if eof(io)
                return Stream{unknown_df,typeof(io)}(io, filename)
            end
            push!(magic, read(io, UInt8))
        end
        if iter_eq(magic, m)
            return Stream{DataFormat{last(p)},typeof(io)}(io, filename)
        end
    end
    if seekable(io)
        for p in magic_func
            seek(io, pos)
            f = first(p)
            if f(io)
                return Stream{DataFormat{last(p)},typeof(io)}(seek(io, pos), filename)
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
    for (a,b) in zip(A,B)
        a == b || return false
    end
    true
end
