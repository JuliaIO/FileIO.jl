using FileIO
using Base.Test

# write your own tests here
test_file = File("test.jpg")
@test file"test.jpg" == test_file
@test test_file.abspath == Pkg.dir("FileIO", "test", "test.jpg")
@test ending(test_file) == :jpg
