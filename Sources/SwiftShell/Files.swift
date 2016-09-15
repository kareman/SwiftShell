/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

/** The default FileManager */
public let Files = FileManager.default

/** Append file or directory url to directory url */
public func + (leftpath: URL, rightpath: String) -> URL {
	return leftpath.appendingPathComponent(rightpath)
}


/** Error type for file commands. */
public enum FileError: Error {

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
public func open (_ path: String, encoding: String.Encoding = main.encoding) throws -> ReadableStream {
	return try open(URL(fileURLWithPath: path, isDirectory: false), encoding: encoding)
}

/** Open a file for reading, throw if an error occurs. */
public func open (_ path: URL, encoding: String.Encoding = main.encoding) throws -> ReadableStream {
	do {
		return ReadableStream(try FileHandle(forReadingFrom: path), encoding: encoding)
	} catch {
		try FileError.checkFile(path.path)
		throw error
	}
}

/**
Open a file for writing, create it first if it doesn't exist.
If the file already exists and overwrite=false, the writing will begin at the end of the file.

- parameter overwrite: If true, replace the file if it exists.
*/
public func open (forWriting path: URL, overwrite: Bool = false, encoding: String.Encoding = main.encoding) throws -> WriteableStream {

	if overwrite || !Files.fileExists(atPath: path.path) {
		_ = Files.createFile(atPath: path.path, contents: nil, attributes: nil)
	}

	do {
		let filehandle = try FileHandle(forWritingTo: path)
		_ = filehandle.seekToEndOfFile()
		return WriteableStream(filehandle, encoding: encoding)
	} catch {
		try FileError.checkFile(path.path)
		throw error
	}
}

/**
Open a file for writing, create it first if it doesn't exist.
If the file already exists and overwrite=false, the writing will begin at the end of the file.

- parameter overwrite: If true, replace the file if it exists.
*/
public func open (forWriting path: String, overwrite: Bool = false, encoding: String.Encoding = main.encoding) throws -> WriteableStream {
	return try open(forWriting: URL(fileURLWithPath: path, isDirectory: false), overwrite: overwrite, encoding:  encoding)
}
