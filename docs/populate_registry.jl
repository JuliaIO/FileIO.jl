# This file updates `docs/src/registry.md` (it does not build documentation in general)
module RegistryMD

using FileIO: FileIO, LOAD, SAVE, OSX, OS, DataFormat, @format_str, MimeWriter
using UUIDs
using Pkg

const ctx = Pkg.Types.Context()
try
    ctx.registries
catch
    error("this file must be run on Julia 1.6 or higher")
end

function pkg_url(uuid)
    for reg in ctx.registries
        entry = get(reg.pkgs, uuid, nothing)
        entry === nothing && continue
        info = Pkg.Registry.init_package_info!(entry)
        base, ext = splitext(info.repo)
        return ext == ".git" ? base : info.repo
    end
end
library2string(x::Pair{<:Any,UUID}) = "[$(x.first)]($(pkg_url(x.second)))"
library2string(x::Module) = string(nameof(x))

extension2string(x) = join(map(string, x), ", ")
extension2string(x::AbstractString) = x

os2string(x::Vector) = isempty(x) ? "all platforms " : join(map(os2string, x), ", ")
os2string(os::Type{O}) where {O <: OS} = "$(O.name.name)"

magic2string(x::Function) = "has detection function"
magic2string(x::Tuple) = isempty(x) ? "only extension" : string(x)
magic2string(x::AbstractString) = '"' * escape_string(x, ['_']) * '"'
magic2string(x) = string(x)
function loadsave2string(load_save_libraries)
    io = IOBuffer()
    loader_str, saver_str = " ", " "
    for (i, predicates) in enumerate(load_save_libraries)
        library = popfirst!(predicates)

        os, loadsave = FileIO.split_predicates(predicates)
        if isempty(loadsave)
            print(io, "loads and saves on all platforms with ", library2string(library), " ")
        elseif (LOAD in loadsave)
            print(io, "loads with ", library2string(library), " on ", os2string(os), " ")
        elseif (SAVE in loadsave)
            print(io, "saves with ", library2string(library), " on ", os2string(os), " ")
        end
        i < length(load_save_libraries) && print(io, '\n')
    end
    split(String(take!(io)), '\n')
end

fs = open(joinpath(pkgdir(FileIO), "docs", "src", "registry.md"), "w")

    println(fs, "# Registry table")
    println(fs)
    println(fs, "The following formats are registered with FileIO:")
    println(fs)

    function add_format(::Type{DataFormat{Sym}}, magic, extension, io_libs...) where Sym
        liblinks = loadsave2string(io_libs)
        for (i, lib) in enumerate(liblinks)
            if i == 1
                println(fs, "| $(Sym) | $(extension2string(extension)) | $lib | $(magic2string(magic)) |")
            else
                println(fs, "| | | $lib | |")
            end
        end
    end


    function add_format(fmt::Type{DataFormat{sym}}, magic::Union{Tuple,AbstractVector,String}, extension) where sym
        println(sym)
    end

    # for multiple magic bytes
    function add_format(sym::Symbol, magics::Vector{Vector{UInt8}}, extension)
        println(sym)
    end

    # For when "magic" is supplied as a function (see the HDF5 example in
    # registry.jl)
    function add_format(fmt::Type{DataFormat{sym}}, magic, extension) where sym
        println(sym)
    end


    println(fs, """
    | Format Name | extensions | IO library | detection or magic number |
    | ----------- | ---------- | ---------- | ------------------------- |""")
    include(joinpath(pkgdir(FileIO), "src", "registry.jl"))

close(fs)

end  # module RegistryMD
