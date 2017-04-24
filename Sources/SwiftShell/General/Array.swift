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
	fileprivate var anyValues: [Any] {
		return self.map { $0 as Any }
	}
}

extension Array where Element: Any {
	func flatten() -> [Any] {
		return self.flatMap { x -> [Any] in
			if let anyarray = x as? AnyArrayType {
				return anyarray.anyValues.flatten()
			}
			return [x]
		}
	}
}
