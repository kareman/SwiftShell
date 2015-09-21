/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

public protocol ShellContextType {
	var encoding: NSStringEncoding {get set}
	var env: [String: String] {get set}

	var stdin: NSFileHandle {get set}
	var stdout: NSFileHandle {get set}
	var stderror: NSFileHandle {get set}

	/**
	The current working directory.

	Must be used instead of `run("cd ...")` because all the `run` commands are executed in a
	separate process and changing the directory there will not affect the rest of the Swift script.
	*/
	var currentdirectory: String {get set}
}


public final class MainShellContext: ShellContextType {

	// TODO: get encoding from environmental variable LC_CTYPE
	public var encoding = NSUTF8StringEncoding
	public lazy var env = NSProcessInfo.processInfo().environment as [String: String]

	public lazy var stdin    = NSFileHandle.fileHandleWithStandardInput() //as ReadableStreamType
	public lazy var stdout   = NSFileHandle.fileHandleWithStandardOutput() //as WriteableStreamType
	public lazy var stderror = NSFileHandle.fileHandleWithStandardError() //as WriteableStreamType

	/**
	The current working directory.

	Must be used instead of `run("cd ...")` because all the `run` commands are executed in a
	separate process and changing the directory there will not affect the rest of the Swift script.

	This directory is also used as the base for relative URL's.
	*/
	public var currentdirectory: String {
		get {	return Files.currentDirectoryPath }
		set {
			if !Files.changeCurrentDirectoryPath(newValue) {
				exit(errormessage: "Could not change the working directory to \(newValue)")
			}
		}
	}


	public lazy var arguments: [String] = Process.arguments.count <= 1 ? [] : Array(Process.arguments.dropFirst())
	public lazy var name: String = Process.arguments.first.map(NSURL.init)?.lastPathComponent ?? ""

	private init() {

	}
}

public let main = MainShellContext()
