const sym2loader = Dict{Symbol,Vector{Symbol}}()
const sym2saver  = Dict{Symbol,Vector{Symbol}}()
const load_locker = Base.ReentrantLock()

is_installed(pkg::Symbol) = get(Pkg.installed(), string(pkg), nothing) != nothing

function _findmod(f::Symbol)
    for (u,v) in Base.loaded_modules
        (Symbol(v) == f) && return u
    end
    nothing
end
function topimport(modname)
    @eval Base.__toplevel__  import $modname
    u = _findmod(modname)
    @eval $modname = Base.loaded_modules[$u]
end

function checked_import(pkg::Symbol)
    lock(load_locker) do
        # kludge for test suite
        if isdefined(Main, pkg)
            m1 = getfield(Main, pkg)
            isa(m1, Module) && return m1
        end
        if isdefined(FileIO, pkg)
            m1 = getfield(FileIO, pkg)
            isa(m1, Module) && return m1
        end
        m = _findmod(pkg)
        m == nothing || return Base.loaded_modules[m]
        topimport(pkg)
        return Base.loaded_modules[_findmod(pkg)]
    end
end

applicable_error(applicable, sym) = error("No $applicable found for $sym")

for (applicable_, add_, dict_) in (
        (:applicable_loaders, :add_loader, :sym2loader),
        (:applicable_savers,  :add_saver,  :sym2saver))
    @eval begin
        function $applicable_(@nospecialize(fmt::Union{Type{<:DataFormat}, Formatted}))
            sym = formatname(fmt)
            if haskey($dict_, sym)
                return $dict_[sym]
            end
            Base.invokelatest(applicable_error, $applicable_, sym)
        end
        function $add_(@nospecialize(fmt::Type{<:DataFormat}), pkg::Symbol)
            sym = formatname(fmt)
            list = get($dict_, sym, Symbol[])
            $dict_[sym] = push!(list, pkg)
        end
    end
end


"""
    add_loader(fmt, :Package)
    add_loader(fmt, [:Package, specifiers...])

Declare that format `fmt` can be loaded with package `:Package`.
Specifiers include `OSX`, `Unix`, `Windows` and `Linux` to restrict usage to particular operating systems.
"""
add_loader

"""
    add_saver(fmt, :Package)
    add_saver(fmt, [:Package, specifiers...])

Declare that format `fmt` can be saved with package `:Package`.
Specifiers include `OSX`, `Unix`, `Windows` and `Linux` to restrict usage to particular operating systems.
"""
add_saver

"""
- `load(filename)` loads the contents of a formatted file, trying to infer
the format from `filename` and/or magic bytes in the file.
- `load(strm)` loads from an `IOStream` or similar object. In this case,
there is no filename extension, so we rely on the magic bytes for format
identification.
- `load(File(format"PNG", filename))` specifies the format directly, and bypasses inference.
- `load(Stream(format"PNG", io))` specifies the format directly, and bypasses inference.
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
- `loadstreaming(strm)` loads the stream from an `IOStream` or similar object.
In this case, there is no filename extension, so we rely on the magic bytes
for format identification.
- `loadstreaming(File(format"WAV",filename))` specifies the format directly, and
bypasses inference.
- `loadstreaming(Stream(format"WAV", io))` specifies the format directly, and
bypasses inference.
- `loadstreaming(f; options...)` passes keyword arguments on to the loader.
"""
loadstreaming

"""
- `save(filename, data...)` saves the contents of a formatted file,
trying to infer the format from `filename`.
- `save(Stream(format"PNG",io), data...)` specifies the format directly, and bypasses inference.
- `save(File(format"PNG",filename), data...)` specifies the format directly, and bypasses inference.
- `save(f, data...; options...)` passes keyword arguments on to the saver.
"""
save

"""
Some packages may implement a streaming API, where the contents of the file can
be written in chunks, rather than all at once. These higher-level streams should
accept formatted objects, like an image or chunk of video or audio.

- `savestreaming(filename, data...)` saves the contents of a formatted file,
trying to infer the format from `filename`.
- `savestreaming(File(format"WAV",filename))` specifies the format directly, and
bypasses inference.
- `savestreaming(Stream(format"WAV", io))` specifies the format directly, and
bypasses inference.
- `savestreaming(f, data...; options...)` passes keyword arguments on to the saver.
"""
savestreaming

# if a bare filename or IO stream are given, query for the format and dispatch
# to the formatted handlers below
for fn in (:load, :loadstreaming, :metadata)
    @eval $fn(file, args...; options...) = $fn(query(file), args...; options...)
