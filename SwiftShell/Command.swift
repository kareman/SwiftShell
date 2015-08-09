/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation


/** Print message to standard error and halt execution. */
@noreturn public func printErrorAndExit <T> (errormessage: T, errorcode: Int32 = EXIT_FAILURE) {
	main.stderror.writeln("SwiftShell: \(errormessage)")
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
		if outputstring.hasSuffix("\n") && outputstring.characters.indexOf("\n") == outputstring.endIndex.predecessor() {
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
