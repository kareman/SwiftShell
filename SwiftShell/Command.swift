//
// Command.swift
// SwiftShell
//
// Created by Kåre Morstøl on 15/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import Foundation

private func newtask (shellcommand: String) -> NSTask {
	let task = NSTask()
	task.arguments = ["-c", shellcommand]
	task.launchPath = "/bin/bash"

	return task
}

/** 
Run a shellcommand synchronously with no standard input. 

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
	task.standardInput = input as File
	
	let output = NSPipe ()
	task.standardOutput = output
	task.launch()
	task.waitUntilExit()
	
	return output.fileHandleForReading
}
