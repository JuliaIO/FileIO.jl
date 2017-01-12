const sym2loader = Dict{Symbol,Vector{Symbol}}()
const sym2saver  = Dict{Symbol,Vector{Symbol}}()

function is_installed(pkg::Symbol)
    isdefined(pkg) && isa(@compat(getfield(Main, pkg)), Module) && return true # is a module defined in Main scope
    path = Base.find_in_path(string(pkg)) # hacky way to determine if a Package is installed
    path == nothing && return false
    return isfile(path)
end

function checked_import(pkg::Symbol)
    !is_installed(pkg)      && throw(NotInstalledError(pkg, ""))
    !isdefined(Main, pkg)   && eval(Main, Expr(:import, pkg))
    return @compat(getfield(Main, pkg))
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


"`add_loader(fmt, :Package)` triggers `using Package` before loading format `fmt`"
add_loader
"`add_saver(fmt, :Package)` triggers `using Package` before saving format `fmt`"
add_saver


"""
- `load(filename)` loads the contents of a formatted file, trying to infer
the format from `filename` and/or magic bytes in the file.
- `load(strm)` loads from an `IOStream` or similar object. In this case,
the magic bytes are essential.
- `load(File(format"PNG",filename))` specifies the format directly, and bypasses inference.
- `load(f; options...)` passes keyword arguments on to the loader.
"""
load(s::@compat(Union{AbstractString,IO}), args...; options...) =
    load(query(s), args...; options...)

"""
- `save(filename, data...)` saves the contents of a formatted file,
trying to infer the format from `filename`.
- `save(Stream(format"PNG",io), data...)` specifies the format directly, and bypasses inference.
- `save(f, data...; options...)` passes keyword arguments on to the saver.
"""
save(s::@compat(Union{AbstractString,IO}), data...; options...) =
    save(query(s), data...; options...)

# Forced format
function save{sym}(df::Type{DataFormat{sym}}, f::AbstractString, data...; options...)
    libraries = applicable_savers(df)
    checked_import(libraries[1])
    eval(Main, :($save($File($(DataFormat{sym}), $f),
                       $data...; $options...)))
end

function save{sym}(df::Type{DataFormat{sym}}, s::IO, data...; options...)
    libraries = applicable_savers(df)
    checked_import(libraries[1])
    eval(Main, :($save($Stream($(DataFormat{sym}), $s),
                       $data...; $options...)))
end


# Fallbacks
function load{F}(q::Formatted{F}, args...; options...)
    if unknown(q)
        isfile(filename(q)) || open(filename(q))  # force systemerror
        throw(UnknownFormat(q))
    end
    libraries = applicable_loaders(q)
    failures  = Any[]
    for library in libraries
        try
            Library = checked_import(library)
            if !has_method_from(methods(Library.load), Library)
                throw(LoaderError(string(library), "load not defined"))
            end
            return eval(Main, :($(Library.load)($q, $args...; $options...)))
        catch e
            push!(failures, (e, q))
        end
    end
    handle_exceptions(failures, "loading \"$(filename(q))\"")
end
function save{F}(q::Formatted{F}, data...; options...)
    unknown(q) && throw(UnknownFormat(q))
    libraries = applicable_savers(q)
    failures  = Any[]
    for library in libraries
        try
            Library = checked_import(library)
            if !has_method_from(methods(Library.save), Library)
                throw(WriterError(string(library), "save not defined"))
            end
            return eval(Main, :($(Library.save)($q, $data...; $options...)))
        catch e
            push!(failures, (e, q))
        end
    end
    handle_exceptions(failures, "saving \"$(filename(q))\"")
end

function has_method_from(mt, Library)
    for m in mt
        if getmodule(m) == Library
            return true
        end
    end
    false
end

if VERSION < v"0.5.0-dev+3543"
    getmodule(m) = m.func.code.module
else
    getmodule(m) = m.module
end
