/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

// MARK: exit

/**
Print message to standard error and halt execution.

- parameter errormessage: the error message.
- parameter errorcode: exit code for the entire program. Defaults to 1.
- returns: not.
*/
public func exit <T> (errormessage: T, errorcode: Int = 1, file: String = #file, line: Int = #line) -> Never  {
	main.stderror.write(file + ":\(line): ")
	main.stderror.writeln(errormessage)
	exit(Int32(errorcode))
}

/**
Print message to standard error and halt execution.

- parameter errormessage: the error message.
- parameter errorcode: exit code for the entire program. Defaults to 1.
- returns: not.
*/
public func exit <T> (errormessage: T, errorcode: Int32, file: String = #file, line: Int = #line) -> Never  {
	main.stderror.write(file + ":\(line): ")
	main.stderror.writeln(errormessage)
	exit(errorcode)
}

/**
Print error to standard error and halt execution.

- parameter error: the error
- returns: not.
*/
public func exit (_ error: Error, file: String = #file, line: Int = #line) -> Never  {
	if let shellerror = error as? ShellError {
		exit(errormessage: shellerror, errorcode: shellerror.errorcode, file: file, line: line)
	} else {
#if os(OSX)
		let error = error as NSError
		// Cast to String to avoid compiler bug in release builds where the error message would not be printed.
		exit(errormessage: String(error.localizedDescription), errorcode: error.code, file: file, line: line)
#else
		exit(errormessage: String(error), errorcode: error._code, file: file, line: line)
#endif
	}
}


//	MARK: ShellRunnable

public protocol ShellRunnable {
	var shellcontext: ShellContextType { get }
}

extension ShellRunnable {

	func createTask (_ executable: String, args: [String]) -> Process {

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

		let process = Process()
		process.arguments = args
		process.launchPath = pathForExecutable(executable: executable)

		process.environment = shellcontext.env
		process.currentDirectoryPath = shellcontext.currentdirectory

		process.standardInput = shellcontext.stdin.filehandle
		process.standardOutput = shellcontext.stdout.filehandle
		process.standardError = shellcontext.stderror.filehandle

		return process
	}
}


// MARK: ShellError

/** Error type for shell commands. */
public enum ShellError: Error, Equatable {

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

// MARK: Process

extension Process {

	/**
	Launch process.

	- throws: ShellError.InAccessibleExecutable if command could not be executed.
	*/
	public func launchThrowably() throws {
		guard Files.isExecutableFile(atPath: self.launchPath!) else {
			throw ShellError.InAccessibleExecutable(path: self.launchPath!)
		}
		launch()
	}

	/**
	Wait until process is finished.

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
		return self.arguments?.reduce(path) { (acc:String, arg:String) in
			return acc + " " + ( arg.characters.contains(" ") ? ("\"" + arg + "\"") : arg )
		}
	}
}

// MARK: run

extension ShellRunnable {

	func outputFromRun (_ process: Process, file: String, line: Int) -> String {
		let output = Pipe ()
		process.standardOutput = output
		process.standardError = output
		do {
			try process.launchThrowably()
		} catch {
			exit(errormessage: error, file: file, line: line)
		}
		var outputstring = output.fileHandleForReading.read(encoding: shellcontext.encoding)
		process.waitUntilExit()

		// if output is single-line, trim it.
		let firstnewline = outputstring.characters.index(of: "\n")
		if firstnewline == nil || outputstring.characters.index(after: firstnewline!) == outputstring.endIndex {
			outputstring = outputstring.trimmingCharacters(in: .whitespacesAndNewlines)
		}

		return outputstring
	}

	/**
	Shortcut for shell command, returns output and errors as a String.

	- warning: will crash if ‘executable’ could not be launched.
	- parameter executable: path to an executable file.
	- parameter args: the arguments, one string for each.
	- returns: standard output and standard error in one string, trimmed of whitespace and newline if it is single-line.
	*/
	@discardableResult public func run (_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> String {
		let stringargs = args.flatten().map(String.init(describing:))
		return outputFromRun(createTask(executable, args: stringargs), file: file, line: line)
	}
}


// MARK: runAsync

/** Output from the 'runAsync' methods. */
public final class AsyncShellTask {
	public let stdout: ReadableStream
	public let stderror: ReadableStream
	fileprivate let process: Process

