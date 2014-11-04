//
//  String_Tests.swift
//  SwiftShell
//
//  Created by Kåre Morstøl on 04.11.14.
//  Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import XCTest

class String_Tests: XCTestCase {

	func testCountOccurrencesOfStringInstring () {
		let text = "how many are there here"

		XCTAssertEqual( text.countOccurrencesOf( "e"), 5)
		XCTAssertEqual( text.countOccurrencesOf( "x"), 0)
		XCTAssertEqual( text.countOccurrencesOf( "h"), 3)
		XCTAssertEqual( text.countOccurrencesOf( "ho"), 1)
		XCTAssertEqual( text.countOccurrencesOf( "re"), 3)
		XCTAssertEqual( text.countOccurrencesOf( "Not found"), 0)
	}
}
