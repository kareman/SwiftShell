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

	var stdin: ReadableStream {get set}
	var stdout: WriteableStream {get set}
	var stderror: WriteableStream {get set}

	/**
	The current working directory.

	Must be used instead of `run("cd", "...")` because all the `run` commands are executed in a
	separate process and changing the directory there will not affect the rest of the Swift script.
	*/
	var currentdirectory: String {get set}
}


public struct ShellContext: ShellContextType {
	public var encoding: NSStringEncoding
	public var env: [String: String]

	public var stdin: ReadableStream
	public var stdout: WriteableStream
	public var stderror: WriteableStream

	/**
	The current working directory.

	Must be used instead of `run("cd", "...")` because all the `run` commands are executed in a
	separate process and changing the directory there will not affect the rest of the Swift script.
	*/
	public var currentdirectory: String

	/** Creates a blank ShellContext. */
	public init () {
		encoding = NSUTF8StringEncoding
		env = [String:String]()

		stdin =    ReadableStream(NSFileHandle.fileHandleWithNullDevice(), encoding: encoding)
		stdout =   WriteableStream(NSFileHandle.fileHandleWithNullDevice(), encoding: encoding)
		stderror = WriteableStream(NSFileHandle.fileHandleWithNullDevice(), encoding: encoding)

		currentdirectory = main.currentdirectory
	}

	/** Creates a new ShellContext from another ShellContextType. */
	public init (_ context: ShellContextType) {
		encoding = context.encoding
		env = context.env

		stdin =    context.stdin
		stdout =   context.stdout
		stderror = context.stderror

		currentdirectory = context.currentdirectory
	}
}

extension ShellContext: ShellRunnable {
	public var shellcontext: ShellContextType { return self }
}


private func createTempdirectory () -> String {
	let tempdirectory = NSURL(fileURLWithPath:NSTemporaryDirectory()) / ("SwiftShell-" + NSProcessInfo.processInfo().globallyUniqueString)
	do {
		try Files.createDirectoryAtPath(tempdirectory.path!, withIntermediateDirectories: true, attributes: nil)
		return tempdirectory.path!
	} catch let error as NSError {
		exit(errormessage: "Could not create new temporary directory '\(tempdirectory)':\n\(error.localizedDescription)")
	} catch {
		exit(errormessage: "Unexpected error: \(error)")
	}
}

public final class MainShellContext: ShellContextType {

	// TODO: get encoding from environmental variable LC_CTYPE
	public var encoding = NSUTF8StringEncoding
	public lazy var env = NSProcessInfo.processInfo().environment as [String: String]

	public lazy var stdin: ReadableStream = { ReadableStream(NSFileHandle.fileHandleWithStandardInput(), encoding: self.encoding) }()
	public lazy var stdout: WriteableStream = { WriteableStream(NSFileHandle.fileHandleWithStandardOutput(), encoding: self.encoding) }()
	public lazy var stderror: WriteableStream = { WriteableStream(NSFileHandle.fileHandleWithStandardError(), encoding: self.encoding) }()

	/**
	The current working directory.

	Must be used instead of `run("cd", "...")` because all the `run` commands are executed in a
	separate process and changing the directory there will not affect the rest of the Swift script.

	This directory is also used as the base for relative NSURLs.
	*/
	public var currentdirectory: String {
		get {	return Files.currentDirectoryPath }
		set {
			if !Files.changeCurrentDirectoryPath(newValue) {
				exit(errormessage: "Could not change the working directory to \(newValue)")
			}
		}
	}

	/**
	The tempdirectory is unique each time a script is run and is created the first time it is used.
	It lies in the user's temporary directory and will be automatically deleted at some point.
	*/
	public lazy var tempdirectory: String = createTempdirectory()

	public lazy var arguments: [String] = Process.arguments.count <= 1 ? [] : Array(Process.arguments.dropFirst())
	public lazy var name: String = Process.arguments.first.map(NSURL.init)?.lastPathComponent ?? ""

	private init() {
	}
}

extension MainShellContext: ShellRunnable {
	public var shellcontext: ShellContextType { return self }
}

public let main = MainShellContext()
