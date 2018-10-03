/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

#if !(os(iOS) || os(tvOS) || os(watchOS))

import Foundation
import Dispatch

// MARK: exit

/**
Prints message to standard error and terminates the application.

- parameter errormessage: the error message.
- parameter errorcode: exit code for the entire program. Defaults to 1.
- returns: Never.
*/
public func exit <T>(errormessage: T, errorcode: Int = 1, file: String = #file, line: Int = #line) -> Never  {
	main.stderror.print(file + ":\(line):", errormessage)
	exit(Int32(errorcode))
}

/**
Prints error to standard error and terminates the application.

- parameter error: the error
- returns: Never.
*/
public func exit(_ error: Error, file: String = #file, line: Int = #line) -> Never {
	if let commanderror = error as? CommandError {
		exit(errormessage: commanderror, errorcode: commanderror.errorcode, file: file, line: line)
	} else {
		exit(errormessage: error.localizedDescription, errorcode: error._code, file: file, line: line)
	}
}

// MARK: CommandRunning

/// Can run commands.
public protocol CommandRunning {
	var context: Context { get }
}

extension CommandRunning where Self: Context {
	public var context: Context { return self }
}

extension CommandRunning {

	func createProcess(_ executable: String, args: [String]) -> Process {

		/**
		If `executable` is not a path and a path for an executable file of that name can be found, return that path.
		Otherwise just return `executable`.
		*/
		func path(for executable: String) -> String {
			guard !executable.contains("/") else {
				return executable
			}
			let path = self.run("/usr/bin/which", executable).stdout
			return path.isEmpty ? executable : path
		}

		let process = Process()
		process.arguments = args
		process.launchPath = path(for: executable)

		process.environment = context.env
		process.currentDirectoryPath = context.currentdirectory

		process.standardInput = context.stdin.filehandle
		process.standardOutput = context.stdout.filehandle
		process.standardError = context.stderror.filehandle

		return process
	}
}

// MARK: CommandError

/** Error type for commands. */
public enum CommandError: Error {

	/** Exit code was not zero. */
	case returnedErrorCode(command: String, errorcode: Int)

	/** Command could not be executed. */
	case inAccessibleExecutable(path: String)

	/** Exit code for this error. */
	public var errorcode: Int {
		switch self {
		case .returnedErrorCode(_, let code):
			return code
		case .inAccessibleExecutable:
			return 127 // according to http://tldp.org/LDP/abs/html/exitcodes.html
		}
	}
}

extension CommandError: CustomStringConvertible {
	public var description: String {
		switch self {
		case .inAccessibleExecutable(let path):
			return "Could not execute file at path '\(path)'."
		case .returnedErrorCode(let command, let code):
			return "Command '\(command)' returned with error code \(code)."
		}
	}
}

extension CommandError: Equatable {
	static public func == (e1: CommandError, e2: CommandError) -> Bool {
		switch (e1, e2) {
		case (.returnedErrorCode(let c1), .returnedErrorCode(let c2)):
			return c1.errorcode == c2.errorcode && c1.command == c2.command
		case (.inAccessibleExecutable(let c1), .inAccessibleExecutable(let c2)):
			return c1 == c2
		case (.inAccessibleExecutable, .returnedErrorCode), (.returnedErrorCode, .inAccessibleExecutable):
			return false
		}
	}
}

// MARK: run

/// Output from a `run` command.
public final class RunOutput {
	fileprivate let output: AsyncCommand
	private let rawStdout: Data
	private let rawStderror: Data

	/// The error from running the command, if any.
	public let error: CommandError?

	/// Launches command, reads all output from both standard output and standard error simultaneously,
	/// and waits until the command is finished.
	init(launch command: AsyncCommand) {
		var error: CommandError?
		var stdout = Data()
		var stderror = Data()
		let group = DispatchGroup()

		do {
			// launch and read stdout and stderror.
			// see https://github.com/kareman/SwiftShell/issues/52
			try command.process.launchThrowably()

			if command.stdout.filehandle.fileDescriptor != command.stderror.filehandle.fileDescriptor {
				DispatchQueue.global().async(group: group) {
					stderror = command.stderror.readData()
				}
			}

			stdout = command.stdout.readData()
			try command.finish()
		} catch let commandError as CommandError {
			error = commandError
		} catch let error {
			assertionFailure("Unexpected error: \(error)")
		}

		group.wait()

		self.rawStdout = stdout
		self.rawStderror = stderror
		self.output = command
		self.error = error
	}

	/// If text is single-line, trim it.
	static private func cleanUpOutput(_ text: String) -> String {
		let afterfirstnewline = text.index(of: "\n").map(text.index(after:))
		return (afterfirstnewline == nil || afterfirstnewline == text.endIndex)
			? text.trimmingCharacters(in: .whitespacesAndNewlines)
			: text
	}

