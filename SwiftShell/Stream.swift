//
// Stream.swift
// SwiftShell
//
// Created by Kåre Morstøl on 25/07/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import Foundation

public var streamencoding = NSUTF8StringEncoding

public protocol ReadableStreamType {
	
	func readSome() -> String?
	func read() -> String
	func lines() -> SequenceOf <String >
}

public protocol WriteableStreamType : OutputStreamType {
	
	func write(string: String)
	func closeStream()
}


public func stream (text: String) -> NSFileHandle {
	let pipe = NSPipe()
	
	let input: NSFileHandle = pipe.fileHandleForWriting
	input.writeabilityHandler = { filehandle in 
		filehandle.write(text) 
		//filehandle.closeStream() // why doesn't this work? (beta 6) 
		// input.closeFile() 
		
		// this will surely create a reference cycle, but it doesn't work when input is declared unowned (beta 6)
		input.writeabilityHandler = nil
	} 
	
	return pipe.fileHandleForReading
}

public func stream ( closureclosure:() -> () -> String? ) -> NSFileHandle {
	let closure = closureclosure()
	let pipe = NSPipe()
	
	let input: NSFileHandle = pipe.fileHandleForWriting
	input.writeabilityHandler = { filehandle in 
		if let text = closure() {
			filehandle.write(text) 
		} else {
			// why don't these work? (beta 6) 
			// filehandle.closeStream() 
			// input.closeFile() 
			
			// this will surely create a reference cycle, but it crashes when input is declared unowned (beta 6)
			input.writeabilityHandler = nil
		}
	}
	
	return pipe.fileHandleForReading
}


// TODO: replace with stream ( () -> () -> String? )
public func stream (array: [String]) -> ReadableStreamType {
	class ArrayStream: ReadableStreamType {
		var generator: IndexingGenerator<[ String]>
		
		init(array: Array <String >) {
			generator = array.generate() 
		}
		
		func readSome() -> String? {
			return generator.next()
		}
		
		func read() -> String {
			assert(false, "not implemented")
			return "" 
		}
		
		func lines() -> SequenceOf <String >{
			return split(delimiter: "\n")(stream: self)
		}
	}
	
	return ArrayStream (array: array)
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
				cache = nextline + newcache // TODO: crashes on long streams
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
