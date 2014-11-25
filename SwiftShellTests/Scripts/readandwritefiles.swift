#!/usr/bin/env swiftshell

import SwiftShell

let filepath = tempdirectory.URLByAppendingPathComponent("newfile.txt").path!

// File doesn't exist. Create it.
let file1 = open(forWriting: filepath )
file1.writeln("line 1")
file1.closeStream()

// File does exist. Append it.
let file2 = open(forWriting: filepath)
file2.writeln("line 2")
file2.closeStream()

// Test file.
let file3 = open(filepath)
if file3.read() != "line 1\nline 2\n" {
	printErrorAndExit( "newfile.txt should contain 'line 1\\n line 2\\n'." )
}

// File exists. Overwrite it.
let file4 = open(forWriting: filepath, overwrite: true)
file4.write("file now contains only this")
file4.closeStream()

// Test file.
let file5 = open(filepath)
if file5.read() != "file now contains only this" {
	printErrorAndExit( "newfile.txt should contain 'file now contains only this'." )
}