	/// Standard output, trimmed of whitespace and newline if it is single-line.
	public private(set) lazy var stdout: String = {
		guard let result = String(data: rawStdout, encoding: output.stdout.encoding) else {
			fatalError("Could not convert binary output of stdout to text using encoding \(output.stdout.encoding).")
		}
		return RunOutput.cleanUpOutput(result)
	}()

	/// Standard error, trimmed of whitespace and newline if it is single-line.
	public private(set) lazy var stderror: String = {
		guard let result = String(data: rawStderror, encoding: output.stderror.encoding) else {
			fatalError("Could not convert binary output of stderror to text using encoding \(output.stderror.encoding).")
		}
		return RunOutput.cleanUpOutput(result)
	}()

	/// The exit code of the command. Anything but 0 means there was an error.
	public var exitcode: Int { return output.exitcode() }

	/// Checks if the exit code is 0.
	public var succeeded: Bool { return exitcode == 0 }

	/// Runs the first command, then the second one only if the first succeeded.
	///
	/// - Returns: the result of the second one if it was run, otherwise the first one.
	@discardableResult
	public static func && (lhs: RunOutput, rhs: @autoclosure () -> RunOutput) -> RunOutput {
		guard lhs.succeeded else { return lhs }
		return rhs()
	}

	/// Runs the first command, then the second one only if the first failed.
	///
	/// - Returns: the result of the second one if it was run, otherwise the first one.
	@discardableResult
	public static func || (lhs: RunOutput, rhs: @autoclosure () -> RunOutput) -> RunOutput {
		if lhs.succeeded { return lhs }
		return rhs()
	}
}

extension CommandRunning {
	@available(*, unavailable, message: "Use `run(...).stdout` instead.")
	@discardableResult public func run(_ executable: String, _ args: Any ..., combineOutput: Bool = false) -> String {
		fatalError()
	}

	/// Runs a command.
	///
	/// - parameter executable: path to an executable, or the name of an executable in PATH.
	/// - parameter args: the arguments, one string for each.
	/// - parameter combineOutput: if true then stdout and stderror go to the same stream. Default is false.
	@discardableResult public func run(_ executable: String, _ args: Any ..., combineOutput: Bool = false) -> RunOutput {
		let stringargs = args.flatten().map(String.init(describing:))
		let asyncCommand = AsyncCommand(unlaunched: createProcess(executable, args: stringargs), combineOutput: combineOutput)
		return RunOutput(launch: asyncCommand)
	}
}

// MARK: runAsync

/// Output from the `runAsyncAndPrint` commands.
public class PrintedAsyncCommand {
	fileprivate let process: Process

	init(unlaunched process: Process, combineOutput: Bool) {
		self.process = process

		if combineOutput {
			process.standardError = process.standardOutput
		}
	}

	/// Calls `init(unlaunched:)`, then launches the process and exits the application on error.
	convenience init(launch process: Process, file: String, line: Int) {
		self.init(unlaunched: process, combineOutput: false)
		do {
			try process.launchThrowably()
		} catch {
			exit(errormessage: error, file: file, line: line)
		}
	}

	/// Is the command still running?
	public var isRunning: Bool { return process.isRunning }

	/// Terminates the command by sending the SIGTERM signal.
	public func stop() {
		process.terminate()
	}

	/// Interrupts the command by sending the SIGINT signal.
	public func interrupt() {
		process.interrupt()
	}

	/**
	Temporarily suspends a command. Call resume() to resume a suspended command.

	- warning: You may suspend a command multiple times, but it must be resumed an equal number of times before the command will truly be resumed.
	- returns: `true` iff the command was successfully suspended.
	*/
	@discardableResult public func suspend() -> Bool {
		return process.suspend()
	}

	/**
	Resumes a command previously suspended with suspend().

	- warning: If the command has been suspended multiple times then it will have to be resumed the same number of times before execution will truly be resumed.
	- returns: true if the command was successfully resumed.
	*/
	@discardableResult public func resume() -> Bool {
		return process.resume()
	}

	/**
	Waits for this command to finish.

	- warning: Hangs if the unread output of either standard output or standard error is larger than 64KB ([#52](https://github.com/kareman/SwiftShell/issues/52)). To work around this problem, read all the output first, even if you're not going to use it.
	- returns: self
	- throws:  `CommandError.returnedErrorCode(command: String, errorcode: Int)` if the exit code is anything but 0.
	*/
	@discardableResult public func finish() throws -> Self {
		try process.finish()
		return self
	}

	/** Waits for command to finish, then returns with exit code. */
	public func exitcode() -> Int {
		process.waitUntilExit()
		return Int(process.terminationStatus)
	}

	/**
	Waits for the command to finish, then returns why the command terminated.

	- returns: `.exited` if the command exited normally, otherwise `.uncaughtSignal`.
	*/
	public func terminationReason() -> Process.TerminationReason {
		process.waitUntilExit()
		return process.terminationReason
	}

