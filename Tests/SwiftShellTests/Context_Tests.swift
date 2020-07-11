//
// Context_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 20.07.15.
//

import Foundation
import SwiftShell
import XCTest

public class MainContext_Tests: XCTestCase {
	func testCurrentDirectory_IsCurrentDirectory() {
		XCTAssertEqual(main.currentdirectory, Files.currentDirectoryPath + "/")
	}

	func testCurrentDirectory_CanChange() {
		let originalcurrentdirectory = main.currentdirectory
		XCTAssertNotEqual(main.run("/bin/pwd").stdout, "/usr")
		main.currentdirectory = "/usr"

		XCTAssertEqual(main.run("/bin/pwd").stdout, "/usr")
		XCTAssertEqual(main.currentdirectory, "/usr/")
		main.currentdirectory = originalcurrentdirectory
	}

	func testCurrentDirectory_AffectsNSURLBase() {
		let originalcurrentdirectory = main.currentdirectory
		XCTAssertNotEqual(URL(fileURLWithPath: "file").baseURL, URL(fileURLWithPath: "/usr"))

		main.currentdirectory = "/usr"

		XCTAssertEqual(URL(fileURLWithPath: "file").baseURL, URL(fileURLWithPath: "/usr"))
		main.currentdirectory = originalcurrentdirectory
	}

	func testTempDirectory() {
		XCTAssertEqual(main.tempdirectory, main.tempdirectory)
		XCTAssert(Files.fileExists(atPath: main.tempdirectory), "Temporary directory \(main.tempdirectory) does not exist")
	}
}

public class CopiedCustomContext_Tests: XCTestCase {
	func testCopies() {
		let context = CustomContext(main)

		XCTAssert(context.stdin === main.stdin)
		XCTAssertEqual(context.env, main.env)
	}

	func testCurrentDirectory_DoesNotAffectNSURLBase() {
		let originalnsurlbaseurl = URL(fileURLWithPath: "file").baseURL

		var context = CustomContext(main)
		context.currentdirectory = "/private"

		XCTAssertEqual(URL(fileURLWithPath: "file").baseURL, originalnsurlbaseurl)
	}
}

public class BlankCustomContext_Tests: XCTestCase {
	func testIsBlank() {
		let context = CustomContext()

		XCTAssert(context.stdin.filehandle === FileHandle.nullDevice)
		XCTAssert(context.stdout.filehandle === FileHandle.nullDevice)
		XCTAssert(context.stderror.filehandle === FileHandle.nullDevice)
	}

	func testRunCommand() {
		let context = CustomContext()

		XCTAssertEqual(context.run("/bin/echo", "one").stdout, "one")
	}

	func testRunAsyncCommand() {
		let context = CustomContext()
		let process = context.runAsync("/bin/echo", "one")

		XCTAssertEqual(process.stdout.read(), "one\n")
	}

	func testRunAndPrintCommand() throws {
		var context = CustomContext()

		try context.runAndPrint("/bin/echo", "one") // sent to null

		let outputpipe = Pipe()
		context.stdout = FileHandleStream(outputpipe.fileHandleForWriting, encoding: .utf8)
		let output = outputpipe.fileHandleForReading

		try context.runAndPrint("/bin/echo", "two")
		XCTAssertEqual(output.readSome(encoding: .utf8), "two\n")
	}
}
