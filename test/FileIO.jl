module FileIOTests

using FileIO
using FactCheck

facts("File Creation") do
    test_file = File("test.txt")
    context("Create File object from existing file") do
        @fact file"test.txt"     => test_file
        @fact test_file.abspath  => Pkg.dir("FileIO", "test", "test.txt")
        @fact abspath(test_file) => test_file.abspath
        @fact ending(test_file)  => :txt
    end

    context("Inexistent file")
        @fact_throws file"inexistent_file.txt"
    end
end

# Remove comment to make Travis fail when tests fail:
# FactCheck.exitstatus()

end #module
