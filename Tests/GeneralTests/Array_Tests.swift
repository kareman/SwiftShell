//
// Array_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 20.09.15.
//
//

@testable import SwiftShell
import XCTest

public class Array_Tests: XCTestCase {
	// comparing as strings because XCTAssertEqual doesn't support [Any]

	func testAnyArrayFlattenAFlatOne() {
		XCTAssertEqual(([1, "2"] as [Any]).flatten().description, "[1, \"2\"]")
		XCTAssertEqual((["1", "2"] as [Any]).flatten().description, ["1", "2"].description)
		XCTAssertEqual(([1, 2] as [Any]).flatten().description, [1, 2].description)
	}

	func testAnyArrayFlattenABumpyOne() {
		let intarray = [1, 2]
		XCTAssertEqual(([intarray] as [Any]).flatten().description, [1, 2].description)
		XCTAssertEqual((["1", [2, 3]] as [Any]).flatten().description, "[\"1\", 2, 3]")

		let stringarray = ["one", "two"]
		XCTAssertEqual(([stringarray, "three"] as [Any]).flatten().description, ["one", "two", "three"].description)
		XCTAssertEqual(([stringarray, 3] as [Any]).flatten().description, (["one", "two", 3] as [Any]).description)
	}

	func testAnyArrayFlattenAVeryBumpyOne() {
		let intarray = [1, 2]
		XCTAssertEqual(([[intarray]] as [Any]).flatten().description, intarray.description)
		XCTAssertEqual((["1", [2, [3] as Any]] as [Any]).flatten().description, "[\"1\", 2, 3]")
	}
}
