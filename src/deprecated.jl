# Deprecations added in 1.5.0, March 2021

function File(fmt::Type{DataFormat{sym}}, filename) where {sym}
    Base.depwarn("`File(format\"$sym\", filename)` is deprecated, please use `File{format\"$sym\"}(filename)` instead.", :File)
    return File{fmt}(filename)
end
function Stream(fmt::Type{DataFormat{sym}}, args...) where {sym}
    Base.depwarn("`Stream(format\"$sym\", filename)` is deprecated, please use `Stream{format\"$sym\"}(filename)` instead.", :Stream)
    return Stream{fmt}(args...)
end

# These aren't used here, but old versions of ImageIO expect them

function _findmod(f::Symbol)
    Base.depwarn("_findmod is deprecated and will be removed. Use `Base.require(::Base.PkgId)` instead.", :_findmod)
    for (u,v) in Base.loaded_modules
        (Symbol(v) == f) && return u
    end
    nothing
end
function topimport(modname)
    Base.depwarn("topimport is deprecated and will be removed. Use `Base.require(::Base.PkgId)` instead.", :topimport)
    @eval Base.__toplevel__  import $modname
    u = _findmod(modname)
    @eval $modname = Base.loaded_modules[$u]
end

# Legacy add_loader/add_saver
for add_ in (:add_loader, :add_saver)
    @eval begin
        function $add_(fmt, pkg)
            # TODO: delete this method in FileIO v2
            sym = isa(fmt, Symbol) ? fmt : formatname(fmt)::Symbol
            Base.depwarn(string($add_) * "(fmt, pkg::$(typeof(pkg))) is deprecated, supply `pkg` as a Module or `name=>uuid`", Symbol($add_))
            pkg === :MimeWriter && return $add_(sym, MimeWriter)
            # Try to look it up in the caller's environment
            pkgname = string(pkg)
            id = Base.identify_package(pkgname)
            if id === nothing
                # See if it's in Main
                pkgsym = Symbol(pkg)
                if isdefined(Main, pkgsym)
                    id = getfield(Main, pkgsym)
                    if !isa(id, Module)
                        id = nothing
                    end
                end
                if id === nothing
                    # Look it up in the registries. The tricky part here is supporting different Julia versions
                    ctx = Pkg.API.Context()
                    uuids = UUID[]
                    @static if Base.VERSION >= v"1.2"
                        if hasfield(typeof(ctx), :registries)
                            for reg in ctx.registries
                                append!(uuids, Pkg.Registry.uuids_from_name(reg, pkgname))
                            end
                        else
                            ctx = Pkg.API.Context!(ctx)
                            if isdefined(Pkg.Types, :find_registered!) && hasmethod(Pkg.Types.find_registered!, (typeof(ctx.env), Vector{String}))
                                Pkg.Types.find_registered!(ctx.env, [pkgname])
                            elseif isdefined(Pkg.Types, :find_registered!) && hasmethod(Pkg.Types.find_registered!, (typeof(ctx), Vector{String}))
                                Pkg.Types.find_registered!(ctx, [pkgname])
                            end
                            append!(uuids, get(ctx.env.uuids, pkgname, UUID[]))
                        end
                    else
                        Pkg.Types.find_registered!(ctx.env)
                        append!(uuids, get(ctx.env.uuids, pkgname, UUID[]))
                    end
                    isempty(uuids) && throw(ArgumentError("no UUID found for $pkg"))
                    length(uuids) == 1 || throw(ArgumentError("multiple UUIDs found for $pkg"))
                    id = PkgId(uuids[1], pkgname)
                end
            end
            $add_(sym, id)
        end
    end
end