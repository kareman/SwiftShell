//
//  Command_Tests.swift
//  SwiftShell
//
//  Created by Kåre Morstøl on 15/08/14.
//  Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest
class Command_Tests: XCTestCase {

    func testSimpleCommandWithOutput() {
		XCTAssertEqual(SwiftShell.run("echo this is streamed").read(), "this is streamed\n")
	}

	func testChainedCommands() {
		let result = SwiftShell.run("echo this is streamed") |>  SwiftShell.run( "wc -w")
		XCTAssertEqual( result.read().trim(), "3", "the number of words should be 3")
	}
}
