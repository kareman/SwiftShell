//
// Command.swift
// SwiftShell
//
// Created by Kåre Morstøl on 15/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import Foundation

private func newtask (shellcommand: String) -> NSTask  {
	let task = NSTask()
	task.arguments = ["-c",shellcommand]
	task.launchPath = "/bin/bash"
	task.standardInput =  NSPipe ()// to avoid implicit reading of the script's standardInput

	return task
}

public func run (shellcommand: String) -> ReadableStreamType {
	let task = newtask(shellcommand)
	let output = NSPipe ()
	task.standardOutput = output
	task.launch()
	return output.fileHandleForReading
}

public func run (shellcommand: String)(input: ReadableStreamType) ->  ReadableStreamType {
	let task = newtask(shellcommand)
	task.standardInput =  input as File
	let output = NSPipe ()
	task.standardOutput = output
	task.launch()
	return output.fileHandleForReading
}
