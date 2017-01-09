//
// Command_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 15/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

@testable
import SwiftShell
import XCTest
import Foundation

public class Run_Tests: XCTestCase {

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

public class RunAsync_Tests: XCTestCase {

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

	func testFinishThrowsErrorOnExitcodeNotZero () {
		let asynctask = runAsync(bash: "echo errormessage > /dev/stderr; exit 1" )

		AssertThrows(ShellError.ReturnedErrorCode(command: "/bin/bash -c \"echo errormessage > /dev/stderr; exit 1\"", errorcode: 1))
			{ try asynctask.finish() }
		XCTAssertEqual( asynctask.stderror.read(), "errormessage\n" )
	}

	func testExitCode () {
		let asynctask = runAsync(bash: "exit 1" )

		XCTAssertEqual( asynctask.exitcode(), 1 )
	}

	func testOnCompletion () {
		let expectcompletion = expectation(description: "onCompletion will be called when command has finished.")

		runAsync("echo")
			.onCompletion { _ in expectcompletion.fulfill()	}
		waitForExpectations(timeout: 0.5, handler: nil)
	}
}

public class RunAndPrint_Tests: XCTestCase {

	var test_stdout: FileHandle!
	var test_stderr: FileHandle!

	public override func setUp () {
		let outputpipe = Pipe()
		main.stdout = FileHandleStream(outputpipe.fileHandleForWriting)
		test_stdout = outputpipe.fileHandleForReading

		let errorpipe = Pipe()
		main.stderror = FileHandleStream(errorpipe.fileHandleForWriting)
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
		AssertThrows(ShellError.ReturnedErrorCode(command: "/bin/bash -c \"exit 1\"", errorcode: 1))
			{ try runAndPrint("bash", "-c", "exit 1") }
	}

	func testThrowsErrorOnInaccessibleExecutable () {
		AssertThrows(ShellError.InAccessibleExecutable(path: "notachance"))
			{ try runAndPrint("notachance") }
	}
}

extension Run_Tests {
	public static var allTests = [
		("testBashCommand", testBashCommand),
		("testArgumentsFromArray", testArgumentsFromArray),
		("testSinglelineOutput", testSinglelineOutput),
		("testMultilineOutput", testMultilineOutput),
		("testExecutableWithoutPath", testExecutableWithoutPath),
		]
}

extension RunAsync_Tests {
	public static var allTests = [
		("testReturnsStandardOutput", testReturnsStandardOutput),
		("testReturnsStandardError", testReturnsStandardError),
		("testArgumentsFromArray", testArgumentsFromArray),
		("testFinishThrowsErrorOnExitcodeNotZero", testFinishThrowsErrorOnExitcodeNotZero),
		("testExitCode", testExitCode),
		("testOnCompletion", testOnCompletion),
		]
}

extension RunAndPrint_Tests {
	public static var allTests = [
		("testReturnsStandardOutput", testReturnsStandardOutput),
		("testArgumentsFromArray", testArgumentsFromArray),
		("testReturnsStandardError", testReturnsStandardError),
		("testThrowsErrorOnExitcodeNotZero", testThrowsErrorOnExitcodeNotZero),
		("testThrowsErrorOnInaccessibleExecutable", testThrowsErrorOnInaccessibleExecutable),
		]
}
