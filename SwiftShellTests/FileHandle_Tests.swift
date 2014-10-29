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

	// waiting for error handling to be implemented
	func notestOpenForReadingFileWhichDoesNotExist () {
		let file = open("file which does not exist")
		XCTFail("not implemented yet")
	}
	
	func testReadFileLineByLine () {
		let shorttextpath = pathForTestResource("shorttext", type: "txt")
		var contents = ""
		
		for line in open(shorttextpath).lines() {
			contents.write(line)
		}
	}
}
