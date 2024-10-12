# This file contains the code that allows things to be added to the registry

const ext2sym    = Dict{String, Union{Symbol,Vector{Symbol}}}()
const magic_list = Vector{Pair{Vector{UInt8},Symbol}}()     # sorted, see magic_cmp below
const sym2info   = Dict{Symbol,Tuple{Any,Any}}()   # Symbol=>(magic, extension)
const magic_func = Vector{Pair{Function,Symbol}}() # for formats with complex magic detection
const empty_magic = UInt8[]

## OS:
@enum OS Unix Windows OSX Linux

applies_to_os(oslist) = isempty(oslist) || any(applies_to_os, oslist)
function applies_to_os(os::OS)
    os == Unix && return Sys.isunix()
    os == Windows && return Sys.iswindows()
    os == OSX && return Sys.isapple()
    os == Linux && return Sys.islinux()
    return false
end

## Magic bytes:

# magic_cmp results in magic_list being sorted in order of increasing
# length(magic), then (among sequences with the same length) in
# lexographic order. This ordering has the advantage that you can
# incrementally read bytes from the stream without worrying that
# you'll encounter an EOF yet still have potential matches later in
# the list.
function magic_cmp(a::Vector{UInt8}, b::Vector{UInt8})
    la, lb = length(a), length(b)
    la < lb && return true
    la > lb && return false
    for (ia, ib) in zip(a, b)
        ia < ib && return true
        ia > ib && return false
    end
    return false
end
magic_cmp(p::Pair, m::Vector{UInt8}) = magic_cmp(p.first, m)
magic_cmp(m::Vector{UInt8}, p::Pair) = magic_cmp(m, p.first)

canonicalize_magic(@nospecialize(m::Tuple{Vararg{UInt8}})) = UInt8[m...]
canonicalize_magic(m::AbstractVector{UInt8}) = convert(Vector{UInt8}, m)
canonicalize_magic(m::String) = canonicalize_magic(codeunits(m))


## Load/Save

@enum IOSupport LOAD SAVE

function split_predicates(list)
    os = OS[]
    ls = IOSupport[]
    for item in list
        if isa(item, OS)
            push!(os, item)
        else
            push!(ls, item)
        end
    end
    return os, ls
end


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

## Add Format:

function add_format(fmt, magic, extension, load_save_libraries...)
    for library in load_save_libraries
        add_loadsave(fmt, library)
    end
    # Add the format after we've validated the packages (to prevent a partially-registered format)
    add_format(fmt, magic, extension)
    fmt
end

"""
    add_format(fmt, magic, extension)

registers a new [`DataFormat`](@ref).

For example:
```julia
add_format(format"TIFF", (UInt8[0x4d,0x4d,0x00,0x2b], UInt8[0x49,0x49,0x2a,0x00]), [".tiff", ".tif"])
add_format(format"PNG", [0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a], ".png")
add_format(format"NRRD", "NRRD", [".nrrd",".nhdr"])
```

Note that extensions, magic numbers, and format-identifiers are case-sensitive.

You can also specify particular packages that support the format with `add_format(fmt, magic, extension, pkgspecifiers...)`,
where example `pkgspecifiers` are:
```julia
add_format(fmt, magic, extension, [:PkgA=>UUID(...)])                     # only PkgA supports the format (load & save)
add_format(fmt, magic, extension, [:PkgA=>uuidA], [:PkgB=>uuidB])         # try PkgA first, but if it fails try PkgB
add_format(fmt, magic, extension, [:PkgA=>uuidA, LOAD], [:PkgB=>uuidB])   # try PkgA first for `load`, otherwise use PkgB
add_format(fmt, magic, extension, [:PkgA=>uuidA, OSX], [:PkgB=>uuidB])    # use PkgA on OSX, and PkgB otherwise
```
The `uuid`s are all of type `UUID` and can be obtained from the package's `Project.toml` file.

You can combine `LOAD`, `SAVE`, `OSX`, `Unix`, `Windows` and `Linux` arbitrarily to narrow `pkgspecifiers`.
"""
add_format(@nospecialize(fmt::Type), args...) = add_format(formatname(fmt)::Symbol, args...)
add_format(sym::Symbol, magic::Union{Tuple,AbstractVector{UInt8},String}, extension) =
    add_format(sym, canonicalize_magic(magic), extension)
function add_format(sym::Symbol,
                    @nospecialize(magics::Tuple{Vector{UInt8},Vararg{Vector{UInt8}}}), extension)
    add_format(sym, [magics...], extension)
end

function add_format(sym::Symbol, magic::Vector{UInt8}, extension)
    haskey(sym2info, sym) && error("format ", sym, " is already registered")
    rng = searchsorted(magic_list, magic, lt=magic_cmp)
    if !isempty(magic) && !isempty(rng)
        error("magic bytes ", magic, " are already registered")
    end
    insert!(magic_list, first(rng), magic=>sym)
    sym2info[sym] = (magic, extension)
    add_extension(extension, sym)
    nothing
end

# for multiple magic bytes
function add_format(sym::Symbol, magics::Vector{Vector{UInt8}}, extension)
    haskey(sym2info, sym) && error("format ", sym, " is already registered")
    for magic in magics
        rng = searchsorted(magic_list, magic, lt=magic_cmp)
        if !isempty(magic) && !isempty(rng)
            error("magic bytes ", magic, " are already registered")
        end
        insert!(magic_list, first(rng), magic=>sym)
    end
    sym2info[sym] = (sort(magics; lt=magic_cmp), extension)
    add_extension(extension, sym)
    nothing
end

# For when "magic" is supplied as a function (see the HDF5 example in
# registry.jl)
function add_format(sym::Symbol, @nospecialize(magic::Function), extension)
    haskey(sym2info, sym) && error("format ", sym, " is already registered")
    push!(magic_func, Pair(magic,sym))  # magic=>sym in 0.4
    sym2info[sym] = (magic, extension)
    add_extension(extension, sym)
    nothing
end

"""
    del_format(fmt::DataFormat)

deletes `fmt` from the format registry.
"""
del_format(@nospecialize(fmt::Type)) = del_format(formatname(fmt)::Symbol)
function del_format(sym::Symbol)
    magic, extension = sym2info[sym]
    del_magic(magic, sym)
    delete!(sym2info, sym)
    del_extension(extension)
    nothing
end

# # Deletes multiple magic bytes
# del_magic(magic::Tuple, sym) = for m in magic
#     del_magic(m, sym)
# end
# Deletes single magic bytes
del_magic(@nospecialize(magic), sym::Symbol) = del_magic(canonicalize_magic(magic), sym)
function del_magic(magic::Vector{UInt8}, sym::Symbol)
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
del_magic(magics::Vector{Vector{UInt8}}, sym::Symbol) = foreach(magics) do magic
    del_magic(magic, sym)
end

function del_magic(@nospecialize(magic::Function), sym::Symbol)
    deleteat!(magic_func, something(findfirst(isequal(Pair{Function,Symbol}(magic,sym)), magic_func), 0))
    nothing
end

## File Extensions:

function add_extension(ext::String, sym::Symbol)
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
