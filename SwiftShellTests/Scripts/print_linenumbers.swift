#!/usr/bin/env swiftshell

import SwiftShell

let result = main.stdin.read().characters.split("\n")
	.enumerate().map { (linenr,line) in "line " + String(linenr+1) + ": " + String(line) }

//  Swift demands we split this up.
main.stdout.write(result.joinWithSeparator("\n")) 

// TODO:  use .writeTo(&main.stdout)
