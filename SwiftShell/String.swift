//
// String.swift
// SwiftShell
//
// Created by Kåre Morstøl on 15/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//

import Foundation

extension String {
	
	public func replace(replaceOldString: String, _ withString: String) -> String {
		return self.stringByReplacingOccurrencesOfString(replaceOldString, withString: withString)
	}
	
	public func split(sep: String) -> [String] {
		return self.componentsSeparatedByString(sep)
	}
	
	public func trim() -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}
	
	/** 
	  Splits the string at the first occurrence of separator, and returns a 3-tuple containing the part
 	  before the separator, the separator itself, and the part after the separator. If the separator is 
	  not found, returns a 3-tuple containing the string itself, followed by two empty strings. 
	*/
	public func partition(separator: String) -> (String, String, String) {
		if let separatorRange = self.rangeOfString(separator) {
			if !separatorRange.isEmpty {
				let firstpart = self[self.startIndex ..< separatorRange.startIndex]
				let secondpart = self[separatorRange.endIndex ..< self.endIndex]
				
				return (firstpart, separator, secondpart)
			}
		}
		return (self,"","")
	}
}

