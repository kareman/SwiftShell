//
// XCTestCase_Additions.swift
// SwiftShell
//
// Created by Kåre Morstøl on 15/09/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import XCTest
import Foundation

extension XCTestCase {

	func pathForTestResource (_ filename: String, type: String) -> String {
		guard let path = NSBundle(for: self.dynamicType).pathForResource(filename, ofType: type) else {
			preconditionFailure("resource \(filename).\(type) not found")
		}
		return path
	}
}
