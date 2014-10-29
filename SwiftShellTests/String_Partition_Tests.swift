//
// String_Partition_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 20/07/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import XCTest
import SwiftShell

class String_Partition_Tests: XCTestCase {

	func testPartitionWithSeparatorInTheMiddle () {
		let text = "the first part\nthe second part"
		let (firstpart, returnedseparator, secondpart) = text.partition ("\n")
		XCTAssertEqual( firstpart, "the first part")
		XCTAssertEqual( returnedseparator, "\n")
		XCTAssertEqual( secondpart, "the second part")
	}
	
	func testPartitionWithNoSeparatorFound () {
		let text = "the first partthe second part"
		let (firstpart, returnedseparator, secondpart) = text.partition ("\n")
		XCTAssertEqual( firstpart, "the first partthe second part")
		XCTAssertEqual( returnedseparator, "")
		XCTAssertEqual( secondpart, "")
	}
	
	func testPartitionWithSeparatorAtTheEnd () {
		let text = "the first partthe second part\n"
		let (firstpart, returnedseparator, secondpart) = text.partition ("\n")
		XCTAssertEqual( firstpart, "the first partthe second part")
		XCTAssertEqual( returnedseparator, "\n")
		XCTAssertEqual( secondpart, "")
	}
	
	func testPartitionWithSeparatorAtTheBeginning () {
		let text = "\nthe first partthe second part\n"
		let (firstpart, returnedseparator, secondpart) = text.partition ("\n")
		XCTAssertEqual( firstpart, "")
		XCTAssertEqual( returnedseparator, "\n")
		XCTAssertEqual( secondpart, "the first partthe second part\n")
	}
	
	func testPartitionWithSeveralSeparators () {
		let text = "the first partthe second part"
		let (firstpart, returnedseparator, secondpart) = text.partition ("part")
		XCTAssertEqual( firstpart, "the first ")
		XCTAssertEqual( returnedseparator, "part")
		XCTAssertEqual( secondpart, "the second part")
	}
	
	func testPartitionWithEmptyText () {
		let text = ""
		let (firstpart, returnedseparator, secondpart) = text.partition ("part")
		XCTAssertEqual( firstpart, "")
		XCTAssertEqual( returnedseparator, "")
		XCTAssertEqual( secondpart, "")
	}
	
}
