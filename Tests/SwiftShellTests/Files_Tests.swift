//
// Files_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 25.11.14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest
import Foundation

public class UrlAppendationOperator: XCTestCase {

	func testUrlPlusString () {
		XCTAssertEqual( URL(fileURLWithPath: "dir") + "file.txt", URL(fileURLWithPath: "dir/file.txt"))
		XCTAssertEqual( URL(fileURLWithPath: "dir/") + "/file.txt", URL(fileURLWithPath: "dir/file.txt"))
		XCTAssertEqual( URL(string: "dir")! + "file.txt", URL(string: "dir/file.txt"))
	}
}

public class Open: XCTestCase {

	func testReadFile () {
		let path = main.tempdirectory + "testReadFile.txt"
		let _ = SwiftShell.run(bash: "echo Lorem ipsum dolor > " + path)

		AssertNoThrow {
			let file = try open(path)
			XCTAssert(file.read().hasPrefix("Lorem ipsum dolor"))
		}
	}

	func testReadFileWhichDoesNotExist () {
		do {
			let _ = try open("/nonexistingfile.txt")
			XCTFail("Creating stream from non-existing file did not throw error")
		} catch {

		}
	}

	func testOpenForWritingFileWhichDoesNotExist () {
		let path = main.tempdirectory + "testOpenForWritingFileWhichDoesNotExist.txt"

		AssertNoThrow {
			let file = try open(forWriting: path)
			file.print("line 1")
			file.close()

			let contents = try String(contentsOfFile: path)
			XCTAssertEqual( contents, "line 1\n" )
		}
	}

	func testOpenForOverWritingFileWhichDoesNotExist () {
		let path = main.tempdirectory + "testOpenForOverWritingFileWhichDoesNotExist.txt"

		AssertNoThrow {
			let file = try open(forWriting: path, overwrite: true)
			file.print("line 1")
			file.close()

			let contents = try String(contentsOfFile: path)
			XCTAssertEqual( contents, "line 1\n" )
		}
	}

	func testOpenForWritingExistingFile_AppendsFile () {
		let path = main.tempdirectory + "testOpenForWritingExistingFile_AppendsFile.txt"
		let _ = SwiftShell.run(bash: "echo existing line > " + path)

		AssertNoThrow {
			let file = try open(forWriting: path)
			file.print("new line")
			file.close()

			let contents = try String(contentsOfFile: path)
			XCTAssertEqual( contents, "existing line\nnew line\n" )
		}
	}

	func testOpenForOverWritingExistingFile () {
		let path = main.tempdirectory + "testOpenForOverWritingExistingFile.txt"
		let _ = SwiftShell.run(bash: "echo existing line > " + path)

		AssertNoThrow {
			let file = try open(forWriting: path, overwrite: true)
			file.print("new line")
			file.close()

			let contents = try String(contentsOfFile: path)
			XCTAssertEqual( contents, "new line\n" )
		}
	}
}

extension UrlAppendationOperator {
	public static var allTests = [
		("testUrlPlusString", testUrlPlusString),
		]
}

extension Open {
	public static var allTests = [
		("testReadFile", testReadFile),
		("testReadFileWhichDoesNotExist", testReadFileWhichDoesNotExist),
		("testOpenForWritingFileWhichDoesNotExist", testOpenForWritingFileWhichDoesNotExist),
		("testOpenForOverWritingFileWhichDoesNotExist", testOpenForOverWritingFileWhichDoesNotExist),
		("testOpenForWritingExistingFile_AppendsFile", testOpenForWritingExistingFile_AppendsFile),
		("testOpenForOverWritingExistingFile", testOpenForOverWritingExistingFile),
		]
}
