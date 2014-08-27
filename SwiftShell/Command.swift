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
	task.arguments = ["-c",shellcommand]
	task.launchPath = "/bin/bash"

	// avoids implicit reading of the main script's standardInput
	task.standardInput = NSPipe ()

	return task
}

public func run (shellcommand: String) -> ReadableStreamType {
	let task = newtask(shellcommand)
	
	let output = NSPipe ()
	task.standardOutput = output
	task.launch()
	task.waitUntilExit()
	return output.fileHandleForReading
}

public func run (shellcommand: String)(input: ReadableStreamType) -> ReadableStreamType {
	let task = newtask(shellcommand)
	task.standardInput = input as File
	
	let output = NSPipe ()
	task.standardOutput = output
	task.launch()
	task.waitUntilExit()
	return output.fileHandleForReading
}
