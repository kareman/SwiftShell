/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

#if !(os(iOS) || os(tvOS) || os(watchOS))

import Foundation

#if !(os(macOS) || os(iOS) || os(tvOS) || os(watchOS)) && !swift(>=3.1)
typealias Process = Task
#endif

// MARK: exit

/**
Print message to standard error and halt execution.

- parameter errormessage: the error message.
- parameter errorcode: exit code for the entire program. Defaults to 1.
- returns: Never.
*/
public func exit <T> (errormessage: T, errorcode: Int = 1, file: String = #file, line: Int = #line) -> Never  {
	main.stderror.print(file + ":\(line):", errormessage)
	exit(Int32(errorcode))
}

/**
Print error to standard error and halt execution.

- parameter error: the error
- returns: Never.
*/
public func exit (_ error: Error, file: String = #file, line: Int = #line) -> Never  {
	if let shellerror = error as? ShellError {
		exit(errormessage: shellerror, errorcode: shellerror.errorcode, file: file, line: line)
	} else {
		exit(errormessage: error, errorcode: error._code, file: file, line: line)
	}
}


//	MARK: ShellRunnable

/// Can run shell commands using itself as standard input and 'main' as the context.
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
			let path = self.run("/usr/bin/which", executable).stdout
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
	case ReturnedErrorCode (command: String, errorcode: Int)

	/** Command could not be executed. */
	case InAccessibleExecutable (path: String)

	/** Exit code for this error. */
	var errorcode: Int {
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

	- throws: `ShellError.ReturnedErrorCode (command: String, errorcode: Int)` if the exit code is anything but 0.
	*/
	public func finish() throws {
		self.waitUntilExit()
		guard self.terminationStatus == 0 else {
			throw ShellError.ReturnedErrorCode(command: commandAsString()!, errorcode: Int(self.terminationStatus))
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

/** Output from a `run` command. */
public final class RunOutput {
	fileprivate let output: AsyncShellTask

	init(output: AsyncShellTask) {
		output.process.waitUntilExit()
		self.output = output
	}

	/// If output is single-line, trim it.
	static private func cleanUpOutput(_ text: String) -> String {
		var text = text
		let firstnewline = text.characters.index(of: "\n")
		if firstnewline == nil || text.characters.index(after: firstnewline!) == text.endIndex {
			text = text.trimmingCharacters(in: .whitespacesAndNewlines)
		}
		return text
	}

	/// Standard output, trimmed for whitespace and newline if it is single-line.
	public lazy var stdout: String = RunOutput.cleanUpOutput(self.output.stdout.read())

	/// Standard error, trimmed for whitespace and newline if it is single-line.
	public lazy var stderror: String = RunOutput.cleanUpOutput(self.output.stderror.read())

	/// The exit code of the command. Anything but 0 means error.
	public var exitcode: Int { return output.exitcode() }

	/// Checks if the exit code is 0.
	public var succeeded: Bool { return exitcode == 0 }

	@discardableResult
	static func && (lhs: RunOutput, rhs: @autoclosure () -> RunOutput) -> RunOutput {
		guard lhs.succeeded else { return lhs }
		return rhs()
	}

	@discardableResult
	static func || (lhs: RunOutput, rhs: @autoclosure () -> RunOutput) -> RunOutput {
		if lhs.succeeded { return lhs }
		return rhs()
	}
}

extension ShellRunnable {

	@available(*, unavailable, message: "Use `run(...).stdout` instead.")
	@discardableResult public func run (_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> String {
		fatalError()
	}

	/**
	Runs a shell command.

	- warning: will crash if ‘executable’ could not be launched.
	- parameter executable: path to an executable, or the name of an executable in PATH.
	- parameter args: the arguments, one string for each.
	*/
	@discardableResult public func run (_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> RunOutput {
		let stringargs = args.flatten().map(String.init(describing:))
		let async = AsyncShellTask(process: createTask(executable, args: stringargs), file: file, line: line)
		return RunOutput(output: async)
	}
}

// MARK: runAsync

/** Output from the 'runAsync' methods. */
public final class AsyncShellTask {
	public let stdout: ReadableStream
	public let stderror: ReadableStream
	fileprivate let process: Process

	init (process: Process, file: String = #file, line: Int = #line) {
		self.process = process

		let outpipe = Pipe()
		process.standardOutput = outpipe
		stdout = FileHandleStream(outpipe.fileHandleForReading, encoding: main.encoding)

		let errorpipe = Pipe()
		process.standardError = errorpipe
		stderror = FileHandleStream(errorpipe.fileHandleForReading, encoding: main.encoding)

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
	- throws: `ShellError.ReturnedErrorCode (command: String, errorcode: Int)` if the exit code is anything but 0.
	*/
	@discardableResult public func finish() throws -> AsyncShellTask {
		try process.finish()
		return self
	}

	/** Wait for command to finish, then return with exit code. */
	public func exitcode () -> Int {
		process.waitUntilExit()
		return Int(process.terminationStatus)
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
		`ShellError.ReturnedErrorCode (command: String, errorcode: Int)` if the exit code is anything but 0.

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
Runs a shell command.

- warning: will crash if ‘executable’ could not be launched.
- parameter executable: path to an executable, or the name of an executable in PATH.
- parameter args: the arguments, one string for each.
*/
@discardableResult public func run (_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> RunOutput {
	return main.run(executable, args, file: file, line: line)
}

@available(*, unavailable, message: "Use `run(...).stdout` instead.")
@discardableResult public func run (_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> String {
	fatalError()
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
- throws: `ShellError.ReturnedErrorCode (command: String, errorcode: Int)` if the exit code is anything but 0.

	`ShellError.InAccessibleExecutable (path: String)` if 'executable’ turned out to be not so executable after all.
*/
public func runAndPrint (_ executable: String, _ args: Any ...) throws {
	return try main.runAndPrint(executable, args)
}

#endif
