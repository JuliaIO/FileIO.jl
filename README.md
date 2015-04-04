# FileIO

[![Build Status](https://travis-ci.org/SimonDanisch/FileIO.jl.svg?branch=master)](https://travis-ci.org/SimonDanisch/FileIO.jl)

Meta package for FileIO. 
Purpose is to open a file and return the respective Julia object, without doing any research on how to open the file.
```Julia
f = file"test.jpg" # -> File{:jpg}
read(f) # -> Image
read(file"test.obj") # -> Mesh
read(file"test.csv") # -> DataFrame
```
So far only Image is supported.

It is structured the following way:
There are three levels of abstraction, first FileIO, defining the file macro etc, then a meta package for a certain class of file, e.g. Images or Meshes. This meta package defines the Julia datatype (e.g. Mesh, Image) and organizes the importer libraries. This is also a good place to define IO library independant tests for different file formats.
Then on the last level, there are the low-level importer libraries, which do the actual IO. 
They're included via Mike Innes [Requires](https://github.com/one-more-minute/Requires.jl) package, so that it doesn't introduce extra load time if not needed. This way, using FileIO without reading/writing anything should have short load times.

As an implementation example please look at FileIO -> ImageIO -> ImageMagick.
This should already somewhat work as a proof of concept.
Try:
```Julia
using FileIO # should be very fast, thanks to Mike Innes Requires package
read(file"test.jpg") # takes a little longer as it needs to load the IO library
read(file"test.jpg") # should be fast
read(File("documents", "images", "myimage.jpg") # automatic joinpath via File constructor
```
Please open issues if things are not clear or you find flaws in the concept/implementation. 
I'm a little lazy with documentations and much rather produce them on demand.
If you're interested in working on this infrastructure I'll be pleased to add you to the group JuliaIO.

