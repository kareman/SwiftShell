#!/usr/bin/env swiftshell

import SwiftShell

run("cat onetwothree.txt") |> run("./print_linenumbers.swift") |>> standardoutput
