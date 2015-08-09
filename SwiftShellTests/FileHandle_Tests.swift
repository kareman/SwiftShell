//
// FileHandle_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 19/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest

class FileHandle_Tests: XCTestCase {

	func testWriteAndReadSome () {
		let pipe = NSPipe()
		let writer = pipe.fileHandleForWriting
		let reader = pipe.fileHandleForReading

		writer.write("line1")
		XCTAssertEqual(reader.readSome(), "line1")
		writer.write("line2")
		XCTAssertEqual(reader.readSome(), "line2")

		writer.closeFile()
		XCTAssertNil(reader.readSome())
		XCTAssertNil(reader.readSome(), "Performing readSome() repeatedly on closed filehandle should return empty string.")
		XCTAssertEqual(reader.read(), "")
	}

	func testWritelnAndRead () {
		let pipe = NSPipe()
		let writer = pipe.fileHandleForWriting
		let reader = pipe.fileHandleForReading

		writer.writeln("line1")
		writer.closeFile()
		XCTAssertEqual(reader.read(), "line1\n")
		XCTAssertEqual(reader.read(), "", "Performing read() repeatedly on closed filehandle should return empty string.")
	}
}
