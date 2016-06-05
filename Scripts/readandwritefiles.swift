#!/usr/bin/env swiftshell

import SwiftShell

let filepath = main.tempdirectory + "newfile.txt"

// File doesn't exist. Create it.
let file1 = try! open(forWriting: filepath)
file1.writeln("line 1")
file1.close()

// File does exist. Append it.
let file2 = try! open(forWriting: filepath)
file2.writeln("line 2")
file2.close()

// Test file.
let file3 = try! open(filepath)
if file3.read() != "line 1\nline 2\n" {
	exit(errormessage: "newfile.txt should contain 'line 1\\n line 2\\n'." )
}

// File exists. Overwrite it.
let file4 = try! open(forWriting: filepath, overwrite: true)
file4.write("file now contains only this")
file4.close()

// Test file.
let file5 = try! open(filepath)
if file5.read() != "file now contains only this" {
	exit(errormessage: "newfile.txt should contain 'file now contains only this'." )
}
