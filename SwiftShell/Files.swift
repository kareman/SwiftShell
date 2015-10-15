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
public func / (leftpath: NSURL, rightpath: String) -> NSURL {
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
