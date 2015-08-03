const sym2loader = Dict{Symbol,Symbol}()
const sym2saver  = Dict{Symbol,Symbol}()

for (fchk,fadd,dct) in ((:check_loader, :add_loader, :sym2loader),
                        (:check_saver,  :add_saver,  :sym2saver))
    @eval begin
        function $fchk{sym}(::Formatted{DataFormat{sym}})
            if haskey($dct, sym)
                pkg = $dct[sym]
                if !isdefined(Main, pkg)
                    eval(Main, Expr(:using, pkg))
                end
            end
        end

        function $fadd{sym}(::Type{DataFormat{sym}}, pkg::Symbol)
            $dct[sym] = pkg
        end
    end
end

@doc "`add_loader(fmt, :Package)` forces `using Package` before loading format `fmt`" -> add_loader
@doc "`add_saver(fmt, :Package)` forces `using Package` before saving format `fmt`" -> add_saver
