/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

#if !(os(iOS) || os(tvOS) || os(watchOS))

import Foundation
import Dispatch

#if os(Linux)
import Glibc
#endif

#if !(os(macOS) || os(iOS) || os(tvOS) || os(watchOS)) && !swift(>=3.1)
typealias Process = Task

extension Task {
	var isRunning: Bool { return running }
}
#endif

// MARK: exit

/**
Print message to standard error and halt execution.

- parameter errormessage: the error message.
- parameter errorcode: exit code for the entire program. Defaults to 1.
- returns: Never.
*/
public func exit <T>(errormessage: T, errorcode: Int = 1, file: String = #file, line: Int = #line) -> Never  {
	main.stderror.print(file + ":\(line):", errormessage)
	exit(Int32(errorcode))
}

/**
Print error to standard error and halt execution.

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
		func pathForExecutable(executable: String) -> String {
			guard !executable.contains("/") else {
				return executable
			}
			let path = self.run("/usr/bin/which", executable).stdout
			return path.isEmpty ? executable : path
		}

		let process = Process()
		process.arguments = args
		process.launchPath = pathForExecutable(executable: executable)

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
public enum CommandError: Error, Equatable {

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

public func == (e1: CommandError, e2: CommandError) -> Bool {
	switch (e1, e2) {
	case (.returnedErrorCode(let c1), .returnedErrorCode(let c2)):
		return c1.errorcode == c2.errorcode && c1.command == c2.command
	case (.inAccessibleExecutable(let c1), .inAccessibleExecutable(let c2)):
		return c1 == c2
	case (.inAccessibleExecutable, .returnedErrorCode), (.returnedErrorCode, .inAccessibleExecutable):
		return false
	}
}

// MARK: Process

extension Process {

	/**
	Launch process.

	- throws: CommandError.inAccessibleExecutable if command could not be executed.
	*/
	public func launchThrowably() throws {
		guard Files.isExecutableFile(atPath: self.launchPath!) else {
			throw CommandError.inAccessibleExecutable(path: self.launchPath!)
		}
		launch()
	}

	/**
	Wait until process is finished.

	- throws: `CommandError.returnedErrorCode(command: String, errorcode: Int)` if the exit code is anything but 0.
	*/
	public func finish() throws {
		self.waitUntilExit()
		guard self.terminationStatus == 0 else {
			throw CommandError.returnedErrorCode(command: commandAsString()!, errorcode: Int(self.terminationStatus))
		}
	}

	/** The full path to the executable + all arguments, each one quoted if it contains a space. */
	func commandAsString() -> String? {
		guard let path = self.launchPath else { return nil }
		return self.arguments?.reduce(path) { (acc: String, arg: String) in
			return acc + " " + ( arg.contains(" ") ? ("\"" + arg + "\"") : arg )
		}
	}
}

// MARK: run

/// Output from a `run` command.
public final class RunOutput {
	fileprivate let output: AsyncCommand
	private var _stdout = Data()
	private var _stderror: Data

	/// The error from running the command, if any.
	public private(set) var error: CommandError?

	init(launch output: AsyncCommand) {
		var _stderror = Data()
		do {
			try output.process.launchThrowably()

			// see https://github.com/kareman/SwiftShell/issues/52
			let stderrorWork = DispatchWorkItem {
				_stderror = output.stderror.readData()
			}
			DispatchQueue.global().async(execute: stderrorWork)

			_stdout = output.stdout.readData()
			try output.finish()
			stderrorWork.wait()
		} catch let error as CommandError {
			self.error = error
		} catch {
			assertionFailure("Unexpected error: \(error)")
		}
		self._stderror = _stderror
		self.output = output
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
		guard let result = String(data: _stdout, encoding: output.stdout.encoding) else {
			fatalError("Could not convert binary data to text.")
		}
		_stdout = Data()
		return RunOutput.cleanUpOutput(result)
	}()

	/// Standard error, trimmed of whitespace and newline if it is single-line.
	public private(set) lazy var stderror: String = {
		guard let result = String(data: _stderror, encoding: output.stdout.encoding) else {
			fatalError("Could not convert binary data to text.")
		}
		_stderror = Data()
		return RunOutput.cleanUpOutput(result)
	}()

