[![Platform](http://img.shields.io/badge/platform-osx-lightgrey.svg?style=flat)](https://developer.apple.com/resources/) [![Language](http://img.shields.io/badge/language-swift-orange.svg?style=flat)](https://developer.apple.com/swift) [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage) [![License](https://img.shields.io/badge/license-MIT-blue.svg?style=flat)](http://mit-license.org)

[Swift 3](https://github.com/kareman/SwiftShell) | Swift 2

_Not available for Linux, because [NSTask](https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/NSTask.swift) and [NSFileHandle](https://github.com/apple/swift-corelibs-foundation/blob/master/Foundation/NSFileHandle.swift) have not been fully ported yet._

# SwiftShell

An OS X/macOS Framework for command-line scripting in Swift.

#### See also

- [Documentation](http://kareman.github.io/SwiftShell) from the source code.
- A [description](https://www.skilled.io/kare/swiftshell) of the project on [skilled.io](https://www.skilled.io).
- Example scripts
    - [Move files to the trash](http://blog.nottoobadsoftware.com/swiftshell/move-files-to-the-trash/)
    - [Combine markdown files and convert to HTML](http://blog.nottoobadsoftware.com/swiftshell/combine-markdown-files-and-convert-to-html-in-a-swift-script/) (runs a shell command in the middle of a method chain)

## Example

#### Print line numbers

```swift
import SwiftShell

do {
	// If there is an argument, try opening it as a file. Otherwise use standard input.
	let input = try main.arguments.first.map {try open($0)} ?? main.stdin

	input.lines()
		.enumerate().forEach { (linenr,line) in print(linenr+1, ":", line) }

	// Add a newline at the end
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

Run a shell command just like you would in the terminal. The name may seem a bit cumbersome, but it explains exactly what it does. SwiftShell never prints anything without explicitly being told to.

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
try command.finish()
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

#### Shell script

- In the Terminal, go to where you want to download SwiftShell.
- Run

        git clone https://github.com/kareman/SwiftShell.git
        cd SwiftShell

- Copy/link `Misc/swiftshell` to your bin folder or anywhere in your PATH.
- To install the framework itself, either:
  - run `xcodebuild install` from the project's root folder. This will install the SwiftShell framework in ~/Library/Frameworks.
  - _or_ run `xcodebuild` and copy the resulting framework from the build folder to your library folder of choice. If that is not "~/Library/Frameworks" or "/Library/Frameworks"  then make sure the folder is listed in $SWIFTSHELL_FRAMEWORK_PATH.

Then include this in the beginning of each script:

```swift
#!/usr/bin/env swiftshell

import SwiftShell
```

#### [Swift Package Manager](https://github.com/apple/swift-package-manager)

See the [Swift 3 branch](https://github.com/kareman/SwiftShell/tree/Swift3.0).

#### [Carthage](https://github.com/Carthage/Carthage)

Add this to your Cartfile:

```
github "kareman/SwiftShell"
```

Then run `carthage update` and add the resulting framework to the "Embedded Binaries" section of the application. See [Carthage's README][carthage-installation] for instructions.

[carthage-installation]: https://github.com/Carthage/Carthage#adding-frameworks-to-an-application

#### Xcode command-line application

Sadly it is not possible to include a framework in an Xcode command-line application. But you can import one. Set the build settings FRAMEWORK_SEARCH_PATHS and LD_RUNPATH_SEARCH_PATHS to include a folder containing the SwiftShell framework. Or if you want the command line application to be self-contained you can include all the source files from SwiftShell in the command line target itself, and add `"#import "NSTask+NSTask_Errors.h"` to the bridging header.

## License

Released under the MIT License (MIT), http://opensource.org/licenses/MIT

Some files are covered by other licences, see [included works](Misc/Included%20Works).

Kåre Morstøl, [NotTooBad Software](http://nottoobadsoftware.com)
