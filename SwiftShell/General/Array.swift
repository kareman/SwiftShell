/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

private protocol AnyArrayType {
	var anyValues: [Any] { get }
}

extension Array: AnyArrayType {
	var anyValues: [Any] {
		return self.map { $0 as Any }
	}
}

public extension Array where Element: Any {
	func flatten () -> [Any] {
		let result: [Any] = self.flatMap { x -> [Any] in
			switch x {
			case let anyarray as AnyArrayType:
				return anyarray.anyValues
			default:
				return [x]
			}
		}
		return result
	}
}
