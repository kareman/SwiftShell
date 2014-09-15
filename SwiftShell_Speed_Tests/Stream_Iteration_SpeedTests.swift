//
// SwiftShell_Speed_Tests.swift
// SwiftShell Speed Tests
//
// Created by Kåre Morstøl on 28/07/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class Stream_Iteration_SpeedTests: XCTestCase {

	let numberoflines = 2000

	func testSpeedNSStringSplit () {

		// won't work outside of a method (6.1 beta 1)
		let longtextpath = pathForTestResource("long text", type: "txt")

		self.measureBlock() {
			let f = open(longtextpath)
			let text = f.read()
			let array = (text.split("\n"))
			
			var i = 0
			var result = ""
			for line in array {
				i++
				result += line
			}
			XCTAssertEqual(i, self.numberoflines)
			XCTAssert(result != "")
			f.closeFile()
		}
	}
	
	// takes a very long time
	func testSpeedSwiftSplit () {
		let longtextpath = pathForTestResource("long text", type: "txt")
		self.measureBlock(){
			let f = open(longtextpath)
			let text = f.read()
			
			var i = 0
			var result = ""
			for line in split(text, { $0 == "\n"}, allowEmptySlices: true) {
				i++
				result += line
			}
			XCTAssertEqual(i, self.numberoflines)
			XCTAssert(result != "")
			f.closeFile()
		}
	}
	
	func testSpeedSwiftShellSplit () {
		let longtextpath = pathForTestResource("long text", type: "txt")
		self.measureBlock() {
			let f = open(longtextpath)
			
			var i = 0
			var result = ""
			for line in f.lines() {
				i++
				result += line
			}
			XCTAssertEqual(i, self.numberoflines)
			XCTAssert(result != "")
			f.closeFile()
		}
	}	
	
	func allSpeedsSplitFileAsString() -> Array<UInt64> {
		let longtextpath = pathForTestResource("long text", type: "txt")

		// set initial size of array.
		var times = Array<UInt64>(count: numberoflines, repeatedValue: 0)
		
		let f = open(longtextpath)
		let start = mach_absolute_time()

		let text = f.read()
		let array = (text.split("\n"))
		
		var i = 0
		var result = ""
		for line in array {
			
			times[i++] = (mach_absolute_time() - start)
			result += line
		}
		
	XCTAssertEqual(i, numberoflines)
		XCTAssert(result != "")
		f.closeFile()
		return times
	}
	
	func allSpeedIterateOverFile() -> Array<UInt64>{
		let longtextpath = pathForTestResource("long text", type: "txt")
		var times = Array<UInt64>(count: numberoflines, repeatedValue: 0)
		
		let f = open(longtextpath)
		let start = mach_absolute_time()

		var i = 0
		var result = ""
		for line in f.lines() {
			times[i++] = (mach_absolute_time() - start)
			result += line
		}
		XCTAssertEqual(i, numberoflines)
		XCTAssert(result != "")
		f.closeFile()
		return times
	}
	
	func testWhenSplitFileAsStringBecomesQuicker() {
		let splitarray = allSpeedsSplitFileAsString()
		let myarray = allSpeedIterateOverFile()
		for i in 0..<splitarray.count {
			if myarray[i] > splitarray[i] {
				println(" splitting strings is faster after \(i) of \(splitarray.count) iterations")
				return
			}
		}
		println( "splitting strings was never faster!")
	}
	
}
