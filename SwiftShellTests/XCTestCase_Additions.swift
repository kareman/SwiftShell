//
// XCTestCase_Additions.swift
// SwiftShell
//
// Created by Kåre Morstøl on 15/09/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import SwiftShell
import XCTest
import Foundation

extension XCTestCase {
	
	func pathForTestResource (filename: String, type: String) -> String {
		let path = NSBundle(forClass: self.dynamicType).pathForResource(filename, ofType: type) 
		assert(path != nil, "resource \(filename).\(type) not found") 
		
		return path!
	}

	func temporaryDirectory () -> NSURL {
		var error: NSError?
		let tempdirectory = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent(NSProcessInfo.processInfo().globallyUniqueString), isDirectory: true)!
		NSFileManager.defaultManager().createDirectoryAtURL(tempdirectory, withIntermediateDirectories:true, attributes: nil
			, error: &error)
		if let error = error {
			printErrorAndExit("could not create new temporary directory '\(tempdirectory)':\n\(error.localizedDescription)")
		}

		return tempdirectory
	}
}

