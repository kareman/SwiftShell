/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

extension Array where Element: Any {
	func flatten() -> [Any] {
		return self.flatMap { x -> [Any] in
			if let anyarray = x as? Array<Any> {
				return anyarray.map { $0 as Any }.flatten()
			}
			return [x]
		}
	}
}
