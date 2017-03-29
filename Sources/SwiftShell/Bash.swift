/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

#if !(os(iOS) || os(tvOS) || os(watchOS))

import Foundation

// MARK: Bash

extension ShellRunnable {

	func createTask (bash bashcommand: String) -> Process {
		return createTask("/bin/bash", args: ["-c", bashcommand])
	}

	@available(*, unavailable, message: "Use `run(bash: ...).stdout` instead.")
	@discardableResult public func run (bash bashcommand: String, file: String = #file, line: Int = #line) -> String {
		fatalError()
	}

	/**
	Runs a bash shell command.

	- parameter bashcommand: the bash shell command.
	*/
	@discardableResult public func run (bash bashcommand: String, file: String = #file, line: Int = #line) -> RunOutput {
		let async = AsyncShellTask(process: createTask(bash: bashcommand), file: file, line: line)
		return RunOutput(output: async)
	}

	/**
	Run bash command and return before it is finished.

	- parameter bashcommand: the bash shell command.
	- returns: an AsyncShellTask struct with standard output, standard error and a 'finish' function.
	*/
	public func runAsync (bash bashcommand: String) -> AsyncShellTask {
		return AsyncShellTask(process: createTask(bash: bashcommand))
	}

	/**
	Run bash command and print output and errors.

	- parameter bashcommand: the bash shell command.
	- throws: a ShellError.ReturnedErrorCode if the return code is anything but 0.
	*/
	public func runAndPrint (bash bashcommand: String) throws {
		let process = createTask(bash: bashcommand)
		process.launch()
		try process.finish()
	}
}

@available(*, unavailable, message: "Use `run(bash: ...).stdout` instead.")
@discardableResult public func run (bash bashcommand: String, file: String = #file, line: Int = #line) -> String {
	fatalError()
}

/**
Runs a bash shell command.

- parameter bashcommand: the bash shell command.
*/
@discardableResult public func run (bash bashcommand: String, file: String = #file, line: Int = #line) -> RunOutput {
	return main.run(bash: bashcommand, file: file, line: line)
}

/**
Run bash command and return before it is finished.

- parameter bashcommand: the bash shell command.
- returns: an AsyncShellTask struct with standard output, standard error and a 'finish' function.
*/
public func runAsync (bash bashcommand: String) -> AsyncShellTask {
	return main.runAsync(bash: bashcommand)
}

/**
Run bash command and print output and errors.

- parameter bashcommand: the bash shell command.
- throws: a ShellError.ReturnedErrorCode if the return code is anything but 0.
*/
public func runAndPrint (bash bashcommand: String) throws {
	return try main.runAndPrint(bash: bashcommand)
}

#endif
