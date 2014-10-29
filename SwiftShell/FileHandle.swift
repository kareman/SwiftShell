/*
* Copyright (c) 2014 Kåre Morstøl (NotTooBad Software).
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*
* Contributors:
*	Kåre Morstøl, https://github.com/kareman - initial API and implementation.
*/

import Foundation


public typealias FileHandle = NSFileHandle

extension FileHandle: ReadableStreamType {
	
	public func readSome () -> String? {
		let data: NSData = self.availableData
		if data.length == 0 {
			return nil
		} else {
			return (NSString(data: data, encoding: streamencoding) as String)
		}
	}
	
	public func read () -> String {
		let data: NSData = self.readDataToEndOfFile()
		return NSString(data: data, encoding: streamencoding) as String
	}
	
	public func lines () -> SequenceOf<String> {
		return split(delimiter: "\n")(stream: self)
	}

	public func writeTo <Target : OutputStreamType> (inout target: Target) {
		while let some = self.readSome() {
			target.write(some)
		}
	}
}

extension FileHandle: WriteableStreamType {

	public func write (string: String) {
		writeData(string.dataUsingEncoding(streamencoding, allowLossyConversion:false)!)
	}

	public func writeln (string: String) {
		self.write(string + "\n")
	}

	public func writeln () {
		self.write("\n")
	}
	
	public func closeStream () {
		self.closeFile()
	}
}


public enum FileMode {
	case Read, Write, ReadAndWrite
}

public func open (path: String, mode: FileMode = .Read) -> FileHandle {
	var filehandle: FileHandle?
	switch mode {
		case .Read:
			filehandle = FileHandle(forReadingAtPath: path)
		case .Write:
			filehandle = FileHandle(forWritingAtPath: path)
		case .ReadAndWrite:
			filehandle = FileHandle(forUpdatingAtPath: path)
	}

	// file may be nil if for instance path is invalid
	// TODO: it physically pains me to write the next lines. Proper error handling is forthcoming.
	if filehandle == nil {
		standarderror.write("Error: Opening file \"\(path)\" failed.\n")
		exit(EXIT_FAILURE)
	}

	return filehandle!
}


public let environment		= NSProcessInfo.processInfo().environment as [String: String]
public let standardinput	= FileHandle.fileHandleWithStandardInput() as ReadableStreamType
public let standardoutput	= FileHandle.fileHandleWithStandardOutput() as WriteableStreamType
public let standarderror	= FileHandle.fileHandleWithStandardError() as WriteableStreamType
