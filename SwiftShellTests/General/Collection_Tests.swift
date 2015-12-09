//
// Collection_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 08.12.2015.
//
//

import XCTest
@testable import SwiftShell

class LazySplitGenerator_Tests: XCTestCase {

	func splitToArray (s: String) -> [String] {
		let g = LazySplitGenerator(base: s.characters, separator: " " as Character)
		return AnySequence {g} .map {String($0)}
	}

	func testStrings () {
		XCTAssertEqual(splitToArray("abc def"), ["abc","def"])
		XCTAssertEqual(splitToArray(" a"),  ["","a"])
		XCTAssertEqual(splitToArray("a "), ["a",""])
		XCTAssertEqual(splitToArray("a  b"), ["a","","b"])
	}

	func splitIntsToArray (s: [Int]) -> [[Int]] {
		let g = LazySplitGenerator(base: s, separator: 0)
		return AnySequence {g} .map {Array($0)}
	}

	func testInts () {
		XCTAssertEqual(splitIntsToArray([1,2,0,4,0,6,7,8,9]), [[1,2],[4],[6,7,8,9]])
	}
}
