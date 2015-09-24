const sym2loader = Dict{Symbol,Vector{Symbol}}()
const sym2saver  = Dict{Symbol,Vector{Symbol}}()

for (appl,fchk,fadd,dct) in ((:applicable_loaders, :check_loader, :add_loader, :sym2loader),
                        (:applicable_savers, :check_saver,  :add_saver,  :sym2saver))
    @eval begin
        $appl{sym}(::Formatted{DataFormat{sym}}) = get($dct, sym, [:nothing])
        function $fchk(pkg::Symbol)
            if !isdefined(Main, pkg)
                eval(Main, Expr(:using, pkg))
            end
        end
        function $fadd{sym}(::Type{DataFormat{sym}}, pkg::Symbol)
            list = get($dct, sym, Symbol[])
            $dct[sym] = push!(list, pkg)
        end
    end
end

@doc "`add_loader(fmt, :Package)` forces `using Package` before loading format `fmt`" -> add_loader
@doc "`add_saver(fmt, :Package)` forces `using Package` before saving format `fmt`" -> add_saver
