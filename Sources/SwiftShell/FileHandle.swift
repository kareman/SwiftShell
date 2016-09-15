/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

extension FileHandle {

	public func readSome (encoding: String.Encoding = main.encoding) -> String? {
		let data = self.availableData

		guard data.count > 0 else { return nil }
		guard let result = String(data: data, encoding: encoding) else {
			exit(errormessage: "Could not convert binary data to text.")
		}

		return result
	}

	public func read (encoding: String.Encoding = main.encoding) -> String {
		let data = self.readDataToEndOfFile()

		guard let result = String(data: data, encoding: encoding) else {
			exit(errormessage: "Could not convert binary data to text.")
		}

		return result
	}
}

extension FileHandle {

	public func write <T> (_ x: T, encoding: String.Encoding = main.encoding) {
		guard let data = String(describing: x).data(using: encoding, allowLossyConversion:false) else {
			exit(errormessage: "Could not convert text to binary data.")
		}
		self.write(data)
	}

	public func writeln <T> (_ x: T, encoding: String.Encoding = main.encoding) {
		self.write(x, encoding: encoding)
		self.write("\n", encoding: encoding)
	}
}
