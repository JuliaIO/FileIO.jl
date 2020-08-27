function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    @assert precompile(Tuple{typeof(detect_bedgraph),IOStream})
    @assert precompile(Tuple{typeof(detect_noometiff),IOStream})
    @assert precompile(Tuple{typeof(detect_rdata),IOStream})
    @assert precompile(Tuple{typeof(detect_rdata_single),IOStream})
    @assert precompile(Tuple{typeof(detectwav),IOStream})

    @assert precompile(Tuple{typeof(load),File})
    @assert precompile(Tuple{typeof(load),Formatted})
    @assert precompile(Tuple{typeof(load),String})

    @assert precompile(Tuple{typeof(query),String})
    @assert precompile(Tuple{typeof(query),IOStream})
    @assert precompile(Tuple{typeof(query),IOStream,String})
    @assert precompile(Tuple{typeof(query),IOStream,Nothing})

    @assert precompile(Tuple{typeof(hasfunction),Function})
    @assert precompile(Tuple{typeof(hasmagic),Function})

    @assert precompile(Tuple{typeof(applicable_loaders),Type{<:DataFormat}})
    @assert precompile(Tuple{typeof(applicable_loaders),Formatted})
    @assert precompile(Tuple{typeof(applicable_savers),Type{<:DataFormat}})
    @assert precompile(Tuple{typeof(applicable_savers),Formatted})
    @assert precompile(Tuple{typeof(add_loader),Type{<:DataFormat},Symbol})
    @assert precompile(Tuple{typeof(add_saver),Type{<:DataFormat},Symbol})

    @assert precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{10,UInt8}})
    @assert precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{20,UInt8}})
    @assert precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{30,UInt8}})
    @assert precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{32,UInt8}})
    @assert precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{35,UInt8}})
    @assert precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{4,UInt8}})
    @assert precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{6,UInt8}})
    @assert precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{7,UInt8}})
    @assert precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{8,UInt8}})
    @assert precompile(Tuple{typeof(iter_eq),Array{UInt8,1},Tuple{UInt8,UInt8,UInt8}})
    @assert precompile(Tuple{typeof(iter_eq),Array{UInt8,1},Tuple{UInt8,UInt8}})

    if isdefined(Base, :bodyfunction)
        m = which(query, (String,))
        f = Base.bodyfunction(m)
        @assert precompile(f, (Bool, typeof(query), String))
        m = which(load, (String,))
        f = Base.bodyfunction(m)
        @assert precompile(f, (Iterators.Pairs{Union{},Union{},Tuple{},NamedTuple{(),Tuple{}}}, typeof(load), String))
        m = which(load, (Formatted,))
        f = Base.bodyfunction(m)
        @assert precompile(f, (Any, typeof(load), Formatted))
        @assert precompile(f, (Iterators.Pairs{Union{},Union{},Tuple{},NamedTuple{(),Tuple{}}}, typeof(load), File))
    end

end
