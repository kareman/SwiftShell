//
//  Process.swift
//  SwiftShell
//
//  Created by Kåre Morstøl on 06/04/2018.
//

import Foundation

// MARK: Process

extension Process {
	/// Launches process.
	///
	/// - throws: CommandError.inAccessibleExecutable if command could not be executed.
	public func launchThrowably() throws {
		#if !os(macOS)
		guard Files.isExecutableFile(atPath: self.executableURL!.path) else {
			throw CommandError.inAccessibleExecutable(path: self.executableURL!.lastPathComponent)
		}
		#endif
		do {
			if #available(OSX 10.13, *) {
				try run()
			} else {
				launch()
			}
		} catch CocoaError.fileNoSuchFile {
			if #available(OSX 10.13, *) {
				throw CommandError.inAccessibleExecutable(path: self.executableURL!.lastPathComponent)
			} else {
				throw CommandError.inAccessibleExecutable(path: self.launchPath!)
			}
		}
	}

	/// Waits until process is finished.
	///
	/// - throws: `CommandError.returnedErrorCode(command: String, errorcode: Int)`
	///   if the exit code is anything but 0.
	public func finish() throws {
		/// The full path to the executable + all arguments, each one quoted if it contains a space.
		func commandAsString() -> String {
			let path: String
			if #available(OSX 10.13, *) {
				path = self.executableURL?.path ?? ""
			} else {
				path = self.launchPath ?? ""
			}
			return (self.arguments ?? []).reduce(path) { (acc: String, arg: String) in
				acc + " " + (arg.contains(" ") ? ("\"" + arg + "\"") : arg)
			}
		}
		self.waitUntilExit()
		guard self.terminationStatus == 0 else {
			throw CommandError.returnedErrorCode(command: commandAsString(), errorcode: Int(self.terminationStatus))
		}
	}
}
