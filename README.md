# SwiftShell

An OS X Framework for command line scripting in Swift. It supports joining together shell commands and Swift functions, like the pipe in UNIX shell commands and the pipe forward operator in F#. As Swift itself it supports both object-oriented and functional programming.


## Usage

Shell commands return readable streams, which can be read all at once with "read()" or read lazily (as in piece by piece) with "readSome()". The latter is useful for very long texts.

```
#!/usr/bin/env swiftshell

import SwiftShell

let result = run("some shell command").read()
```

For in-line commands, use `$("command")`.

```
print( "The time and date is " + $("date -u") )
```

#### Pipe several commands together

```swift
run("echo piped to the next command") |> run("wc -w") |> write(standardoutput) 
```

#### Read a file line by line

```swift
for line in open(filename).lines() {
	// Do something with each line
}
```

#### List all executables in PATH

```swift
let directories = environment["PATH"]!.split(":")
for directory in directories {
	run("find \"\(directory)\" -type f -perm +ugo+x -print") |> write(standardoutput)
}
```

or more Functionally:

```swift
environment["PATH"]! |> split(":") 
	|> map { dir in run("find \"\(dir)\" -type f -perm +ugo+x -print") } 
	|> write(standardoutput)
```

#### Print standard input with line numbers

```swift
var i = 1
for line in standardinput.lines() {
	print("line \(i++): ")
	println(line)
}
```

or

```swift
var i = 1
standardinput.lines() |> map {line in "line \(i++): \(line)\n"} |> write(standardoutput)
```

Launch with e.g. `ls | print_linenumbers.swift`

## Installation

- In the Terminal, go to where you want to download SwiftShell.
- Run

        git clone https://github.com/kareman/SwiftShell.git 
        cd SwiftShell

- Copy/link `Div/swiftshell` to your bin folder or anywhere in your PATH.
- To install the framework itself, either:
  - run `xcodebuild install` from the project's root folder. This will install the SwiftShell framework in ~/Library/Frameworks.
  - _or_ run `xcodebuild` and copy the resulting framework from the build folder to your library folder of choice. If that is not "~/Library/Frameworks", "/Library/Frameworks" or a folder mentioned in the $DYLD_FRAMEWORK_PATH environment variable then you need to add your folder to $DYLD_FRAMEWORK_PATH.

NOTE: Release builds of SwiftShell built with Xcode 6.1 beta 2 (and possibly later) crash when using streams. Work around this by using debug builds instead:

    xcodebuild -configuration Debug install


## LICENSE

This program and the accompanying materials are made available under the terms of the Eclipse Public License v1.0 which accompanies this distribution, and is available at http://www.eclipse.org/legal/epl-v10.html

If you want to use this project together with a different project with an incompatible license, send a message on GitHub and we will see what we can do.
