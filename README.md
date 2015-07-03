_Works with **Swift 1.2** (Xcode 6.3). Here's the [Swift 2.0](https://github.com/kareman/SwiftShell/tree/Swift2.0) version._

# SwiftShell

An OS X Framework for command line scripting in Swift. It supports joining together shell commands and Swift functions, like the pipe in shell commands and the pipe forward operator in F#.


## Usage

#### Commands

Shell commands return readable streams, which can be read all at once with "read()" or read lazily (as in piece by piece) with "readSome()". The latter is useful for long texts.

```swift
#!/usr/bin/env swiftshell

import SwiftShell

let result = run("some shell command").read()
```

Commands can be piped together:

```swift
run("echo piped to the next command") |> run("wc -w") |>> standardoutput
```

Use any sequence as parameters for a command:

```swift
run( "chmod +x" + parameters(files) )
```

For in-line commands, use `$("command")`:

```swift
print( "The time and date is " + $("date -u") )
```

#### Files

Files are streams too. They can be read line by line:

```swift
for line in open("file1.txt").lines() {
	// Do something with each line
}
```

Or written to:

```swift
let file2 = open(forWriting: tempdirectory / "newfile.txt" )
run("echo line 1") |>> file2
file2.writeln("line 2")
```

And there's easy access to NSFileManager:

```swift
if File.fileExistsAtPath("fileiwant.txt") {...}
if File.isExecutableFileAtPath("program") {...}
...
```

#### Standard input

is also a stream:

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
standardinput.lines() |> map {line in "line \(i++): \(line)\n"} |>> standardoutput
```

Launch with e.g. `ls | print_linenumbers.swift`

## Examples

- [trash.swift](https://gist.github.com/kareman/322c1091f3cc7e1078af): moves files and folders to the trash.
- [listallexecutablesinpath.swift](https://gist.github.com/kareman/d157c46858f91f1a22a7): lists all executables currently available in PATH.

## Documentation

- [generated from code](http://kareman.github.io/SwiftShell)

## Installation

- In the Terminal, go to where you want to download SwiftShell.
- Run

        git clone https://github.com/kareman/SwiftShell.git 
        cd SwiftShell

- Copy/link `Misc/swiftshell` to your bin folder or anywhere in your PATH.
- To install the framework itself, either:
  - run `xcodebuild install` from the project's root folder. This will install the SwiftShell framework in ~/Library/Frameworks.
  - _or_ run `xcodebuild` and copy the resulting framework from the build folder to your library folder of choice. If that is not "~/Library/Frameworks", "/Library/Frameworks" or a folder mentioned in the $DYLD_FRAMEWORK_PATH environment variable then you need to add your folder to $DYLD_FRAMEWORK_PATH.

## License

Released under the MIT License (MIT), http://opensource.org/licenses/MIT

Some files are covered by other licences, see [included works](Misc/Included%20Works).

Kåre Morstøl, [NotTooBad Software](http://nottoobadsoftware.com)
