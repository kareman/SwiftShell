#!/usr/bin/env swiftshell

import SwiftShell

print(NSURL(fileURLWithPath: main.path).lastPathComponent!, main.arguments.map {"\""+($0)+"\""} .joined(separator:" "))
