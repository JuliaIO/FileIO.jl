# World age issue

## Motivation: lazy loading

The goal of FileIO is to provide a unified IO frontend so that users can easily deal with file IO
with the simple `load`/`save` functions. The actual IO work will be dispatched to various IO
backends. For instance, [PNGFiles.jl](https://github.com/JuliaIO/PNGFiles.jl) is used to load PNG
format images. If `using FileIO` were to load all registered IO backends, then it would be very slow
to load, hurting all users of FileIO. For any given user, most of those backends would also be
unnecessary -- for example, people who don't do image processing probably don't want to load any
thing related to image IO.

To avoid such unnecessary loading latency, FileIO defers package loading until it's actually used.
For instance, when you use FileIO, you'll probably observe something like this:

```julia-repl
julia> using TestImages, FileIO

julia> path = testimage("cameraman"; download_only=true)
"/home/jc/.julia/artifacts/27a4c26bcdd47eb717bee089ec231a899cb8ef69/cameraman.tif"

julia> load(path) # actual backend loading happens here
[ Info: Precompiling ImageIO [82e4d734-157c-48bb-816b-45c225c6df19]
[ Info: Precompiling TiffImages [731e570b-9d59-4bfa-96dc-6df516fadf69]
...
```

ImageIO and TiffImages were loaded because the file in `path` was detected to be a TIFF image, well
after FileIO was loaded into the session.

## The hidden issue

Although this lazy-loading trick reduces the time needed for `using FileIO`, it isn't normal
practice in Julia because it introduces a so-called _world age issue_ or _world age problem_. The
world age issue happens when you call methods that get compiled in a newer "world" (get compiled
after initial compilation finishes) than the one you called them from.

Let's demonstrate the problem concretely. In case you don't have a suitable file to play with, let's
first create one:

```julia-repl
julia> using IndirectArrays, ImageCore

julia> img = IndirectArray(rand(1:5, 4, 4), rand(RGB, 5))
4×4 IndirectArray{RGB{Float64}, 2, Int64, Matrix{Int64}, Vector{RGB{Float64}}}:
[...]

julia> save("indexed_image.png", img)
```

Now, **reopen a new julia REPL** (this is crucial for demonstrating the problem) and call `load`
from **within a function** (this is also crucial):

```julia-repl
julia> using FileIO

julia> f() = size(load("indexed_image.png"))
f (generic function with 1 method)

julia> f()
ERROR: MethodError: no method matching size(::IndirectArrays.IndirectArray{ColorTypes.RGB{FixedPointNumbers.N0f8}, 2, UInt8, Matrix{UInt8}, OffsetArrays.OffsetVector{ColorTypes.RGB{FixedPointNumbers.N0f8}, Vector{ColorTypes.RGB{FixedPointNumbers.N0f8}}}})
The applicable method may be too new: running in world age 32382, while current world is 32416.
Closest candidates are:
  size(::IndirectArrays.IndirectArray) at ~/.julia/packages/IndirectArrays/BUQO3/src/IndirectArrays.jl:52 (method too new to be called from this world context.)
  size(::AbstractArray{T, N}, ::Any) where {T, N} at abstractarray.jl:42
  size(::Union{LinearAlgebra.Adjoint{T, var"#s880"}, LinearAlgebra.Transpose{T, var"#s880"}} where {T, var"#s880"<:(AbstractVector)}) at /Applications/Julia-1.8.app/Contents/Resources/julia/share/julia/stdlib/v1.8/LinearAlgebra/src/adjtrans.jl:173
  ...
Stacktrace:
 [1] f()
   @ Main ./REPL[2]:1
 [2] top-level scope
   @ REPL[3]:1
```

To understand why this happened, you have to understand the order of events:

1. When calling `f()` from the REPL, Julia first compiled `f`. Importantly, when compiling, Julia
   didn't know what type of object was going to be returned by `load`, so in the compiled code it
   waits to see what object actually gets returned before figuring out which method of `size` to
   call. (This is called _runtime dispatch_.)
2. It queried the file, recognized a PNG file, and _loaded the ImageIO and PNGFiles packages_. (It's
   for the loading of these packages that you needed to start a fresh Julia session.)
3. FileIO calls the appropriate PNG-specific `load` function in PNGFiles. (We'll have more to say
   about this step further below.) This causes an image to be returned, which is an array of a type
   defined by the IndirectArrays package (a dependency of PNGFiles).
4. `f` calls `size` on the returned image. However, this fails, because at the time you called `f`,
   the IndirectArrays package wasn't loaded.

In other words, `size` method for `IndirectArray` lives in a world that's newer than the one from
which you called `f()`. This leads to the observed error.

!!! note
    World age is crucial to Julia's ability to allow you to _redefine_ methods interactively, but
    the error we're illustrating is an unfortunate side-effect.

The good news is it's easy to fix, just try calling `f()` again:

```julia-repl
julia> f()
(4, 4)
```

The second `f()` works because this time you're calling `f()` in the latest world age with the
necessary `size(::IndirectArray)` already defined. In essence, you fast-forward to the latest world
with each statement you type at the REPL.

## Solutions

### `Base.invokelatest`

One solution is to make the call to `size` via `Base.invokelatest`, which exists explicitly to work
around this world-age dispatch problem. Literally, `invokelatest` dispatches the supplied call using
the latest world age (which may be newer than when you typed `f()` at the REPL). **In a fresh Julia
session**,

```julia-repl
julia> using FileIO

julia> f() = Base.invokelatest(size, load("indexed_image.png"))
f (generic function with 1 method)

julia> f()
(4, 4)
```

!!! note
    In step 3 above ("FileIO calls the appropriate PNG-specific `load` function in PNGFiles"),
    the call to the `load` function defined in PNGFiles is made via `invokelatest`.
    Otherwise, even ordinary interactive usage of FileIO (without burying `load` inside a function)
    would cause world-age errors.

!!! warning
    Using `invokelatest` slows your code considerably. Use it only when absolutely necessary.

### Eagerly load the required packages first

Another solution to the world age issue is simple and doesn't have long-term downsides: **eagerly
load the needed packages**. For instance, if you're seeing world age issue complaining methods
related to `IndirectArray`, then load IndirectArrays eagerly:

```julia-repl
julia> using FileIO, IndirectArrays # try this on a new Julia REPL

julia> f() = size(load("indexed_image.png"))
f (generic function with 1 method)

julia> f()
(4, 4)
```

Thus if you want to build a package, it could be something like this:

```julia
module MyFancyPackage

# This ensures that whoever loads `MyFancyPackage`, he has IndirectArrays loaded and
# thus avoid the world age issue.
using IndirectArrays, FileIO

f(file) = length(load(file))
end
```

Enjoy the FileIO and its lazy loading, but be aware that its speedy loading comes with some caveats.
