//
// FileHandle_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 19/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import Foundation
import SwiftShell
import XCTest

public class FileHandle_Tests: XCTestCase {
	func testWriteAndReadSome() {
		let pipe = Pipe()
		let writer = pipe.fileHandleForWriting
		let reader = pipe.fileHandleForReading

		writer.write("line1")
		XCTAssertEqual(reader.readSome(encoding: .utf8), "line1")
		writer.write("line2")
		XCTAssertEqual(reader.readSome(encoding: .utf8), "line2")

		writer.closeFile()
		XCTAssertNil(reader.readSome(encoding: .utf8))
		XCTAssertNil(reader.readSome(encoding: .utf8), "Performing readSome() repeatedly on closed filehandle should return nil.")
		XCTAssertEqual(reader.read(encoding: .utf8), "")
	}

	func testWriteAndRead() {
		let pipe = Pipe()
		let writer = pipe.fileHandleForWriting
		let reader = pipe.fileHandleForReading

		writer.write("line1")
		writer.closeFile()
		XCTAssertEqual(reader.read(encoding: .utf8), "line1")
		XCTAssertEqual(reader.read(encoding: .utf8), "", "Performing read() repeatedly on closed filehandle should return empty string.")
	}
}
