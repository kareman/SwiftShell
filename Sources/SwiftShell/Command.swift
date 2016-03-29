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
@noreturn public func exit <T> (errormessage errormessage: T, errorcode: Int32 = EXIT_FAILURE, file: String = #file, line: Int = #line) {
	main.stderror.write(file + ":\(line): ")
	main.stderror.writeln(errormessage)
	exit(errorcode)
}

/**
Print error to standard error and halt execution.

- parameter error: the error
- returns: not.
*/
@noreturn public func exit (error: ErrorType, file: String = #file, line: Int = #line) {
	if let shellerror = error as? ShellError {
		exit(errormessage: shellerror, errorcode: shellerror.errorcode, file: file, line: line)
	} else {
		let nserror = error as NSError
		exit(errormessage: nserror.localizedDescription, errorcode: Int32(nserror.code), file: file, line: line)
	}
}


//	MARK: ShellRunnable

public protocol ShellRunnable {
	var shellcontext: ShellContextType { get }
}

extension ShellRunnable {

	func createTask (executable: String, args: [String]) -> NSTask {

		/**
		If `executable` is not a path and a path for an executable file of that name can be found, return that path.
		Otherwise just return `executable`.
		*/
		func pathForExecutable (executable: String) -> String {
			guard !executable.characters.contains("/") else {
				return executable
			}
			let path = self.run("/usr/bin/which", executable)
			return path.isEmpty ? executable : path
		}

		let task = NSTask()
		task.arguments = args
		task.launchPath = pathForExecutable(executable)

		task.environment = shellcontext.env
		task.currentDirectoryPath = shellcontext.currentdirectory

		task.standardInput = shellcontext.stdin.filehandle
		task.standardOutput = shellcontext.stdout.filehandle
		task.standardError = shellcontext.stderror.filehandle

		return task
	}
}


// MARK: ShellError

/** Error type for shell commands. */
public enum ShellError: ErrorType, Equatable {

	/** Exit code was not zero. */
	case ReturnedErrorCode (command: String, errorcode: Int32)

	/** Command could not be executed. */
	case InAccessibleExecutable (path: String)

	/** Exit code for this error. */
	var errorcode: Int32 {
		switch self {
		case .ReturnedErrorCode(_, let code):
			return code
		case .InAccessibleExecutable:
			// according to http://tldp.org/LDP/abs/html/exitcodes.html
			return 127
		}
	}
}

extension ShellError: CustomStringConvertible {
	public var description: String {
		switch self {
		case .InAccessibleExecutable(let path):
			return "Could not execute file at path '\(path)'."
		case .ReturnedErrorCode(let command, let code):
			return "Command '\(command)' returned with error code \(code)."
		}
	}
}

public func == (e1: ShellError, e2: ShellError) -> Bool {
	switch (e1, e2) {
	case (.ReturnedErrorCode(let c1), .ReturnedErrorCode(let c2)):
		return c1.errorcode == c2.errorcode && c1.command == c2.command
	case (.InAccessibleExecutable(let c1), .InAccessibleExecutable(let c2)):
		return c1 == c2
	default:
		return false
	}
}

// MARK: NSTask

extension NSTask {

	/**
	Launch task.

	- throws: ShellError.InAccessibleExecutable if command could not be executed.
	*/
	public func launchThrowably() throws {
		#if SWIFT_PACKAGE
			launch()
		#else
			do {
				try launchWithNSError()
			} catch {
				throw ShellError.InAccessibleExecutable(path: self.launchPath!)
			}
		#endif
	}

	/**
	Wait until task is finished.

	- throws: `ShellError.ReturnedErrorCode (command: String, errorcode: Int32)` if the exit code is anything but 0.
	*/
	public func finish() throws {
		self.waitUntilExit()
		guard self.terminationStatus == 0 else {
			throw ShellError.ReturnedErrorCode(command: commandAsString()!, errorcode: self.terminationStatus)
		}
	}

