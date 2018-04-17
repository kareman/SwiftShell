/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

#if !(os(iOS) || os(tvOS) || os(watchOS))

import Foundation

// MARK: Bash

extension CommandRunning {

	@available(*, unavailable, message: "Use `run(bash: ...).stdout` instead.")
	@discardableResult public func run(bash bashcommand: String, combineOutput: Bool = false) -> String {
		fatalError()
	}

	/// Runs a bash shell command.
	///
	/// - parameter bashcommand: the bash shell command.
	/// - parameter combineOutput: if true then stdout and stderror go to the same stream. Default is false.
	@discardableResult public func run(bash bashcommand: String, combineOutput: Bool = false) -> RunOutput {
		return run("/bin/bash", "-c", bashcommand, combineOutput: combineOutput)
	}

	/**
	Runs bash command and returns before it is finished.

	- parameter bashcommand: the bash shell command.
	*/
	public func runAsync(bash bashcommand: String, file: String = #file, line: Int = #line) -> AsyncCommand {
		return runAsync("/bin/bash", "-c", bashcommand, file: file, line: line)
	}

	/**
	Runs bash command and returns before it is finished.
	Any output is printed to standard output and standard error, respectively.

	- parameter bashcommand: the bash shell command.
	*/
	public func runAsyncAndPrint(bash bashcommand: String, file: String = #file, line: Int = #line) -> PrintedAsyncCommand {
		return runAsyncAndPrint("/bin/bash", "-c", bashcommand, file: file, line: line)
	}

	/**
	Runs bash command and prints output and errors.

	- parameter bashcommand: the bash shell command.
	- throws: a CommandError.returnedErrorCode if the return code is anything but 0.
	*/
	public func runAndPrint(bash bashcommand: String) throws {
		return try runAndPrint("/bin/bash", "-c", bashcommand)
	}
}

@available(*, unavailable, message: "Use `run(bash: ...).stdout` instead.")
@discardableResult public func run(bash bashcommand: String, combineOutput: Bool = false) -> String {
	fatalError()
}

/// Runs a bash shell command.
///
/// - parameter bashcommand: the bash shell command.
/// - parameter combineOutput: if true then stdout and stderror go to the same stream. Default is false.
@discardableResult public func run(bash bashcommand: String, combineOutput: Bool = false) -> RunOutput {
	return main.run(bash: bashcommand, combineOutput: combineOutput)
}

/**
Runs bash command and returns before it is finished.

- parameter bashcommand: the bash shell command.
*/
public func runAsync(bash bashcommand: String, file: String = #file, line: Int = #line) -> AsyncCommand {
	return main.runAsync(bash: bashcommand, file: file, line: line)
}

/**
Runs bash command and returns before it is finished.
Any output is printed to standard output and standard error, respectively.

- parameter bashcommand: the bash shell command.
*/
public func runAsyncAndPrint(bash bashcommand: String, file: String = #file, line: Int = #line) -> PrintedAsyncCommand {
	return main.runAsyncAndPrint(bash: bashcommand, file: file, line: line)
}

/**
Runs bash command and prints output and errors.

- parameter bashcommand: the bash shell command.
- throws: a CommandError.returnedErrorCode if the return code is anything but 0.
*/
public func runAndPrint(bash bashcommand: String) throws {
	return try main.runAndPrint(bash: bashcommand)
}

#endif
