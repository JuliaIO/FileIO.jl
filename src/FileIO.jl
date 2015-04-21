module FileIO

import Base: read,
             write,
             (==),
             open,
             abspath,
             readbytes,
             readall

export File,
       @file_str,
       readformats,
       writeformats,
       ending

include("core.jl")     

end # module
