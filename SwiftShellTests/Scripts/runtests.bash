. assert.sh

# Be aware the “assert” command does not check standard error output or exit code.

assert "./print_arguments.swift 1 2" "[./print_arguments.swift, 1, 2]"
assert_raises "./exitswhenopeningnon-existentfile.swift" 1
assert "cat onetwothree.txt | ./print_linenumbers.swift" "line 1: one\nline 2: two\nline 3: three"
assert "./stream_out.swift" "       3"
assert "./callswiftscriptfromswift.swift" "line 1: one\nline 2: two\nline 3: three"
assert "./readfilelinebyline.swift" "one\ntwo\nthree"
assert_raises "./readandwritefiles.swift" 0

# end of test suite
assert_end SwiftShell