end
for fn in (:save, :savestreaming)
    @eval $fn(file, args...; options...) = $fn(query(file; checkfile=false), args...; options...)
end

# return a save function, so you can do `thing_to_save |> save("filename.ext")`
save(file; options...) = data -> save(file, data; options...)

# Allow format to be overridden with first argument
function save(df::Type{DataFormat{sym}}, filename, data...; options...) where sym
    libraries = applicable_savers(df)
    checked_import(libraries[1])
    return Base.invokelatest(save, File(DataFormat{sym}, filename), data...; options...)
end

function savestreaming(df::Type{DataFormat{sym}}, s::IO, data...; options...) where sym
    libraries = applicable_savers(df)
    checked_import(libraries[1])
    return Base.invokelatest(savestreaming, Stream(DataFormat{sym}, s), data...; options...)
end

function save(df::Type{DataFormat{sym}}, s::IO, data...; options...) where sym
    libraries = applicable_savers(df)
    checked_import(libraries[1])
    return Base.invokelatest(save, Stream(DataFormat{sym}, s), data...; options...)
end

function savestreaming(df::Type{DataFormat{sym}}, filename, data...; options...) where sym
    libraries = applicable_savers(df)
    checked_import(libraries[1])
    return Base.invokelatest(savestreaming, File(DataFormat{sym}, filename), data...; options...)
end

# do-syntax for streaming IO
for fn in (:loadstreaming, :savestreaming)
    @eval function $fn(@nospecialize(f::Function), @nospecialize(args...); @nospecialize(kwargs...))
        str = $fn(args...; kwargs...)
        try
            f(str)
        finally
            close(str)
        end
    end
end

# Handlers for formatted files/streams

for fn in (:load, :loadstreaming, :metadata)
    fn_func_name = Symbol(fn, "_filename")
    gen2_func_name = Symbol("fileio_", fn)
    @eval function $fn(@nospecialize(q::Formatted), @nospecialize(args...); @nospecialize(options...))
        Base.invokelatest($fn_func_name, q, filename(q), args...; options...)
    end
    @eval function $fn_func_name(@nospecialize(q::Formatted), filename, @nospecialize(args...); @nospecialize(options...))
        if unknown(q)
            isfile(filename) || open(filename)  # force systemerror
            throw(UnknownFormat(q))
        end
        if q isa File
            !isfile(filename) && throw(ArgumentError("No file exists at given path: $(filename)"))
        end
        libraries = applicable_loaders(q)
        failures  = Any[]
        for library in libraries
            try
                Library = checked_import(library)
                if isdefined(Library, $(QuoteNode(gen2_func_name)))
                    return Base.invokelatest(Library.$gen2_func_name, q, args...; options...)
                end
                if !has_method_from(methods(Library.$fn), Library)
                    throw(LoaderError(string(library), "$($fn) not defined"))
                end
                return Base.invokelatest(Library.$fn, q, args...; options...)
            catch e
                push!(failures, (e, q))
            end
        end
        handle_exceptions(failures, "loading $(repr(filename))")
    end
end

for fn in (:save, :savestreaming)
    gen2_func_name = Symbol("fileio_", fn)
    @eval function $fn(@nospecialize(q::Formatted), @nospecialize(data...); @nospecialize(options...))
        unknown(q) && throw(UnknownFormat(q))
        if q isa File
            isdir(filename(q)) && throw(ArgumentError("Given file path is a directory: $(filename(q))"))
            !isdir(dirname(filename(q))) && mkpath(dirname(filename(q)))
        end
        libraries = applicable_savers(q)
        failures  = Any[]
        for library in libraries
            try
                Library = checked_import(library)
                if isdefined(Library, $(QuoteNode(gen2_func_name)))
                    return Base.invokelatest(Library.$gen2_func_name, q, data...; options...)
                end
                if !has_method_from(methods(Library.$fn), Library)
                    throw(WriterError(string(library), "$($fn) not defined"))
                end
                return Base.invokelatest(Library.$fn, q, data...; options...)
            catch e
                push!(failures, (e, q))
            end
        end
        handle_exceptions(failures, "saving $(repr(filename(q)))")
    end
end

# returns true if the given method table includes a method defined by the given
# module, false otherwise
function has_method_from(mt, Library)
    for m in mt
        if getmodule(m) == Library
            return true
        end
    end
    false
end

getmodule(m) = m.module
