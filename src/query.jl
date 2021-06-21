# This file contains code that helps to query from the registry to determine the format

"""
`unknown(f)` returns true if the format of `f` is unknown.
"""
unknown(@nospecialize(f::Union{Formatted,Type})) = unknown(formatname(f)::Symbol)
unknown(name::Symbol) = name === :UNKNOWN

const unknown_df = DataFormat{:UNKNOWN}


"""
`info(fmt)` returns the magic bytes/extension information for
`fmt`.
"""
info(@nospecialize(f::Union{Formatted,Type})) = info(formatname(f)::Symbol)
info(sym::Symbol) = sym2info[sym]

"`magic(fmt)` returns the magic bytes of format `fmt`"
magic(@nospecialize(fmt::Type)) = magic(formatname(fmt)::Symbol)
magic(sym::Symbol) = info(sym)[1]

"""
`skipmagic(s::Stream)` sets the position of `s` to be just after the magic bytes.
For a plain IO object, you can use `skipmagic(io, fmt)`.
"""
skipmagic(@nospecialize(s::Stream)) = (skipmagic(stream(s), formatname(s)::Symbol); s)
skipmagic(io, @nospecialize(fmt::Type)) = skipmagic(io, formatname(fmt)::Symbol)
function skipmagic(io, sym::Symbol)
    magic, _ = sym2info[sym]
    skipmagic(io, magic)
    nothing
end
skipmagic(io, @nospecialize(magic::Function)) = nothing
skipmagic(io, magic::Vector{UInt8}) = seek(io, length(magic))
function skipmagic(io, magics::Vector{Vector{UInt8}})
    lengths = map(length, magics)
    l1 = lengths[1]
    all(isequal(l1), lengths) && return seek(io, l1) # it doesn't matter what magic bytes get skipped as they all have the same length
    len = getlength(io)
    tmp = read(io, min(len, maximum(lengths)))
    for m in reverse(magics)  # start with the longest since they are most specific
        if magic_equal(m, tmp)
            seek(io, length(m))
            return nothing
        end
    end
    error("tried to skip magic bytes of an IO that does not contain the magic bytes of the format. IO: $io")
end

function magic_equal(magic, buffer)
    length(magic) > length(buffer) && return false
    for (i,elem) in enumerate(magic)
        buffer[i] != elem && return false
    end
    true
end

function getlength(io, pos=position(io))
    seekend(io)
    len = position(io)
    seek(io, pos)
    return len
end

"""
    query(filename; checkfile=true)

Return a `File` object with information about the
format inferred from the file's extension and/or magic bytes.
If `filename` already exists, the file's magic bytes will take priority
unless `checkfile` is false.
"""
function query(filename; checkfile::Bool=true)
    filename = abspath(filename)
    sym = querysym(filename; checkfile=checkfile)
    return File{DataFormat{sym}}(filename)
end
query(@nospecialize(f::Formatted)) = f

# This is recommended for internal use because it returns Symbol (or errors)
function querysym(filename; checkfile::Bool=true)
    hasmagic(@nospecialize(magic)) = !(isa(magic, Vector{UInt8}) && isempty(magic))

    checkfile &= isfile(filename)
    _, ext = splitext(filename)
    if haskey(ext2sym, ext)
        sym = ext2sym[ext]
        if isa(sym, Symbol)               # there's only one format with this extension
            checkfile || return sym       # since we're not checking, we can return it immediately
            magic = sym2info[sym][1]
            hasmagic(magic) || return sym
            return open(filename) do io
                match(io, magic) && return sym
                # if it doesn't match, we prioritize the magic bytes over the guess based on extension
                fmt = querysym_all(io)[1]
                # but if it fails to query the magic bytes, still use the extension-based guess
                return fmt === :UNKNOWN ? sym : fmt
            end
        end
        # There are multiple formats consistent with this extension
        syms = sym::Vector{Symbol}
        checkfile || return syms[1]     # with !checkfile we default to the first. TODO?: change to an error?
        return open(filename) do io
            badmagic = false
            for sym in syms
                magic = sym2info[sym][1]
                if !hasmagic(magic)
                    badmagic = true
                    continue
                end
                match(io, magic) && return sym
            end
            badmagic && error("Some formats with extension ", ext, " have no magic bytes; use `File{format\"FMT\"}(filename)` to resolve the ambiguity.")
            fmt = querysym_all(io)[1]
            return fmt === :UNKNOWN ? syms[1] : fmt
        end
    end
    !checkfile && return :UNKNOWN
    return open(filename) do io
        return querysym_all(io)[1]
    end
end

function match(io, magic::Vector{UInt8})
    len = getlength(io)
    len < length(magic) && return false
    return magic_equal(magic, read(io, length(magic)))
end

function match(io, magics::Vector{Vector{UInt8}})
    lengths = map(length, magics)
    len = getlength(io)
    tmp = read(io, min(len, maximum(lengths)))
    for m in reverse(magics)  # start with the longest since they are most specific
        if magic_equal(m, tmp)
            return true
        end
    end
    return false
end

function match(io, @nospecialize(magic::Function))
    seekstart(io)
    try
        magic(io)
    catch e
        @error("""There was an error in magic function $magic.
                  Please open an issue at FileIO.jl.""", exception=(e, catch_backtrace()))
        false
    end
end

# Returns sym, magic (the latter may be empty if a magic-function matched)
# Upon return the stream position is set to the end of magic.
function querysym_all(io)
    seekstart(io)
    len = getlength(io)
    lengths = map(magic_list) do p
        length(p.first)
    end
    tmp = read(io, min(len, maximum(lengths)))
    for (magic, sym) in reverse(magic_list)
        isempty(magic) && break
        if magic_equal(magic, tmp)
            seek(io, length(magic))
            return sym, magic
        end
    end
    for (magic, sym) in magic_func
        seekstart(io)
        match(io, magic) && return sym, empty_magic
    end
    seekstart(io)
    return :UNKNOWN, empty_magic
end

function querysym(io::IO)
    if seekable(io)
        sym, _ = querysym_all(io)
        seekstart(io)
        return sym
    end
    # When it's not seekable, we can only work our way upwards in length of magic bytes
    # We're essentially counting on the fact that one of them will match, otherwise the stream
    # is corrupted.
    buffer = UInt8[]
    for (magic, sym) in magic_list
        isempty(magic) && continue
        while length(buffer) < length(magic) && !eof(io)
            push!(buffer, read(io, UInt8))
        end
        if magic_equal(magic, buffer)
            return sym
        end
        eof(io) && break
    end
    return :UNKNOWN
end


"""
`query(io, [filename])` returns a `Stream` object with information about the
format inferred from the magic bytes.
"""
function query(io::IO, filename = nothing)
    sym = querysym(io)
    return Stream{DataFormat{sym}}(io, filename)
end
query(io::IO, @nospecialize(file::Formatted)) = Stream{DataFormat{formatname(file)::Symbol}}(io, filename(file))

seekable(io::IOBuffer) = io.seekable
seekable(::IOStream) = true
seekable(::Any) = false
