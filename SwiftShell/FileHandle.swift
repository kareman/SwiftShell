//
// FileHandle.swift
// SwiftShell
//
// Created by Kåre Morstøl on 17/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import Foundation


public typealias FileHandle = NSFileHandle

extension FileHandle: ReadableStreamType {
	
	public func readSome() -> String? {
		let data: NSData = self.availableData
		if data.length == 0 {
			return nil
		} else {
			return NSString(data: data, encoding: streamencoding) as String
		}
	}
	
	public func read() -> String {
		let data: NSData = self.readDataToEndOfFile()
		return NSString(data: data, encoding: streamencoding) as String
	}
	
	public func lines() -> SequenceOf <String >{
		return split(delimiter: "\n")(stream: self)
	}

	public func writeTo<Target : OutputStreamType>(inout target: Target) {
		target.write(self.read())
	}

}

extension FileHandle: WriteableStreamType {

	public func write (text: String) {
		writeData(text.dataUsingEncoding(streamencoding, allowLossyConversion:false)!)
	}

	public func closeStream () {
		self.closeFile()
	}
}

public enum FileMode {
	case Read, Write, ReadAndWrite
}

public func open(path: String, mode: FileMode = .Read) -> FileHandle {
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

public let environment = NSProcessInfo.processInfo().environment as [String: String]
public let standardinput = FileHandle.fileHandleWithStandardInput()
public let standardoutput = FileHandle.fileHandleWithStandardOutput()
public let standarderror = FileHandle.fileHandleWithStandardError()
