/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

/** Let Strings run commands using itself as stdin. */
extension String: ShellRunnable {
	public var shellcontext: ShellContextType {
		var context = ShellContext(main)
		let (writer,reader) = streams()

		writer.write(self)
		writer.close()
		context.stdin = reader
		return context
	}
}
