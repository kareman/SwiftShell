#!/usr/bin/env swiftshell

import SwiftShell

for line in open("onetwothree.txt").lines() {
	// Do something with each line
	println(line)
}
