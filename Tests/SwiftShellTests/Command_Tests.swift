//
// Command_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 15/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest
import Foundation

public class Run_Tests: XCTestCase {

	func testCompilesWhenNotDefiningReturnType() {
		_ = SwiftShell.run("echo", "hi")
		_ = SwiftShell.run(bash: "echo hi")
		main.run("echo", "hi")
		main.run(bash: "echo hi")
	}

	func testBashCommand() {
		XCTAssertEqual( SwiftShell.run(bash:"echo one").stdout, "one" )
	}

	func testArgumentsFromArray() {
		let stringarray = ["one", "two"]
		XCTAssertEqual( SwiftShell.run("/bin/echo", stringarray).stdout, "one two" )
	}

	func testSinglelineOutput() {
		XCTAssertEqual( SwiftShell.run("/bin/echo", "one", "two").stdout, "one two" )
	}

	func testMultilineOutput() {
		XCTAssertEqual( SwiftShell.run("/bin/echo", "one\ntwo").stdout, "one\ntwo\n" )
	}

	func testExecutableWithoutPath() {
		XCTAssertEqual( SwiftShell.run("echo", "one").stdout, "one")
	}

	func testSuccess() {
		let success = SwiftShell.run(bash: "exit 0")
		XCTAssertEqual( success.exitcode, 0)
		XCTAssertEqual( success.succeeded, true)

		let failure = SwiftShell.run(bash: "exit 1")
		XCTAssertEqual( failure.exitcode, 1)
		XCTAssertEqual( failure.succeeded, false)
	}

	func testAnd() {
		main.currentdirectory = main.tempdirectory
		let bothsucceed = SwiftShell.run("touch", "created") && SwiftShell.run("echo", "thisran")
		XCTAssert(Files.fileExists(atPath: "created"))
		XCTAssertEqual(bothsucceed.stdout, "thisran")

		let firstfails = SwiftShell.run(bash: "exit 1") && SwiftShell.run("touch", "notcreated")
		XCTAssertFalse(firstfails.succeeded)
		XCTAssertFalse(Files.fileExists(atPath: "notcreated"))
	}

	func testOr() {
		main.currentdirectory = main.tempdirectory
		let firstran = SwiftShell.run("echo", "thisran") || SwiftShell.run("touch", "notcreated")
		XCTAssertEqual(firstran.stdout, "thisran")
		XCTAssertFalse(Files.fileExists(atPath: "notcreated"))

		let firstfailedsecondran = SwiftShell.run(bash: "exit 1") || SwiftShell.run("echo", "thisran")
		XCTAssertEqual(firstfailedsecondran.stdout, "thisran")
	}
}

public class RunAsync_Tests: XCTestCase {

	func testReturnsStandardOutput() {
		let asynccommand = runAsync("/bin/echo", "one", "two" )
		AssertDoesNotThrow { try asynccommand.finish() }

		XCTAssertEqual( asynccommand.stdout.read(), "one two\n" )
		XCTAssertEqual( asynccommand.stderror.read(), "" )
	}

	func testReturnsStandardError() {
		let asynccommand = runAsync(bash: "echo one two > /dev/stderr" )
		AssertDoesNotThrow { try asynccommand.finish() }

		XCTAssertEqual( asynccommand.stderror.read(), "one two\n" )
		XCTAssertEqual( asynccommand.stdout.read(), "" )
	}

	func testArgumentsFromArray() {
		AssertDoesNotThrow {
			let output = try runAsync("/bin/echo", ["one", "two"]).finish().stdout.read()
			XCTAssertEqual( output, "one two\n" )
		}
	}

	func testFinishThrowsErrorOnExitcodeNotZero() {
		let asynccommand = runAsync(bash: "echo errormessage > /dev/stderr; exit 1" )

		AssertThrows(CommandError.returnedErrorCode(command: "/bin/bash -c \"echo errormessage > /dev/stderr; exit 1\"", errorcode: 1))
			{ try asynccommand.finish() }
		XCTAssertEqual( asynccommand.stderror.read(), "errormessage\n" )
	}

	func testExitCode() {
		let asynccommand = runAsync(bash: "exit 1" )

		XCTAssertEqual( asynccommand.exitcode(), 1 )
	}

	func testOnCompletion() {
		let expectcompletion = expectation(description: "onCompletion will be called when command has finished.")

		runAsync("echo").onCompletion { command in
			XCTAssertFalse(command.isRunning)
			expectcompletion.fulfill()
		}
		waitForExpectations(timeout: 0.5, handler: nil)
	}
}

public class RunAndPrint_Tests: XCTestCase {

	var test_stdout: FileHandle!
	var test_stderr: FileHandle!

	public override func setUp() {
		let outputpipe = Pipe()
		main.stdout = FileHandleStream(outputpipe.fileHandleForWriting, encoding: .utf8)
		test_stdout = outputpipe.fileHandleForReading

		let errorpipe = Pipe()
		main.stderror = FileHandleStream(errorpipe.fileHandleForWriting, encoding: .utf8)
		test_stderr = errorpipe.fileHandleForReading
	}

	func testReturnsStandardOutput() {
		AssertDoesNotThrow { try runAndPrint("/bin/echo", "one", "two" ) }

		XCTAssertEqual( test_stdout.readSome(encoding: .utf8), "one two\n" )
	}

	func testArgumentsFromArray() {
		AssertDoesNotThrow { try runAndPrint("/bin/echo", ["one", "two"] ) }

		XCTAssertEqual( test_stdout.readSome(encoding: .utf8), "one two\n" )
	}

	func testReturnsStandardError() {
		AssertDoesNotThrow { try runAndPrint(bash: "echo one two > /dev/stderr" ) }

		XCTAssertEqual( test_stderr.readSome(encoding: .utf8), "one two\n" )
	}

	func testThrowsErrorOnExitcodeNotZero() {
		AssertThrows(CommandError.returnedErrorCode(command: "/bin/bash -c \"exit 1\"", errorcode: 1))
			{ try runAndPrint("bash", "-c", "exit 1") }
	}

	func testThrowsErrorOnInaccessibleExecutable() {
		AssertThrows(CommandError.inAccessibleExecutable(path: "notachance"))
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
