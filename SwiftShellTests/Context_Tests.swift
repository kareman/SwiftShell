//
//  Context_Tests.swift
//  SwiftShell2
//
//  Created by Kåre Morstøl on 20.07.15.
//
//

import XCTest
import SwiftShell

class Context_Tests: XCTestCase {

	func testCurrentDirectory_IsCurrentDirectory () {
		XCTAssertEqual( main.currentdirectory, NSFileManager.defaultManager().currentDirectoryPath )
	}

	func testCurrentDirectory_CanChange () {
		main.currentdirectory = "/tmp"

		XCTAssertEqual( main.currentdirectory, "/private/tmp" )
		XCTAssertEqual( main.$("/bin/pwd"), "/tmp" )
		XCTAssertEqual( main.currentdirectory, NSFileManager.defaultManager().currentDirectoryPath )
	}
}
