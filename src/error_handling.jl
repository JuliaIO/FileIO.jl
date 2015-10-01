
@doc """
`LoaderError` should be thrown when loader library code fails, and other libraries should
be given the chance to recover from the error.  Reports the library name and an error message:
LoaderError("ImageMagick", "Foo not available")
""" ->
immutable LoaderError <: Exception
    library::UTF8String
    msg::UTF8String
end
Base.showerror(io::IO, e::LoaderError) = println(io, e.library, " load error: ",
                                                 msg, "\n  Will try next loader.")

@doc """
`WriterError` should be thrown when writer library code fails, and other libraries should
be given the chance to recover from the error.  Reports the library name and an error message:
WriterError("ImageMagick", "Foo not available")
""" ->
immutable WriterError <: Exception
    library::UTF8String
    msg::UTF8String
end
Base.showerror(io::IO, e::WriterError) = println(
    io, e.library, " writer error: ",
    msg, "\n  Will try next writer."
)


@doc """
`NotInstalledError` should be thrown when a library is currently not installed.
""" ->
immutable NotInstalledError <: Exception
    library::Symbol
    message::UTF8String
end
Base.showerror(io::IO, e::NotInstalledError) = println(io, e.library, " is not installed.")

function handle_error(e)
	rethrow(last(first(e)))
end

function handle_error(e::LoaderError)
	

end