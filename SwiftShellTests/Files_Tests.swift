//
// Files_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 25.11.14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class Files_Tests: XCTestCase {

	func testTempDirectory_IsTheSameAfterRepeatedCalls () {
		XCTAssertEqual( tempdirectory, tempdirectory )
	}

	func testWorkDirectory_IsCurrentDirectory () {
		XCTAssertEqual( workdirectory, NSFileManager.defaultManager().currentDirectoryPath )
	}

	func testWorkDirectory_CanChange () {
		workdirectory = "/private/tmp"

		XCTAssertEqual( workdirectory, "/private/tmp" )
		XCTAssertEqual( $("pwd"), "/private/tmp" )
	}

	func testURLConcatenationOperator () {
		XCTAssertEqual( "/directory" / "file.extension", "/directory/file.extension" )
		XCTAssertEqual( "/root" / "directory" / "file.extension", "/root/directory/file.extension" )
		XCTAssertEqual( "directory" / "file.extension", workdirectory + "/directory/file.extension" )
	}
}
