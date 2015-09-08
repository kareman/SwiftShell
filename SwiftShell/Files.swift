/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

import Foundation

/** The default NSFileManager */
public let Files = NSFileManager.defaultManager()

/** Append file or directory url to directory url */
public func / (leftpath: NSURL, rightpath: String) -> NSURL {
	return leftpath.URLByAppendingPathComponent(rightpath)
}
