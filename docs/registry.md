| Format Name | extensions | IO library | detection or magic number |
| ----------- | ---------- | ---------- | ---------- |
| JLD | .jld | loads and saves on **all** platforms with [JLD](http:///github.com/JuliaLang/JLD.jl.git)  | Julia data file (HDF5) |
| PBMBinary | .pbm | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x50,0x34] |
| PGMBinary | .pgm | loads and saves on **all** platforms with [Netpbm](http:///github.com/JuliaIO/Netpbm.jl.git)  | UInt8[0x50,0x35] |
| PPMBinary | .ppm | loads and saves on **all** platforms with [Netpbm](http:///github.com/JuliaIO/Netpbm.jl.git)  | UInt8[0x50,0x36] |
| PBMText | .pbm | loads with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git) on: **all** platforms   | UInt8[0x50,0x31] |
| PGMText | .pgm | loads with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git) on: **all** platforms   | UInt8[0x50,0x32] |
| PPMText | .ppm | loads with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git) on: **all** platforms   | UInt8[0x50,0x33] |
| NRRD | .nrrd, .nhdr | loads and saves on **all** platforms with [NRRD](http:///github.com/JuliaIO/NRRD.jl.git)  | NRRD |
| AndorSIF | .sif | loads with [AndorSIF](http:///github.com/JuliaIO/AndorSIF.jl.git) on: **all** platforms   | Andor Technology Multi-Channel File |
| CRW | .crw | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x49,0x49,0x1a,0x00,0x00,0x00,0x48,0x45] |
| CUR | .cur | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x00,0x00,0x02,0x00] |
| DCX | .dcx | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0xb1,0x68,0xde,0x3a] |
| DOT | .dot | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0xd0,0xcf,0x11,0xe0,0xa1,0xb1,0x1a,0xe1] |
| EPS | .eps | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x25,0x21,0x50,0x53,0x2d,0x41,0x64,0x6f] |
| HDR | .hdr | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x23,0x3f,0x52,0x41,0x44,0x49,0x41,0x4e] |
| ICO | .ico | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x00,0x00,0x01,0x00] |
| INFO | .info | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x7a,0x62,0x65,0x78] |
| JP2 | .jp2 | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x00,0x00,0x00,0x0c,0x6a,0x50,0x20,0x20] |
| PCX | .pcx | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x0a,0x05,0x01,0x01] |
| PDB | .pdb | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x73,0x7a,0x65,0x7a] |
| PDF | .pdf | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x25,0x50,0x44,0x46] |
| PGM | .pgm | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x50,0x35,0x0a] |
| PSD | .psd | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x38,0x42,0x50,0x53] |
| RGB | .rgb | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x01,0xda,0x01,0x01,0x00,0x03] |
| WMF | .wmf | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0xd7,0xcd,0xc6,0x9a] |
| WPG | .wpg | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0xff,0x57,0x50,0x43] |
| Imagine | .imagine | loads and saves on **all** platforms with [ImagineFormat](http:///github.com/timholy/ImagineFormat.jl.git)  | IMAGINE |
| TGA | .tga | loads and saves on **all** platforms with [QuartzImageIO](http:///github.com/JuliaIO/QuartzImageIO.jl.git) loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | only extension |
| GIF | .gif | loads and saves on **all** platforms with [QuartzImageIO](http:///github.com/JuliaIO/QuartzImageIO.jl.git) loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x47,0x49,0x46,0x38] |
| PNG | .png | loads and saves on **all** platforms with [QuartzImageIO](http:///github.com/JuliaIO/QuartzImageIO.jl.git) loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x89,0x50,0x4e,0x47,0x0d,0x0a,0x1a,0x0a] |
| TIFF | .tiff, .tif | loads and saves on **all** platforms with [QuartzImageIO](http:///github.com/JuliaIO/QuartzImageIO.jl.git) loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | (UInt8[0x4d,0x4d,0x00,0x2a],UInt8[0x4d,0x4d,0x00,0x2b],UInt8[0x49,0x49,0x2a,0x00]) |
| JPEG | .jpeg, .jpg, .JPG | loads and saves on **all** platforms with [QuartzImageIO](http:///github.com/JuliaIO/QuartzImageIO.jl.git) loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0xff,0xd8,0xff] |
| BMP | .bmp | loads and saves on **all** platforms with [QuartzImageIO](http:///github.com/JuliaIO/QuartzImageIO.jl.git) loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | UInt8[0x42,0x4d] |
| GLSLShader | .frag, .vert, .geom, .comp | loads and saves on **all** platforms with [GLAbstraction](http:///github.com/JuliaGL/GLAbstraction.jl.git)  | only extension |
| OBJ | .obj | loads and saves on **all** platforms with [MeshIO](http:///github.com/JuliaIO/MeshIO.jl.git)  | only extension |
| PLY_ASCII | .ply | loads and saves on **all** platforms with [MeshIO](http:///github.com/JuliaIO/MeshIO.jl.git)  | ply
format ascii 1.0 |
| PLY_BINARY | .ply | loads and saves on **all** platforms with [MeshIO](http:///github.com/JuliaIO/MeshIO.jl.git)  | ply
format binary_little_endian 1.0 |
| 2DM | .2dm | loads and saves on **all** platforms with [MeshIO](http:///github.com/JuliaIO/MeshIO.jl.git)  | MESH2D |
| OFF | .off | loads and saves on **all** platforms with [MeshIO](http:///github.com/JuliaIO/MeshIO.jl.git)  | OFF |
| AVI | .avi | loads and saves on **all** platforms with [ImageMagick](http:///github.com/JuliaIO/ImageMagick.jl.git)  | has detection function |
| HDF5 | .h5, .hdf5 | loads and saves on **all** platforms with [HDF5](http:///github.com/JuliaLang/HDF5.jl.git)  | has detection function |
| STL_ASCII | .stl, .STL | loads and saves on **all** platforms with [MeshIO](http:///github.com/JuliaIO/MeshIO.jl.git)  | has detection function |
| STL_BINARY | .stl, .STL | loads and saves on **all** platforms with [MeshIO](http:///github.com/JuliaIO/MeshIO.jl.git)  | has detection function |
