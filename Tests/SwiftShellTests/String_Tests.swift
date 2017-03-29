//
// String_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 04.11.14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import XCTest
import SwiftShell

public class String_Tests: XCTestCase {

	func testRunCommands () {
		XCTAssertEqual("one two".run("wc","-w").stdout, "2")
		XCTAssertEqual("one".runAsync("cat").stdout.read(), "one")
	}
}

extension String_Tests {
	public static var allTests = [
		("testRunCommands", testRunCommands),
		]
}
