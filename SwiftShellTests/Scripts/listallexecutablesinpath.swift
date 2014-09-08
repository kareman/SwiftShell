#!/usr/bin/env swiftshell

import SwiftShell

let directories = environment["PATH"]!.split(":")

for directory in directories {
	run("find \"\(directory)\" -type f -perm +ugo+x -print") |> standardoutput
}
