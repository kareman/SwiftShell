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

	func testSpeedNSStringSplit() {
		self.measureBlock(){
			let f = open( "/Users/karemorstol/Dropbox/Swift Standard Library Beta 5.txt")
			let text = f.read()
			let array = (text.split("\n"))
			
			var i = 0
			var result = ""
			for line in array {
				i++
				result += line
			}
			XCTAssertEqual(i, 5470)
			XCTAssert(result != "")
			f.closeFile()
		}
	}
	
	// takes a very long time
	func notestSpeedSwiftSplit() {
		self.measureBlock(){
			let f = open( "/Users/karemorstol/Dropbox/Swift Standard Library Beta 5.txt")
			let text = f.read()
			// let array = (text.split("\n"))
			
			var i = 0
			var result = ""
			for line in split(text, { $0 == "\n"}, allowEmptySlices: true) {
				i++
				result += line
			}
			XCTAssertEqual(i, 5470)
			XCTAssert(result != "")
			f.closeFile()
		}
	}
	
	func testSpeedMyPartition() {
		self.measureBlock() {
			let f = open( "/Users/karemorstol/Dropbox/Swift Standard Library Beta 5.txt")
			
			var i = 0
			var result = ""
			for line in f.lines() {
				i++
				result += line
			}
			XCTAssertEqual(i, 5469)
			XCTAssert(result != "")
			f.closeFile()
		}
	}	
	
	func allSpeedsSplitFileAsString() -> Array<UInt64> {
		var times = Array<UInt64>(count: 5471,repeatedValue: 0)
		
		let f = open( "/Users/karemorstol/Dropbox/Swift Standard Library Beta 5.txt")
		let start = mach_absolute_time()

		let text = f.read()
		let array = (text.split("\n"))
		
		var i = 0
		var result = ""
		for line in array {
			
			times[i++] = (mach_absolute_time() - start)
			result += line
		}
		
		XCTAssertEqual(i, 5470)
		XCTAssert(result != "")
		f.closeFile()
		return times
	}
	
	func allSpeedIterateOverFile() -> Array<UInt64>{
		var times = Array<UInt64>(count: 5471,repeatedValue: 0)
		
		let f = open( "/Users/karemorstol/Dropbox/Swift Standard Library Beta 5.txt")
		let start = mach_absolute_time()

		var i = 0
		var result = ""
		for line in f.lines() {
			times[i++] = (mach_absolute_time() - start)
			result += line
		}
		XCTAssertEqual(i, 5469)
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
