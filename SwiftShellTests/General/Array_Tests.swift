//
//  Array_Tests.swift
//  SwiftShell2
//
//  Created by Kåre Morstøl on 20.09.15.
//
//

import XCTest

@testable import SwiftShell

class Array_Tests: XCTestCase {

	// comparing as strings because XCTAssertEqual doesn't support [Any]

	func testAnyArrayFlattenAFlatOne () {
		XCTAssertEqual( ([1,"2"] as [Any]).flatten().description, "[1, \"2\"]")
	}

	func testAnyArrayFlattenABumpyOne () {
		XCTAssertEqual( (["1",[2,3]] as [Any]).flatten().description, "[\"1\", 2, 3]")
	}
}
