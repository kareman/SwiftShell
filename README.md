[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

_This is the **SwiftShell 2.0** branch. Use [master](https://github.com/kareman/SwiftShell/tree/master) for SwiftShell 1._

# SwiftShell

An OS X Framework for command line scripting in Swift. 

## Usage

Put this at the beginning of each script file:

```swift
#!/usr/bin/env swiftshell

import SwiftShell
```

### Run commands

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

### Output

`main.stdout` is for normal output and `main.stderror` for errors:

```swift
main.stdout.writeln("...")

main.stderror.write("something went wrong ...")
```

### Input

Use `main.stdin` to read from standard input:

```swift
let input: String = main.stdin.read()
```

### Main

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

## Examples

### Print line numbers

```swift
do {
	let input = try main.arguments.first.flatMap {try open($0)} ?? main.stdin

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

## Installation

- In the Terminal, go to where you want to download SwiftShell.
- Run

        git clone https://github.com/kareman/SwiftShell.git
        cd SwiftShell
        git checkout SwiftShell2

- Copy/link `Misc/swiftshell` to your bin folder or anywhere in your PATH.
- To install the framework itself, either:
  - run `xcodebuild install` from the project's root folder. This will install the SwiftShell framework in ~/Library/Frameworks.
  - _or_ run `xcodebuild` and copy the resulting framework from the build folder to your library folder of choice. If that is not "~/Library/Frameworks", "/Library/Frameworks" or a folder mentioned in the $SWIFTSHELL_FRAMEWORK_PATH environment variable then you need to add your folder to $SWIFTSHELL_FRAMEWORK_PATH.

## License

Released under the MIT License (MIT), http://opensource.org/licenses/MIT

Some files are covered by other licences, see [included works](Misc/Included%20Works).

Kåre Morstøl, [NotTooBad Software](http://nottoobadsoftware.com)
