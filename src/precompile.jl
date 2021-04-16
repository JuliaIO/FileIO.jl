function _precompile_()
    ccall(:jl_generating_output, Cint, ()) == 1 || return nothing
    for f in (detect_rdata, detect_rdata_single, detectwav, detect_bedgraph,
              detecttiff, detect_noometiff, detect_ometiff, detectavi,
              detecthdf5, detect_stlascii, detect_stlbinary, detect_gadget2)
        @assert precompile(f, (IOStream,))
    end

    for F in (String, IOStream, Formatted)
        @assert precompile(query, (F,))
        @assert precompile(load, (F,))
        @assert precompile(save, (F,Nothing,))
        @assert precompile(loadstreaming, (F,))
        @assert precompile(savestreaming, (F,))
    end
    @assert precompile(action, (Symbol,Vector{Union{PkgId, Module}},Symbol,String))
    @assert precompile(action, (Symbol,Vector{Union{PkgId, Module}},Symbol,IOStream))
    @assert precompile(action, (Symbol,Vector{Union{PkgId, Module}},Formatted))
    @assert precompile(loadstreaming, (Function, Any))
    @assert precompile(savestreaming, (Function, Any))
    @assert precompile(skipmagic, (IOStream,Vector{Vector{UInt8}},))
end
