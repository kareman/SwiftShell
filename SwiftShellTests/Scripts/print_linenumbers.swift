#!/usr/bin/env swiftshell

import SwiftShell

/*
var i = 1
for line in standardinput.lines() {
	print("line \(i++): ")
	println(line)
}
*/

var i = 1
standardinput.lines() |> map {line in "line \(i++): \(line)\n"} |> writeTo(standardoutput)
