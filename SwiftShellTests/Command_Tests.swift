//
// Command_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 15/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class Command_Tests: XCTestCase {

	func test$BashCommand () {
		XCTAssertEqual( main.$(bash:"echo one"), "one" )
	}

	func testSingleline$Command () {
		XCTAssertEqual( main.$("/bin/echo", "one", "two"), "one two" )
	}

	func testMultiline$Command () {
		XCTAssertEqual( main.$("/bin/echo", "one\ntwo"), "one\ntwo\n" )
	}

}
