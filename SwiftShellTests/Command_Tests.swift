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
		XCTAssertEqual( SwiftShell.run(bash:"echo one"), "one" )
	}

	func testArgumentsFromArray () {
		let stringarray = ["one", "two"]
		XCTAssertEqual( SwiftShell.run("/bin/echo", stringarray), "one two" )
	}

	func testSinglelineOutput () {
		XCTAssertEqual( SwiftShell.run("/bin/echo", "one", "two"), "one two" )
	}

	func testMultilineOutput () {
		XCTAssertEqual( SwiftShell.run("/bin/echo", "one\ntwo"), "one\ntwo\n" )
	}

	func testExecutableWithoutPath () {
		XCTAssertEqual( SwiftShell.run("echo", "one"), "one")
	}
}

class RunAsync_Tests: XCTestCase {

	func testReturnsStandardOutput () {
		let asynctask = runAsync("/bin/echo", "one", "two" )
		AssertNoThrow { try asynctask.finish() }

		XCTAssertEqual( asynctask.stdout.read(), "one two\n" )
		XCTAssertEqual( asynctask.stderror.read(), "" )
	}

	func testReturnsStandardError () {
		let asynctask = runAsync(bash: "echo one two > /dev/stderr" )
		AssertNoThrow { try asynctask.finish() }

		XCTAssertEqual( asynctask.stderror.read(), "one two\n" )
		XCTAssertEqual( asynctask.stdout.read(), "" )
	}

	func testArgumentsFromArray () {
		AssertNoThrow {
			let output = try runAsync("/bin/echo", ["one", "two"]).finish().stdout.read()
			XCTAssertEqual( output, "one two\n" )
		}
	}

	func testThrowsErrorOnExitcodeNotZero () {
		let asynctask = runAsync(bash: "echo errormessage > /dev/stderr; exit 1" )

		AssertThrows(ShellError.ReturnedErrorCode(command: "/bin/bash -c \"echo errormessage > /dev/stderr; exit 1\"", errorcode: 1))
			{ try asynctask.finish() }
		XCTAssertEqual( asynctask.stderror.read(), "errormessage\n" )
	}
}

class RunAndPrint_Tests: XCTestCase {

	var test_stdout: NSFileHandle!
	var test_stderr: NSFileHandle!

	override func setUp () {
		let outputpipe = NSPipe()
		main.stdout = WriteableStream(outputpipe.fileHandleForWriting)
		test_stdout = outputpipe.fileHandleForReading

		let errorpipe = NSPipe()
		main.stderror = errorpipe.fileHandleForWriting
		test_stderr = errorpipe.fileHandleForReading
	}

	func testReturnsStandardOutput () {
		AssertNoThrow { try runAndPrint("/bin/echo", "one", "two" ) }

		XCTAssertEqual( test_stdout.readSome(), "one two\n" )
	}

	func testArgumentsFromArray () {
		AssertNoThrow { try runAndPrint("/bin/echo", ["one", "two"] ) }

		XCTAssertEqual( test_stdout.readSome(), "one two\n" )
	}

	func testReturnsStandardError () {
		AssertNoThrow { try runAndPrint(bash: "echo one two > /dev/stderr" ) }

		XCTAssertEqual( test_stderr.readSome(), "one two\n" )
	}

	func testThrowsErrorOnExitcodeNotZero () {
		AssertThrows(ShellError.ReturnedErrorCode(command: "/bin/test \"1 1\" = \"2 2\"", errorcode: 1))
			{ try runAndPrint("test", "1 1", "=", "2 2") }
	}

	func testThrowsErrorOnInaccessibleExecutable () {
		AssertThrows(ShellError.InAccessibleExecutable(path: "notachance"))
			{ try runAndPrint("notachance") }
	}
}
