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

	/** Split stream lazily into lines. */
	public func lines () -> LazyMapSequence<PartialSourceLazySplitSequence<String.CharacterView>, String> {
		return PartialSourceLazySplitSequence(bases: {self.readSome()?.characters}, separator: "\n").map { String($0) }
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

/** Callback with when ReadableStream has data.*/
extension ReadableStream {

	public func onOutput ( handler: ((ReadableStream) -> ())? ) {
		guard let handler = handler else {
			filehandle.readabilityHandler = nil
			return
		}
		filehandle.readabilityHandler = { [unowned self] _ in
			handler(self)
		}
	}

	public func onStringOutput ( handler: ((String) -> ())? ) {
		if let h = handler {
			filehandle.readabilityHandler = { (NSFileHandle) in
				if let output = self.readSome() {
					h(output)
				}
			}
		} else {
			filehandle.readabilityHandler = nil
		}
	}
}

/** An output stream, like standard output or a writeable file. */
public final class WriteableStream : OutputStreamType {

	public let filehandle: NSFileHandle
	let encoding: NSStringEncoding

	/** Write the textual representation of `x` to the stream. */
	public func write <T> (x: T) {
		if filehandle.fileDescriptor == STDOUT_FILENO {
			print(x, terminator: "")
		} else {
			filehandle.write(x, encoding: encoding)
		}
	}

	/** Write the textual representation of `x` to the stream, and add a newline. */
	public func writeln <T> (x: T) {
		if filehandle.fileDescriptor == STDOUT_FILENO {
			print(x)
		} else {
			filehandle.writeln(x, encoding: encoding)
		}
	}

	/** Write a newline to the stream. */
	public func writeln () {
		writeln("")
	}

	/** Close the stream. Must be called on local streams when finished writing. */
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
