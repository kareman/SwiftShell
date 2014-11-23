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
	}
}
