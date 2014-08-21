//
// Stream_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 21/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class Stream_Tests: XCTestCase {

	func testStreamFromAString () {
		XCTAssertEqual( "this is a string", stream("this is a string").read())
		XCTAssertEqual( "These are weird↔️🐻♨︎", stream("These are weird↔️🐻♨︎").read())
	}
	
	func testCustomStream () {
		let result = stream ({
			 var finished = false
			return {
				if !finished {
					finished = true
					return "this is it"
				} else {
					return nil
				
				}
			}
		})
		XCTAssertEqual( result.read(), "this is it")
	}
}
