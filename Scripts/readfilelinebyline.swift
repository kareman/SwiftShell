#!/usr/bin/env swiftshell

import SwiftShell

for line in try open("onetwothree.txt").lines() {
	// Do something with each line
	print(line)
}
