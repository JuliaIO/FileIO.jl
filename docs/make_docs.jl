using FileIO, Compat
import Compat.String
import FileIO: LOAD, SAVE, OSX, OS
const fs = open(Pkg.dir("FileIO", "docs", "registry.md"), "w")

function pkg_url(pkgname)
    result = readchomp(Pkg.dir("METADATA", string(pkgname), "url"))
    g = "git://"
    if startswith(result, g)
        return string("http://", result[length(g):end])
    end
    result
end
library2string(x) = "[$(x)]($(pkg_url(x)))"

extension2string(x) = join(map(string, x), ", ")
extension2string(x::AbstractString) = x

os2string(x::Vector) = isempty(x) ? "**all** platforms " : join(map(os2string, x), ", ")
os2string{O <: OS}(os::Type{O}) = "**$(O.name.name)**"

magic2string(x::Function) = "has detection function"
magic2string(x::Tuple) = isempty(x) ? "only extension": string(x)
magic2string(x) = string(x)
function loadsave2string(load_save_libraries)
    io = IOBuffer()
    loader_str, saver_str = " ", " "
    for predicates in load_save_libraries
        library = shift!(predicates)

        os, loadsave = FileIO.split_predicates(predicates)
        if isempty(loadsave)
            print(io, "loads and saves on **all** platforms with ", library2string(library), " ")
        elseif (LOAD in loadsave)
            print(io, "loads with ", library2string(library), " on: ", os2string(os), " ")
        elseif (SAVE in loadsave)
            print(io, "loads with ", library2string(library), " on: ", os2string(os), " ")
        end
    end
    String(take!(io))
end
function add_format{Sym}(::Type{DataFormat{Sym}}, magic, extension, io_libs...)
    println(fs, "| $(Sym) | $(extension2string(extension)) | $(loadsave2string(io_libs)) | $(magic2string(magic)) |")
end


function add_format{sym}(fmt::Type{DataFormat{sym}}, magic::@compat(Union{Tuple,AbstractVector,String}), extension)
    println(sym)
end

# for multiple magic bytes
function add_format{sym, T <: Vector{UInt8}, N}(fmt::Type{DataFormat{sym}}, magics::NTuple{N, T}, extension)
    println(sym)
end

# For when "magic" is supplied as a function (see the HDF5 example in
# registry.jl)
function add_format{sym}(fmt::Type{DataFormat{sym}}, magic, extension)
    println(sym)
end


println(fs, """
| Format Name | extensions | IO library | detection or magic number |
| ----------- | ---------- | ---------- | ---------- |""")
include(Pkg.dir("FileIO", "src", "registry.jl"))

close(fs)
