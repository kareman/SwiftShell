#!/usr/bin/env swiftshell

import SwiftShell

run("echo this is streamed") |> run("wc -w") |> writeTo(standardoutput) 
