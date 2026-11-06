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
                    # See if a package by that name has already been loaded (e.g., a package
                    # registering itself from its `__init__`)
                    ids = PkgId[k for k in keys(Base.loaded_modules) if k.name == pkgname]
                    length(ids) == 1 && (id = only(ids))
                end
                if id === nothing
                    throw(ArgumentError("could not resolve package \"$pkgname\" from the active environment; pass it as a Module or as `:$pkgname => uuid`"))
                end
            end
            $add_(sym, id)
        end
    end
end