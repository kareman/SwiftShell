#!/usr/bin/env swiftshell

import SwiftShell

try! run("echo","this is streamed").runAndPrint("wc", "-w")
