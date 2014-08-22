//
// Stream_Iteration_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 18/07/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import XCTest
import SwiftShell

class Stream_Iteration_Tests: XCTestCase {
	
	func testIterateOverFileHandle() {
		var filehandletest = ""
		
		for line in stream("line 1\nline 2\n").lines() {
			filehandletest += line + "\n"
		}
		XCTAssertEqual(filehandletest , "line 1\nline 2\n")
		
		XCTAssertEqual(["line 1","line 2"] , Array(stream("line 1\nline 2").lines()))
		XCTAssertEqual(["line 1"] , Array(stream("line 1\n").lines()))
		XCTAssertEqual(["line 1"] , Array(stream("line 1").lines()))
		XCTAssertEqual(["line 1", "", "line 3"] , Array(stream("line 1\n\nline 3").lines()))
		XCTAssertEqual(["", "line 2", "line 3"] , Array(stream("\nline 2\nline 3").lines()))
		XCTAssertEqual(["", "", "line 3"] , Array(stream("\n\nline 3").lines()))
	}
	
	func testIterateOverStreamInPieces () {
		XCTAssertEqual(["line 1","line 2"] , Array(stream(["line"," 1\nline 2"]).lines()))
		XCTAssertEqual(["line 1"] , Array(stream(["line 1","\n"]).lines()))
		XCTAssertEqual(["line 1"] , Array(stream(["li","ne"," 1"]).lines()))
		XCTAssertEqual(["line 1", "", "line 3"] , Array(stream(["line 1\n","\n","line 3"]).lines()))
		XCTAssertEqual(["", "line 2", "line 3"] , Array(stream(["\nline 2\n","line 3"]).lines()))
		XCTAssertEqual(["", "", "line 3"] , Array(stream(["\n","\nli","ne 3"]).lines()))		
	}
	
}
