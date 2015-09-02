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

extension ShellContextType {

	func setupTask (executable: String, args: [String]) -> NSTask {
		let task = NSTask()
		task.arguments = args
		task.launchPath = executable

		task.environment = self.env
		task.currentDirectoryPath = self.currentdirectory

		task.standardInput = self.stdin
		task.standardOutput = self.stdout
		task.standardError = self.stderror

		return task
	}

	func setupTask (bash bashcommand: String) -> NSTask {
		return setupTask("/bin/bash", args: ["-c", bashcommand])
	}


	private func outputFrom$ (task: NSTask) -> String {
		let output = NSPipe ()
		task.standardOutput = output
		task.standardError = output
		task.launch()
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

	- parameter args: the arguments, one string for each.
	- returns: standard output and standard error in one string, trimmed of whitespace and newline if it is single-line.
	*/
	public func $ (executable: String, _ args: String ...) -> String {
		return outputFrom$(setupTask(executable, args: args))
	}

	/**
	Shortcut for bash shell command, returns output and errors as a String.

	- returns: standard output and standard error in one string, trimmed of whitespace and newline if it is single-line.
	*/
	public func $ (bash bashcommand: String) -> String {
		return outputFrom$(setupTask(bash: bashcommand))
	}
}

public struct AsyncShellTask {
	public let stdout: NSFileHandle
	public let stderror: NSFileHandle
	private let task: NSTask

	private init (task: NSTask) {
		self.task = task

		let outpipe = NSPipe()
		task.standardOutput = outpipe
		self.stdout = outpipe.fileHandleForReading

		let errorpipe = NSPipe()
		task.standardError = errorpipe
		self.stderror = errorpipe.fileHandleForReading

		task.launch()
	}

	/** 
   Wait for this shell task to finish.

   - throws: a TaskError if the return code is anything but 0.
	*/
	public func finish() throws {
		task.waitUntilExit()
	}
}

extension ShellContextType {

	/**
   Run executable and return before it is finished.

   - parameter executable: path to an executable file.
   - parameter args: arguments to the executable.
   - returns: an AsyncShellTask with standard output, standard error and a 'finish' function.
	*/
	public func runAsync (executable: String, _ args: String ...) -> AsyncShellTask {
		return AsyncShellTask(task: setupTask(executable, args: args))
	}

	/**
   Run bash command and return before it is finished.

   - parameter bashcommand: the bash shell command.
   - returns: an AsyncShellTask struct with standard output, standard error and a 'finish' function.
	*/
	public func runAsync (bash bashcommand: String) -> AsyncShellTask {
		return AsyncShellTask(task: setupTask(bash: bashcommand))
	}
}
