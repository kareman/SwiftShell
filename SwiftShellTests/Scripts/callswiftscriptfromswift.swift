#!/usr/bin/env swiftshell

import SwiftShell

run("./listallexecutablesinpath.swift") |> run("./print_linenumbers.swift") |> write(standardoutput) 
