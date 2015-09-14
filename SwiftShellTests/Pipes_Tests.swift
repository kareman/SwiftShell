//
// Pipes_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 17/09/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class Pipes_Tests: XCTestCase {

	/*
	func testSplitMapFilterSortedAndJoinWithPipeForwardOperator () {
		let numbers = "4,1,6,2,5,3,9,7,0,8"
		
		// doing this on one line takes a very very long time to compile (6.1 beta 2)
		let numberslessthan5	= numbers |> split(delimiter: ",") |> map {Int($0)!} |> filter {$0<5}
		let result				= numberslessthan5 |> sorted {$0>$1} |> map {String($0)!}  |> join(",")
		
		XCTAssertEqual( result, "4,3,2,1,0" )
	}
	*/

	func testSplitAndReduceWithPipeForwardOperator () {
		let numbers = "4,1,6,2,5,3,9,7,0,8"
		
		let result = numbers |> split(delimiter: ",") |> reduce(0) {$0 + Int($1)!}
		
		XCTAssertEqual( result, 45 )
	}
	
	func testTurnSequenceIntoArray () {
		let numbers = [4,1,6]
		
		let result = AnySequence(numbers) |> toArray
		
		XCTAssertEqual( result, [4,1,6] )
	}
	
	func testDrop () {
		let numbers = [1,2,3,4,5,6]
		
		let result = numbers |> drop([2,3,5]) |> toArray 
		
		XCTAssertEqual( result, [1,4,6] )
	}

	func testTake () {
		let numbers = [1,2,3,4,5,6]

		XCTAssertEqual( numbers |> take(3), [1,2,3] )
		XCTAssertEqual( numbers |> take(100), [1,2,3,4,5,6] )
		XCTAssertEqual( numbers |> take(0), [] )
	}
}
