Run shell commands | [Parse command line arguments](https://github.com/kareman/Moderator) | [Handle files and directories](https://github.com/kareman/FileSmith)

---

<img src="Misc/logo.png" alt="SwiftShell logo" style='float:right' />

Swift 3 | [Swift 2](https://github.com/kareman/SwiftShell/tree/Swift2)

[![Build Status](https://travis-ci.org/kareman/SwiftShell.svg?branch=master)](https://travis-ci.org/kareman/SwiftShell) ![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Linux-lightgrey.svg) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

# SwiftShell

A library for creating command-line applications and running shell commands in Swift. 

#### Features

- [x] run commands, and handle the output.
- [x] run commands asynchronously, and be notified when output is available.
- [x] access the context your application is running in, like environment variables, standard input, standard output, standard error, the current directory and the command line arguments.
- [x] create new such contexts you can run commands in.
- [x] handle errors.
- [x] read and write files.

#### See also

- [Documentation](http://kareman.github.io/SwiftShell) from the source code.
- A [description](https://www.skilled.io/kare/swiftshell) of the project on [skilled.io](https://www.skilled.io).
- Example scripts
    - [Move files to the trash](http://blog.nottoobadsoftware.com/swiftshell/move-files-to-the-trash/)
    - [Combine markdown files and convert to HTML](http://blog.nottoobadsoftware.com/swiftshell/combine-markdown-files-and-convert-to-html-in-a-swift-script/) (runs a shell command in the middle of a method chain)

## Example

#### Print line numbers

```swift
#!/usr/bin/env swiftshell

import SwiftShell

do {
	// If there is an argument, try opening it as a file. Otherwise use standard input.
	let input = try main.arguments.first.map {try open($0)} ?? main.stdin

	input.lines()
		.enumerated().forEach { (linenr,line) in print(linenr+1, ":", line) }

	// Add a newline at the end
	print("")
} catch {
	exit(error)
}
```

Launched with e.g. `cat long.txt | print_linenumbers.swift` or `print_linenumbers.swift long.txt` this will print the line number at the beginning of each line.

## Overview

### Context

When running programs (or [processes][]) in the Terminal or launching them some other way, in addition to their arguments they have access to the following information, represented in SwiftShell by the Context protocol:

```swift
public protocol Context {
	var env: [String: String] {get set}
	var currentdirectory: String {get set}
	var stdin: ReadableStream {get set}
	var stdout: WritableStream {get set}
	var stderror: WritableStream {get set}
}
```

For more, check out Wikipedia on [Environment variables](https://en.wikipedia.org/wiki/Environment_variable), [Current working directory](https://en.wikipedia.org/wiki/Working_directory) and [standard streams](https://en.wikipedia.org/wiki/Standard_streams).

Commands don't change their context.

[processes]: https://en.wikipedia.org/wiki/Process_(computing)

#### Main context

So what else can `main` do? It is the only global value in SwiftShell and contains all the contextual information about the outside world:

```swift
var encoding: UInt
lazy var tempdirectory: String

lazy var arguments: [String]
lazy var name: String
```

Everything is mutable, so you can set e.g. the text encoding or reroute standard error to a file.

### Commands

#### Run

```swift
let date: String = run("date", "-u")
print("Today's date in UTC is " + date)
```

Similar to `$(cmd)` in bash, this just returns the output from the command as a string, ignoring any errors.

#### Print output

```swift
try runAndPrint(bash: "cmd1 arg | cmd2 arg") 
```

Run a shell command just like you would in the terminal. The name may seem a bit cumbersome, but it explains exactly what it does. SwiftShell never prints anything without explicitly being told to.

#### Asynchronous

```swift
let command = runAsync("cmd", "-n", 245)
// do something with command.stderror or command.stdout
try command.finish()
```

Launch a command and continue before it's finished. You can process standard output and standard error, and optionally wait until it's finished and handle any errors.

If you read all of command.stderror or command.stdout it will automatically wait for the command to finish running. You can still call `finish()` to check for errors.

#### Parameters

The 3 `run` functions above take 2 different types of parameters:

##### (_ executable: String, _ args: Any ...)

If the path to the executable is without any `/`, SwiftShell will try to find the full path using the `which` shell command.

The array of arguments can contain any type, since everything is convertible to strings in Swift. If it contains any arrays it will be flattened so only the elements will be used, not the arrays themselves.

```swift
try runAndPrint("echo", "We are", 4, "arguments")
// echo "We are" 4 arguments

let array = ["But", "we", "are"]
try runAndPrint("echo", array, array.count + 2, "arguments")
// echo But we are 5 arguments
```

##### (bash bashcommand: String)

These are the commands you normally use in the Terminal. You can use pipes and redirection and all that good stuff. Support for other shell interpreters can easily be added.

#### Errors

If the command provided to `runAsync` could not be launched for any reason the program will print the error to standard error and exit, as is usual in scripts (it is quite possible SwiftShell should be less usual here).

The `runAsync("cmd").finish()` method on the other hand throws an error if the exit code of the command is anything but 0:

```swift
let command = runAsync("cmd", "-n", 245)
// do something with command.stderror or command.stdout
do {
	try command.finish()
} catch ShellError.ReturnedErrorCode(let error) {
	// use error.command or error.errorcode
}
```

The `runAndPrint` command can also throw this error, in addition to this one if the command could not be launched:

```swift
} catch ShellError.InAccessibleExecutable(let path) {
	// ‘path’ is the full path to the executable
}
```

Instead of dealing with the values from these errors you can just print them:

```swift
} catch {
	print(error)
}
```

... or if they are sufficiently serious you can print them to standard error and exit:

```swift
} catch {
	exit(error)
}
```

&nbsp;

When launched from the top level you don't need to catch any errors, but you still have to use `try`.

### Streams

#### Output

`main.stdout` is for normal output and `main.stderror` for errors. You can also write to a file:

```swift
main.stdout.print("everything is fine")
main.stderror.print("no wait, something went wrong ...")

let file = try open(forWriting: path)
file.print("something")
```

`.write` doesn't add a newline, and you can change the text encoding with `.encoding`.

#### Input

Use `main.stdin` to read from standard input, or you can read from a file:

```swift
let input: String? = main.stdin.readSome() // read what is available, don't wait for end of file 

let file = try open(path)
let contents: String = file.read() // read everything
```

Using `.readSome()` you can read piecewise instead of waiting for the input to be finished and then reading everything at once. You can change the text encoding with `.encoding`.

### The Terminal

## Setup

One of the goals of SwiftShell is to be able to run single .swift files directly, like you do with bash and Python files. This is possible now, but every time you upgrade Xcode or Swift you have to recompile all the third party frameworks your Swift script files use (including the SwiftShell framework). This will continue to be a problem until Swift achieves ABI stability in (hopefully) version 5. For now it is more practical to precompile the script into a self-contained executable.

### Pre-compiled executable

If you put [Misc/swiftshell-init](https://raw.githubusercontent.com/kareman/SwiftShell/master/Misc/swiftshell-init) somewhere in your $PATH you can create a new project with `swiftshell-init <name>`. This creates a new folder, initialises a Swift Package Manager executable folder structure, downloads the latest version of SwiftShell, creates an Xcode project and opens it. After running `swift build` you can find the compiled executable at `.build/debug/<name>`.

### Shell script

- In the Terminal, go to where you want to download SwiftShell.
- Run

        git clone https://github.com/kareman/SwiftShell.git
        cd SwiftShell

- Copy/link `Misc/swiftshell` to your bin folder or anywhere in your PATH.
- To install the framework itself, run `xcodebuild` and copy the resulting framework from the build folder to your library folder of choice. If that is not "~/Library/Frameworks" or "/Library/Frameworks"  then make sure the folder is listed in $SWIFTSHELL_FRAMEWORK_PATH.

Then include this in the beginning of each script:

```swift
#!/usr/bin/env swiftshell

import SwiftShell
```

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Add `.Package(url: "https://github.com/kareman/SwiftShell", "3.0.0-beta")` to your Package.swift:

```swift
import PackageDescription

let package = Package(
	name: "somecommandlineapp",
	dependencies: [
		.Package(url: "https://github.com/kareman/SwiftShell.git", "3.0.0-beta")
		 ]
)
```

and run `swift build`.

### [Carthage](https://github.com/Carthage/Carthage)

Add `github "kareman/SwiftShell" "master"` to your Cartfile, then run `carthage update` and add the resulting framework to the "Embedded Binaries" section of the application. See [Carthage's README][carthage-installation] for further instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

### [CocoaPods](https://cocoapods.org/)

Add `SwiftShell` to your `Podfile`.

```Ruby
pod 'SwiftShell', '>= 3.0.0-beta'
```

Then run `pod install` to install it.

## License

Released under the MIT License (MIT), http://opensource.org/licenses/MIT

Some files are covered by other licences, see [included works](Misc/Included%20Works).

Kåre Morstøl, [NotTooBad Software](http://nottoobadsoftware.com)
