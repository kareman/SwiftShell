//
// Stream_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 21/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class Stream_Tests: XCTestCase {
	
	func testStreamFromAString () {
		XCTAssertEqual( "this is a string", stream("this is a string").read() )
		XCTAssertEqual( "These are weird↔️🐻♨︎", stream("These are weird↔️🐻♨︎").read() )
	}
	
	func testCustomStream () {
		let result = stream ({
			var finished = false
			return {
				if !finished {
					finished = true
					return "this is it"
				} else {
					return nil
				}
			}
		})
		XCTAssertEqual( result.read(), "this is it" )
	}
	
	func testStreamFromArray () {
		XCTAssertEqual( stream(["item 1","item 2"]).read(), "item 1item 2")
	}
	
	func streams () -> (WriteableStreamType, ReadableStreamType) {
		let pipe = NSPipe()
		return (pipe.fileHandleForWriting, pipe.fileHandleForReading)
	}
	
	func testPrintStreamToStream () {
		var (writable, readable) = streams()
		
		stream("this goes in") |> writable
		
		XCTAssertEqual(readable.readSome()!, "this goes in")
	}

	func testPrintStringToStream () {
		var (writable, readable) = streams()
		
		"this goes in" |> writable
		
		XCTAssertEqual(readable.readSome()!, "this goes in")
	}

	func testCommandChainToStream () {
		var (writable, readable) = streams()
		
		SwiftShell.run("echo this is streamed") |> SwiftShell.run("wc -w") |> writable
		
		XCTAssertEqual(readable.readSome()!.trim(), "3")
	}

	
}
