/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

/** A stream of text. Does as much as possible lazily. */
public final class ReadableStream : Streamable {

	public let filehandle: NSFileHandle
	public let encoding: NSStringEncoding

	/**
	Whatever amount of text the stream feels like providing.
	If the source is a file this will read everything at once.

	- returns: more text from the stream, or nil if we have reached the end.
	*/
	public func readSome () -> String? {
		return filehandle.readSome(encoding: encoding)
	}

	/** Read everything at once. */
	public func read () -> String {
		return filehandle.read(encoding: encoding)
	}

	/** Enable stream to be used by "print". */
	public func writeTo <Target : OutputStreamType> (inout target: Target) {
		while let text = self.readSome() { target.write(text) }
	}

	public init (_ filehandle: NSFileHandle, encoding: NSStringEncoding = main.encoding) {
		self.filehandle = filehandle
		self.encoding = encoding
	}
}

/** Let ReadableStream run commands using itself as stdin. */
extension ReadableStream: ShellRunnable {
	public var shellcontext: ShellContextType {
		var context = ShellContext(main)
		context.stdin = self
		return context
	}
}

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

	public func writeln () {
		filehandle.writeln("")
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

/** Create a pair of streams. What is written to the 1st one can be read from the 2nd one. */
public func streams () -> (WriteableStream, ReadableStream) {
	let pipe = NSPipe()
	return (WriteableStream(pipe.fileHandleForWriting), ReadableStream(pipe.fileHandleForReading))
}
