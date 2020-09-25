Run shell commands | [Parse command line arguments](https://github.com/kareman/Moderator) | [Handle files and directories](https://github.com/kareman/FileSmith)

---

Swift 5.1 - 5.3 | [Swift 4](https://github.com/kareman/SwiftShell/tree/Swift4) | [Swift 3](https://github.com/kareman/SwiftShell/tree/Swift3) | [Swift 2](https://github.com/kareman/SwiftShell/tree/Swift2)

<p align="center">
	<img src="https://raw.githubusercontent.com/kareman/SwiftShell/master/Misc/logo.png" alt="SwiftShell logo" />
</p>

![Platforms](https://img.shields.io/badge/platforms-macOS%20%7C%20Linux++-lightgrey.svg) <a href="https://swift.org/package-manager"><img src="https://img.shields.io/badge/spm-compatible-brightgreen.svg?style=flat" alt="Swift Package Manager" /></a> [![Carthage compatible](https://img.shields.io/badge/carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) <a href="https://twitter.com/nottoobadsw"><img src="https://img.shields.io/badge/contact-@nottoobadsw-blue.svg?style=flat" alt="Twitter: @nottoobadsw" /></a>

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

- [API Documentation](https://kareman.github.io/SwiftShell).
- A [description](https://www.skilled.io/kare/swiftshell) of the project on [skilled.io](https://www.skilled.io).

<!-- START doctoc generated TOC please keep comment here to allow auto update -->
<!-- DON'T EDIT THIS SECTION, INSTEAD RE-RUN doctoc TO UPDATE -->
#### Table of Contents

- [Example](#example)
    - [Print line numbers](#print-line-numbers)
    - [Others](#others)
- [Context](#context)
    - [Main context](#main-context)
    - [Example](#example-1)
- [Streams](#streams)
    - [WritableStream](#writablestream)
    - [ReadableStream](#readablestream)
    - [Data](#data)
- [Commands](#commands)
    - [Run](#run)
    - [Print output](#print-output)
    - [Asynchronous](#asynchronous)
    - [Parameters](#parameters)
    - [Errors](#errors)
- [Setup](#setup)
  - [Stand-alone project](#stand-alone-project)
  - [Script file using Marathon](#script-file-using-marathon)
  - [Swift Package Manager](#swift-package-manager)
  - [Carthage](#carthage)
  - [CocoaPods](#cocoapods)
- [License](#license)

<!-- END doctoc generated TOC please keep comment here to allow auto update -->


## Example

#### Print line numbers

```swift
#!/usr/bin/env swiftshell

import SwiftShell

do {
	// If there is an argument, try opening it as a file. Otherwise use standard input.
	let input = try main.arguments.first.map {try open($0)} ?? main.stdin

	input.lines().enumerated().forEach { (linenr,line) in 
		print(linenr+1, ":", line) 
	}

	// Add a newline at the end.
	print("")
} catch {
	exit(error)
}
```

Launched with e.g. `cat long.txt | print_linenumbers.swift` or `print_linenumbers.swift long.txt` this will print the line number at the beginning of each line.

#### Others

- [Test the latest commit (using make and/or Swift).][testcommit]
- [Run a shell command in the middle of a method chain](https://nottoobadsoftware.com/blog/swiftshell/combine-markdown-files-and-convert-to-html-in-a-swift-script/).
- [Move files to the trash](https://nottoobadsoftware.com/blog/swiftshell/move-files-to-the-trash/).

[testcommit]: https://github.com/kareman/testcommit/blob/master/Sources/main.swift

## Context

All commands (a.k.a. [processes][]) you run in SwiftShell need context: [environment variables](https://en.wikipedia.org/wiki/Environment_variable), the [current working directory](https://en.wikipedia.org/wiki/Working_directory), standard input, standard output and standard error ([standard streams](https://en.wikipedia.org/wiki/Standard_streams)).

```swift
public struct CustomContext: Context, CommandRunning {
	public var env: [String: String]
	public var currentdirectory: String
	public var stdin: ReadableStream
	public var stdout: WritableStream
	public var stderror: WritableStream
}
```

You can create a copy of your application's context: `let context = CustomContext(main)`, or create a new empty one: `let context = CustomContext()`. Everything is mutable, so you can set e.g. the current directory or redirect standard error to a file.

[processes]: https://en.wikipedia.org/wiki/Process_(computing)

#### Main context

The global variable `main` is the Context for the application itself. In addition to the properties mentioned above it also has these:

- `public var encoding: String.Encoding`
The default encoding used when opening files or creating new streams.
- `public let tempdirectory: String`
A temporary directory you can use for temporary stuff.
- `public let arguments: [String]`
The arguments used when launching the application.
- `public let path: String`
The path to the application.

`main.stdout` is for normal output, like Swift's `print` function. `main.stderror` is for error output, and `main.stdin` is the standard input to your application, provided by something like `somecommand | yourapplication` in the terminal.

Commands can't change the context they run in (or anything else internally in your application) so e.g. `main.run("cd", "somedirectory")` will achieve nothing. Use `main.currentdirectory = "somedirectory"` instead, this changes the current working directory for the entire application.

#### Example

Prepare a context similar to a new macOS user account's environment in the terminal (from [kareman/testcommit][testcommit]):

```swift
import SwiftShell
import Foundation

extension Dictionary where Key:Hashable {
	public func filterToDictionary <C: Collection> (keys: C) -> [Key:Value]
		where C.Iterator.Element == Key, C.IndexDistance == Int {

		var result = [Key:Value](minimumCapacity: keys.count)
		for key in keys { result[key] = self[key] }
		return result
	}
}

// Prepare an environment as close to a new OS X user account as possible.
var cleanctx = CustomContext(main)
let cleanenvvars = ["TERM_PROGRAM", "SHELL", "TERM", "TMPDIR", "Apple_PubSub_Socket_Render", "TERM_PROGRAM_VERSION", "TERM_SESSION_ID", "USER", "SSH_AUTH_SOCK", "__CF_USER_TEXT_ENCODING", "XPC_FLAGS", "XPC_SERVICE_NAME", "SHLVL", "HOME", "LOGNAME", "LC_CTYPE", "_"]
cleanctx.env = cleanctx.env.filterToDictionary(keys: cleanenvvars)
cleanctx.env["PATH"] = "/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

// Create a temporary directory for testing.
cleanctx.currentdirectory = main.tempdirectory
```

## Streams

The protocols ReadableStream and WritableStream in `Context` above can read and write text from/to commands, files or the application's own standard streams. They both have an `.encoding` property they use when encoding/decoding text.

You can use `let (input,output) = streams()` to create a new pair of streams. What you write to `input` you can read from `output`.

#### WritableStream

When writing to a WritableStream you normally use `.print` which works exactly like Swift's built-in print function:

```swift
main.stdout.print("everything is fine")
main.stderror.print("no wait, something went wrong ...")

let writefile = try open(forWriting: path) // WritableStream
writefile.print("1", 2, 3/5, separator: "+", terminator: "=")
```

If you want to be taken literally, use `.write` instead. It doesn't add a newline and writes exactly and only what you write:

```swift
writefile.write("Read my lips:")
```

You can close the stream, so anyone who tries to read from the other end won't have to wait around forever:

```swift
writefile.close()
```

#### ReadableStream

When reading from a ReadableStream you can read everything at once:

```swift
let readfile = try open(path) // ReadableStream
let contents = readfile.read()
```

This will read everything and wait for the stream to be closed if it isn't already.

You can also read it asynchronously, that is read whatever is in there now and continue without waiting for it to be closed:

```swift
while let text = main.stdin.readSome() {
	// do something with ‘text’...
}
```

`.readSome()` returns `String?` - if there is anything there it returns it, if the stream is closed it returns nil, and if there is nothing there and the stream is still open it will wait until either there is more content or the stream is closed.

Another way to read asynchronously is to use the `lines` method which creates a lazy sequence of Strings, one for each line in the stream:

```swift
for line in main.stdin.lines() {
	// ...
}
```

Or instead of stopping and waiting for any output you can be notified whenever there is something in the stream:

```swift
main.stdin.onOutput { stream in
	// ‘stream’ refers to main.stdin
}
```

#### Data

In addition to text, streams can also handle raw Data:

```swift
let data = Data(...)
writer.write(data: data)
reader.readSomeData()
reader.readData() 
```

## Commands

All Contexts (`CustomContext` and `main`) implement `CommandRunning`, which means they can run commands using themselves as the Context. ReadableStream and String can also run commands, they use `main` as the Context and themselves as `.stdin`. As a shortcut you can just use `run(...)` instead of `main.run(...)`

There are 4 different ways of running a command:

#### Run

The simplest is to just run the command, wait until it's finished and return the results:

```swift
let result1 = run("/usr/bin/executable", "argument1", "argument2")
let result2 = run("executable", "argument1", "argument2")
```

If you don't provide the full path to the executable, then SwiftShell will try to find it in any of the directories in the `PATH` environment variable.

`run` returns the following information:

```swift
/// Output from a `run` command.
public final class RunOutput {

	/// The error from running the command, if any.
	let error: CommandError?

	/// Standard output, trimmed for whitespace and newline if it is single-line.
	let stdout: String

	/// Standard error, trimmed for whitespace and newline if it is single-line.
	let stderror: String

	/// The exit code of the command. Anything but 0 means there was an error.
	let exitcode: Int

	/// Checks if the exit code is 0.
	let succeeded: Bool
}
```

For example:

```swift
let date = run("date", "-u").stdout
print("Today's date in UTC is " + date)
```

#### Print output

```swift
try runAndPrint("executable", "arg") 
```

This runs a command like in the terminal, where any output goes to the Context's (`main` in this case) `.stdout` and `.stderror` respectively.  If the executable could not be found, was inaccessible or not executable, or the command returned with an exit code other than zero, then `runAndPrint` will throw a `CommandError`.

The name may seem a bit cumbersome, but it explains exactly what it does. SwiftShell never prints anything without explicitly being told to.

#### Asynchronous

```swift
let command = runAsync("cmd", "-n", 245).onCompletion { command in
	// be notified when the command is finished.
}
command.stdout.onOutput { stdout in 
	// be notified when the command produces output (only on macOS).	
}

// do something with ‘command’ while it is still running.

try command.finish() // wait for it to finish.
```

`runAsync` launches a command and continues before it's finished. It returns `AsyncCommand` which contains this:

```swift
    public let stdout: ReadableStream
    public let stderror: ReadableStream

    /// Is the command still running?
    public var isRunning: Bool { get }

    /// Terminates the command by sending the SIGTERM signal.
    public func stop()

    /// Interrupts the command by sending the SIGINT signal.
    public func interrupt()

    /// Temporarily suspends a command. Call resume() to resume a suspended command.
    public func suspend() -> Bool

    /// Resumes a command previously suspended with suspend().
    public func resume() -> Bool

    /// Waits for this command to finish.
    public func finish() throws -> Self

    /// Waits for command to finish, then returns with exit code.
    public func exitcode() -> Int

    /// Waits for the command to finish, then returns why the command terminated.
    /// - returns: `.exited` if the command exited normally, otherwise `.uncaughtSignal`.
    public func terminationReason() -> Process.TerminationReason

    /// Takes a closure to be called when the command has finished.
    public func onCompletion(_ handler: @escaping (AsyncCommand) -> Void) -> Self
```

You can process standard output and standard error, and optionally wait until it's finished and handle any errors.

If you read all of command.stderror or command.stdout it will automatically wait for the command to close its streams (and presumably finish running). You can still call `finish()` to check for errors.

`runAsyncAndPrint` does the same as `runAsync`, but prints any output directly and it's return type `PrintedAsyncCommand` doesn't have the `.stdout` and `.stderror` properties.

#### Parameters

The `run`* functions above take 2 different types of parameters:

##### (_ executable: String, _ args: Any ...)

If the path to the executable is without any `/`, SwiftShell will try to find the full path using the `which` shell command, which searches the directories in the `PATH` environment variable in order.

The array of arguments can contain any type, since everything is convertible to strings in Swift. If it contains any arrays it will be flattened so only the elements will be used, not the arrays themselves.

```swift
try runAndPrint("echo", "We are", 4, "arguments")
// echo "We are" 4 arguments

let array = ["But", "we", "are"]
try runAndPrint("echo", array, array.count + 2, "arguments")
// echo But we are 5 arguments
```

##### (bash bashcommand: String)

These are the commands you normally use in the Terminal. You can use pipes and redirection and all that good stuff:

```swift
try runAndPrint(bash: "cmd1 arg1 | cmd2 > output.txt")
```

Note that you can achieve the same thing in pure SwiftShell, though nowhere near as succinctly:

```swift
var file = try open(forWriting: "output.txt")
runAsync("cmd1", "arg1").stdout.runAsync("cmd2").stdout.write(to: &file)
```

#### Errors

If the command provided to `runAsync` could not be launched for any reason the program will print the error to standard error and exit, as is usual in scripts. The `runAsync("cmd").finish()` method throws an error if the exit code of the command is anything but 0:

```swift
let someCommand = runAsync("cmd", "-n", 245)
// ...
do {
	try someCommand.finish()
} catch let CommandError.returnedErrorCode(command, errorcode) {
	print("Command '\(command)' finished with exit code \(errorcode).")
}
```

The `runAndPrint` command can also throw this error, in addition to this one if the command could not be launched:

```swift
} catch CommandError.inAccessibleExecutable(let path) {
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

When at the top code level you don't need to catch any errors, but you still have to use `try`.

## Setup

### Stand-alone project

If you put [Misc/swiftshell-init](https://raw.githubusercontent.com/kareman/SwiftShell/master/Misc/swiftshell-init) somewhere in your $PATH you can create a new project with `swiftshell-init <name>`. This creates a new folder, initialises a Swift Package Manager executable folder structure, downloads the latest version of SwiftShell, creates an Xcode project and opens it. After running `swift build` you can find the compiled executable at `.build/debug/<name>`.

### Script file using [Marathon](https://github.com/JohnSundell/Marathon)

First add SwiftShell to Marathon: 

```bash
marathon add https://github.com/kareman/SwiftShell.git
```

Then run your Swift scripts with `marathon run <name>.swift`. Or add `#!/usr/bin/env marathon run` to the top of every script file and run them with `./<name>.swift`.

### [Swift Package Manager](https://github.com/apple/swift-package-manager)

Add `.package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0")` to your Package.swift:

```swift
// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ProjectName",
    platforms: [.macOS(.v10_13)],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/kareman/SwiftShell", from: "5.1.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages which this package depends on.
        .target(
            name: "ProjectName",
            dependencies: ["SwiftShell"]),
    ]
)

```

and run `swift build`.

### [Carthage](https://github.com/Carthage/Carthage)

Add `github "kareman/SwiftShell" >= 5.1` to your Cartfile, then run `carthage update` and add the resulting framework to the "Embedded Binaries" section of the application. See [Carthage's README][carthage-installation] for further instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

### [CocoaPods](https://cocoapods.org/)

Add `SwiftShell` to your `Podfile`.

```Ruby
pod 'SwiftShell', '>= 5.1.0'
```

Then run `pod install` to install it.

## License

Released under the MIT License (MIT), https://opensource.org/licenses/MIT

Kåre Morstøl, [NotTooBad Software](https://nottoobadsoftware.com)
