//
//  Context_Tests.swift
//  SwiftShell2
//
//  Created by Kåre Morstøl on 20.07.15.
//
//

import XCTest
import SwiftShell

class MainContext_Tests: XCTestCase {

	func testCurrentDirectory_IsCurrentDirectory () {
		XCTAssertEqual( main.currentdirectory, NSFileManager.defaultManager().currentDirectoryPath )
	}

	func testCurrentDirectory_CanChange () {
		main.currentdirectory = "/tmp"

		XCTAssertEqual( main.currentdirectory, "/private/tmp" )
		XCTAssertEqual( main.run("/bin/pwd"), "/tmp" )
		XCTAssertEqual( main.currentdirectory, NSFileManager.defaultManager().currentDirectoryPath )
	}
}

class BlankShellContext_Tests: XCTestCase {

	func testIsBlank () {
		let context = ShellContext()

		XCTAssert( context.stdin === NSFileHandle.fileHandleWithNullDevice() )
		XCTAssert( context.stdout === NSFileHandle.fileHandleWithNullDevice() )
		XCTAssert( context.stderror === NSFileHandle.fileHandleWithNullDevice() )
	}

	func testCopiedShellContext () {
		let context = ShellContext(main)

		XCTAssert( context.stdin === main.stdin )
	}

	func testNonAbsoluteExecutablePathFailsOnEmptyPATHEnvVariable () {
		let context = ShellContext() // everything is empty, including .env

		AssertThrows(ShellError.InAccessibleExecutable(path: "echo")) {
			try context.runAndPrint("echo", "one")
		}
	}

	func testRunCommand () {
		let context = ShellContext()

		XCTAssertEqual(context.run("/bin/echo", "one"), "one")
	}

	func testRunAsyncCommand () {
		let context = ShellContext()
		let task = context.runAsync("/bin/echo", "one")

		XCTAssertEqual(task.stdout.read(), "one\n")
	}

	func testRunAndPrintCommand () {
		var context = ShellContext()

		AssertNoThrow {
			try context.runAndPrint("/bin/echo", "one") // sent to null
		}

		let outputpipe = NSPipe()
		context.stdout = outputpipe.fileHandleForWriting
		let output = outputpipe.fileHandleForReading

		AssertNoThrow {
			try context.runAndPrint("/bin/echo", "two")
		}
		XCTAssertEqual(output.readSome(), "two\n")
	}
}
