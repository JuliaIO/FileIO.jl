const sym2loader = Dict{Symbol,Vector{Symbol}}()
const sym2saver  = Dict{Symbol,Vector{Symbol}}()
const mimedict   = Dict{Symbol,Vector{Any}}()

for (appl,fchk,fadd,dct) in (
        (:applicable_loaders, :check_loader, :add_loader, :sym2loader),
        (:applicable_savers,  :check_saver,  :add_saver,  :sym2saver))
    @eval begin
        $appl{sym}(::Formatted{DataFormat{sym}}) = get($dct, sym, [:nothing])
        function $fchk(pkg::Symbol)
            pkg == :nothing && return FileIO #nothing is the symbol for no load/save specific lib. see above
            !isdefined(Main, pkg) && eval(Main, Expr(:import, pkg))
            return Main.(pkg)
        end
        function $fadd{sym}(::Type{DataFormat{sym}}, pkg::Symbol)
            list = get($dct, sym, Symbol[])
            $dct[sym] = push!(list, pkg)
        end
    end
end

applicable_mime{sym}(::MIME{sym}) = get(mimedict, sym, [:nothing])
function check_mime(pkg::Symbol)
    pkg == :nothing && error("No MIME package available")
    !isdefined(Main, pkg) && eval(Main, Expr(:import, pkg))
    return pkg
end

@doc """
`add_mime(mime, T, :Package)`  triggers `using Package` before attempting to write object of type `T` in format `mime`.
""" ->
function add_mime{sym,T}(::MIME{sym}, ::Type{T}, pkg::Symbol)
    list = get(mimedict, sym, Any[])
    mimedict[sym] = push!(list, (T,pkg))
end

@doc "`add_loader(fmt, :Package)` triggers `using Package` before loading format `fmt`" -> add_loader
@doc "`add_saver(fmt, :Package)` triggers `using Package` before saving format `fmt`" -> add_saver
