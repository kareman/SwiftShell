#!/usr/bin/env swiftshell

import SwiftShell

try! run("cat","onetwothree.txt").runAndPrint("./print_linenumbers.swift")
