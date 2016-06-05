/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

/** The default NSFileManager */
public let Files = NSFileManager.default()

/** Append file or directory url to directory url */
public func + (leftpath: NSURL, rightpath: String) -> NSURL {
	return leftpath.appendingPathComponent(rightpath)
}


/** Error type for file commands. */
public enum FileError: ErrorProtocol {

	case notFound (path: String)

	public static func checkFile (_ path: String) throws {
		if !Files.fileExists(atPath: path) {
			throw notFound(path: path)
		}
	}
}

extension FileError: CustomStringConvertible {
	public var description: String {
		switch self {
		case .notFound(let path):
			return "Error: '\(path)' does not exist."
		}
	}
}

/** Open a file for reading, throw if an error occurs. */
public func open (_ path: String, encoding: NSStringEncoding = main.encoding) throws -> ReadableStream {
	return try open(NSURL(fileURLWithPath: path, isDirectory: false), encoding: encoding)
}

/** Open a file for reading, throw if an error occurs. */
public func open (_ path: NSURL, encoding: NSStringEncoding = main.encoding) throws -> ReadableStream {
	do {
		return ReadableStream(try NSFileHandle(forReadingFrom: path), encoding: encoding)
	} catch {
		try FileError.checkFile(path.path!)
		throw error
	}
}

/**
Open a file for writing, create it first if it doesn't exist.
If the file already exists and overwrite=false, the writing will begin at the end of the file.

- parameter overwrite: If true, replace the file if it exists.
*/
public func open (forWriting path: NSURL, overwrite: Bool = false, encoding: NSStringEncoding = main.encoding) throws -> WriteableStream {

	if overwrite || !Files.fileExists(atPath: path.path!) {
		Files.createFile(atPath: path.path!, contents: nil, attributes: nil)
	}

	do {
		let filehandle = try NSFileHandle(forWritingTo: path)
		filehandle.seekToEndOfFile()
		return WriteableStream(filehandle, encoding: encoding)
	} catch {
		try FileError.checkFile(path.path!)
		throw error
	}
}

/**
Open a file for writing, create it first if it doesn't exist.
If the file already exists and overwrite=false, the writing will begin at the end of the file.

- parameter overwrite: If true, replace the file if it exists.
*/
public func open (forWriting path: String, overwrite: Bool = false, encoding: NSStringEncoding = main.encoding) throws -> WriteableStream {
	return try open(forWriting: NSURL(fileURLWithPath: path, isDirectory: false), overwrite: overwrite, encoding:  encoding)
}
