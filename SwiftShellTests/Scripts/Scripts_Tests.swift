//
//  Scripts_Tests.swift
//  SwiftShell
//
//  Created by Kåre Morstøl on 24/08/14.
//  Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import  SwiftShell
import XCTest

class Scripts_Tests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
		println( SwiftShell.run("env").read()    )
	}

}