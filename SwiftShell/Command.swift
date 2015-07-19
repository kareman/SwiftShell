/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2014 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
* Contributors:
*	Kåre Morstøl, https://github.com/kareman - initial API and implementation.
*/

import Foundation

public func runLater (shellcommand: String) -> NSTask {
	let task = NSTask()
	task.arguments = ["-c", shellcommand]
	task.launchPath = "/bin/bash"

	return task
}