	/// The exit code of the command. Anything but 0 means there was an error.
	public var exitcode: Int { return output.exitcode() }

	/// Checks if the exit code is 0.
	public var succeeded: Bool { return exitcode == 0 }

	/// Run the first command, then the second one only if the first succeeded.
	///
	/// - Returns: the result of the second one if it was run, otherwise the first one.
	@discardableResult
	public static func && (lhs: RunOutput, rhs: @autoclosure () -> RunOutput) -> RunOutput {
		guard lhs.succeeded else { return lhs }
		return rhs()
	}

	/// Run the first command, then the second one only if the first failed.
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
		let async = AsyncCommand(unlaunched: createProcess(executable, args: stringargs), combineOutput: combineOutput)
		return RunOutput(launch: async)
	}
}

// MARK: runAsync

/** Output from the 'runAsync' methods. */
public final class AsyncCommand {
	public let stdout: ReadableStream
	public let stderror: ReadableStream
	fileprivate let process: Process

	init(unlaunched process: Process, combineOutput: Bool) {
		self.process = process

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
	}

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

	#if os(Linux)
	fileprivate enum ProcessAttribute: String {
		case blockedSignals = "blocked"
		case ignoredSignals = "ignored"
	}

	/**
	Gets a specified process attribute using the `ps` command installed on all
	Linux systems

	- parameter attr: Which specific attribute to return
	- returns: A String containing the hexadecimal representation of the mask,
			   or nil if there is no stdout output
	*/
	fileprivate func getProcessInfo(_ attr: ProcessAttribute) -> String? {
		let attribute = run(bash: "ps --no-headers -q \(process.processIdentifier) -o \(attr.rawValue)").stdout
		return attribute.isEmpty ? nil : attribute
	}

	/// Determines whether the running process is blocking the specified signal
	fileprivate func isBlockingSignal(_ signum: Int32) -> Bool {
		// If there is no mask, then the signal isn't blocked
		guard let blockedMask = getProcessInfo(.blockedSignals) else { return false }

		// If the output isn't in proper hexadecimal (like it should be), then
		// it could be ignored, but we can't be sure. Return true, just to be safe
		guard let blocked = Int(blockedMask, radix: 16) else { return true }

		// Checks if the signals bit in the mask is 1 (1 == blocked)
		return blocked & (1 << signum) == 1
	}

	/// Determines whether the running process is ignoring the specified signal
	fileprivate func isIgnoringSignal(_ signum: Int32) -> Bool {
		// If there is no mask, then the signal isn't ignored
		guard let ignoredMask = getProcessInfo(.ignoredSignals) else { return false }

		// If the output isn't in proper hexadecimal (like it should be), then
		// it could be ignored, but we can't be sure. Return true, just to be safe
		guard let ignored = Int(ignoredMask, radix: 16) else { return true }

		// Checks if the signals bit in the mask is 1 (1 == ignored)
		return ignored & (1 << signum) == 1
	}

	/// Sends the specified signal to the currently running process
	@discardableResult fileprivate func signal(_ signum: Int32) -> Int32 {
		return kill(process.processIdentifier, signum)
	}

	/// Terminates the command by sending the SIGTERM signal
	public func stop() {
		// If the SIGTERM signal is being blocked or ignored by the process,
		// then don't bother sending it
		guard !(isBlockingSignal(SIGTERM) || isIgnoringSignal(SIGTERM)) else { return }

		signal(SIGTERM)
	}

	/// Interrupts the command by sending the SIGINT signal
	public func interrupt() {
		// If the SIGINT signal is being blocked or ignored by the process,
		// then don't bother sending it
		guard !(isBlockingSignal(SIGINT) || isIgnoringSignal(SIGINT)) else { return }

		signal(SIGINT)
	}

	/**
	Temporarily suspends a command. Call resume() to resume a suspended command

	- returns: true if the command was successfully suspended
	*/
	@discardableResult public func suspend() -> Bool {
		return signal(SIGTSTP) == 0
	}

