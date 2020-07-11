/*
 * Released under the MIT License (MIT), http://opensource.org/licenses/MIT
 *
 * Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
 *
 */

import Foundation

/** The default FileManager */
public let Files = FileManager.default

/** Appends file or directory url to directory url */
public func + (leftpath: URL, rightpath: String) -> URL {
	leftpath.appendingPathComponent(rightpath)
}

/** Error type for file commands. */
public enum FileError: Error {
	case notFound(path: String)

	public static func checkFile(_ path: String) throws {
		if !Files.fileExists(atPath: path) {
			throw notFound(path: path)
		}
	}
}

extension FileError: CustomStringConvertible {
	public var description: String {
		switch self {
		case let .notFound(path):
			return "Error: '\(path)' does not exist."
		}
	}
}

/** Opens a file for reading, throws if an error occurs. */
public func open(_ path: String, encoding: String.Encoding = main.encoding) throws -> ReadableStream {
	// URL does not handle leading "~/"
	let fixedpath = path.hasPrefix("~") ? NSString(string: path).expandingTildeInPath : path
	return try open(URL(fileURLWithPath: fixedpath, isDirectory: false), encoding: encoding)
}

/** Opens a file for reading, throws if an error occurs. */
public func open(_ path: URL, encoding: String.Encoding = main.encoding) throws -> ReadableStream {
	do {
		return FileHandleStream(try FileHandle(forReadingFrom: path), encoding: encoding)
	} catch {
		try FileError.checkFile(path.path)
		throw error
	}
}

/**
 Opens a file for writing, creates it first if it doesn't exist.
 If the file already exists and overwrite=false, the writing will begin at the end of the file.

 - parameter overwrite: If true, replace the file if it exists.
 */
public func open(forWriting path: URL, overwrite: Bool = false, encoding: String.Encoding = main.encoding) throws -> FileHandleStream {
	if overwrite || !Files.fileExists(atPath: path.path) {
		try Files.createDirectory(at: path.deletingLastPathComponent(), withIntermediateDirectories: true, attributes: nil)
		_ = Files.createFile(atPath: path.path, contents: nil, attributes: nil)
	}

	do {
		let filehandle = try FileHandle(forWritingTo: path)
		_ = filehandle.seekToEndOfFile()
		return FileHandleStream(filehandle, encoding: encoding)
	} catch {
		try FileError.checkFile(path.path)
		throw error
	}
}

/**
 Opens a file for writing, creates it first if it doesn't exist.
 If the file already exists and overwrite=false, the writing will begin at the end of the file.

 - parameter overwrite: If true, replace the file if it exists.
 */
public func open(forWriting path: String, overwrite: Bool = false, encoding: String.Encoding = main.encoding) throws -> FileHandleStream {
	let fixedpath = path.hasPrefix("~") ? NSString(string: path).expandingTildeInPath : path
	return try open(forWriting: URL(fileURLWithPath: fixedpath, isDirectory: false), overwrite: overwrite, encoding: encoding)
}
