"""
`LoaderError` should be thrown when loader library code fails, and other libraries should
be given the chance to recover from the error.  Reports the library name and an error message:
LoaderError("ImageMagick", "Foo not available")
"""
struct LoaderError <: Exception
    library::String
    msg::String
end
Base.showerror(io::IO, e::LoaderError) = println(io, e.library, " load error: ",
                                                 e.msg, "\n  Will try next loader.")

"""
`WriterError` should be thrown when writer library code fails, and other libraries should
be given the chance to recover from the error.  Reports the library name and an error message:
WriterError("ImageMagick", "Foo not available")
"""
struct WriterError <: Exception
    library::String
    msg::String
end
Base.showerror(io::IO, e::WriterError) = println(
    io, e.library, " writer error: ",
    e.msg, "\n  Will try next writer."
)

"""
`NotInstalledError` should be thrown when a library is currently not installed.
"""
struct NotInstalledError <: Exception
    library::Symbol
    message::String
end
Base.showerror(io::IO, e::NotInstalledError) = println(io, e.library, " is not installed.")

"""
`UnknownFormat` gets thrown when FileIO can't recognize the format of a file.
"""
struct UnknownFormat{T <: Formatted} <: Exception
    format::T
end
Base.showerror(io::IO, e::UnknownFormat) = println(io, e.format, " couldn't be recognized by FileIO.")


"""
Handles error as soon as they get thrown while doing IO
"""
function handle_current_error(e, library, islast::Bool)
    bt = catch_backtrace()
    bts = sprint(io->Base.show_backtrace(io, bt))
    message = islast ? "" : "\nTrying next loading library! Please report this issue on the Github page for $library"
    @warn string(e, bts, message)
end
handle_current_error(e::NotInstalledError) = @warn string("lib ", e.library, " not installed, trying next library")


struct SpecError <: Exception
    mod::Module
    call::Symbol
end
Base.showerror(io::IO, e::SpecError) = print(io, e.mod, " is missing $(e.call) and fileio_$(e.call)")

"""
Handles a list of thrown errors after no IO library was found working
"""
function handle_exceptions(exceptions::Vector, action)
    # first show all errors when there are more then one
    multiple = length(exceptions) > 1
    println(stderr, "Error$(multiple ? "s" : "") encountered while $action.")
    if multiple
        println("All errors:")
        println("===========================================")
        for (err, file) in exceptions
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

handle_error(e, q) = throw(e)

function handle_error(e::NotInstalledError, q)
    println("Library \"", e.library, "\" is not installed but is recommended as a library to load format: \"", file_extension(q), "\"")
    rethrow(e)
end
