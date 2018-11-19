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


"""
Handles a list of thrown errors after no IO library was found working
"""
function handle_exceptions(exceptions::Vector, action)
    # first show all errors when there are more then one
    multiple = length(exceptions) > 1
    println(stderr, "Error$(multiple ? "s" : "") encountered while $action.")
    if multiple
        println("All errors:")
        for (err, file) in exceptions
            println("   ", err)
        end
    end
    # then handle all errors.
    # this way first fatal exception throws and user can still see all errors
    # TODO, don't throw, if it contains a NotInstalledError?!
    println(stderr, "Fatal error:")
    for exception in exceptions
        continue_ = handle_error(exception...)
        continue_ || break
    end
end

handle_error(e, q) = throw(e)

function handle_error(e::NotInstalledError, q)
    println("Library \"", e.library, "\" is not installed but is recommended as a library to load format: \"", file_extension(q), "\"")
    !isinteractive() && rethrow(e) # if we're not in interactive mode just throw
    while true
        println("Should we install \"", e.library, "\" for you? (y/n):")
        input = lowercase(chomp(strip(readline(stdin))))
        if input == "y"
            @info(string("Start installing ", e.library, "..."))
            Pkg.add(string(e.library))
            return false # don't continue
        elseif input == "n"
            @info(string("Not installing ", e.library))
            return true # User does not install, continue going through errors.
        else
            println("$input is not a valid choice. Try typing y or n")
        end
    end
    true # User does not install, continue going through errors.
end
