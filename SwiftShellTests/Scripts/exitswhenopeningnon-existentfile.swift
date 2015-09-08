#!/usr/bin/env swiftshell

import SwiftShell

try! runAndPrint("/bin/cat", "file which does not exist")
print("this is not printed, the script has exited")
