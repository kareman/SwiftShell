//
// Command_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 15/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import Foundation
import SwiftShell
import XCTest

#if os(Linux)
import Glibc
#endif

public class Run_Tests: XCTestCase {
	func testCompilesWhenNotDefiningReturnType() {
		_ = SwiftShell.run("echo", "hi")
		_ = SwiftShell.run(bash: "echo hi")
		main.run("echo", "hi")
		main.run(bash: "echo hi")
	}

	func testBashCommand() {
		XCTAssertEqual(SwiftShell.run(bash: "echo one").stdout, "one")
	}

	func testArgumentsFromArray() {
		let stringarray = ["one", "two"]
		XCTAssertEqual(SwiftShell.run("/bin/echo", stringarray).stdout, "one two")
	}

	func testSinglelineOutput() {
		XCTAssertEqual(SwiftShell.run("/bin/echo", "one", "two").stdout, "one two")
	}

	func testMultilineOutput() {
		XCTAssertEqual(SwiftShell.run("/bin/echo", "one\ntwo").stdout, "one\ntwo\n")
	}

	func testStandardErrorOutput() {
		XCTAssertEqual(SwiftShell.run(bash: "echo one 1>&2").stderror, "one")
	}

	func testCombinesOutput() {
		XCTAssertEqual(SwiftShell.run(bash: "echo stdout; echo stderr > /dev/stderr", combineOutput: true).stdout, "stdout\nstderr\n")
	}

	func testExecutableWithoutPath() {
		XCTAssertEqual(SwiftShell.run("echo", "one").stdout, "one")
	}

	func testSuccess() {
		let success = SwiftShell.run(bash: "exit 0")
		XCTAssertEqual(success.exitcode, 0)
		XCTAssertEqual(success.succeeded, true)

		let failure = SwiftShell.run(bash: "exit 1")
		XCTAssertEqual(failure.exitcode, 1)
		XCTAssertEqual(failure.succeeded, false)
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

	// https://github.com/kareman/SwiftShell/issues/52
	func testDoesNotHaltOnLargeOutput() {
		SwiftShell.run(bash: "for i in {1..65537}; do echo -n '='; done") // standard output

		SwiftShell.run(bash: "for i in {1..65537}; do echo -n '=' 1>&2; done") // standard error

		SwiftShell.run(bash: "for i in {1..65537}; do echo -n '='; echo -n '=' 1>&2; done") // both
	}
}

public class RunAsync_Tests: XCTestCase {
	func testReturnsStandardOutput() throws {
		let asynccommand = runAsync("/bin/echo", "one", "two")
		try asynccommand.finish()

		XCTAssertEqual(asynccommand.stdout.read(), "one two\n")
		XCTAssertEqual(asynccommand.stderror.read(), "")
	}

	func testReturnsStandardError() throws {
		let asynccommand = runAsync(bash: "echo one two > /dev/stderr")
		try asynccommand.finish()

		XCTAssertEqual(asynccommand.stderror.read(), "one two\n")
		XCTAssertEqual(asynccommand.stdout.read(), "")
	}

	func testArgumentsFromArray() throws {
		let output = try runAsync("/bin/echo", ["one", "two"]).finish().stdout.read()
		XCTAssertEqual(output, "one two\n")
	}

	func testFinishThrowsErrorOnExitcodeNotZero() {
		let asynccommand = runAsync(bash: "echo errormessage > /dev/stderr; exit 1")

		XCTAssertThrowsError(try asynccommand.finish())
		XCTAssertEqual(asynccommand.stderror.read(), "errormessage\n")
	}

	func testExitCode() {
		let asynccommand = runAsync(bash: "exit 1")

		XCTAssertEqual(asynccommand.exitcode(), 1)
	}

	func testOnCompletion() {
		let expectcompletion = expectation(description: "onCompletion will be called when command has finished.")

		runAsync("echo").onCompletion { command in
			XCTAssertFalse(command.isRunning)
			expectcompletion.fulfill()
		}
		waitForExpectations(timeout: 0.5, handler: nil)
	}

