/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2014 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
* Contributors:
*	Kåre Morstøl, https://github.com/kareman - initial API and implementation.
*/

import Foundation

public typealias FileHandle = NSFileHandle

extension FileHandle: ReadableStreamType {

	public func readSome () -> String? {
		let data: NSData = self.availableData
		if data.length == 0 {
			return nil
		} else {
			if let result = NSString(data: data, encoding: streamencoding) {
				return result as String
			} else {
				printErrorAndExit("Fatal error - could not read stream.")
			}
		}
	}

	public func read () -> String {
		let data: NSData = self.readDataToEndOfFile()
		if let result = NSString(data: data, encoding: streamencoding) {
			return result as String
		} else {
			printErrorAndExit("Fatal error - could not read stream.")
		}
	}

	public func lines () -> AnySequence<String> {
		return split("\n")(stream: self)
	}

	public func writeTo <Target : OutputStreamType> (inout target: Target) {
		while let some = self.readSome() {
			target.write(some)
		}
	}
}

extension FileHandle: WriteableStreamType {

	public func write (string: String) {
		writeData(string.dataUsingEncoding(streamencoding, allowLossyConversion:false)!)
	}

	public func writeln (string: String) {
		self.write(string + "\n")
	}

	public func writeln () {
		self.write("\n")
	}

	public func closeStream () {
		self.closeFile()
	}
}

/** Print message to standard error and halt execution. */
@noreturn public func printErrorAndExit <T> (errormessage: T) {
	standarderror.writeln("SwiftShell: \(errormessage)")
	exit(EXIT_FAILURE)
}

/** Run a function which takes a NSErrorPointer. If an NSError occurs, throw it, otherwise return result. */
func makeThrowable <T> (nserrorfunc: (NSErrorPointer) -> T) throws -> T {
	var maybeerror: NSError?
	let result = nserrorfunc(&maybeerror)
	if let actualerror = maybeerror {
		throw actualerror
	}
	return result
}

/** Open a file for reading, and exit if an error occurs. */
public func open (path: String) -> ReadableStreamType {

	let url = toURLOrError(path)
	do {
		return try FileHandle(forReadingFromURL: url)
	} catch {
		do {
			try makeThrowable(url.checkResourceIsReachableAndReturnError)
		} catch {
			printErrorAndExit(error)
		}
		printErrorAndExit(error)
	}
}

/**
Open a file for writing, create it if it doesn't exist, and exit if an error occurs.
If the file already exists and overwrite=false, the writing will begin at the end of the file.

- parameter overwrite: If true, replace the file if it exists.
*/
public func open (forWriting path: String, overwrite: Bool = false) -> WriteableStreamType {

	let url = toURLOrError(path)
	if overwrite || !File.fileExistsAtPath(url.path!) {
		File.createFileAtPath(url.path!, contents: nil, attributes: nil)
	}

	do {
		let filehandle = try FileHandle(forWritingToURL: url)
		filehandle.seekToEndOfFile()
		return filehandle
	} catch {
		do {
			try makeThrowable(url.checkResourceIsReachableAndReturnError)
		} catch {
			printErrorAndExit(error)
		}
		printErrorAndExit(error)
	}
}


public let environment		= NSProcessInfo.processInfo().environment as [String: String]
public let standardinput	= FileHandle.fileHandleWithStandardInput() as ReadableStreamType
public let standardoutput	= FileHandle.fileHandleWithStandardOutput() as WriteableStreamType
public let standarderror	= FileHandle.fileHandleWithStandardError() as WriteableStreamType
