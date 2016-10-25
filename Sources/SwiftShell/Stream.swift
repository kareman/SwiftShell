/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

/** A stream of text. Does as much as possible lazily. */
public protocol ReadableStream : class, TextOutputStreamable, ShellRunnable {

	var filehandle: FileHandle {get}
	var encoding: String.Encoding {get}

	/**
	Whatever amount of text the stream feels like providing.
	If the source is a file this will read everything at once.

	- returns: more text from the stream, or nil if we have reached the end.
	*/
	func readSome () -> String?

	/** Read everything at once. */
	func read () -> String

	/** Split stream lazily into lines. */
	func lines () -> LazyMapSequence<PartialSourceLazySplitSequence<String.CharacterView>, String>
}

extension ReadableStream {

	public func lines () -> LazyMapSequence<PartialSourceLazySplitSequence<String.CharacterView>, String> {
		return PartialSourceLazySplitSequence({self.readSome()?.characters}, separator: "\n").map { String($0) }
	}

	// ShellRunnable
	public var shellcontext: ShellContextType {
		var context = ShellContext(main)
		context.stdin = self
		return context
	}

	// TextOutputStreamable
	public func write<Target : TextOutputStream>(to target: inout Target) {
		while let text = self.readSome() { target.write(text) }
	}
}

class FileHandleStream {
	public let filehandle: FileHandle
	public let encoding: String.Encoding

	public init (_ filehandle: FileHandle, encoding: String.Encoding = main.encoding) {
		self.filehandle = filehandle
		self.encoding = encoding
	}
}

extension FileHandleStream: ReadableStream {

	public func readSome () -> String? {
		return filehandle.readSome(encoding: encoding)
	}

	public func read () -> String {
		return filehandle.read(encoding: encoding)
	}
}

#if !os(Linux)
extension ReadableStream {

	/**
	`handler` will be called whenever there is new output available.
	Pass `nil` to remove any preexisting handlers.

	- note: if the stream is read from outside of the handler, or more than once inside
	the handler, it may be called once when stream is closed and empty.
	*/
	public func onOutput ( handler: ((ReadableStream) -> ())? ) {
		guard let handler = handler else {
			filehandle.readabilityHandler = nil
			return
		}
		filehandle.readabilityHandler = { [unowned self] _ in
			handler(self)
		}
	}


	/**
	`handler` will be called whenever there is new text output available.
	Pass `nil` to remove any preexisting handlers.
	*/
	public func onStringOutput ( handler: ((String) -> ())? ) {
		if let h = handler {
			filehandle.readabilityHandler = { (FileHandle) in
				if let output = self.readSome() {
					h(output)
				}
			}
		} else {
			filehandle.readabilityHandler = nil
		}
	}
}
#endif

/** An output stream, like standard output or a writeable file. */
public final class WriteableStream : TextOutputStream {

	public let filehandle: FileHandle
	let encoding: String.Encoding

	/** Write the textual representation of `x` to the stream. */
	public func write <T> (_ x: T) {
		if filehandle.fileDescriptor == STDOUT_FILENO {
			print(x, terminator: "")
		} else {
			filehandle.write(x, encoding: encoding)
		}
	}

	/** Write the textual representation of `x` to the stream, and add a newline. */
	public func writeln <T> (_ x: T) {
		if filehandle.fileDescriptor == STDOUT_FILENO {
			print(x)
		} else {
			filehandle.writeln(x, encoding: encoding)
		}
	}

	/** Write a newline to the stream. */
	public func writeln () {
		write("\n")
	}

	/** Close the stream. Must be called on local streams when finished writing. */
	public func close () {
		filehandle.closeFile()
	}

	public init (_ filehandle: FileHandle, encoding: String.Encoding = main.encoding) {
		self.filehandle = filehandle
		self.encoding = encoding
	}
}

/** Create a pair of streams. What is written to the 1st one can be read from the 2nd one. */
public func streams () -> (WriteableStream, ReadableStream) {
	let pipe = Pipe()
	return (WriteableStream(pipe.fileHandleForWriting), FileHandleStream(pipe.fileHandleForReading))
}
