/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

extension NSFileHandle {

	public func readSome (encoding encoding: UInt = main.encoding) -> String? {
		let data: NSData = self.availableData

		guard data.length > 0 else { return nil }
		guard let result = NSString(data: data, encoding: encoding) else {
			printErrorAndExit("Fatal error - could not convert stream to text.")
		}

		return result as String
	}

	public func read (encoding encoding: UInt = main.encoding) -> String {
		let data: NSData = self.readDataToEndOfFile()
		
		guard let result = NSString(data: data, encoding: encoding) else {
			printErrorAndExit("Fatal error - could not convert stream to text.")
		}

		return result as String
	}
}

extension NSFileHandle {

	public func write <T> (x: T, encoding: UInt = main.encoding) {
		writeData(String(x).dataUsingEncoding(encoding, allowLossyConversion:false)!)
	}

	public func writeln <T> (x: T, encoding: UInt = main.encoding) {
		self.write(x, encoding: encoding)
		self.write("\n", encoding: encoding)
	}
}