	init (process: Process, file: String = #file, line: Int = #line) {
		self.process = Process()

		let outpipe = Pipe()
		process.standardOutput = outpipe
		self.stdout = ReadableStream(outpipe.fileHandleForReading)

		let errorpipe = Pipe()
		process.standardError = errorpipe
		self.stderror = ReadableStream(errorpipe.fileHandleForReading)

		do {
			try process.launchThrowably()
		} catch {
			exit(errormessage: error, file: file, line: line)
		}
	}

	/** Terminate process early. */
	public func stop () {
		process.terminate()
	}

	/**
	Wait for this shell process to finish.

	- returns: itself
	- throws: `ShellError.ReturnedErrorCode (command: String, errorcode: Int32)` if the exit code is anything but 0.
	*/
	@discardableResult public func finish() throws -> AsyncShellTask {
		try process.finish()
		return self
	}

	/** Wait for command to finish, then return with exit code. */
	public func exitcode () -> Int32 {
		process.waitUntilExit()
		return process.terminationStatus
	}
}

extension AsyncShellTask {
	@discardableResult public func onCompletion ( handler: ((AsyncShellTask) -> ())? ) -> AsyncShellTask {
		process.terminationHandler = { (Process) in
			handler?(self)
		}
		return self
	}
}

extension ShellRunnable {

	/**
	Run executable and return before it is finished.

	- warning: will crash if ‘executable’ could not be launched.
	- parameter executable: Path to an executable file. If not then exit.
	- parameter args: Arguments to the executable.
	- returns: An AsyncShellTask with standard output, standard error and a 'finish' function.
	*/
	public func runAsync (_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> AsyncShellTask {
		let stringargs = args.flatten().map(String.init(describing:))
		return AsyncShellTask(process: createTask(executable, args: stringargs), file: file, line: line)
	}
}


// MARK: runAndPrint

extension ShellRunnable {

	/**
	Run executable and print output and errors.

	- parameter executable: path to an executable file.
	- parameter args: arguments to the executable.
	- throws: 
		`ShellError.ReturnedErrorCode (command: String, errorcode: Int32)` if the exit code is anything but 0.

		`ShellError.InAccessibleExecutable (path: String)` if 'executable’ turned out to be not so executable after all.
	*/
	public func runAndPrint (_ executable: String, _ args: Any ...) throws {
		let stringargs = args.flatten().map(String.init(describing:))
		let process = createTask(executable, args: stringargs)

		try process.launchThrowably()
		try process.finish()
	}
}

// MARK: Global functions

/**
Shortcut for shell command, returns output and errors as a String.

- warning: will crash if ‘executable’ could not be launched.
- parameter executable: path to an executable file.
- parameter args: the arguments, one string for each.
- returns: standard output and standard error in one string, trimmed of whitespace and newline if it is single-line.
*/
@discardableResult public func run (_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> String {
	return main.run(executable, args, file: file, line: line)
}

/**
Run executable and return before it is finished.

- warning: will crash if ‘executable’ could not be launched.
- parameter executable: path to an executable file.
- parameter args: arguments to the executable.
- returns: an AsyncShellTask with standard output, standard error and a 'finish' function.
*/
public func runAsync (_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> AsyncShellTask {
	return main.runAsync(executable, args, file: file, line: line)
}

/**
Run executable and print output and errors.

- parameter executable: path to an executable file.
- parameter args: arguments to the executable.
- throws: `ShellError.ReturnedErrorCode (command: String, errorcode: Int32)` if the exit code is anything but 0.

	`ShellError.InAccessibleExecutable (path: String)` if 'executable’ turned out to be not so executable after all.
*/
public func runAndPrint (_ executable: String, _ args: Any ...) throws {
	return try main.runAndPrint(executable, args)
}
