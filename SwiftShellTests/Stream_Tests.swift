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
	
	func testPrintStreamToStream () {
		var (writable, readable) = streams()
		
		stream("this goes in") |> write(writable)
		
		XCTAssertEqual( readable.readSome()!, "this goes in")
	}

	func testPrintStreamToStreamInPieces () {
		var (writable, readable) = streams()
		
		stream(["this ", "goes", " in"]) |> write(writable)
		
		writable.closeStream()
		XCTAssertEqual( readable.read(), "this goes in")
	}
	
	func testPrintStringToStream () {
		var (writable, readable) = streams()
		
		"this goes in" |> write(writable)
		
		XCTAssertEqual( readable.readSome()!, "this goes in")
	}

	func testCommandChainToStream () {
		var (writable, readable) = streams()
		
		SwiftShell.run("echo this is streamed") |> SwiftShell.run("wc -w") |> write(writable)
		
		XCTAssertEqual( readable.readSome()!.trim(), "3")
	}

	func testSequenceOfStreamsToStream () {
		var (writable, readable) = streams()
		
		// make sure the array isn't printed as a Printable.
		SequenceOf([stream("line 1"), stream("line 2"), stream("line 3")].generate()) |> write(writable)
		
		XCTAssertEqual( readable.readSome()!.trim(), "line 1line 2line 3")
	}

	func testChainWithSequenceOfStreamsPrintedToStream () {
		var (writable, readable) = streams()
		let dict = ["test":"line 1:line 2:line 3"]
		
		dict["test"]! |> split(":") 
			|> map { line in SwiftShell.run("echo \(line)") } 
			|> write(writable)

		XCTAssertEqual( readable.readSome()!.trim(), "line 1\nline 2\nline 3")
	}
	
	func testChainWithSequenceOfStringsPrintedToStream () {
		var (writable, readable) = streams()
		var i = 1
		
		stream("line 1\nline 2\nline 3").lines() |> map {line in "line \(i++): \(line)\n"} |> write(writable)
		
		XCTAssertEqual( readable.readSome()!.trim(), "line 1: line 1\nline 2: line 2\nline 3: line 3")
	}
	
}
