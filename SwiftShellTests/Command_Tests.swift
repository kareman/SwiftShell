//
// Command_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 15/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class Run_Tests: XCTestCase {

	func testBashCommand () {
		XCTAssertEqual( main.run(bash:"echo one"), "one" )
	}

	func testSinglelineOutput () {
		XCTAssertEqual( main.run("/bin/echo", "one", "two"), "one two" )
	}

	func testMultilineOutput () {
		XCTAssertEqual( main.run("/bin/echo", "one\ntwo"), "one\ntwo\n" )
	}
}

class RunAsync_Tests: XCTestCase {

	func testReturnsStandardOutput () {
		let asynctask = main.runAsync("/bin/echo", "one", "two" )
		try! asynctask.finish()

		XCTAssertEqual( asynctask.stdout.read(), "one two\n" )
		XCTAssertEqual( asynctask.stderror.read(), "" )
	}

	func testReturnsStandardError () {
		let asynctask = main.runAsync(bash: "echo one two > /dev/stderr" )
		try! asynctask.finish()

		XCTAssertEqual( asynctask.stderror.read(), "one two\n" )
		XCTAssertEqual( asynctask.stdout.read(), "" )
	}
}
