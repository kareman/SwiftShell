/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2014 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
* Contributors:
*	Kåre Morstøl, https://github.com/kareman - initial API and implementation.
*/

import Foundation

func toURLOrError (path: String) -> NSURL {
	// no longer returns an optional. Weird. And it also seems to confuse the compiler (Swift 2 b2)
	let result = NSURL.fileURLWithPath(path)
	return result
}

/** The default NSFileManager */
public let File = NSFileManager.defaultManager()

/**
The tempdirectory is unique each time a script is run and is created the first time it is used.
It lies in the user's temporary directory and will be automatically deleted at some point.
*/
public let tempdirectory: String = {
	let tempdirectory = NSTemporaryDirectory() / "SwiftShell-" + NSProcessInfo.processInfo().globallyUniqueString
	do {
		try File.createDirectoryAtPath(tempdirectory, withIntermediateDirectories:true, attributes: nil)
	} catch let error as NSError {
		printErrorAndExit("Could not create new temporary directory '\(tempdirectory)':\n\(error.localizedDescription)")
	} catch {
		printErrorAndExit("Unexpected error: \(error)")
	}

	return tempdirectory
	}()

/**
The current working directory.

Must be used instead of `run("cd ...")` because all the `run` commands are executed in a
separate process and changing the directory there will not affect the rest of the Swift script.

This directory is also used as the base for relative URL's.
*/
public var workdirectory: String {
	get {	return File.currentDirectoryPath }
	set {
		if !File.changeCurrentDirectoryPath(newValue) {
			printErrorAndExit("Could not change the working directory to \(newValue)")
		}
	}
}


/** Allows for `"/directory" / "file.extension"` etc. */
public func / (leftpath: String, rightpath: String) -> String {
	return toURLOrError(leftpath).URLByAppendingPathComponent(rightpath).path!
}
