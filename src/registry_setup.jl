# This file contains the code that allows things to be added to the registry

const ext2sym    = Dict{String, Union{Symbol,Vector{Symbol}}}()
const magic_list = Vector{Pair}()     # sorted, see magic_cmp below
const sym2info   = Dict{Symbol,Any}() # Symbol=>(magic, extension)
const magic_func = Vector{Pair}()     # for formats with complex magic #s

## OS:
abstract type OS end
abstract type Unix <: OS end
struct Windows <: OS end
struct OSX <: Unix end
struct Linux <: Unix end

split_predicates(list) = filter(x-> x <: OS, list), filter(x-> !(x <: OS), list)
applies_to_os(os::Vector) = isempty(os) || any(applies_to_os, os)
applies_to_os(os::Type{<:OS}) = false

applies_to_os(os::Type{<:Unix}) = Sys.isunix()
applies_to_os(os::Type{Windows}) = Sys.iswindows()
applies_to_os(os::Type{OSX}) = Sys.isapple()
applies_to_os(os::Type{Linux}) = Sys.islinux()

## Magic bytes:

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

canonicalize_magic(m::NTuple{N,UInt8}) where {N} = m
canonicalize_magic(m::AbstractVector{UInt8}) = tuple(m...)
canonicalize_magic(m::String) = canonicalize_magic(codeunits(m))


## Load/Save

struct LOAD end
struct SAVE end

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

## File Extensions:

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
