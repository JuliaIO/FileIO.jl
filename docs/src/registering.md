# Registering a new format

You register a new format by adding

```julia
add_format(fmt, magic, extension, libraries...)
```

to FileIO's [registry](https://github.com/JuliaIO/FileIO.jl/blob/master/src/registry.jl).
It's generally best if you experiment with this locally and make sure everything works
before submitting a pull request.
You'll need to [`pkg> dev FileIO`](https://julialang.github.io/Pkg.jl/v1/managing-packages/#developing) to make the required changes.

Before going into detail explaining the arguments of `add_format`,
here is a real example that could be used to register an I/O package for one of the [Netpbm image formats](https://en.wikipedia.org/wiki/Netpbm#File_formats):

```julia
add_format(format"PPMBinary", "P6", ".ppm", [:Netpbm => UUID("f09324ee-3d7c-5217-9330-fc30815ba969")])
```

Briefly, this indicates that files in this format typically have extension `.ppm`, the file contents typically start with "P6" (the byte sequence `[0x50, 0x36]`), and these files can be read and written by the [Netpbm package](https://github.com/JuliaIO/Netpbm.jl). (The `UUID` is Julia's unique identifier for this registered package and can be obtained from the `Project.toml` file.)

## Argument `fmt`

`fmt` is a `DataFormat` type, most conveniently created as `format"IDENTIFIER"`.
If this file format has not previously been supported,
you can make up `IDENTIFIER` yourself--there is no external standard, this is just a "tag"
used internally by FileIO and its support routines.
You should generally choose something that makes it easy to guess what format it refers to.
Examples of some existing `fmt`s are:

- `format"PNG"`: the format for [png image files](https://en.wikipedia.org/wiki/Portable_Network_Graphics)
- `format"HDF5"`: the format for [hierarchical data files v5](https://en.wikipedia.org/wiki/Hierarchical_Data_Format)

## Argument `magic`

`magic` typically contains the [magic bytes](https://en.wikipedia.org/wiki/File_format#Magic_number) that identify the format.
While file format can sometimes be guessed from the extension (e.g., "pic.png" would likely be a PNG image file),
fundamentally the name of the file is something that can be changed by the user,
so it may have no relationship to the content of the file.
Moreover, there are many examples in which two or more different formats use the same extension,
leading to ambiguity about the nature of the file.
Is a `.gbv` file a Genie Timeline file or a PCB CAD file?
Is that `.fst` file an audio file, a puzzle game file, or an R serialized dataframe file?

To identify the file uniquely, good format designers will include "magic bytes" as part of the content of the file to ensure that one can recognize or validate the format of the file.
Typically, these magic bytes are the first bytes in the file, although there are many exceptions.

!!! warning
    Formats that use common extensions (e.g., `.out`) and lack magic bytes cannot be registered with FileIO--
    permitting this would force us to choose one particular format above all others.
    In such cases, your package should provide its own I/O without using FileIO.
    To avoid name conflicts with FileIO, it may be best to avoid exporting names like `load` and `save` from your package; use module-qualifiers like `MyPkg.load` instead.

Some formats have multiple "flavors" of magic bytes (which might, for example, include a "format version" number);
in such cases `magic` can be a list of byte sequences.
In other cases, files cannot be identified by a specific set of bytes, but there's a pattern that can be exploited:
`magic` can be a function that returns `true` or `false` depending on whether an I/O stream
is consistent with the format.

Examples of magic bytes include:
- [GIF image files](https://en.wikipedia.org/wiki/GIF) can have magic bytes corresponding to the ASCII characters in `"GIF87a"`, i.e., `[0x47, 0x49, 0x46, 0x38, 0x37, 0x61]`. Alternatively, they might use `"GIF89a"`, which signals a different version of the GIF format.
- [PLY mesh files](https://en.wikipedia.org/wiki/PLY_(file_format)) can come in two flavors, ASCII and binary. Their magic bytes are `"ply\nformat ascii 1.0"` and `"ply\nformat binary_little_endian 1.0"`, respectively. These magic bytes are human-readable and span the first two lines of the file.
- [BedGraph genomic data files](http://genome.ucsc.edu/goldenPath/help/bedgraph.html) do not have official magic bytes, but they do have a structure which can be fairly reliably recognized by a suitable detection function. (Though it would have made life far more straightforward if the creators of the format had just added some magic bytes!)

## Argument `extension`

This can be a string or list of strings. Each should start with `'.'`.

Example: the [Nearly Raw Raster Data](http://teem.sourceforge.net/nrrd/format.html) format uses `[".nrrd",".nhdr"]`.

## Argument `libraries`

This argument specifies the package or packages that can support input and/or output for the format.
Each package specification should be of the form `name => uuid`, where `name` is the name of the package (encoded as a `Symbol`, e.g., `:FeatherFiles`) and `uuid` is the `UUID` from the package's `Project.toml`.
The first-to-be listed package has highest priority; FileIO will try to use it to perform the requested operation, and move onto the next only if that fails.
Failure might occur because the user does not have the package installed, or because the package's handler threw an error.

Some packages may only support specific forms of I/O, and can use `LOAD` and `SAVE` as specifiers for supported operations. Likewise, some packages rely on system libraries available only on certain platforms, and can include a platform specifier.

If your package isn't (yet) registered, you can alternatively specify the handler as the module itself.  In such cases, your call to `add_format` will likely be made from within your module or at the Julia REPL rather than in FileIO's registry. An exception is `MimeWriter`, a sub-module of `FileIO` that can write a few [MIME](https://en.wikipedia.org/wiki/MIME) formats.

Here's a real-world example (contained in FileIO's `src/registry.jl`) for PNG:

```julia
add_format(
    format"PNG",
    UInt8[0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a],
    ".png",
    [idImageIO],
    [idQuartzImageIO, OSX],
    [idImageMagick],
    [MimeWriter, SAVE]
)
```

`idImageIO`, `idQuartzImageIO`, and `idImageMagic` are `name => uuid` pairs for three different packages.
[QuartzImageIO](https://github.com/JuliaIO/QuartzImageIO.jl) is available only on macOS (`OSX`).
The `MimeWriter` module (which is internally accessible to FileIO) only supports output (`SAVE`), not input.

## Examples

For further examples, users are encouraged to inspect FileIO's [registry](https://github.com/JuliaIO/FileIO.jl/blob/master/src/registry.jl) directly.
