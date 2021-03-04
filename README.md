# FileIO

[![Build status](https://github.com/JuliaIO/FileIO.jl/actions/workflows/test.yml/badge.svg)](https://github.com/JuliaIO/FileIO.jl/actions/workflows/test.yml)
[![codecov](https://codecov.io/gh/JuliaIO/FileIO.jl/branch/master/graph/badge.svg?token=I0NjrZpJKh)](https://codecov.io/gh/JuliaIO/FileIO.jl)
[![](https://img.shields.io/badge/docs-stable-blue.svg)](https://JuliaIO.github.io/FileIO.jl/stable)

# FileIO.jl

FileIO aims to provide a common framework for detecting file formats
and dispatching to appropriate readers/writers.  The two core
functions in this package are called `load` and `save`, and offer
high-level support for formatted files (in contrast with julia's
low-level `read` and `write`).  To avoid name conflicts, packages that
provide support for standard file formats through functions named
`load` and `save` are encouraged to register with FileIO.

## Help

You can get an API overview by typing `?FileIO` at the REPL prompt.
Individual functions have their own help too, e.g., `?add_format`.

For more detailed help, including information about how you can add support
for additional file formats, see the [documentation](https://JuliaIO.github.io/FileIO.jl/stable).
