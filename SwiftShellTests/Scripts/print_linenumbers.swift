#!/usr/bin/env swiftshell

import SwiftShell

main.stdin.read().characters.split("\n")
	.enumerate().map { (linenr,line) in "\(linenr+1): " + String(line) }
	.joinWithSeparator("\n").writeTo(&main.stdout)

// add a final newline at the end
print("")