	/// Takes a closure to be called when the command has finished.
	///
	/// - Parameter handler: A closure taking this AsyncCommand as input, returning nothing.
	/// - Returns: This PrintedAsyncCommand.
	@discardableResult public func onCompletion(_ handler: @escaping (PrintedAsyncCommand) -> Void) -> Self {
		process.terminationHandler = { _ in
			handler(self)
		}
		return self
	}
}

/** Output from the 'runAsync' commands. */
public final class AsyncCommand: PrintedAsyncCommand {
	public let stdout: ReadableStream
	public let stderror: ReadableStream

	override init(unlaunched process: Process, combineOutput: Bool) {
		let outpipe = Pipe()
		process.standardOutput = outpipe
		stdout = FileHandleStream(outpipe.fileHandleForReading, encoding: main.encoding)

		if combineOutput {
			stderror = stdout
		} else {
			let errorpipe = Pipe()
			process.standardError = errorpipe
			stderror = FileHandleStream(errorpipe.fileHandleForReading, encoding: main.encoding)
		}

		super.init(unlaunched: process, combineOutput: combineOutput)
	}

	/// Takes a closure to be called when the command has finished.
	///
	/// - Parameter handler: A closure taking this AsyncCommand as input, returning nothing.
	/// - Returns: This AsyncCommand.
	@discardableResult public override func onCompletion(_ handler: @escaping (AsyncCommand) -> Void) -> Self {
		process.terminationHandler = { _ in
			handler(self)
		}
		return self
	}
}

extension CommandRunning {
	/**
	Runs executable and returns before it is finished.

	- warning:              Application will be terminated if ‘executable’ could not be launched.
	- parameter executable: Path to an executable file. If not then exit.
	- parameter args:       Arguments to the executable.
	*/
	public func runAsync(_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> AsyncCommand {
		let stringargs = args.flatten().map(String.init(describing:))
		return AsyncCommand(launch: createProcess(executable, args: stringargs), file: file, line: line)
	}

	/**
	Runs executable and returns before it is finished.
	Any output is printed to standard output and standard error, respectively.

	- warning:              Application will be terminated if ‘executable’ could not be launched.
	- parameter executable: Path to an executable file. If not then exit.
	- parameter args:       Arguments to the executable.
	*/
	public func runAsyncAndPrint(_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> PrintedAsyncCommand {
		let stringargs = args.flatten().map(String.init(describing:))
		return PrintedAsyncCommand(launch: createProcess(executable, args: stringargs), file: file, line: line)
	}
}

// MARK: runAndPrint

extension CommandRunning {

	/**
	Runs executable and prints output and errors.

	- parameter executable: path to an executable file.
	- parameter args:       arguments to the executable.
	- throws:
		`CommandError.returnedErrorCode(command: String, errorcode: Int)` if the exit code is anything but 0.

		`CommandError.inAccessibleExecutable(path: String)` if 'executable’ turned out to be not so executable after all.
	*/
	public func runAndPrint(_ executable: String, _ args: Any ...) throws {
		let stringargs = args.flatten().map(String.init(describing:))
		let process = createProcess(executable, args: stringargs)

		try process.launchThrowably()
		try process.finish()
	}
}

// MARK: Global functions

/// Runs a command.
///
/// - parameter executable: path to an executable, or the name of an executable in PATH.
/// - parameter args: the arguments, one string for each.
/// - parameter combineOutput: if true then stdout and stderror go to the same stream. Default is false.
@discardableResult public func run(_ executable: String, _ args: Any ..., combineOutput: Bool = false) -> RunOutput {
	return main.run(executable, args, combineOutput: combineOutput)
}

@available(*, unavailable, message: "Use `run(...).stdout` instead.")
@discardableResult public func run(_ executable: String, _ args: Any ..., combineOutput: Bool = false) -> String {
	fatalError()
}

/**
Runs executable and returns before it is finished.

- warning:              Application will be terminated if ‘executable’ could not be launched.
- parameter executable: Path to an executable file. If not then exit.
- parameter args:       Arguments to the executable.
*/
public func runAsync(_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> AsyncCommand {
	return main.runAsync(executable, args, file: file, line: line)
}

/**
Runs executable and returns before it is finished.
Any output is printed to standard output and standard error, respectively.

- warning:              Application will be terminated if ‘executable’ could not be launched.
- parameter executable: Path to an executable file. If not then exit.
- parameter args:       Arguments to the executable.
*/
public func runAsyncAndPrint(_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> PrintedAsyncCommand {
	return main.runAsyncAndPrint(executable, args, file: file, line: line)
}

/**
Runs executable and prints output and errors.

- parameter executable: path to an executable file.
- parameter args: arguments to the executable.
- throws: `CommandError.returnedErrorCode(command: String, errorcode: Int)` if the exit code is anything but 0.

	`CommandError.inAccessibleExecutable(path: String)` if 'executable’ turned out to be not so executable after all.
*/
public func runAndPrint(_ executable: String, _ args: Any ...) throws {
	return try main.runAndPrint(executable, args)
}

#endif
