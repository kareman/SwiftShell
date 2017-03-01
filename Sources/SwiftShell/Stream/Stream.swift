//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
//

import Foundation

extension FileHandle {

	/// Read what is available, as a String.
	/// - Parameter encoding: the encoding to use.
	/// - Returns: The contents as a String, or nil the end has been reached.
	public func readSome(encoding: String.Encoding) -> String? {
		let data = self.availableData

		guard data.count > 0 else { return nil }
		guard let result = String(data: data, encoding: encoding) else {
			fatalError("Could not convert binary data to text.")
		}

		return result
	}

	/// Read to the end, as a String.
	/// - Parameter encoding: the encoding to use.
	public func read(encoding: String.Encoding) -> String {
		let data = self.readDataToEndOfFile()

		guard let result = String(data: data, encoding: encoding) else {
			fatalError("Could not convert binary data to text.")
		}

		return result
	}
}

extension FileHandle {

	public func write(_ string: String, encoding: String.Encoding = .utf8) {
		#if !(os(macOS) || os(iOS) || os(tvOS) || os(watchOS))
			guard !string.isEmpty else {return}
		#endif
		guard let data = string.data(using: encoding, allowLossyConversion: false) else {
			fatalError("Could not convert text to binary data.")
		}
		self.write(data)
	}
}

#if os(iOS) || os(tvOS) || os(watchOS)
/// ShellRunnable is not available on iOS, tvOS and watchOS.
public protocol ShellRunnable {}
#endif

/// A stream of text. Does as much as possible lazily.
public protocol ReadableStream: class, TextOutputStreamable, ShellRunnable {

	var encoding: String.Encoding {get set}
	var filehandle: FileHandle {get}

	/// Whatever amount of text the stream feels like providing.
	/// If the source is a file this will read everything at once.
	/// - returns: more text from the stream, or nil if we have reached the end.
	func readSome() -> String?

	/// Reads everything at once.
	func read() -> String
}

extension ReadableStream {

	public func readSome () -> String? {
		return filehandle.readSome(encoding: encoding)
	}

	public func read () -> String {
		return filehandle.read(encoding: encoding)
	}

	/// Splits stream lazily into lines.
	public func lines() -> LazySequence<AnySequence<String>> {
		return AnySequence(PartialSourceLazySplitSequence({self.readSome()?.characters}, separator: "\n").map { String($0) }).lazy
	}

	/// Writes the text in this file to the given TextOutputStream.
	public func write<Target: TextOutputStream>(to target: inout Target) {
		while let text = self.readSome() { target.write(text) }
	}

	#if !(os(iOS) || os(tvOS) || os(watchOS))
	public var shellcontext: ShellContextType {
		var context = ShellContext(main)
		context.stdin = self
		return context
	}
	#endif
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
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


/// An output stream, like standard output or a writeable file.
public protocol WritableStream: class, TextOutputStream {

	var encoding: String.Encoding {get set}
	var filehandle: FileHandle {get}

	/// Writes `x` to the stream.
	func write(_ x: String)

	/// Closes the stream. Must be called on non-file streams when finished writing,
	/// to prevent deadlock when reading.
	func close()
}

extension WritableStream {

	public func write (_ x: String) {
		if filehandle.fileDescriptor == STDOUT_FILENO {
			Swift.print(x, terminator: "")
		} else {
			filehandle.write(x, encoding: encoding)
		}
	}

	public func close () {
		filehandle.closeFile()
	}

	/// Writes the textual representations of the given items into the stream.
	/// Works exactly the same way as the built-in `print`.
	///
	/// To avoid printing a newline at the end, pass `terminator: ""` or use `write` ìnstead.
	///
	/// - Parameters:
	///   - items: Zero or more items to print, converting them to text with String(describing:).
	///   - separator: What to print between each item. Default is " ".
	///   - terminator: What to print at the end. Default is newline.
	@warn_unqualified_access
	public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
		var iterator = items.lazy.map(String.init(describing:)).makeIterator()
		iterator.next().map(write)
		while let item = iterator.next() {
			write(separator)
			write(item)
		}
		write(terminator)
	}
}


/// Singleton WritableStream used only for `print`ing to stdout.
public class StdoutStream: WritableStream {
	public var encoding: String.Encoding = .utf8
	public let filehandle = FileHandle.standardOutput

	private init() {}

	public static var `default`: StdoutStream { return StdoutStream() }

	public func write(_ x: String) {
		Swift.print(x, terminator: "")
	}

	public func close() {}
}

public class FileHandleStream: ReadableStream, WritableStream {
	public let filehandle: FileHandle
	public var encoding: String.Encoding

	public init (_ filehandle: FileHandle, encoding: String.Encoding) {
		self.filehandle = filehandle
		self.encoding = encoding
	}
}

/// Creates a pair of streams. What is written to the 1st one can be read from the 2nd one.
public func streams () -> (WritableStream, ReadableStream) {
	let pipe = Pipe()
	return (FileHandleStream(pipe.fileHandleForWriting, encoding: .utf8), FileHandleStream(pipe.fileHandleForReading, encoding: .utf8))
}
