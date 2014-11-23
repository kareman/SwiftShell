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
			return (NSString(data: data, encoding: streamencoding) as String)
		}
	}

	public func read () -> String {
		let data: NSData = self.readDataToEndOfFile()
		return NSString(data: data, encoding: streamencoding) as String
	}

	public func lines () -> SequenceOf<String> {
		return split(delimiter: "\n")(stream: self)
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

/** Print message to standard error and halt execution */
@noreturn public func printErrorAndExit (errormessage: String) {
	standarderror.writeln("SwiftShell: " + errormessage)
	exit(EXIT_FAILURE)
}

/** Open a file for reading, and exit if an error occurs. */
public func open (path: String) -> ReadableStreamType {

	if let url = NSURL(fileURLWithPath: path) {

		var error: NSError?
		let filehandle = FileHandle(forReadingFromURL: url, error: &error)

		if let error = error {
			var fileaccesserror: NSError?
			url.checkResourceIsReachableAndReturnError(&fileaccesserror)
			printErrorAndExit( fileaccesserror?.localizedDescription ?? error.localizedDescription )
		}

		return filehandle!

	} else {
		printErrorAndExit("Invalid file path: \(path)")
	}
}


public let environment		= NSProcessInfo.processInfo().environment as [String: String]
public let standardinput	= FileHandle.fileHandleWithStandardInput() as ReadableStreamType
public let standardoutput	= FileHandle.fileHandleWithStandardOutput() as WriteableStreamType
public let standarderror	= FileHandle.fileHandleWithStandardError() as WriteableStreamType
