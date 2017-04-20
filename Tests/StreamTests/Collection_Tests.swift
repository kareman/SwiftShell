//
// Collection_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 08.12.2015.
//
//

import XCTest
@testable import SwiftShell

public class LazySplitGenerator_Tests: XCTestCase {

	func lazySplitToArray(allowEmptySlices: Bool) -> (String) -> [String] {
		return { s in
			let seq: LazySplitSequence = s.characters.lazy.split(separator: "," as Character, allowEmptySlices: allowEmptySlices)
			return seq.map {String($0)}
		}
	}

	func testStringsLazySplit_AllowingEmptySlices() {
		let split = lazySplitToArray(allowEmptySlices: true)

		XCTAssertEqual(split("ab,c,de,f"), ["ab","c","de","f"])
		XCTAssertEqual(split(",a"),        ["","a"])
		XCTAssertEqual(split("a,"),        ["a",""])
		XCTAssertEqual(split("a,,b,,,c"),  ["a","","b","","","c"])
		XCTAssertEqual(split(""),          [""])
		XCTAssertEqual(split(","),         ["",""])
		XCTAssertEqual(split("ab"),        ["ab"])
	}

	func testCollectionTypeSplit_AllowingEmptySlices() {
		let split = { (s: String) -> [String] in
			s.characters.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
		}

		XCTAssertEqual(split("ab,c,de,f"), ["ab","c","de","f"])
		XCTAssertEqual(split(",a"),        ["","a"])
		XCTAssertEqual(split("a,"),        ["a",""])
		XCTAssertEqual(split("a,,b,,,c"),  ["a","","b","","","c"])
		XCTAssertEqual(split(""),          [""])
		XCTAssertEqual(split(","),         ["",""])
		XCTAssertEqual(split("ab"),        ["ab"])
	}

	func testStringsLazySplit_NoEmptySlices() {
		let split = lazySplitToArray(allowEmptySlices: false)

		XCTAssertEqual(split("ab,c,de,f"), ["ab","c","de","f"])
		XCTAssertEqual(split(",a"),        ["a"])
		XCTAssertEqual(split("a,"),        ["a"])
		XCTAssertEqual(split("a,,b,,,c"),  ["a","b","c"])
		XCTAssertEqual(split(""),          [])
		XCTAssertEqual(split(","),         [])
		XCTAssertEqual(split("ab"),        ["ab"])
	}

	func testCollectionTypeSplit_NoEmptySlices() {
		let split = {(s: String) -> [String] in
			s.characters.split(separator: ",", omittingEmptySubsequences: true).map(String.init)
		}

		XCTAssertEqual(split("ab,c,de,f"), ["ab","c","de","f"])
		XCTAssertEqual(split(",a"),        ["a"])
		XCTAssertEqual(split("a,"),        ["a"])
		XCTAssertEqual(split("a,,b,,,c"),  ["a","b","c"])
		XCTAssertEqual(split(""),          [])
		XCTAssertEqual(split(","),         [])
		XCTAssertEqual(split("ab"),        ["ab"])
	}

	func testIntsLazySplit_NoEmptySlices() {
		_ = {(s: [Int]) -> [[Int]] in
			s.lazy.split(separator: 0, omittingEmptySubsequences: true).map(Array.init)
		}

		//XCTAssertEqual(split([1,2,0,4,0,6,7,8,9]), [[1,2],[4],[6,7,8,9]])
	}

	func testPartialSourceLazySplit_AllowingEmptySlices() {
		func split(_ s: String...) -> [String] {
			var sg = s.map {$0.characters} .makeIterator()
			return PartialSourceLazySplitSequence({sg.next()}, separator: ",").map {String($0)}
		}

		XCTAssertEqual(split("ab,c",",de,f"), ["ab","c","de","f"])
		XCTAssertEqual(split(",a"),        ["","a"])
		XCTAssertEqual(split("a,"),        ["a",""])
		XCTAssertEqual(split("a,",",","b,",",,c"),  ["a","","b","","","c"])
		XCTAssertEqual(split(""),          [""])
		XCTAssertEqual(split(","),         ["",""])
		XCTAssertEqual(split("ab"),        ["ab"])

		XCTAssertEqual(split(), [])
		XCTAssertEqual(split("abc","def","g,","h"),       ["abcdefg","h"])
		XCTAssertEqual(split(",abc","def","g","h,"),      ["","abcdefgh",""])
		XCTAssertEqual(split("","abc","","def","g,","h"), ["abcdefg","h"])
	}
}

extension String.CharacterView: CustomDebugStringConvertible {
	public var debugDescription: String { return String(self) }
}

extension LazySplitGenerator_Tests {
	public static var allTests = [
		("testStringsLazySplit_AllowingEmptySlices", testStringsLazySplit_AllowingEmptySlices),
		("testCollectionTypeSplit_AllowingEmptySlices", testCollectionTypeSplit_AllowingEmptySlices),
		("testStringsLazySplit_NoEmptySlices", testStringsLazySplit_NoEmptySlices),
		("testCollectionTypeSplit_NoEmptySlices", testCollectionTypeSplit_NoEmptySlices),
		("testIntsLazySplit_NoEmptySlices", testIntsLazySplit_NoEmptySlices),
		("testPartialSourceLazySplit_AllowingEmptySlices", testPartialSourceLazySplit_AllowingEmptySlices),
		]
}
