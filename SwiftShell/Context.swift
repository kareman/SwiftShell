/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

public struct Context {

	// TODO: get encoding from environmental variable LC_CTYPE
	public var encoding = NSUTF8StringEncoding
	public lazy var env = NSProcessInfo.processInfo().environment as [String: String]

	public var stdin    = NSFileHandle.fileHandleWithStandardInput() //as ReadableStreamType
	public var stdout	  = NSFileHandle.fileHandleWithStandardOutput() //as WriteableStreamType
	public var stderror = NSFileHandle.fileHandleWithStandardError() //as WriteableStreamType

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
				printErrorAndExit("Could not change the working directory to \(newValue)")
			}
		}
	}

	public lazy var arguments: [String] = Process.arguments.isEmpty ? [] : Array(dropFirst(Process.arguments))
	public lazy var name: String = Process.arguments.first ?? ""
}

public var main = Context()
