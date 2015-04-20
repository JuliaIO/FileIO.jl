using FileIO
using Base.Test

test_file = File("test.txt")

@test file"test.txt" == test_file
@test test_file.abspath  === Pkg.dir("FileIO", "test", "test.txt")
@test abspath(test_file) === test_file.abspath
@test ending(test_file)  === :txt

@test_throw file"inexistent_file.txt"
