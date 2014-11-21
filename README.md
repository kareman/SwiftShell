# SwiftShell

An OS X Framework for command line scripting in Swift. It supports joining together shell commands and Swift functions, like the pipe in UNIX shell commands and the pipe forward operator in F#. As Swift itself it supports both object-oriented and functional programming.


## Usage

Shell commands return readable streams, which can be read all at once with "read()" or read lazily (as in piece by piece) with "readSome()". The latter is useful for long texts.

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
run("echo piped to the next command") |> run("wc -w") |> writeTo(standardoutput) 
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
	run("find \"\(directory)\" -type f -perm +ugo+x -print") |> writeTo(standardoutput)
}
```

or more Functionally:

```swift
environment["PATH"]! |> split(":") 
	|> map { dir in run("find \"\(dir)\" -type f -perm +ugo+x -print") } 
	|> writeTo(standardoutput)
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
standardinput.lines() |> map {line in "line \(i++): \(line)\n"} |> writeTo(standardoutput)
```

Launch with e.g. `ls | print_linenumbers.swift`

## Scripts

- [trash.swift](https://gist.github.com/kareman/322c1091f3cc7e1078af): moves files and folders to the trash.

## Installation

- In the Terminal, go to where you want to download SwiftShell.
- Run

        git clone https://github.com/kareman/SwiftShell.git 
        cd SwiftShell

- Copy/link `Div/swiftshell` to your bin folder or anywhere in your PATH.
- To install the framework itself, either:
  - run `xcodebuild install` from the project's root folder. This will install the SwiftShell framework in ~/Library/Frameworks.
  - _or_ run `xcodebuild` and copy the resulting framework from the build folder to your library folder of choice. If that is not "~/Library/Frameworks", "/Library/Frameworks" or a folder mentioned in the $DYLD_FRAMEWORK_PATH environment variable then you need to add your folder to $DYLD_FRAMEWORK_PATH.

NOTE: Code compiled with optimisations turned on (anything but "SWIFT_OPTIMIZATION_LEVEL = -Onone") crashes when reading from streams. SwiftShell is therefore compiled with the “Debug” configuration by default.


## LICENSE

Released under the MIT License (MIT), http://opensource.org/licenses/MIT

Kåre Morstøl, [NotTooBad Software](http://nottoobadsoftware.com)
