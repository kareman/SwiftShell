#!/usr/bin/env swiftshell

import SwiftShell

print(main.name, main.arguments.map {"\""+($0)+"\""} .joinWithSeparator(" "))
