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
