module FileIO

if VERSION < v"0.4.0-dev"
    using Docile, Compat
    immutable Pair{A,B}
        first::A
        second::B
    end
    Base.first(p::Pair) = p.first
    Base.last(p::Pair) = p.second
end

export DataFormat,
       File,
       Formatted,
       Stream,

       @format_str,

       addformat,
       delformat,
       filename,
       info,
       load,
       query,
       save,
       unknown

include("query.jl")
include("registry.jl")

load(s::Union(AbstractString,IO); options...) = load(query(s); options...)
save(s::Union(AbstractString,IO), data...; options...) = save(query(s), data...; options...)

# Fallbacks
load{F}(f::Formatted{F}; options...) = error("No load function defined for format ", F, " with filename ", filename(f))
save{F}(f::Formatted{F}, data...; options...) = error("No save function defined for format ", F, " with filename ", filename(f))

end # module
