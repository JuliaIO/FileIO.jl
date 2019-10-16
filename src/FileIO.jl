module FileIO

export DataFormat,
       File,
       Formatted,
       Stream,
       @format_str,
       add_format,
       del_format,
       add_loader,
       add_saver,
       filename,
       file_extension,
       load,
       loadstreaming,
       magic,
       query,
       save,
       savestreaming,
       skipmagic,
       stream,
       unknown,
       metadata

import Base.showerror
using Base: RefValue
using Pkg

include("types.jl")
include("registry_setup.jl")
include("query.jl")
include("error_handling.jl")
include("loadsave.jl")
include("mimesave.jl")
include("registry.jl")


"""
`FileIO` API (brief summary, see individual functions for more detail):

- `format"PNG"`: specifies a particular defined format
- `File{fmt}` and `Stream{fmt}`: types of objects that declare that a resource has a particular format `fmt`

- `load([filename|stream])`: read data in formatted file, inferring the format
- `load(File(format"PNG",filename))`: specify the format manually
- `loadstreaming([filename|stream])`: similar to `load`, except that it returns an object that can be read from
- `save(filename, data...)` for similar operations involving saving data
- `savestreaming([filename|stream])`: similar to `save`, except that it returns an object that can be written to

- `io = open(f::File, args...)` opens a file
- `io = stream(s::Stream)` returns the IOStream from the query object `s`

- `query([filename|stream])`: attempt to infer the format of `filename`
- `unknown(q)` returns true if a query can't be resolved
- `skipmagic(io, fmt)` sets the position of `io` to just after the magic bytes
- `magic(fmt)` returns the magic bytes for format `fmt`
- `info(fmt)` returns `(magic, extensions)` for format `fmt`

- `add_format(fmt, magic, extension)`: register a new format
- `add_loader(fmt, :Package)`: indicate that `Package` supports loading files of type `fmt`
- `add_saver(fmt, :Package)`: indicate that `Package` supports saving files of type `fmt`
"""
FileIO

end
