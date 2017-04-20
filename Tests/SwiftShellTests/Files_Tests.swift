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

	func testUrlPlusString() {
		XCTAssertEqual( URL(fileURLWithPath: "dir") + "file.txt", URL(fileURLWithPath: "dir/file.txt"))
		XCTAssertEqual( URL(fileURLWithPath: "dir/") + "/file.txt", URL(fileURLWithPath: "dir/file.txt"))
		XCTAssertEqual( URL(string: "dir")! + "file.txt", URL(string: "dir/file.txt"))
	}
}

public class Open: XCTestCase {

	func testReadFile() {
		let path = main.tempdirectory + "testReadFile.txt"
		let _ = SwiftShell.run(bash: "echo Lorem ipsum dolor > " + path)

		AssertDoesNotThrow {
			let file = try open(path)
			XCTAssert(file.read().hasPrefix("Lorem ipsum dolor"))
		}
	}

	func testReadFileWhichDoesNotExist() {
		XCTAssertThrowsError(try open("/nonexistingfile.txt"))
	}

	func testOpenForWritingFileWhichDoesNotExist() {
		let path = main.tempdirectory + "testOpenForWritingFileWhichDoesNotExist.txt"

		AssertDoesNotThrow {
			let file = try open(forWriting: path)
			file.print("line 1")
			file.close()

			let contents = try String(contentsOfFile: path, encoding: .utf8)
			XCTAssertEqual( contents, "line 1\n" )
		}
	}

	func testOpenForOverWritingFileWhichDoesNotExist() {
		let path = main.tempdirectory + "testOpenForOverWritingFileWhichDoesNotExist.txt"

		AssertDoesNotThrow {
			let file = try open(forWriting: path, overwrite: true)
			file.print("line 1")
			file.close()

			let contents = try String(contentsOfFile: path, encoding: .utf8)
			XCTAssertEqual( contents, "line 1\n" )
		}
	}

	func testOpenForWritingExistingFile_AppendsFile() {
		let path = main.tempdirectory + "testOpenForWritingExistingFile_AppendsFile.txt"
		let _ = SwiftShell.run(bash: "echo existing line > " + path)

		AssertDoesNotThrow {
			let file = try open(forWriting: path)
			file.print("new line")
			file.close()

			let contents = try String(contentsOfFile: path, encoding: .utf8)
			XCTAssertEqual( contents, "existing line\nnew line\n" )
		}
	}

	func testOpenForOverWritingExistingFile() {
		let path = main.tempdirectory + "testOpenForOverWritingExistingFile.txt"
		let _ = SwiftShell.run(bash: "echo existing line > " + path)

		AssertDoesNotThrow {
			let file = try open(forWriting: path, overwrite: true)
			file.print("new line")
			file.close()

			let contents = try String(contentsOfFile: path, encoding: .utf8)
			XCTAssertEqual( contents, "new line\n" )
		}
	}
    
    func testOpenForOverWritingCreatesIntermediateDirectory() {
        let path = main.tempdirectory + "intermediate/path/testOpenForOverWritingExistingFile.txt"

        AssertDoesNotThrow {
            _ = try open(forWriting: path, overwrite: false)
			XCTAssert(Files.fileExists(atPath: path))
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
		("testOpenForOverWritingCreatesIntermediateDirectory", testOpenForOverWritingCreatesIntermediateDirectory)
		]
}
