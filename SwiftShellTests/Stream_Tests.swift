//
// Stream_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 21/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class Stream_Tests: XCTestCase {

	func testStreams () {
		let (writer,reader) = streams()

		writer.write("one")
		XCTAssertEqual(reader.readSome(), "one")

		writer.writeln()
		writer.writeln("two")
		XCTAssertEqual(reader.readSome(), "\ntwo\n")

		writer.write("three")
		writer.close()
		XCTAssertEqual(reader.read(), "three")
	}
}