	/**
	Resumes a command previously suspended with suspend().

	- returns: true if the command was successfully resumed
	*/
	@discardableResult public func resume() -> Bool {
		return signal(SIGCONT) == 0
	}
	#else
	/// Terminates the command by sending the SIGTERM signal
	public func stop() {
		process.terminate()
	}

	/// Interrupts the command by sending the SIGINT signal
	public func interrupt() {
		process.interrupt()
	}

	/**
	Temporarily suspends a command. Call resume() to resume a suspended command

	- warning: You may suspend a command multiple times, but it must be resumed an equal number of times before the command will truly be resumed
	- returns: true if the command was successfully suspended
	*/
	@discardableResult public func suspend() -> Bool {
		return process.suspend()
	}

	/**
	Resumes a command previously suspended with suspend().

	- warning: If the command has been suspended multiple times then it will have to be resumed the same number of times before execution will truly be resumed
	- returns: true if the command was successfully resumed
	*/
	@discardableResult public func resume() -> Bool {
		return process.resume()
	}
	#endif

	/**
	Wait for this command to finish.

	- warning: Will hang if the unread output of either standard output or standard error is larger than 64KB ([#52](https://github.com/kareman/SwiftShell/issues/52)). To work around this problem, read all the output first, even if you're not going to use it.
	- returns: self
	- throws: `CommandError.returnedErrorCode(command: String, errorcode: Int)` if the exit code is anything but 0.
	*/
	@discardableResult public func finish() throws -> AsyncCommand {
		try process.finish()
		return self
	}

	/** Wait for command to finish, then return with exit code. */
	public func exitcode() -> Int {
		process.waitUntilExit()
		return Int(process.terminationStatus)
	}

	/**
	Wait for the command to finish, then return why the command terminated

	- returns: .exited if the command exited normally, otherwise it's .uncaughtSignal
	*/
	public func terminationReason() -> Process.TerminationReason {
		process.waitUntilExit()
		return process.terminationReason
	}

	/// Takes a closure to be called when the command has finished.
	///
	/// - Parameter handler: A closure taking this AsyncCommand as input, returning nothing.
	/// - Returns: This AsyncCommand.
	@discardableResult public func onCompletion(_ handler: @escaping (AsyncCommand) -> Void) -> AsyncCommand {
		process.terminationHandler = { _ in
			handler(self)
		}
		return self
	}
}

extension CommandRunning {

	/**
	Run executable and return before it is finished.

	- warning: Will crash if ‘executable’ could not be launched.
	- parameter executable: Path to an executable file. If not then exit.
	- parameter args: Arguments to the executable.
	- returns: An AsyncCommand with standard output, standard error and a 'finish' function.
	*/
	public func runAsync(_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> AsyncCommand {
		let stringargs = args.flatten().map(String.init(describing:))
		return AsyncCommand(launch: createProcess(executable, args: stringargs), file: file, line: line)
	}
}

// MARK: runAndPrint

extension CommandRunning {

	/**
	Run executable and print output and errors.

	- parameter executable: path to an executable file.
	- parameter args: arguments to the executable.
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
Run executable and return before it is finished.

- warning: will crash if ‘executable’ could not be launched.
- parameter executable: path to an executable file.
- parameter args: arguments to the executable.
- returns: an AsyncCommand with standard output, standard error and a 'finish' function.
*/
public func runAsync(_ executable: String, _ args: Any ..., file: String = #file, line: Int = #line) -> AsyncCommand {
	return main.runAsync(executable, args, file: file, line: line)
}

/**
Run executable and print output and errors.

- parameter executable: path to an executable file.
- parameter args: arguments to the executable.
- throws: `CommandError.returnedErrorCode(command: String, errorcode: Int)` if the exit code is anything but 0.

	`CommandError.inAccessibleExecutable(path: String)` if 'executable’ turned out to be not so executable after all.
*/
public func runAndPrint(_ executable: String, _ args: Any ...) throws {
	return try main.runAndPrint(executable, args)
}

#endif
