/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

#if !(os(iOS) || os(tvOS) || os(watchOS))

import Foundation

/// Let Strings run commands using itself as stdin.
extension String: CommandRunning {
	public var context: Context {
		var context = CustomContext(main)
		let (writer, reader) = streams()

		writer.write(self)
		writer.close()
		context.stdin = reader
		return context
	}
}

#endif

extension String {
	/// Split text into lines (as separated by newlines).
	public func lines() -> [String] {
		return characters.split(separator: "\n").map(String.init)
	}
}
