const sym2loader = Dict{Symbol,Vector{Symbol}}()
const sym2saver  = Dict{Symbol,Vector{Symbol}}()

function is_installed(pkg::Symbol)
    isdefined(Main, pkg) && isa(getfield(Main, pkg), Module) && return true # is a module defined in Main scope
    path = Base.find_in_path(string(pkg)) # hacky way to determine if a Package is installed
    path == nothing && return false
    return isfile(path)
end

function checked_import(pkg::Symbol)
    isdefined(Main, pkg) && return getfield(Main, pkg)
    isdefined(FileIO, pkg) && return getfield(FileIO, pkg)
    !is_installed(pkg) && throw(NotInstalledError(pkg, ""))
    !isdefined(Main, pkg) && eval(Main, Expr(:import, pkg))
    return getfield(Main, pkg)
end


for (applicable_, add_, dict_) in (
        (:applicable_loaders, :add_loader, :sym2loader),
        (:applicable_savers,  :add_saver,  :sym2saver))
    @eval begin
        function $applicable_{sym}(::Union{Type{DataFormat{sym}}, Formatted{DataFormat{sym}}})
            if haskey($dict_, sym)
                return $dict_[sym]
            end
            error("No $($applicable_) found for $(sym)")
        end
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


for fn in (:load, :loadstreaming, :save, :savestreaming)
    @eval $fn(s::@compat(Union{AbstractString,IO}), args...; options...) =
        $fn(query(s), args...; options...)
end

function save(s::Union{AbstractString,IO}; options...)
    data -> save(s, data; options...)
end

# Forced format
function save{sym}(df::Type{DataFormat{sym}}, f::AbstractString, data...; options...)
    libraries = applicable_savers(df)
    checked_import(libraries[1])
    eval(Main, :($save($File($(DataFormat{sym}), $f),
                       $data...; $options...)))
end

function savestreaming{sym}(df::Type{DataFormat{sym}}, s::IO, data...; options...)
    libraries = applicable_savers(df)
    checked_import(libraries[1])
    eval(Main, :($savestreaming($Stream($(DataFormat{sym}), $s),
                                $data...; $options...)))

function save{sym}(df::Type{DataFormat{sym}}, s::IO, data...; options...)
    libraries = applicable_savers(df)
    checked_import(libraries[1])
    eval(Main, :($save($Stream($(DataFormat{sym}), $s),
                       $data...; $options...)))

function savestreaming{sym}(df::Type{DataFormat{sym}}, f::AbstractString, data...; options...)
    libraries = applicable_savers(df)
    checked_import(libraries[1])
    eval(Main, :($savestreaming($File($(DataFormat{sym}), $f),
                                $data...; $options...)))
end

# do-syntax for streaming IO
for fn in (:loadstreaming, :savestreaming)
    @eval function $fn(f::Function, args...; kwargs...)
        str = $fn(args...; kwargs...)
        try
            ret = f(str)
        finally
            close(str)
        end

        ret
    end
end

# Fallbacks
for fn in (:load, :loadstreaming)
    @eval function $fn{F}(q::Formatted{F}, args...; options...)
        if unknown(q)
            isfile(filename(q)) || open(filename(q))  # force systemerror
            throw(UnknownFormat(q))
        end
        libraries = applicable_loaders(q)
        failures  = Any[]
        for library in libraries
            try
                Library = checked_import(library)
                if !has_method_from(methods(Library.$fn), Library)
                    throw(LoaderError(string(library), "$fn not defined"))
                end
                return eval(Main, :($(Library.$fn)($q, $args...; $options...)))
            catch e
                push!(failures, (e, q))
            end
        end
        handle_exceptions(failures, "loading \"$(filename(q))\"")
    end
end
for fn in (:save, :savestreaming)
    @eval function $fn{F}(q::Formatted{F}, data...; options...)
        unknown(q) && throw(UnknownFormat(q))
        libraries = applicable_savers(q)
        failures  = Any[]
        for library in libraries
            try
                Library = checked_import(library)
                if !has_method_from(methods(Library.$fn), Library)
                    throw(WriterError(string(library), "$fn not defined"))
                end
                return eval(Main, :($(Library.$fn)($q, $data...; $options...)))
            catch e
                push!(failures, (e, q))
            end
        end
        handle_exceptions(failures, "saving \"$(filename(q))\"")
    end
end

"""
- `load(filename)` loads the contents of a formatted file, trying to infer
the format from `filename` and/or magic bytes in the file.
- `load(strm)` loads from an `IOStream` or similar object. In this case,
the magic bytes are essential.
- `load(File(format"PNG",filename))` specifies the format directly, and bypasses inference.
- `load(f; options...)` passes keyword arguments on to the loader.
"""
load

"""
Some packages may implement a streaming API, where the contents of the file can
be read in chunks and processed, rather than all at once. Reading from these
higher-level streams should return a formatted object, like an image or chunk of
video or audio.

- `loadstreaming(filename)` loads the contents of a formatted file, trying to infer
the format from `filename` and/or magic bytes in the file. It returns a streaming
type that can be read from in chunks, rather than loading the whole contents all
at once
- `loadstreaming(strm)` loads the stream from an `IOStream` or similar object. In this case,
the magic bytes are essential.
- `load(File(format"PNG",filename))` specifies the format directly, and bypasses inference.
- `load(f; options...)` passes keyword arguments on to the loader.
"""
loadstreaming

"""
- `save(filename, data...)` saves the contents of a formatted file,
trying to infer the format from `filename`.
- `save(Stream(format"PNG",io), data...)` specifies the format directly, and bypasses inference.
- `save(f, data...; options...)` passes keyword arguments on to the saver.
"""
save

"""
Some packages may implement a streaming API, where the contents of the file can
be written in chunks, rather than all at once. These higher-level streams should
accept formatted objects, like an image or chunk of video or audio.

- `savestreaming(filename, data...)` saves the contents of a formatted file,
trying to infer the format from `filename`.
- `savestreaming(Stream(format"PNG",io), data...)` specifies the format directly, and bypasses inference.
- `savestreaming(f, data...; options...)` passes keyword arguments on to the saver.
"""
savestreaming

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
