#!/usr/bin/env swiftshell

import SwiftShell

for line in open("../shorttext.txt").lines() {
	// Do something with each line
	println(line)
}