/*
* Copyright (c) 2014 Kåre Morstøl (NotTooBad Software).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*
* Contributors:
*	Kåre Morstøl, https://github.com/kareman - initial API and implementation.
*/

import Foundation

// TODO: get encoding from environmental variable LC_TYPE
public var streamencoding = NSUTF8StringEncoding

/** A stream of text. Does as much as possible lazily. */
public protocol ReadableStreamType : Streamable {
	
	/**
	Whatever amount of text the stream feels like providing.
	If the source is a file this will read everything at once.
	
	:returns: more text from the stream, or nil if we have reached the end.
	*/
	func readSome() -> String?
	
	/** Reads everything at once. */
	func read() -> String
	
	/** Lazily splits the stream into lines. */
	func lines() -> SequenceOf<String>
	
	/** Allows stream to be used by "println". */
	func writeTo<Target : OutputStreamType>(inout target: Target)
}

/** An output stream, like standard output and standard error. */
public protocol WriteableStreamType : OutputStreamType {
	
	func write(string: String)
	
	/** Must be called on local streams when finished writing. */
	func closeStream()
}

/** Creates a stream from a String. */
public func stream (text: String) -> ReadableStreamType {
	let pipe = NSPipe()
	let input = pipe.fileHandleForWriting
	input.write(text)
	input.closeStream()
	return pipe.fileHandleForReading
}

/** 
Creates a stream from a function returning a generator function, which is called every time the stream is asked for more text.

stream {
	// initialisation...
	return {
		// called repeatedly by the resulting stream
		// return text,	or return nil when done.
	}
}

:returns: The output stream.
*/
public func stream ( closure:() -> () -> String? ) -> ReadableStreamType {
	let getmoretext = closure()
	let pipe = NSPipe()
	
	let input: NSFileHandle = pipe.fileHandleForWriting
	input.writeabilityHandler = { filehandle in 
		if let text = getmoretext() {
			filehandle.write(text) 
		} else {
			// close the stream
			input.writeabilityHandler = nil
		}
	}
	
	return pipe.fileHandleForReading
}

/** Creates a stream from a sequence of Strings. */
public func stream <Seq:SequenceType where Seq.Generator.Element == String>(sequence: Seq) -> ReadableStreamType {
	return stream {
		var generator = sequence.generate()
		return { generator.next() }
	}
}

/** 
Returns a writable stream and a readable stream. What you write to the 1st one can be read from the 2nd one.
Make sure to call closeStream() on the writable stream before you call read() on the readable one.
*/
public func streams () -> (WriteableStreamType, ReadableStreamType) {
	let pipe = NSPipe()
	return (pipe.fileHandleForWriting, pipe.fileHandleForReading)
}


/** Splits a stream into parts separated by "delimiter". */
struct StringStreamGenerator : GeneratorType {
	private let stream: ReadableStreamType
	private	let delimiter: String
	private var cache = ""
	
	init (stream: ReadableStreamType, delimiter: String = "\n") {
		self.stream = stream
		self.delimiter = delimiter
	}
	
	/** Passes on the stream until the next occurrence of "delimiter" */
	mutating func next () -> String? {
		let (nextpart, returneddelimiter, remainder) = cache.partition(delimiter)
		let delimiterwasfound = returneddelimiter != ""
		cache = remainder
		
		if delimiterwasfound {
			return nextpart
		} else {
			if let newcache = stream.readSome() {
				// add the next part of the stream to what's left of the previous one, 
				// and start again from the beginning of the function.
				cache = nextpart + newcache 
				return next()
			} else {
				// the stream is empty and there are no more delimiters left.
				// return whatever is left, or nil if empty.
				return nextpart == "" ? nil : nextpart
			}
		}
	}
}

/** Splits a stream lazily */
public func split(delimiter: String = "\n")(stream: ReadableStreamType) -> SequenceOf<String> {
	return SequenceOf({StringStreamGenerator (stream: stream, delimiter: delimiter)})
}

/* crashes the compiler (6.1 beta).
Should replace other implementations of "write (stream: WriteableStreamType)(input: ReadableStreamType)" 
as it is more general and will also work with strings.
public func write (stream: WriteableStreamType)(input: Streamable) {

// specifically it's these that crash the compiler, not the function definition.
// input.writeTo(&stream)
// print(input, &stream)

}
*/

/**
Writes one stream to another.

readablestream |> write(writablestream)
*/
public func write (stream: WriteableStreamType)(input: ReadableStreamType) {
	while let some = input.readSome() {
		stream.write(some)
	}
}

/** Writes something Printable to a writable stream. */
public func write (stream: WriteableStreamType)(input: Printable) {
	stream.write(input.description)
}

/** Writes a String to a writable stream. */
public func write (stream: WriteableStreamType)(input: String) {
	stream.write(input)
}

/*  Me and Swift (6.1 GM 2) are having a disagreement over whether or not it should be possible to define multiple functions which only differ in the generic “where” clause. Me and the language reference say yes, Swift says "Basic Block in function ' something something USs12SequenceType_USs13GeneratorType__FQ_Si' does not have terminator!". So until Swift comes to its senses there can only be one "write" function which takes a sequence, and that will have to be the unholy mess seen below.
*/
/** Writes a sequence of streams or strings to another stream. */
public func write <S : SequenceType>(stream: WriteableStreamType)(seq: S) {
	for item in seq {
		if let inputstream = item as? FileHandle {
			inputstream as ReadableStreamType |> write(stream)
		} else if let text = item as? String {
			stream.write(text)
		} else {
			preconditionFailure("SwiftShell error: Currently only sequences of strings and readable streams can be written directly to a writable stream with the global 'write' function") 
		}
	}
}
