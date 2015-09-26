/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

// MARK: Bash

extension ShellContextType {

	func createTask (bash bashcommand: String) -> NSTask {
		return createTask("/bin/bash", args: ["-c", bashcommand])
	}

	/**
	Shortcut for bash shell command, returns output and errors as a String.

	- parameter bashcommand: the bash shell command.
	- returns: standard output and standard error in one string, trimmed of whitespace and newline if it is single-line.
	*/
	public func run (bash bashcommand: String) -> String {
		return outputFromRun(createTask(bash: bashcommand))
	}

	/**
	Run bash command and return before it is finished.

	- parameter bashcommand: the bash shell command.
	- returns: an AsyncShellTask struct with standard output, standard error and a 'finish' function.
	*/
	public func runAsync (bash bashcommand: String) -> AsyncShellTask {
		return AsyncShellTask(task: createTask(bash: bashcommand))
	}

	/**
	Run bash command and print output and errors.

	- parameter bashcommand: the bash shell command.
	- throws: a ShellError if the return code is anything but 0.
	*/
	public func runAndPrint (bash bashcommand: String) throws {
		let task = createTask(bash: bashcommand)
		task.launch()
		try task.finish()
	}
}

/**
Shortcut for bash shell command, returns output and errors as a String.

- parameter bashcommand: the bash shell command.
- returns: standard output and standard error in one string, trimmed of whitespace and newline if it is single-line.
*/
public func run (bash bashcommand: String) -> String {
	return main.run(bash: bashcommand)
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
- throws: a ShellError if the return code is anything but 0.
*/
public func runAndPrint (bash bashcommand: String) throws {
	return try main.runAndPrint(bash: bashcommand)
}
