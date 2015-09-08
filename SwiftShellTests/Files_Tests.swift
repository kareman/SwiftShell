//
// Files_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 25.11.14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class UrlAppendationOperator: XCTestCase {

	func testUrlSlashString () {
		XCTAssertEqual( NSURL(fileURLWithPath: "dir") / "file.txt", NSURL(fileURLWithPath: "dir/file.txt"))
		XCTAssertEqual( NSURL(fileURLWithPath: "dir/") / "/file.txt", NSURL(fileURLWithPath: "dir/file.txt"))
		XCTAssertEqual( NSURL(string: "dir")! / "file.txt", NSURL(string: "dir/file.txt"))
	}
}
