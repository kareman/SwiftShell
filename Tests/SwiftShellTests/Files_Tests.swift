//
// Files_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 25.11.14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import Foundation
import SwiftShell
import XCTest

public class UrlAppendationOperator: XCTestCase {
	func testUrlPlusString() {
		XCTAssertEqual(URL(fileURLWithPath: "dir") + "file.txt", URL(fileURLWithPath: "dir/file.txt"))
		XCTAssertEqual(URL(fileURLWithPath: "dir/") + "/file.txt", URL(fileURLWithPath: "dir/file.txt"))
		XCTAssertEqual(URL(string: "dir")! + "file.txt", URL(string: "dir/file.txt"))
	}
}

public class Open: XCTestCase {
	func testReadFile() throws {
		let path = main.tempdirectory + "testReadFile.txt"
		_ = SwiftShell.run(bash: "echo Lorem ipsum dolor > " + path)

		let file = try open(path)
		XCTAssert(file.read().hasPrefix("Lorem ipsum dolor"))
	}

	func testReadFileWhichDoesNotExist() {
		XCTAssertThrowsError(try open("/nonexistingfile.txt"))
	}

	func testOpenForWritingFileWhichDoesNotExist() throws {
		let path = main.tempdirectory + "testOpenForWritingFileWhichDoesNotExist.txt"

		let file = try open(forWriting: path)
		file.print("line 1")
		file.close()

		let contents = try String(contentsOfFile: path, encoding: .utf8)
		XCTAssertEqual(contents, "line 1\n")
	}

	func testOpenForOverWritingFileWhichDoesNotExist() throws {
		let path = main.tempdirectory + "testOpenForOverWritingFileWhichDoesNotExist.txt"

		let file = try open(forWriting: path, overwrite: true)
		file.print("line 1")
		file.close()

		let contents = try String(contentsOfFile: path, encoding: .utf8)
		XCTAssertEqual(contents, "line 1\n")
	}

	func testOpenForWritingExistingFile_AppendsFile() throws {
		let path = main.tempdirectory + "testOpenForWritingExistingFile_AppendsFile.txt"
		_ = SwiftShell.run(bash: "echo existing line > " + path)

		let file = try open(forWriting: path)
		file.print("new line")
		file.close()

		let contents = try String(contentsOfFile: path, encoding: .utf8)
		XCTAssertEqual(contents, "existing line\nnew line\n")
	}

	func testOpenForOverWritingExistingFile() throws {
		let path = main.tempdirectory + "testOpenForOverWritingExistingFile.txt"
		_ = SwiftShell.run(bash: "echo existing line > " + path)

		let file = try open(forWriting: path, overwrite: true)
		file.print("new line")
		file.close()

		let contents = try String(contentsOfFile: path, encoding: .utf8)
		XCTAssertEqual(contents, "new line\n")
	}

	func testOpenForOverWritingCreatesIntermediateDirectory() throws {
		let path = main.tempdirectory + "intermediate/path/testOpenForOverWritingExistingFile.txt"
		_ = try open(forWriting: path, overwrite: false)
		XCTAssert(Files.fileExists(atPath: path))
	}
}
