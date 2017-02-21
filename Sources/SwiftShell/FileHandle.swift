/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

#if os(macOS)
extension FileHandle {
	/** Returns '.nullDevice'. 'nullDevice' has not been implemented yet in Swift Foundation. */
	public class var nullDev: FileHandle {
		return nullDevice
	}
}
#else
extension FileHandle {
	@nonobjc static var _nulldevFileHandle: FileHandle = {
		return FileHandle(forUpdatingAtPath: "/dev/null")!
	}()

	/** Returns '/dev/null'. 'nullDevice' has not been implemented yet in Swift Foundation. */
	public class var nullDev: FileHandle {
		return _nulldevFileHandle
	}
}
#endif
