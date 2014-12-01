//
// FileHandle_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 19/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class FileHandle_Tests: XCTestCase {

	func notestOpenForReadingFileWhichDoesNotExist () {
		// prints error message and stops execution.
		let file = open("file which does not exist")
	}
	
	func testReadFileLineByLine () {
		let shorttextpath = pathForTestResource("shorttext", type: "txt")
		var contents = ""
		
		for line in open(shorttextpath).lines() {
			contents.write(line)
		}

		XCTAssertFalse(contents.isEmpty, "could not read from file")
	}


	func testOpenForWritingFileWhichDoesNotExist () {
		let path = tempdirectory + "/testOpenForWritingFileWhichDoesNotExist.txt"
		let file = open(forWriting: path)
		file.writeln( "line 1")
		file.closeStream()

		XCTAssertEqual( open(path).read(), "line 1\n" )
	}

	func testOpenForOverWritingFileWhichDoesNotExist () {
		let path = tempdirectory + "/testOpenForOverWritingFileWhichDoesNotExist.txt"
		let file = open(forWriting: path, overwrite: true)
		file.writeln( "line 1")
		file.closeStream()

		XCTAssertEqual( open(path).read(), "line 1\n" )
	}

	func testOpenForWritingExistingFile_AppendsFile () {
		let path = tempdirectory + "/testOpenForWritingExistingFile_AppendsFile.txt"
		SwiftShell.run("echo existing line > " + path)

		let file = open(forWriting: path)
		file.writeln( "new line")
		file.closeStream()

		XCTAssertEqual( open(path).read(), "existing line\nnew line\n" )
	}

	func testOpenForOverWritingExistingFile () {
		let path = tempdirectory + "/testOpenForOverWritingExistingFile.txt"
		SwiftShell.run("echo existing line > " + path)

		let file = open(forWriting: path, overwrite: true)
		file.writeln( "new line")
		file.closeStream()

		XCTAssertEqual( open(path).read(), "new line\n" )
	}
}
