//
// Collection_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 08.12.2015.
//
//

@testable import SwiftShell
import XCTest

public class LazySplitGenerator_Tests: XCTestCase {
	func lazySplitToArray(allowEmptySlices: Bool) -> (String) -> [String] {
		{ s in
			let seq: LazySplitSequence = s.lazy.split(separator: "," as Character, allowEmptySlices: allowEmptySlices)
			return seq.map(String.init)
		}
	}

	func testStringsLazySplit_AllowingEmptySlices() {
		let split = lazySplitToArray(allowEmptySlices: true)

		XCTAssertEqual(split("ab,c,de,f"), ["ab", "c", "de", "f"])
		XCTAssertEqual(split(",a"), ["", "a"])
		XCTAssertEqual(split("a,"), ["a", ""])
		XCTAssertEqual(split("a,,b,,,c"), ["a", "", "b", "", "", "c"])
		XCTAssertEqual(split(""), [""])
		XCTAssertEqual(split(","), ["", ""])
		XCTAssertEqual(split("ab"), ["ab"])
	}

	func testCollectionTypeSplit_AllowingEmptySlices() {
		let split = { (s: String) -> [String] in
			s.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
		}

		XCTAssertEqual(split("ab,c,de,f"), ["ab", "c", "de", "f"])
		XCTAssertEqual(split(",a"), ["", "a"])
		XCTAssertEqual(split("a,"), ["a", ""])
		XCTAssertEqual(split("a,,b,,,c"), ["a", "", "b", "", "", "c"])
		XCTAssertEqual(split(""), [""])
		XCTAssertEqual(split(","), ["", ""])
		XCTAssertEqual(split("ab"), ["ab"])
	}

	func testStringsLazySplit_NoEmptySlices() {
		let split = lazySplitToArray(allowEmptySlices: false)

		XCTAssertEqual(split("ab,c,de,f"), ["ab", "c", "de", "f"])
		XCTAssertEqual(split(",a"), ["a"])
		XCTAssertEqual(split("a,"), ["a"])
		XCTAssertEqual(split("a,,b,,,c"), ["a", "b", "c"])
		XCTAssertEqual(split(""), [])
		XCTAssertEqual(split(","), [])
		XCTAssertEqual(split("ab"), ["ab"])
	}

	func testCollectionTypeSplit_NoEmptySlices() {
		let split = { (s: String) -> [String] in
			s.split(separator: ",", omittingEmptySubsequences: true).map(String.init)
		}

		XCTAssertEqual(split("ab,c,de,f"), ["ab", "c", "de", "f"])
		XCTAssertEqual(split(",a"), ["a"])
		XCTAssertEqual(split("a,"), ["a"])
		XCTAssertEqual(split("a,,b,,,c"), ["a", "b", "c"])
		XCTAssertEqual(split(""), [])
		XCTAssertEqual(split(","), [])
		XCTAssertEqual(split("ab"), ["ab"])
	}

	func testIntsLazySplit_NoEmptySlices() {
		let split = { (s: [Int]) -> [[Int]] in
			s.lazy.split(separator: 0, omittingEmptySubsequences: true).map(Array.init)
		}

		XCTAssertEqual(split([1, 2, 0, 4, 0, 6, 7, 8, 9]), [[1, 2], [4], [6, 7, 8, 9]])
	}

	func testPartialSourceLazySplit_AllowingEmptySlices() {
		func split(_ s: String...) -> [String] {
			var sg = s.makeIterator()
			return PartialSourceLazySplitSequence({ sg.next() }, separator: ",").map(String.init)
		}

		XCTAssertEqual(split("ab,c", ",de,f"), ["ab", "c", "de", "f"])
		XCTAssertEqual(split(",a"), ["", "a"])
		XCTAssertEqual(split("a,"), ["a", ""])
		XCTAssertEqual(split("a,", ",", "b,", ",,c"), ["a", "", "b", "", "", "c"])
		XCTAssertEqual(split(""), [""])
		XCTAssertEqual(split(","), ["", ""])
		XCTAssertEqual(split("ab"), ["ab"])

		XCTAssertEqual(split(), [])
		XCTAssertEqual(split("abc", "def", "g,", "h"), ["abcdefg", "h"])
		XCTAssertEqual(split(",abc", "def", "g", "h,"), ["", "abcdefgh", ""])
		XCTAssertEqual(split("", "abc", "", "def", "g,", "h"), ["abcdefg", "h"])
	}
}
