//
// String_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 04.11.14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import XCTest
import SwiftShell

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

	func testFindAll () {

		func ranges(findstring: String) -> [Range<String.Index>] {
			let text = "a b c aa bbb cc ab bc ca"
			return text.findAll(findstring) |> toArray
		}

		XCTAssertEqual(ranges("a").count, 5)
		XCTAssertEqual(ranges("bb").count, 1)
		XCTAssertEqual(ranges("a ").count, 2)
	}


	func testReplaceStringwithstring () {
		let text = "a b c aa bb cc ab bc ca"

		XCTAssertEqual( text.replace("a", "x"), "x b c xx bb cc xb bc cx")
		XCTAssertEqual( text.replace("b ", "x"), "a xc aa bxcc axbc ca")
	}

	func testReplaceOnlySomeStringsWithString () {
		let text = "a b c aa bb cc ab bc ca"

		XCTAssertEqual( text.replace("a", "x", limit: 0), "a b c aa bb cc ab bc ca")
		XCTAssertEqual( text.replace("a", "x", limit: 2), "x b c xa bb cc ab bc ca")
		XCTAssertEqual( text.replace("a", "x", limit: 4), "x b c xx bb cc xb bc ca")
		XCTAssertEqual( text.replace("a", "x", limit: 5), "x b c xx bb cc xb bc cx")
		XCTAssertEqual( text.replace("a", "x", limit: 6), "x b c xx bb cc xb bc cx")

		XCTAssertEqual( text.replace("a", "[xy]", limit: 4), "[xy] b c [xy][xy] bb cc [xy]b bc ca")
		XCTAssertEqual( text.replace("a", "[xy]", limit: 5), "[xy] b c [xy][xy] bb cc [xy]b bc c[xy]")
		XCTAssertEqual( text.replace("a", "[xy]", limit: 6), "[xy] b c [xy][xy] bb cc [xy]b bc c[xy]")

		XCTAssertEqual( text.replace("a ", "x", limit: 0), "a b c aa bb cc ab bc ca")
		XCTAssertEqual( text.replace("a ", "x", limit: 1), "xb c aa bb cc ab bc ca")
		XCTAssertEqual( text.replace("a ", "x", limit: 2), "xb c axbb cc ab bc ca")
		XCTAssertEqual( text.replace("a ", "x", limit: 3), "xb c axbb cc ab bc ca")
	}
}
