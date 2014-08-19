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
