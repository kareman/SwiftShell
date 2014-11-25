#!/usr/bin/env swiftshell

import SwiftShell

run("ls") |> run("./print_linenumbers.swift") |> writeTo(standardoutput) 
