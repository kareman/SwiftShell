//
//  Process.swift
//  SwiftShell
//
//  Created by Kåre Morstøl on 06/04/2018.
//

#if !(os(iOS) || os(tvOS) || os(watchOS))

import Foundation

// MARK: Process

extension Process {
	/// Launches process.
	///
	/// - throws: CommandError.inAccessibleExecutable if command could not be executed.
	public func launchThrowably() throws {
		guard Files.isExecutableFile(atPath: self.launchPath!) else {
			throw CommandError.inAccessibleExecutable(path: self.launchPath!)
		}
		launch()
	}

	/// Waits until process is finished.
	///
	/// - throws: `CommandError.returnedErrorCode(command: String, errorcode: Int)`
	///   if the exit code is anything but 0.
	public func finish() throws {
		/// The full path to the executable + all arguments, each one quoted if it contains a space.
		func commandAsString() -> String {
			let path = self.launchPath ?? ""
			return (self.arguments ?? []).reduce(path) { (acc: String, arg: String) in
				return acc + " " + ( arg.contains(" ") ? ("\"" + arg + "\"") : arg )
			}
		}
		self.waitUntilExit()
		guard self.terminationStatus == 0 else {
			throw CommandError.returnedErrorCode(command: commandAsString(), errorcode: Int(self.terminationStatus))
		}
	}
}

// MARK: Process extensions for Linux

#if os(Linux)
import Glibc

extension Process {
	fileprivate enum ProcessAttribute: String {
		case blockedSignals = "blocked"
		case ignoredSignals = "ignored"
	}

	/// Gets a specified process attribute using the `ps` command installed on all Linux systems
	///
	/// - parameter attr: Which specific attribute to return
	/// - returns: A String containing the hexadecimal representation of the mask,
	/// or nil if there is no stdout output
	fileprivate func getProcessInfo(_ attr: ProcessAttribute) -> String? {
		let attribute = run(bash: "ps --no-headers -q \(self.processIdentifier) -o \(attr.rawValue)").stdout
		return attribute.isEmpty ? nil : attribute
	}

	/// Determines whether the running process is blocking the specified signal
	fileprivate func isBlockingSignal(_ signum: Int32) -> Bool {
		// If there is no mask, then the signal isn't blocked
		guard let blockedMask = getProcessInfo(.blockedSignals) else { return false }

		// If the output isn't in proper hexadecimal (like it should be), then
		// it could be ignored, but we can't be sure. Return true, just to be safe
		guard let blocked = Int(blockedMask, radix: 16) else { return true }

		// Checks if the signals bit in the mask is 1 (1 == blocked)
		return blocked & (1 << signum) == 1
	}

	/// Determines whether the running process is ignoring the specified signal
	fileprivate func isIgnoringSignal(_ signum: Int32) -> Bool {
		// If there is no mask, then the signal isn't ignored
		guard let ignoredMask = getProcessInfo(.ignoredSignals) else { return false }

		// If the output isn't in proper hexadecimal (like it should be), then
		// it could be ignored, but we can't be sure. Return true, just to be safe
		guard let ignored = Int(ignoredMask, radix: 16) else { return true }

		// Checks if the signals bit in the mask is 1 (1 == ignored)
		return ignored & (1 << signum) == 1
	}

	/// Sends the specified signal to the currently running process
	@discardableResult fileprivate func signal(_ signum: Int32) -> Int32 {
		return kill(self.processIdentifier, signum)
	}


	/// Terminates the command by sending the SIGTERM signal
	public func terminate() {
		// If the SIGTERM signal is being blocked or ignored by the process,
		// then don't bother sending it
		guard !(isBlockingSignal(SIGTERM) || isIgnoringSignal(SIGTERM)) else { return }

		signal(SIGTERM)
	}

	/// Interrupts the command by sending the SIGINT signal
	public func interrupt() {
		// If the SIGINT signal is being blocked or ignored by the process,
		// then don't bother sending it
		guard !(isBlockingSignal(SIGINT) || isIgnoringSignal(SIGINT)) else { return }

		signal(SIGINT)
	}

	/// Temporarily suspends a command. Call resume() to resume a suspended command
	///
	/// - returns: true if the command was successfully suspended
	@discardableResult public func suspend() -> Bool {
		return signal(SIGTSTP) == 0
	}

	/// Resumes a command previously suspended with suspend().
	///
	/// - returns: true if the command was successfully resumed.
	@discardableResult public func resume() -> Bool {
		return signal(SIGCONT) == 0
	}
}
#endif
#endif
