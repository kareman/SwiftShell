//
// Command_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 15/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class Command_Tests: XCTestCase {

	func testSimpleCommand () {
		SwiftShell.run("echo")
	}
	
	func testSimpleCommandWithOutput () {
		XCTAssertEqual( SwiftShell.run("echo this is streamed").read(), "this is streamed\n" )
	}

	func testChainedCommands () {
		let result = SwiftShell.run("echo this is streamed") |> SwiftShell.run("wc -w")
		XCTAssertEqual( result.read().trim(), "3", "the number of words should be 3" )
	}
	
	func testInlineCommand () {
		XCTAssertEqual( $("echo one"), "one" )
	}
	
	func testInlineCommandInsideRunCommandAfterPipe () {
		let result = stream("line 1\nline 2\nline 3") |> SwiftShell.run("grep " + $("echo 2"))
		XCTAssertEqual( result.read(), "line 2\n" )
	}
	
	func testParametersFromSequenceOfStrings () {
		XCTAssertEqual( parameters(["one", "two", "three"]), " \"one\" \"two\" \"three\"" )
	}
	
	func testParametersFromSequenceOfStreams () {
		let result = AnySequence( [stream("one"), stream("two"), stream("three")].generate() ) |> parameters
		
		XCTAssertEqual( result, " \"one\" \"two\" \"three\"" )
	}
	
	func testParametersFromSequenceOfNumbers () {
		XCTAssertEqual( parameters([1, 2, 3]), " \"1\" \"2\" \"3\"" )
	}
}
