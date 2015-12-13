[![Platform](http://img.shields.io/badge/platform-osx-lightgrey.svg?style=flat)](https://developer.apple.com/resources/) [![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)

_This is the **SwiftShell 2.0** branch. Use [master](https://github.com/kareman/SwiftShell/tree/master) for SwiftShell 1._

# SwiftShell

An OS X Framework for command line scripting in Swift. 

## Example

#### Print line numbers

```swift
do {
	let input = try main.arguments.first.map {try open($0)} ?? main.stdin

	input.read().characters.split("\n")
		.enumerate().map { (linenr,line) in "\(linenr+1): " + String(line) }
		.joinWithSeparator("\n").writeTo(&main.stdout)

	// add a newline at the end
	print("")
} catch {
	exit(error)
}
```

Launched with e.g. `cat long.txt | print_linenumbers.swift` or `print_linenumbers.swift long.txt` this will print the line number at the beginning of each line.

## Run commands

#### Print output

```swift
try runAndPrint(bash: "cmd1 arg | cmd2 arg") 
```

Runs a shell command just like you would in the terminal. If the command returns with a non-zero exit code it will throw a ShellError.

_The name may seem a bit cumbersome, but it explains exactly what it does. SwiftShell never prints anything without explicitly being told to._

#### In-line

```swift
let date: String = run("date", "-u")
print("Today's date in UTC is " + date)
```

Similar to `$(cmd)` in bash, this just returns the output from the command as a string, ignoring any errors.

#### Asynchronous

```swift
let command = runAsync("cmd", "-n", 245)
// do something with command.stderror or command.stdout
do {
	try command.finish()
} catch {
	// deal with errors. or not.
}
```

Launch a command and continue before it's finished. You can process standard output and standard error, and optionally wait until it's finished and handle any errors.

If you read all of command.stderror or command.stdout it will automatically wait for the command to finish running. You can still call `finish()` to check for errors.

#### Parameters

The 3 `run` functions above take 2 different types of parameters:

**(executable: String, _ args: Any ...)**

If the path to the executable is without any `/`, SwiftShell will try to find the full path using the `which` shell command.

The array of arguments can contain any type, since everything is convertible to strings in Swift. If it contains any arrays it will be flattened so only the elements will be used, not the arrays themselves.

```swift
run("echo", "We are", 4, "arguments")
// echo "We are" 4 arguments

let array = ["But", "we", "are"]
run("echo", array, array.count + 2, "arguments")
// echo But we are 5 arguments
```

**(bash bashcommand: String)**

These are the commands you normally use in the Terminal. You can use pipes and redirection and all that good stuff. Support for other shell interpreters can easily be added.

## Output

`main.stdout` is for normal output and `main.stderror` for errors:

```swift
main.stdout.writeln("everything is fine")

main.stderror.write("something went wrong ...")
```

## Input

Use `main.stdin` to read from standard input:

```swift
let input: String = main.stdin.read()
```

## Main

So what else can `main` do? It is the only global value in SwiftShell and contains all the contextual information about the outside world:

```swift
var encoding: UInt
lazy var env: [String : String]

lazy var stdin: ReadableStream
lazy var stdout: WriteableStream
lazy var stderror: WriteableStream

var currentdirectory: String
lazy var tempdirectory: String

lazy var arguments: [String]
lazy var name: String
```

Everything is mutable, so you can set e.g. the text encoding or reroute standard error to a file.

## Setup

Installation depends on where you want to use SwiftShell from:

#### Shell script

- In the Terminal, go to where you want to download SwiftShell.
- Run

        git clone https://github.com/kareman/SwiftShell.git
        cd SwiftShell
        git checkout SwiftShell2

- Copy/link `Misc/swiftshell` to your bin folder or anywhere in your PATH.
- To install the framework itself, either:
  - run `xcodebuild install` from the project's root folder. This will install the SwiftShell framework in ~/Library/Frameworks.
  - _or_ run `xcodebuild` and copy the resulting framework from the build folder to your library folder of choice. If that is not "~/Library/Frameworks" or "/Library/Frameworks"  then make sure the folder is listed in $SWIFTSHELL_FRAMEWORK_PATH.

Then include this in the beginning of each script:

```swift
#!/usr/bin/env swiftshell

import SwiftShell
```

#### OS X application

##### Using [Carthage](https://github.com/Carthage/Carthage)

Add this to your Cartfile:

```
github "kareman/SwiftShell" "SwiftShell2"
```

Then run `carthage update` and add the resulting framework to the "Embedded Binaries" section of the application. See [Carthage's README][carthage-installation] for instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

#### Commandline application

Sadly it is not possible to include a framework in a commandline application. But you can import one. Set the build settings FRAMEWORK_SEARCH_PATHS and LD_RUNPATH_SEARCH_PATHS to include a folder containing the SwiftShell framework. Or if you want the command line application to be self-contained you can include all the source files from SwiftShell in the command line target itself, and add `"#import "NSTask+NSTask_Errors.h"` to the bridging header.

## License

Released under the MIT License (MIT), http://opensource.org/licenses/MIT

Some files are covered by other licences, see [included works](Misc/Included%20Works).

Kåre Morstøl, [NotTooBad Software](http://nottoobadsoftware.com)
