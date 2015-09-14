/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2014 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
* Contributors:
*	Kåre Morstøl, https://github.com/kareman - initial API and implementation.
*/

import Foundation

// TODO: get encoding from environmental variable LC_CTYPE
public var streamencoding = NSUTF8StringEncoding

/** A stream of text. Does as much as possible lazily. */
public protocol ReadableStreamType : Streamable {
	
	/**
	Whatever amount of text the stream feels like providing.
	If the source is a file this will read everything at once.
	
	- returns: more text from the stream, or nil if we have reached the end.
	*/
	func readSome () -> String?
	
	/** Read everything at once. */
	func read () -> String
	
	/** Lazily split the stream into lines. */
	func lines () -> AnySequence<String>
	
	/** Enable stream to be used by "println" and "toString". */
	func writeTo <Target : OutputStreamType> (inout target: Target)
}

/** An output stream, like standard output and standard error. */
public protocol WriteableStreamType : OutputStreamType {
	
	func write (string: String)
	
	func writeln (string: String)

	func writeln ()

	/** Must be called on local streams when finished writing. */
	func closeStream ()
}

/** Create a stream from a String. */
public func stream (text: String) -> ReadableStreamType {
	let pipe = NSPipe()
	let input = pipe.fileHandleForWriting
	input.write(text)
	input.closeStream()
	return pipe.fileHandleForReading
}

/** 
Create a stream from a function returning a generator function, which is called every time the stream is asked for more text.

stream {
	// initialisation...
	return {
		// called repeatedly by the resulting stream
		// return text,	or return nil when done.
	}
}

- returns: The output stream.
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

/** Create a stream from a sequence of Strings. */
public func stream <Seq : SequenceType where Seq.Generator.Element == String> (sequence: Seq) -> ReadableStreamType {
	return stream {
		var generator = sequence.generate()
		return { generator.next() }
	}
}

/** 
Return a writable stream and a readable stream. What you write to the 1st one can be read from the 2nd one.
Make sure to call closeStream() on the writable stream before you call read() on the readable one.
*/
public func streams () -> (WriteableStreamType, ReadableStreamType) {
	let pipe = NSPipe()
	return (pipe.fileHandleForWriting, pipe.fileHandleForReading)
}


/** Split a stream into parts separated by "delimiter". */
struct StringStreamGenerator : GeneratorType {
	private let stream: ReadableStreamType
	private	let delimiter: String
	private var cache = ""
	
	init (stream: ReadableStreamType, delimiter: String = "\n") {
		self.stream = stream
		self.delimiter = delimiter
	}
	
	/** Pass on the stream until the next occurrence of "delimiter" */
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

/** Split a stream lazily */
public func split (delimiter: String = "\n")(stream: ReadableStreamType) -> AnySequence<String> {
	return AnySequence({StringStreamGenerator (stream: stream, delimiter: delimiter)})
}


/**
Write something to a stream.

	something |> writeTo(writablestream)
*/
public func writeTo <T> (stream: WriteableStreamType)(input: T) {
	stream.write( String(input) )
}

// needed to avoid `writeTo(SequenceType)` being called instead,
// treating the string as a sequence of characters.
/** Write a String to a writable stream. */
public func writeTo (stream: WriteableStreamType)(input: String) {
	stream.write(input)
}

/** Write a sequence to a stream. */
public func writeTo <S : SequenceType> (stream: WriteableStreamType)(seq: S) {
	for item in seq {
		item |> writeTo(stream)
	}
}

infix operator |>> { precedence 50 associativity left }

/**
Write something to a stream.

something |>> writablestream
*/
public func |>> <T> (input: T, stream: WriteableStreamType) {
	writeTo(stream)(input: input)
}

// needed to avoid `func |>> <S : SequenceType>` being called instead,
// treating the string as a sequence of characters.
/** Write a String to a writable stream. */
public func |>> (text: String, stream: WriteableStreamType) {
	writeTo(stream)(input: text)
}

/** Write a sequence to a stream. */
public func |>> <S : SequenceType> (seq: S, stream: WriteableStreamType) {
	writeTo(stream)(seq: seq)
}
