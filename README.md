# SwiftShell

A Swift module for shell scripting.


##  Usage

#### Pipe several commands together

```swift
#!/usr/bin/env swiftshell

import SwiftShell

run("echo this is streamed") |> run("wc -w") |> standardoutput 
```

#### Read a file line by line

```swift
#!/usr/bin/env swiftshell

import SwiftShell

for line in open("../shorttext.txt").lines() {
	// Do something with each line
}
```

#### Print standard input with line numbers

```swift
#!/usr/bin/env swiftshell

import SwiftShell

var i = 1
for line in standardinput.lines() {
	print("line \(i++): ")
	println(line)
}
```

Launch with e.g. `ls | print_linenumbers.swift`

#### List all executables in PATH

```swift
#!/usr/bin/env swiftshell

import SwiftShell

let directories = environment["PATH"]!.split(":")

for directory in directories {
	run("find \"\(directory)\" -type f -perm +ugo+x -print") |> standardoutput
}
```

## Installation

- In the Terminal, go to where you want to download SwiftShell.
- Run

        git clone https://github.com/kareman/SwiftShell.git 
        cd SwiftShell

- Copy/link `Div/swiftshell` to your bin folder or anywhere in your PATH.
- To install the framework, either:
  - run `xcodebuild install` from the project's root folder. This will install the SwiftShell framework in ~/Library/Frameworks.
  - _or_ run `xcodebuild` and copy the resulting framework from the build folder to your library folder of choice. If that is not "~/Library/Frameworks", "/Library/Frameworks" or a folder mentioned in the $DYLD_FRAMEWORK_PATH environment variable then you need to add your folder to $DYLD_FRAMEWORK_PATH.


## LICENSE

This program and the accompanying materials are made available under the terms of the Eclipse Public License v1.0 which accompanies this distribution, and is available at http://www.eclipse.org/legal/epl-v10.html

If you want to use this project together with a different project with an incompatible license, send a message on GitHub and we will see what we can do.
