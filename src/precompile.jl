function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    precompile(Tuple{typeof(detect_bedgraph),IOStream})
    precompile(Tuple{typeof(detect_noometiff),IOStream})
    precompile(Tuple{typeof(detect_rdata),IOStream})
    precompile(Tuple{typeof(detect_rdata_single),IOStream})
    precompile(Tuple{typeof(detectwav),IOStream})

    precompile(Tuple{typeof(load),File})
    precompile(Tuple{typeof(load),Formatted})
    precompile(Tuple{typeof(load),String})
    precompile(Tuple{typeof(FileIO.load_filename),Formatted,String})
    if isdefined(Base, :bodyfunction)
        fbody = Base.bodyfunction(which(FileIO.load_filename, (Formatted, String)))
        precompile(fbody, (Any, typeof(FileIO.load_filename), Formatted, String))
        precompile(fbody, (Any, typeof(FileIO.load_filename), Formatted, String, Vararg{Any,100}))
    end

    precompile(Tuple{typeof(query),String})
    precompile(Tuple{typeof(query),IOStream})
    precompile(Tuple{typeof(query),IOStream,String})
    precompile(Tuple{typeof(query),IOStream,Nothing})

    precompile(Tuple{typeof(hasfunction),Function})
    precompile(Tuple{typeof(hasmagic),Function})

    precompile(Tuple{typeof(applicable_loaders),Type{<:DataFormat}})
    precompile(Tuple{typeof(applicable_loaders),Formatted})
    precompile(Tuple{typeof(applicable_savers),Type{<:DataFormat}})
    precompile(Tuple{typeof(applicable_savers),Formatted})
    precompile(Tuple{typeof(add_loader),Type{<:DataFormat},Symbol})
    precompile(Tuple{typeof(add_saver),Type{<:DataFormat},Symbol})

    precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{10,UInt8}})
    precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{20,UInt8}})
    precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{30,UInt8}})
    precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{32,UInt8}})
    precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{35,UInt8}})
    precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{4,UInt8}})
    precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{6,UInt8}})
    precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{7,UInt8}})
    precompile(Tuple{typeof(iter_eq),Array{UInt8,1},NTuple{8,UInt8}})
    precompile(Tuple{typeof(iter_eq),Array{UInt8,1},Tuple{UInt8,UInt8,UInt8}})
    precompile(Tuple{typeof(iter_eq),Array{UInt8,1},Tuple{UInt8,UInt8}})

    if isdefined(Base, :bodyfunction)
        m = which(query, (String,))
        f = Base.bodyfunction(m)
        precompile(f, (Bool, typeof(query), String))
        m = which(load, (String,))
        f = Base.bodyfunction(m)
        precompile(f, (Iterators.Pairs{Union{},Union{},Tuple{},NamedTuple{(),Tuple{}}}, typeof(load), String))
        m = which(load, (Formatted,))
        f = Base.bodyfunction(m)
        precompile(f, (Any, typeof(load), Formatted))
        precompile(f, (Iterators.Pairs{Union{},Union{},Tuple{},NamedTuple{(),Tuple{}}}, typeof(load), File))
    end

end
