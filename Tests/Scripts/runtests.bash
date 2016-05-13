#!/usr/bin/env bash

SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd $SCRIPT_DIR
PROJECT_ROOT=$SCRIPT_DIR/../..

# Build the framework and record any errors.
BUILDERRORS=$(xcodebuild -project $PROJECT_ROOT/SwiftShell2.xcodeproj/ 2>&1 >/dev/null)

# If there were any errors (exit code is not 0), print them and exit.
if [ $? -ne 0 ]; then
	printf "$BUILDERRORS \n"
	exit 1
fi

# Add the swiftshell script to the path
export PATH=$PROJECT_ROOT/Misc:$PATH

# ... and make sure it uses the newly built framework.
export SWIFTSHELL_FRAMEWORK_PATH=$PROJECT_ROOT/build/Release/

# Import the unit testing script.
. $SCRIPT_DIR/assert.sh

# Be aware the “assert” command does not check standard error output or exit code.
assert "./print_name_and_args.swift 1 2" "print_name_and_args.swift \"1\" \"2\""
assert_raises "./exitswhenopeningnon-existentfile.swift" 132
assert "cat onetwothree.txt | ./print_linenumbers.swift" "1: one\n2: two\n3: three"
assert "./stream_out.swift" "       3"
assert "./callswiftscriptfromswift.swift" "1: one\n2: two\n3: three"
assert "./readfilelinebyline.swift" "one\ntwo\nthree"
assert_raises "./readandwritefiles.swift" 0

# end of test suite
assert_end SwiftShell
