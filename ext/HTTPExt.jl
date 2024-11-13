module HTTPExt

if isdefined(Base, :get_extension)
    using FileIO
    using HTTP
else
    using ..FileIO
    using ..HTTP
end

FileIO.load(uri::HTTP.URI) = load(IOBuffer(HTTP.get(uri).body))

end # module