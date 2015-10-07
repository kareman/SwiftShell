/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

/** An output stream, like standard output or a writeable file. */
public final class WriteableStream : OutputStreamType {

	public let filehandle: NSFileHandle
	let encoding: NSStringEncoding

	public func write <T> (x: T) {
		filehandle.write(x, encoding: encoding)
	}

	public func writeln <T> (x: T) {
		filehandle.writeln(x, encoding: encoding)
	}

	public func writeln (s: String = "") {
		self.writeln(s)
	}

	/** Must be called on local streams when finished writing. */
	public func close () {
		filehandle.closeFile()
	}

	public init (_ filehandle: NSFileHandle, encoding: NSStringEncoding = main.encoding) {
		self.filehandle = filehandle
		self.encoding = encoding
	}
}
