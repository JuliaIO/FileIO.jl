# World age issue

## Motivation: lazy loading

The goal of FileIO is to provide a unified IO frontend so that users can easily deal with file IO
with the simple `load`/`save` functions. The actual IO work will be dispatched to various IO backends.
For instance, [PNGFiles.jl](https://github.com/JuliaIO/PNGFiles.jl) is used to load PNG format images.
If `using FileIO` loads all registered IO backends, then it would bring a significant loading latency
to the entire ecosystem and most of them are unnecessary -- people don't do image processing probably
don't want to load any thing related to image IO.

To avoid such unnecessary loading latency, FileIO defers package loading until it's actually used.
For instance, when you use FileIO, you'll probably observe something like this:

```julia
julia> using TestImages, FileIO

julia> path = testimage("cameraman"; download_only=true)
"/home/jc/.julia/artifacts/27a4c26bcdd47eb717bee089ec231a899cb8ef69/cameraman.tif"

julia> load(path) # actual backend loading happens here
[ Info: Precompiling ImageIO [82e4d734-157c-48bb-816b-45c225c6df19]
[ Info: Precompiling TiffImages [731e570b-9d59-4bfa-96dc-6df516fadf69]
...
```

## The hidden issue

Although this lazy loading trick solves the large loading latency issue, it isn't a normal practice
in Julia because it introduces a so-called _world age issue_ or _world age problem_. The world age
issue happens when the compiled function becomes outdated.

Now, let's try something new to uncover this issue:

```julia
julia> using IndirectArrays, ImageCore

julia> img = IndirectArray(rand(1:5, 4, 4), rand(RGB, 5))
4×4 IndirectArray{RGB{Float64}, 2, Int64, Matrix{Int64}, Vector{RGB{Float64}}}:
...

julia> save("indexed_image.png", img)
```

and **reopen a new julia REPL** and wrap the `load` into a function, you'll observe something like
this:

```julia
julia> using FileIO

julia> f() = length(load("indexed_image.png"))
f (generic function with 1 method)

julia> f()
ERROR: MethodError: no method matching size(::IndirectArrays.IndirectArray{ColorTypes.RGB{FixedPointNumbers.N0f8}, 2, UInt8, Matrix{UInt8}, OffsetArrays.OffsetVector{ColorTypes.RGB{FixedPointNumbers.N0f8}, Vector{ColorTypes.RGB{FixedPointNumbers.N0f8}}}})
The applicable method may be too new: running in world age 32711, while current world is 32746.
Closest candidates are:
  size(::IndirectArrays.IndirectArray) at ~/.julia/packages/IndirectArrays/BUQO3/src/IndirectArrays.jl:52 (method too new to be called from this world context.)
  size(::AbstractArray{T, N}, ::Any) where {T, N} at abstractarray.jl:42
  size(::Union{LinearAlgebra.Adjoint{T, var"#s962"}, LinearAlgebra.Transpose{T, var"#s962"}} where {T, var"#s962"<:(AbstractVector)}) at ~/packages/julias/julia-latest/share/julia/stdlib/v1.9/LinearAlgebra/src/adjtrans.jl:173
  ...
Stacktrace:
 [1] length(t::IndirectArrays.IndirectArray{ColorTypes.RGB{FixedPointNumbers.N0f8}, 2, UInt8, Matrix{UInt8}, OffsetArrays.OffsetVector{ColorTypes.RGB{FixedPointNumbers.N0f8}, Vector{ColorTypes.RGB{FixedPointNumbers.N0f8}}}})
   @ Base ./abstractarray.jl:291
```

This is because when you first call function `f()`, the IndirectArrays package is not yet loaded and
thus `size(::IndirectArray)` method is not defined yet. This is exactly what world age means: the
compiled `f()` function is outdated because new methods are dynamically added in runtime. The
perhaps surprising fact is that if you retry `f()`, it just works:

```julia
julia> f()
16
```

The second `f()` works because this time you're running a recompiled version of `f()` in the latest
world age with the necessary `size(::IndirectArray)` defined.

## Solution

The solution to the world age issue is simple: **eagerly load the needed packages**. For instance,
if you're seeing world age issue complaining methods related to `IndirectArray`, then load
IndirectArrays eagerly:

```julia
julia> using FileIO, IndirectArrays # try this on a new Julia REPL

julia> f() = length(load("indexed_image.png"))
f (generic function with 1 method)

julia> f()
16
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

Enjoy the FileIO and its lazy loading, but be aware that this isn't the silver bullet for latency.
