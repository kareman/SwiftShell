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

class UrlAppendationOperator: XCTestCase {

	func testUrlPlusString () {
		XCTAssertEqual( NSURL(fileURLWithPath: "dir") + "file.txt", NSURL(fileURLWithPath: "dir/file.txt"))
		XCTAssertEqual( NSURL(fileURLWithPath: "dir/") + "/file.txt", NSURL(fileURLWithPath: "dir/file.txt"))
		XCTAssertEqual( NSURL(string: "dir")! + "file.txt", NSURL(string: "dir/file.txt"))
	}
}

class Open: XCTestCase {

	func testReadFile () {
		let shorttextpath = pathForTestResource("shorttext", type: "txt")

		AssertNoThrow {
			let file = try open(shorttextpath)
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
			file.writeln("line 1")
			file.close()

			let contents = try String(contentsOfFile: path)
			XCTAssertEqual( contents, "line 1\n" )
		}
	}

	func testOpenForOverWritingFileWhichDoesNotExist () {
		let path = main.tempdirectory + "testOpenForOverWritingFileWhichDoesNotExist.txt"

		AssertNoThrow {
			let file = try open(forWriting: path, overwrite: true)
			file.writeln("line 1")
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
			file.writeln("new line")
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
			file.writeln("new line")
			file.close()

			let contents = try String(contentsOfFile: path)
			XCTAssertEqual( contents, "new line\n" )
		}
	}
}
