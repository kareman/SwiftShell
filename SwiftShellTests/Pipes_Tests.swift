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
	
	func testSplitMapFilterSortedAndJoinWithPipeForwardOperator () {
		let numbers = "4,1,6,2,5,3,9,7,0,8"
		
		// doing this on one line takes a very very long time to compile (6.1 beta 2)
		let numberslessthan5	= numbers |> split(",") |> map {$0.toInt()!} |> filter {$0<5}
		let result				= numberslessthan5 |> sorted {$0>$1} |> map(toString) |> join(",")
		
		XCTAssertEqual( result, "4,3,2,1,0" )
	}

	func testSplitAndReduceWithPipeForwardOperator () {
		let numbers = "4,1,6,2,5,3,9,7,0,8"
		
		let result = numbers |> split(",") |> reduce(0) {$0 + $1.toInt()!}
		
		XCTAssertEqual( result, 45 )
	}
	
	func testTurnSequenceIntoArray () {
		let numbers = [4,1,6]
		
		let result = SequenceOf(numbers) |> array
		
		XCTAssertEqual( result, [4,1,6] )
	}
}
