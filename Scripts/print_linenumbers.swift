#!/usr/bin/env swiftshell

import SwiftShell

main.stdin.lines()
	.enumerated().map { (linenr,line) in String(linenr+1) + ": " + String(line) }
	.joined(separator: "\n").write(to: &main.stdout)

// add a final newline at the end
print("")
