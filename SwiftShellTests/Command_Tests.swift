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

import CatchingFire

class RunAsync_Tests: XCTestCase {

	func testReturnsStandardOutput () {
		let asynctask = main.runAsync("/bin/echo", "one", "two" )
		AssertNoThrow { try asynctask.finish() }

		XCTAssertEqual( asynctask.stdout.read(), "one two\n" )
		XCTAssertEqual( asynctask.stderror.read(), "" )
	}

	func testReturnsStandardError () {
		let asynctask = main.runAsync(bash: "echo one two > /dev/stderr" )
		AssertNoThrow { try asynctask.finish() }

		XCTAssertEqual( asynctask.stderror.read(), "one two\n" )
		XCTAssertEqual( asynctask.stdout.read(), "" )
	}

	func testThrowsErrorOnExitcodeNotZero () {
		let asynctask = main.runAsync(bash: "echo errormessage > /dev/stderr; exit 1" )

		AssertThrows(ShellError.ReturnedErrorCode(errorcode: 1)) { try asynctask.finish() }
		XCTAssertEqual( asynctask.stderror.read(), "errormessage\n" )
	}

	func testFinishReturnsSelf () {
		AssertNoThrow {
			let output = try main.runAsync(bash: "echo hi").finish().stdout.read()
			XCTAssertEqual(output, "hi\n")
		}
	}
}

class RunAndPrint_Tests: XCTestCase {

	var test_stdout: NSFileHandle!
	var test_stderr: NSFileHandle!

	override func setUp () {
		let outputpipe = NSPipe()
		main.stdout = outputpipe.fileHandleForWriting
		test_stdout = outputpipe.fileHandleForReading

		let errorpipe = NSPipe()
		main.stderror = errorpipe.fileHandleForWriting
		test_stderr = errorpipe.fileHandleForReading
	}

	func testReturnsStandardOutput () {
		AssertNoThrow { try main.runAndPrint("/bin/echo", "one", "two" ) }

		XCTAssertEqual( test_stdout.readSome(), "one two\n" )
	}

	func testReturnsStandardError () {
		AssertNoThrow { try main.runAndPrint(bash: "echo one two > /dev/stderr" ) }

		XCTAssertEqual( test_stderr.readSome(), "one two\n" )
	}

	func testThrowsErrorOnExitcodeNotZero () {
		AssertThrows(ShellError.ReturnedErrorCode(errorcode: 1))
			{ try main.runAndPrint(bash: "echo errormessage > /dev/stderr; exit 1" ) }

		XCTAssertEqual( test_stderr.readSome(), "errormessage\n" )
	}
}
