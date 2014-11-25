/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2014 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
* Contributors:
*	Kåre Morstøl, https://github.com/kareman - initial API and implementation.
*/

import Foundation

/** 
The tempdirectory is unique each time a script is run and is created the first time it is used.
It lies in the user's temporary directory and will be automatically deleted at some point.
*/
public var tempdirectory: NSURL = {
	var error: NSError?
	let tempdirectory = NSURL(fileURLWithPath: NSTemporaryDirectory().stringByAppendingPathComponent("SwiftShell-" + NSProcessInfo.processInfo().globallyUniqueString), isDirectory: true)!
	NSFileManager.defaultManager()
		.createDirectoryAtURL(tempdirectory, withIntermediateDirectories:true, attributes: nil, error: &error)
	if let error = error {
		printErrorAndExit("could not create new temporary directory '\(tempdirectory)':\n\(error.localizedDescription)")
	}

	return tempdirectory
}()
