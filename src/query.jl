# This file contains code that helps to query from the registry to determine the format

"""
`unknown(f)` returns true if the format of `f` is unknown.
"""
unknown(::Type{format"UNKNOWN"}) = true
unknown(::Type{DataFormat{sym}}) where {sym} = false

unknown(::File{F}) where {F} = unknown(F)
unknown(::Stream{F}) where {F} = unknown(F)

const unknown_df = DataFormat{:UNKNOWN}


"""
`info(fmt)` returns the magic bytes/extension information for
`DataFormat` `fmt`.
"""
info(::Type{DataFormat{sym}}) where {sym} = sym2info[sym]

"`magic(fmt)` returns the magic bytes of format `fmt`"
magic(fmt::Type{<:DataFormat})= UInt8[info(fmt)[1]...]


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
