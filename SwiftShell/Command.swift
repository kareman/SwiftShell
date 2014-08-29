/*
* Copyright (c) 2014 Kåre Morstøl (NotTooBad Software).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*
* Contributors:
*    Kåre Morstøl, https://github.com/kareman - initial API and implementation.
*/

import Foundation

private func newtask (shellcommand: String) -> NSTask {
	let task = NSTask()
	task.arguments = ["-c", shellcommand]
	task.launchPath = "/bin/bash"

	return task
}

/** 
Run a shell command synchronously with no standard input. 

:returns: Standard output
*/
public func run (shellcommand: String) -> ReadableStreamType {
	let task = newtask(shellcommand)

	// avoids implicit reading of the main script's standardInput
	task.standardInput = NSPipe ()
	
	let output = NSPipe ()
	task.standardOutput = output
	task.launch()
	
	// necessary for now to ensure one shellcommand is finished before another begins.
	// uncontrolled asynchronous shell processes could be messy.
	// but shell commands on the same line connected with the pipe operator should preferably be asynchronous.
	task.waitUntilExit()
	
	return output.fileHandleForReading
}

/** 
Run a shell command synchronously.

:param: input	Standard input.

:returns:		Standard output
*/
public func run (shellcommand: String)(input: ReadableStreamType) -> ReadableStreamType {
	let task = newtask(shellcommand)
	task.standardInput = input as FileHandle
	
	let output = NSPipe ()
	task.standardOutput = output
	task.launch()
	task.waitUntilExit()
	
	return output.fileHandleForReading
}
