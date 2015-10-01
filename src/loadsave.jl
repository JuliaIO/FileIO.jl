const sym2loader = Dict{Symbol,Vector{Symbol}}()
const sym2saver  = Dict{Symbol,Vector{Symbol}}()
const mimedict   = Dict{Symbol,Vector{@compat(Tuple{DataType, Symbol})}}()

function is_installed(pkg::Symbol)
    isdefined(pkg) && isa(Main.(pkg), Module) && return true # is a module defined in Main scope
    path = Base.find_in_path(string(pkg)) # hacky way to determine if a Package is installed
    path == nothing && return false
    return isfile(path)
end

function save_import(pkg::Symbol)
    !is_installed(pkg)      && throw(NotInstalledError(pkg, ""))
    !isdefined(Main, pkg)   && eval(Main, Expr(:import, pkg))
    return Main.(pkg)
end


for (applicable_, add_, dict_) in (
        (:applicable_loaders, :add_loader, :sym2loader),
        (:applicable_savers,  :add_saver,  :sym2saver))
    @eval begin
        $applicable_{sym}(::@compat(Union{Type{DataFormat{sym}}, Formatted{DataFormat{sym}}})) = get($dict_, sym, [:FileIO]) # if no loader is declared, fallback to FileIO
        function $add_{sym}(::Type{DataFormat{sym}}, pkg::Symbol)
            list = get($dict_, sym, Symbol[])
            $dict_[sym] = push!(list, pkg)
        end
    end
end

applicable_mime{sym}(::MIME{sym}) = get(mimedict, sym, [(Any, :FileIO)])

@doc """
`add_mime(mime, T, :Package)`  triggers `using Package` before attempting to write object of type `T` in format `mime`.
""" ->
function add_mime{sym,T}(::MIME{sym}, ::Type{T}, pkg::Symbol)
    list = get(mimedict, sym, @compat(Tuple{DataType, Symbol})[])
    mimedict[sym] = push!(list, (T,pkg))
end

@doc "`add_loader(fmt, :Package)` triggers `using Package` before loading format `fmt`" -> add_loader
@doc "`add_saver(fmt, :Package)` triggers `using Package` before saving format `fmt`" -> add_saver


@doc """
- `load(filename)` loads the contents of a formatted file, trying to infer
the format from `filename` and/or magic bytes in the file.
- `load(strm)` loads from an `IOStream` or similar object. In this case,
the magic bytes are essential.
- `load(File(format"PNG",filename))` specifies the format directly, and bypasses inference.
- `load(f; options...)` passes keyword arguments on to the loader.
""" ->
function load(s::@compat(Union{AbstractString,IO}), args...; options...)
    q           = query(s)
    libraries   = applicable_loaders(q)
    failures    = Any[]
    for library in libraries
        try
            Library = save_import(library)
            return Library.load(q, args...; options...)
        catch e
            push!(failures, (e, q, args, options))
        end
    end
    handle_error(failures)
end

@doc """
- `save(filename, data...)` saves the contents of a formatted file,
trying to infer the format from `filename`.
- `save(Stream(format"PNG",io), data...)` specifies the format directly, and bypasses inference.
- `save(f, data...; options...)` passes keyword arguments on to the saver.
""" ->
function save(s::@compat(Union{AbstractString,IO}), data...; options...)
    q           = query(s)
    libraries   = applicable_savers(q)
    failures    = Any[]
    for library in libraries
        try
            Library = save_import(library)
            return Library.save(q, data...; options...)
        catch e
            push!(failures, (library, e))
        end
    end
    handle_error(failures)
end

# Forced format
function save{sym}(df::Type{DataFormat{sym}}, f::AbstractString, data...; options...)
    libraries = applicable_savers(df)
    save_import(libraries[1])
    save(File(DataFormat{sym}, f), data...; options...)
end

function save{sym}(df::Type{DataFormat{sym}}, s::IO, data...; options...)
    libraries = applicable_savers(df)
    save_import(libraries[1])
    save(Stream(DataFormat{sym}, s), data...; options...)
end

function Base.writemime(io::IO, mime::MIME, x)
    handlers = applicable_mime(mime)
    failures = Any[]
    for (T,pkg) in handlers
        isa(x, T) || continue
        try
            save_import(pkg)
            return writemime(Stream(DataFormat{pkg}, io), mime, x)
        catch e
            push!(failures, (library, e))
        end
    end
    handle_error(failures)
end

# Fallbacks
load{F}(f::Formatted{F}, args...; options...) = error("No load function defined for format ", F, " with filename ", filename(f))
save{F}(f::Formatted{F}, data...; options...) = error("No save function defined for format ", F, " with filename ", filename(f))
