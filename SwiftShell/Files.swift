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
	if let url = NSURL(fileURLWithPath: path) {
		return url
	} else {
		printErrorAndExit("Invalid file path: \(path)")
	}
}

/** The default NSFileManager */
public let File = NSFileManager.defaultManager()

/**
The tempdirectory is unique each time a script is run and is created the first time it is used.
It lies in the user's temporary directory and will be automatically deleted at some point.
*/
public let tempdirectory: String = {
	var error: NSError?
	let tempdirectory = NSTemporaryDirectory() / "SwiftShell-" + NSProcessInfo.processInfo().globallyUniqueString
	File.createDirectoryAtPath(tempdirectory, withIntermediateDirectories:true, attributes: nil, error: &error)
	if let error = error {
		printErrorAndExit("Could not create new temporary directory '\(tempdirectory)':\n\(error.localizedDescription)")
	}

	return tempdirectory
}()

/** 
The current working directory.

Must be used instead of `run("cd ...")` because all the `run` commands are executed in a
separate process and changing the directory there will not affect the rest of the Swift script.

This directory is also used as the base for relative URL's.
*/
public struct workdirectory {
    public static func get() -> String { return File.currentDirectoryPath }
    public static func set(newValue: String) {
		if !File.changeCurrentDirectoryPath(newValue) {
			printErrorAndExit("Could not change the working directory to \(newValue)")
		}
	}
}


/** Allows for `"/directory" / "file.extension"` etc. */
public func / (leftpath: String, rightpath: String) -> String {
	return toURLOrError(leftpath).URLByAppendingPathComponent(rightpath).path!
}
