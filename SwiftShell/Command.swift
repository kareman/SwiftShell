/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation


/**
Print message to standard error and halt execution.

- parameter errormessage: the error message.
- parameter errorcode: exit code for the entire program. Defaults to 1.
- returns: not.
*/
@noreturn public func exit <T> (errormessage errormessage: T, errorcode: Int32 = EXIT_FAILURE) {
	main.stderror.writeln(errormessage)
	exit(errorcode)
}

@noreturn public func exit (error: ErrorType) {
	if let shellerror = error as? ShellError {
		exit(errormessage: shellerror, errorcode: shellerror.errorcode)
	} else {
		let nserror = error as NSError
		exit(errormessage: nserror, errorcode: Int32(nserror.code))
	}
}


/** 
If `executable` is not a path and a path for an executable file of that name can be found, return that path.
Otherwise just return `executable`.
*/
func pathForExecutable (executable: String) -> String {
	guard !executable.characters.contains("/") else {
		return executable
	}
	let path = run("/usr/bin/which", executable)
	return path.isEmpty ? executable : path
}

extension ShellContextType {

	func setupTask (executable: String, args: [String]) -> NSTask {
		let task = NSTask()
		task.arguments = args
		task.launchPath = pathForExecutable(executable)

		task.environment = self.env
		task.currentDirectoryPath = self.currentdirectory

		task.standardInput = self.stdin
		task.standardOutput = self.stdout
		task.standardError = self.stderror

		return task
	}
}

// MARK: run

extension ShellContextType {

	func outputFromRun (task: NSTask) -> String {
		let output = NSPipe ()
		task.standardOutput = output
		task.standardError = output
		do {
			try task.launchThrowably()
		} catch {
			exit(error)
		}
		task.waitUntilExit()
		var outputstring = output.fileHandleForReading.read(encoding: self.encoding)

		// if output is single-line, trim it.
		let firstnewline = outputstring.characters.indexOf("\n")
		if firstnewline == nil ||
			firstnewline == outputstring.endIndex.predecessor() {
				outputstring = outputstring.stringByTrimmingCharactersInSet(.whitespaceAndNewlineCharacterSet())
		}

		return outputstring
	}

	/**
	Shortcut for shell command, returns output and errors as a String.

	- parameter executable: path to an executable file.
	- parameter args: the arguments, one string for each.
	- returns: standard output and standard error in one string, trimmed of whitespace and newline if it is single-line.
	*/
	public func run (executable: String, _ args: Any ...) -> String {
		let stringargs = args.flatten().map { String($0) }
		return outputFromRun(setupTask(executable, args: stringargs))
	}
}


// MARK: ShellError

/** Error type for completed shell commands. */
public enum ShellError: ErrorType, Equatable {

	/** Exit code was not zero. */
	case ReturnedErrorCode (errorcode: Int32)
	case InAccessibleExecutable (path: String)

	var errorcode: Int32 {
		switch self {
		case .ReturnedErrorCode(let code):
			return code
		case .InAccessibleExecutable:
			return EXIT_FAILURE
		}
	}
}

extension ShellError: CustomStringConvertible {
	public var description: String {
		switch self {
		case .InAccessibleExecutable(let path):
			return "Could not execute file at path '\(path)'."
		case .ReturnedErrorCode(let code):
			return "Command returned with error code \(code)."
		}
	}
}

public func == (e1: ShellError, e2: ShellError) -> Bool {
	switch (e1, e2) {
	case (.ReturnedErrorCode(let c1), .ReturnedErrorCode(let c2)):
		return c1 == c2
	case (.InAccessibleExecutable(let c1), .InAccessibleExecutable(let c2)):
		return c1 == c2
	default:
		return false
	}
}

extension NSTask {
	public func finish() throws {
		self.waitUntilExit()
		guard self.terminationStatus == 0 else {
			throw ShellError.ReturnedErrorCode(errorcode: self.terminationStatus)
		}
	}

	public func launchThrowably() throws {
		do {
			try launchWithNSError()
		} catch {
			throw ShellError.InAccessibleExecutable(path: self.launchPath!)
		}
	}
}


// MARK: runAsync

/** Output from the 'runAsync' methods. */
public struct AsyncShellTask {
	public let stdout: NSFileHandle
	public let stderror: NSFileHandle
	private let task: NSTask

	init (task: NSTask) {
		self.task = task

		let outpipe = NSPipe()
		task.standardOutput = outpipe
		self.stdout = outpipe.fileHandleForReading

		let errorpipe = NSPipe()
		task.standardError = errorpipe
		self.stderror = errorpipe.fileHandleForReading

		do {
			try task.launchThrowably()
		} catch {
			exit(error)
		}
	}

	/** 
   Wait for this shell task to finish.

   - returns: itself
   - throws: a ShellError if the return code is anything but 0.
	*/
	public func finish() throws -> AsyncShellTask {
		try task.finish()
		return self
	}
}

extension ShellContextType {

	/**
   Run executable and return before it is finished.

   - parameter executable: path to an executable file.
   - parameter args: arguments to the executable.
   - returns: an AsyncShellTask with standard output, standard error and a 'finish' function.
	*/
	public func runAsync (executable: String, _ args: Any ...) -> AsyncShellTask {
		let stringargs = args.flatten().map { String($0) }
		return AsyncShellTask(task: setupTask(executable, args: stringargs))
	}
}


// MARK: runAndPrint

extension ShellContextType {

	/** 
   Run executable and print output and errors.

   - parameter executable: path to an executable file.
   - parameter args: arguments to the executable.
   - throws: a ShellError if the return code is anything but 0.
	*/
	public func runAndPrint (executable: String, _ args: Any ...) throws {
		let stringargs = args.flatten().map { String($0) }
		let task = setupTask(executable, args: stringargs)

		try task.launchThrowably()
		try task.finish()
	}
}

// MARK: Global functions

/**
Shortcut for shell command, returns output and errors as a String.

- parameter executable: path to an executable file.
- parameter args: the arguments, one string for each.
- returns: standard output and standard error in one string, trimmed of whitespace and newline if it is single-line.
*/
public func run (executable: String, _ args: Any ...) -> String {
	return main.run(executable, args)
}

/**
Run executable and return before it is finished.

- parameter executable: path to an executable file.
- parameter args: arguments to the executable.
- returns: an AsyncShellTask with standard output, standard error and a 'finish' function.
*/
public func runAsync (executable: String, _ args: Any ...) -> AsyncShellTask {
	return main.runAsync(executable, args)
}

/**
Run executable and print output and errors.

- parameter executable: path to an executable file.
- parameter args: arguments to the executable.
- throws: a ShellError if the return code is anything but 0.
*/
public func runAndPrint (executable: String, _ args: Any ...) throws {
	return try main.runAndPrint(executable, args)
}
