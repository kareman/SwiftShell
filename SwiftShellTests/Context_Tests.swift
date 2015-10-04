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

class ShellContext_Tests: XCTestCase {

	func testBlankShellContext () {
		let context = ShellContext()

		XCTAssert( context.stdin === NSFileHandle.fileHandleWithNullDevice() )
	}

	func testCopiedShellContext () {
		let context = ShellContext(main)

		XCTAssert( context.stdin === main.stdin )
	}

	func testRunCommand () {
		let context = ShellContext()

		XCTAssertEqual(context.run("echo", "one"), "one")
	}

	func testRunAsyncCommand () {
		let context = ShellContext()
		let task = context.runAsync("echo", "one")

		XCTAssertEqual(task.stdout.read(), "one\n")
	}

	func testRunAndPrintCommand () {
		var context = ShellContext()

		AssertNoThrow {
			try context.runAndPrint("echo", "one") // sent to null
		}

		let outputpipe = NSPipe()
		context.stdout = outputpipe.fileHandleForWriting
		let output = outputpipe.fileHandleForReading

		AssertNoThrow {
			try context.runAndPrint("echo", "two")
		}
		XCTAssertEqual(output.readSome(), "two\n")
	}
}