	/** The full path to the executable + all arguments, each one quoted if it contains a space. */
	func commandAsString () -> String? {
		guard let path = self.launchPath else { return nil }
		return self.arguments?.reduce(path) { acc, arg in
			return acc + " " + ( arg.characters.contains(" ") ? ("\"" + arg + "\"") : arg )
		}
	}
}

// MARK: run

extension ShellRunnable {

	func outputFromRun (task: NSTask, file: String, line: Int) -> String {
		let output = NSPipe ()
		task.standardOutput = output
		task.standardError = output
		do {
			try task.launchThrowably()
		} catch {
			exit(error, file: file, line: line)
		}
		var outputstring = output.fileHandleForReading.read(encoding: shellcontext.encoding)
		task.waitUntilExit()

		// if output is single-line, trim it.
		let firstnewline = outputstring.characters.indexOf("\n")
		if firstnewline == nil || firstnewline == outputstring.endIndex.predecessor() {
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
	public func run (executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> String {
		let stringargs = args.flatten().map { String($0) }
		return outputFromRun(createTask(executable, args: stringargs), file: file, line: line)
	}
}


// MARK: runAsync

/** Output from the 'runAsync' methods. */
public struct AsyncShellTask {
	public let stdout: ReadableStream
	public let stderror: ReadableStream
	private let task: NSTask

	init (task: NSTask, file: String = #file, line: Int = #line) {
		self.task = task

		let outpipe = NSPipe()
		task.standardOutput = outpipe
		self.stdout = ReadableStream(outpipe.fileHandleForReading)

		let errorpipe = NSPipe()
		task.standardError = errorpipe
		self.stderror = ReadableStream(errorpipe.fileHandleForReading)

		do {
			try task.launchThrowably()
		} catch {
			exit(error, file: file, line: line)
		}
	}

	/**
	Wait for this shell task to finish.

	- returns: itself
	- throws: `ShellError.ReturnedErrorCode (command: String, errorcode: Int32)` if the exit code is anything but 0.
	*/
	public func finish() throws -> AsyncShellTask {
		try task.finish()
		return self
	}

	/** Wait for command to finish, then return with exit code. */
	public func exitcode () -> Int32 {
		task.waitUntilExit()
		return task.terminationStatus
	}
}

extension ShellRunnable {

	/**
	Run executable and return before it is finished.

	- parameter executable: Path to an executable file. If not then exit.
	- parameter args: Arguments to the executable.
	- returns: An AsyncShellTask with standard output, standard error and a 'finish' function.
	*/
	public func runAsync (executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> AsyncShellTask {
		let stringargs = args.flatten().map { String($0) }
		return AsyncShellTask(task: createTask(executable, args: stringargs), file: file, line: line)
	}
}


// MARK: runAndPrint

extension ShellRunnable {

	/**
	Run executable and print output and errors.

	- parameter executable: path to an executable file.
	- parameter args: arguments to the executable.
	- throws: `ShellError.ReturnedErrorCode (command: String, errorcode: Int32)` if the exit code is anything but 0.

		`ShellError.InAccessibleExecutable (path: String)` if 'executable’ turned out to be not so executable after all.
	*/
	public func runAndPrint (executable: String, _ args: Any ...) throws {
		let stringargs = args.flatten().map { String($0) }
		let task = createTask(executable, args: stringargs)

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
public func run (executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> String {
	return main.run(executable, args, file: file, line: line)
}

/**
Run executable and return before it is finished.

- parameter executable: path to an executable file.
- parameter args: arguments to the executable.
- returns: an AsyncShellTask with standard output, standard error and a 'finish' function.
*/
public func runAsync (executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> AsyncShellTask {
	return main.runAsync(executable, args, file: file, line: line)
}

/**
Run executable and print output and errors.

- parameter executable: path to an executable file.
- parameter args: arguments to the executable.
- throws: `ShellError.ReturnedErrorCode (command: String, errorcode: Int32)` if the exit code is anything but 0.

	`ShellError.InAccessibleExecutable (path: String)` if 'executable’ turned out to be not so executable after all.
*/
public func runAndPrint (executable: String, _ args: Any ...) throws {
	return try main.runAndPrint(executable, args)
}
