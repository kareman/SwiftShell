//
// Stream.swift
// SwiftShell
//
// Created by Kåre Morstøl on 25/07/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

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
	
	/** Must be called on local streams when done writing. */
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
Creates a stream from a function returning a  generator function, which is called everytime the stream is  asked for more text.

stream {
	// initialisation...
	return {
		// called repeatedly by the resulting stream
		// return text,	or return nil when done.
	}
}

:returns:  The output stream.
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

/** For splitting a stream into parts separated by "delimiter". */
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

/** Split a stream lazily */
public func split(delimiter: String = "\n")(stream: ReadableStreamType) -> SequenceOf<String> {
	return SequenceOf({StringStreamGenerator (stream: stream, delimiter: delimiter)})
}
