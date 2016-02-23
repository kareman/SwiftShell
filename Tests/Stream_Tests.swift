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

	func testReadableStreamRun () {
		let (writer,reader) = streams()

		writer.write("one")
		writer.close()

		XCTAssertEqual(reader.run("cat"), "one")
	}

	func testReadableStreamRunAsync () {
		let (writer,reader) = streams()

		writer.write("one")
		writer.close()

		XCTAssertEqual(reader.runAsync("cat").stdout.read(), "one")
	}

	func testPrintStream () {
		let (writer,reader) = streams()
		writer.write("one")
		writer.close()

		var string = ""
		print(reader, toStream: &string)
		
		XCTAssertEqual(string, "one\n")
	}

	func testPrintToStream () {
		var (writer,reader) = streams()

		print("one", toStream: &writer)

		XCTAssertEqual(reader.readSome(), "one\n")
	}
}
