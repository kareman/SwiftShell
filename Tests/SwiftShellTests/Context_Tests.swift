//
// Context_Tests.swift
// SwiftShell2
//
// Created by Kåre Morstøl on 20.07.15.
//
//

import XCTest
@testable import SwiftShell
import Foundation

public class MainContext_Tests: XCTestCase {

	func testCurrentDirectory_IsCurrentDirectory () {
		XCTAssertEqual( main.currentdirectory, Files.currentDirectoryPath + "/")
	}

	func testCurrentDirectory_CanChange () {
		let originalcurrentdirectory = main.currentdirectory
		XCTAssertNotEqual( main.run("/bin/pwd"), "/usr" )
		main.currentdirectory = "/usr"

		XCTAssertEqual( main.run("/bin/pwd"), "/usr" )
		XCTAssertEqual( main.currentdirectory, "/usr/" )
		main.currentdirectory = originalcurrentdirectory
	}

	func testCurrentDirectory_AffectsNSURLBase () {
		let originalcurrentdirectory = main.currentdirectory
		XCTAssertNotEqual(URL(fileURLWithPath: "file").baseURL, URL(fileURLWithPath: "/usr") )

		main.currentdirectory = "/usr"

		XCTAssertEqual(URL(fileURLWithPath: "file").baseURL, URL(fileURLWithPath: "/usr") )
		main.currentdirectory = originalcurrentdirectory
	}

	func testTempDirectory () {
		XCTAssertEqual( main.tempdirectory, main.tempdirectory )
		XCTAssert( Files.fileExists(atPath: main.tempdirectory), "Temporary directory \(main.tempdirectory) does not exist" )
	}
}

public class CopiedShellContext_Tests: XCTestCase {

	func testCopies () {
		let context = ShellContext(main)

		XCTAssert( context.stdin === main.stdin )
		XCTAssertEqual(context.env, main.env)
	}

	func testCurrentDirectory_DoesNotAffectNSURLBase () {
		let originalnsurlbaseurl = URL(fileURLWithPath: "file").baseURL

		var context = ShellContext(main)
		context.currentdirectory = "/private"

		XCTAssertEqual(URL(fileURLWithPath: "file").baseURL, originalnsurlbaseurl )
	}
}

public class BlankShellContext_Tests: XCTestCase {

	func testIsBlank () {
		let context = ShellContext()

		XCTAssert( context.stdin.filehandle === FileHandle.nullDev )
		XCTAssert( context.stdout.filehandle === FileHandle.nullDev )
		XCTAssert( context.stderror.filehandle === FileHandle.nullDev )
	}

	func testRunCommand () {
		let context = ShellContext()

		XCTAssertEqual(context.run("/bin/echo", "one"), "one")
	}

	func testRunAsyncCommand () {
		let context = ShellContext()
		let process = context.runAsync("/bin/echo", "one")

		XCTAssertEqual(process.stdout.read(), "one\n")
	}

	func testRunAndPrintCommand () {
		var context = ShellContext()

		AssertDoesNotThrow {
			try context.runAndPrint("/bin/echo", "one") // sent to null

			let outputpipe = Pipe()
			context.stdout = FileHandleStream(outputpipe.fileHandleForWriting)
			let output = outputpipe.fileHandleForReading

			try context.runAndPrint("/bin/echo", "two")
			XCTAssertEqual(output.readSome(), "two\n")
		}
	}
}

extension MainContext_Tests {
	public static var allTests = [
		("testCurrentDirectory_IsCurrentDirectory", testCurrentDirectory_IsCurrentDirectory),
		("testCurrentDirectory_CanChange", testCurrentDirectory_CanChange),
		("testCurrentDirectory_AffectsNSURLBase", testCurrentDirectory_AffectsNSURLBase),
		("testTempDirectory", testTempDirectory),
		]
}

extension CopiedShellContext_Tests {
	public static var allTests = [
		("testCopies", testCopies),
		("testCurrentDirectory_DoesNotAffectNSURLBase", testCurrentDirectory_DoesNotAffectNSURLBase),
		]
}

extension BlankShellContext_Tests {
	public static var allTests = [
		("testIsBlank", testIsBlank),
		("testRunCommand", testRunCommand),
		("testRunAsyncCommand", testRunAsyncCommand),
		("testRunAndPrintCommand", testRunAndPrintCommand),
		]
}