	func testStop() {
		// Start a command that won't exit for a long time
		let command = runAsync(bash: "sleep 100")

		XCTAssertTrue(command.isRunning)
		command.stop()

		// On Linux, command.isRunning becomes false once the command has been
		// stopped, but the terminationReason does not become .uncaughtSignal
		#if os(Linux)
		// Checking the isRunning occasionally happens too quick for the
		// assert. Sleeping for 1 second ensures the assert should pass
		sleep(1)
		XCTAssertFalse(command.isRunning)
		// On macOS, command.isRunning is true until waitUntilExit() has been
		// called, but the process's terminationReason becomes .uncaughtSignal.
		#else
		XCTAssertEqual(command.terminationReason(), Process.TerminationReason.uncaughtSignal)
		#endif
	}

	func testInterrupt() {
		// Start a command that won't exit for a long time
		let command = runAsync(bash: "sleep 100")

		XCTAssertTrue(command.isRunning)
		command.interrupt()

		// On Linux, command.isRunning becomes false once the command has been
		// interrupted, but the terminationReason does not become
		// .uncaughtSignal
		#if os(Linux)
		// Checking the isRunning occasionally happens too quick for the
		// assert. Sleeping for 1 second ensures the assert should pass
		sleep(1)
		XCTAssertFalse(command.isRunning)
		// On macOS, command.isRunning is true until waitUntilExit() has been
		// called, but the process's terminationReason becomes .uncaughtSignal.
		#else
		XCTAssertEqual(command.terminationReason(), Process.TerminationReason.uncaughtSignal)
		#endif
	}

	/*
	 Cannot test the suspend/resume calls reliably

	 func testSuspendAndResume() {
	 	// Start a command that wouldn't ever exit normally
	 	let command = runAsync("cat")

	 	XCTAssertTrue(command.isRunning)
	 	command.suspend()

	 	XCTAssertFalse(command.isRunning)
	 	command.resume()

	 	XCTAssertTrue(command.isRunning)
	 }
	 */
}

public class XCTestCase_TestOutput: XCTestCase {
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
}

public class RunAsyncAndPrint_Tests: XCTestCase_TestOutput {
	func testReturnsStandardOutput() throws {
		try runAsyncAndPrint("/bin/echo", "one", "two").finish()

		XCTAssertEqual(test_stdout.readSome(encoding: .utf8), "one two\n")
	}

	func testReturnsStandardError() throws {
		try runAsyncAndPrint(bash: "echo one two > /dev/stderr").finish()

		XCTAssertEqual(test_stderr.readSome(encoding: .utf8), "one two\n")
	}

	func testOnCompletion() {
		let expectcompletion = expectation(description: "onCompletion will be called when command has finished.")

		runAsyncAndPrint("echo").onCompletion { command in
			XCTAssertFalse(command.isRunning)
			expectcompletion.fulfill()
		}
		waitForExpectations(timeout: 0.5, handler: nil)
	}
}

public class RunAndPrint_Tests: XCTestCase_TestOutput {
	func testArgumentsFromArray() throws {
		try runAndPrint("/bin/echo", ["one", "two"])
		XCTAssertEqual(test_stdout.readSome(encoding: .utf8), "one two\n")
	}

	func testReturnsStandardOutput() throws {
		try runAndPrint("/bin/echo", "one", "two")
		XCTAssertEqual(test_stdout.readSome(encoding: .utf8), "one two\n")
	}

	func testReturnsStandardError() throws {
		try runAndPrint(bash: "echo one two > /dev/stderr")
		XCTAssertEqual(test_stderr.readSome(encoding: .utf8), "one two\n")
	}

	func testThrowsErrorOnExitcodeNotZero() {
		XCTAssertThrowsError(try runAndPrint("bash", "-c", "exit 1"))
	}

	func testThrowsErrorOnInaccessibleExecutable() {
		XCTAssertThrowsError(try runAndPrint("notachance"))
	}
}
