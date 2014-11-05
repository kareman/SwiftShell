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

extension String {

	public func replace (oldString: String, _ newString: String) -> String {
		return self.stringByReplacingOccurrencesOfString(oldString, withString: newString)
	}

	/** Replace the first `limit` occurrences of oldString with newString. */
	public func replace (oldString: String, _ newString: String, limit: Int) -> String {
		let ranges = self.findAll(oldString) |> take(limit)
		return ranges.count == 0
			? self
			: self.stringByReplacingOccurrencesOfString(oldString, withString: newString,
				range: ranges.first!.startIndex ..< ranges.last!.endIndex)
	}

	public func split (sep: String) -> [String] {
		return self.componentsSeparatedByString(sep)
	}

	public func trim () -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}

	public func countOccurrencesOf (substring: String) -> Int {
		return self.split(substring).count - 1
	}

	/** A lazy sequence of the ranges of `findstring` in this string. */
	public func findAll (findstring: String) -> SequenceOf<Range<String.Index>> {
		var rangeofremainder: Range = self.startIndex..<self.endIndex
		return SequenceOf (GeneratorOf {
			if let foundrange = self.rangeOfString(findstring, range:rangeofremainder) {
				rangeofremainder = foundrange.endIndex..<self.endIndex
				return foundrange
			} else {
				return nil
			}
		})
	}

	/**
	Split the string at the first occurrence of separator, and return a 3-tuple containing the part
	before the separator, the separator itself, and the part after the separator. If the separator is
	not found, return a 3-tuple containing the string itself, followed by two empty strings.
	*/
	public func partition (separator: String) -> (String, String, String) {
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

