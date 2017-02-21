//
// TestHelpers.swift
// SwiftShell
//
// Created by Kåre Morstøl on 30.01.2017.
//

import XCTest

/// Verifies the closure does not throw any errors.
///
///     AssertDoesNotThrow {
///         try something()
///     }
///
func AssertDoesNotThrow(_ closure: () throws -> ()) {
	do {
		try closure()
	} catch {
		XCTFail(String(describing: error))
	}
}

// From https://github.com/mrackwitz/CatchingFire/blob/master/src/CatchingFire.swift
/// Verifies the closure throws the expected error.
///
///     AssertThrows(Error.ArgumentMayNotBeNegative) {
///         try fib(-1)
///     }
///
/// If the closure does not throw the expected error, the test fails.
public func AssertThrows<E>(_ expectedError: E,
	file: StaticString = #file, line: UInt = #line, _ closure: () throws -> ())
	where E: Error, E: Equatable {

	do {
		try closure()
		XCTFail("Expected to catch <\(expectedError)>, but no error was thrown.", file: file, line: line)
	} catch let error as E {
		XCTAssertEqual(error, expectedError,
		               "Caught error <\(error)> is of the expected type <\(E.self)>, "
						+ "but not the expected case <\(expectedError)>.", file: file, line: line)
	} catch {
		XCTFail("Caught error <\(error)>, but not of the expected type and value <\(expectedError)>.", file: file, line: line)
	}
}
