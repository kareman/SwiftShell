//
// Stream_Tests.swift
// SwiftShell
//
// Created by Kåre Morstøl on 21/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import Foundation
import SwiftShell
import XCTest

public class Stream_Tests: XCTestCase {
	func testStreams() {
		let (writer, reader) = streams()

		writer.write("one")
		XCTAssertEqual(reader.readSome(), "one")

		writer.print()
		writer.print("two")
		XCTAssertEqual(reader.readSome(), "\ntwo\n")

		writer.write("three")
		writer.close()
		XCTAssertEqual(reader.read(), "three")
	}

	func testData() {
		let (writer, reader) = streams()
		let data = Data([2, 4, 9, 7])

		writer.write(data: data)
		XCTAssertEqual(reader.readSomeData(), data)

		writer.write(data: data.base64EncodedData())
		writer.close()
		XCTAssertEqual(reader.readData(), data.base64EncodedData())
	}

	func testReadableStreamRun() {
		let (writer, reader) = streams()

		writer.write("one")
		writer.close()

		XCTAssertEqual(reader.run("cat").stdout, "one")
	}

	func testReadableStreamRunAsync() {
		let (writer, reader) = streams()

		writer.write("one")
		writer.close()

		XCTAssertEqual(reader.runAsync("cat").stdout.read(), "one")
	}

	func testPrintStream() {
		let (writer, reader) = streams()
		writer.write("one")
		writer.close()

		var string = ""
		print(reader, to: &string)

		XCTAssertEqual(string, "one\n")
	}

	func testPrintToStream() {
		let (w, reader) = streams()
		// 'print' does not work with protocol types directly, not even 'TextOutputStream'.
		var writer = w as! FileHandleStream

		print("one", to: &writer)

		XCTAssertEqual(reader.readSome(), "one\n")
	}

	func testPrintWorksTheSameAsTheBuiltinOne() {
		let (writer, reader) = streams()

		var text = ""
		print(to: &text)
		writer.print()
		XCTAssertEqual(reader.readSome(), text)

		text = ""
		print("1", to: &text)
		writer.print("1")
		XCTAssertEqual(reader.readSome(), text)

		text = ""
		print("1", 2, 3.0, to: &text)
		writer.print("1", 2, 3.0)
		XCTAssertEqual(reader.readSome(), text)

		text = ""
		print("1", [2, 3], separator: "", terminator: "", to: &text)
		writer.print("1", [2, 3], separator: "", terminator: "")
		XCTAssertEqual(reader.readSome(), text)
	}

	func testWriteStreamToAnotherStreamCompiles() {
		var file = try! open(forWriting: "/tmp/testWriteStreamToAnotherStreamCompiles.txt")
		runAsync("echo", "arg1").stdout.runAsync("wc").stdout.write(to: &file)
	}

	func testOnOutput() {
		let (writer, reader) = streams()

		let expectoutput = expectation(description: "onOutput will be called when output is available")
		reader.onOutput { stream in
			if stream.readSome() != nil {
				expectoutput.fulfill()
			}
		}
		writer.print()
		waitForExpectations(timeout: 0.5, handler: nil)
	}

	func testOnStringOutput() {
		let (writer, reader) = streams()

		let expectoutput = expectation(description: "onStringOutput will be called when output is available")
		reader.onStringOutput { string in
			XCTAssertEqual(string, "hi")
			expectoutput.fulfill()
		}
		writer.write("hi")
		waitForExpectations(timeout: 0.5, handler: nil)
	}
}
