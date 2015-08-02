module FileIO

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
