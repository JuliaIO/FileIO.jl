"""
    LoaderError <: Exception

`LoaderError` should be thrown when loader library code fails, and other libraries should
be given the chance to recover from the error.  Reports the library name and an error message:
```julia
LoaderError("ImageMagick", "Foo not available")
```
"""
struct LoaderError <: Exception
    library::String
    msg::String
    ex
end
Base.showerror(io::IO, e::LoaderError) = println(IOContext(io, :limit=>true), e.library, " load error: ",
                                                 e.msg, "\n  due to ", e.ex, "\n  Will try next loader.")

"""
    WriterError <: Exception

`WriterError` should be thrown when writer library code fails, and other libraries should
be given the chance to recover from the error.  Reports the library name and an error message:
```julia
WriterError("ImageMagick", "Foo not available")
```
"""
struct WriterError <: Exception
    library::String
    msg::String
    ex
end
Base.showerror(io::IO, e::WriterError) = println(
    IOContext(io, :limit=>true), e.library, " writer error: ",
    e.msg, "\n  due to ", e.ex, "\n  Will try next loader."
)


struct SpecError <: Exception
    mod::Module
    call::Symbol
end
Base.showerror(io::IO, e::SpecError) = print(io, e.mod, " is missing $(e.call) and fileio_$(e.call)")

"""
    handle_exceptions(exceptions::Vector, action)

Handles a list of thrown errors after no IO library was found working
"""
function handle_exceptions(exceptions::Vector, action)
    # first show all errors when there are more then one
    multiple = length(exceptions) > 1
    println(stderr, "Error$(multiple ? "s" : "") encountered while $action.")
    if multiple
        println("All errors:")
        println("===========================================")
        for (err, file, bt) in exceptions
            showerror(stdout, err)
            println("\n===========================================")
        end
    end
    # then handle all errors.
    # this way first fatal exception throws and user can still see all errors
    # TODO, don't throw, if it contains a NotInstalledError?!
    println(stderr, "\nFatal error:")
    for exception in exceptions
        continue_ = handle_error(exception...)
        continue_ || break
    end
end

function handle_error(e, q, bt)
    if VERSION >= v"1.13.0-DEV.927"
        throw(CapturedException(e, bt))
    else
        throw(CapturedException(e, trim!(stacktrace(bt))))
    end
end

function trim!(sfs)
    i = firstindex(sfs)
    while i <= lastindex(sfs)
        sf = sfs[i]
        if Base.StackTraces.is_top_level_frame(sf)
            deleteat!(sfs, i+1:lastindex(sfs))
            break
        end
        i += 1
    end
    return sfs
end
