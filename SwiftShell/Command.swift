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

	func runLater (shellcommand: String, args: [String]) -> NSTask {
		let task = NSTask()
		task.arguments = args
		task.launchPath = shellcommand
		task.environment = main.env

		return task
	}

	func runLater (bash bashcommand: String) -> NSTask {
		return runLater("/bin/bash", args: ["-c", bashcommand])
	}

	/** Shortcut for in-line command, returns output as String. */
	public func $ (shellcommand: String, args: String ...) -> String {
		let task = runLater(shellcommand, args: args)

		// avoids implicit reading of the main script's standardInput
		task.standardInput = NSPipe ()

		let output = NSPipe ()
		task.standardOutput = output
		task.standardError = output
		task.launch()
		task.waitUntilExit()

		return output.fileHandleForReading.read(encoding: self.encoding)
	}
	
}
