/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

/** The default NSFileManager */
public let Files = NSFileManager.defaultManager()

/** Append file or directory url to directory url */
public func + (leftpath: NSURL, rightpath: String) -> NSURL {
	return leftpath.URLByAppendingPathComponent(rightpath)
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

/** Open a file for reading, throw if an error occurs. */
public func open (path: String, encoding: NSStringEncoding = main.encoding) throws -> ReadableStream {
	return try open(NSURL(fileURLWithPath: path, isDirectory: false), encoding: encoding)
}

/** Open a file for reading, throw if an error occurs. */
public func open (path: NSURL, encoding: NSStringEncoding = main.encoding) throws -> ReadableStream {
	try makeThrowable(path.checkResourceIsReachableAndReturnError)
	return ReadableStream(try NSFileHandle(forReadingFromURL: path), encoding: encoding)
}

/**
Open a file for writing, create it first if it doesn't exist.
If the file already exists and overwrite=false, the writing will begin at the end of the file.

- parameter overwrite: If true, replace the file if it exists.
*/
public func open (forWriting path: NSURL, overwrite: Bool = false, encoding: NSStringEncoding = main.encoding) throws -> WriteableStream {

	if overwrite || !Files.fileExistsAtPath(path.path!) {
		Files.createFileAtPath(path.path!, contents: nil, attributes: nil)
	}
	try makeThrowable(path.checkResourceIsReachableAndReturnError)

	let filehandle = try NSFileHandle(forWritingToURL: path)
	filehandle.seekToEndOfFile()
	return WriteableStream(filehandle, encoding: encoding)
}

/**
Open a file for writing, create it first if it doesn't exist.
If the file already exists and overwrite=false, the writing will begin at the end of the file.

- parameter overwrite: If true, replace the file if it exists.
*/
public func open (forWriting path: String, overwrite: Bool = false, encoding: NSStringEncoding = main.encoding) throws -> WriteableStream {
	return try open(forWriting:  NSURL(fileURLWithPath: path, isDirectory: false), overwrite: overwrite, encoding:  encoding)
}
