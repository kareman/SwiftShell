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
	
	/// Reads everything at once.
	func read() -> String
	
	/// Lazily splits the stream into lines
	func lines() -> SequenceOf<String>
	
	/// Allows stream to be used by "println"
	func writeTo<Target : OutputStreamType>(inout target: Target)
}

/** An output stream, like standard output and standard error. */
public protocol WriteableStreamType : OutputStreamType {
	
	func write(string: String)
	
	/// Must be called on local streams when done writing.
	func closeStream()
}

/** Creates a stream from a String. */
public func stream(text: String) -> ReadableStreamType {
	let pipe = NSPipe()
	let input = pipe.fileHandleForWriting
	input.write(text)
	input.closeStream()
	return pipe.fileHandleForReading
}

public func stream ( closureclosure:() -> () -> String? ) -> ReadableStreamType {
	let closure = closureclosure()
	let pipe = NSPipe()
	
	let input: NSFileHandle = pipe.fileHandleForWriting
	input.writeabilityHandler = { filehandle in 
		if let text = closure() {
			filehandle.write(text) 
		} else {
			// why won't this work? (beta 6) 
			// filehandle.writeabilityHandler = nil
			
			input.writeabilityHandler = nil
		}
	}
	
	return pipe.fileHandleForReading
}

public func stream <Seq:SequenceType where Seq.Generator.Element == String>(sequence: Seq) -> ReadableStreamType {
	return stream {
		var generator = sequence.generate()
		return { generator.next() }
	}
}


struct StringStreamGenerator : GeneratorType {
	private let stream: ReadableStreamType
	private	let delimiter: String
	private var cache = ""
	
	init (stream: ReadableStreamType, delimiter: String = "\n") {
		self.stream = stream
		self.delimiter = delimiter
	}
	
	mutating func next () -> String? {
		let (nextline, returnedseparator, remainder) = cache.partition(delimiter)
		let separatorwasfound = returnedseparator != ""
		cache = remainder
		
		if separatorwasfound {
			return nextline
		} else {
			if let newcache = stream.readSome() {
				cache = nextline + newcache 
				return next()
			} else {
				return nextline == "" ? nil : nextline
			}
		}
	}
	
}

public func split(delimiter: String = "\n")(stream: ReadableStreamType) -> SequenceOf<String> {
	return SequenceOf({StringStreamGenerator (stream: stream, delimiter: delimiter)})
}
