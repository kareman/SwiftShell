
import Foundation

extension String {
	
	public func replace(replaceOldString: String, _ withString: String) -> String {
		return self.stringByReplacingOccurrencesOfString(replaceOldString, withString: withString)
	}
	
	// TODO: More arguments. string.split(s[, sep[, maxsplit]])
	public func split(sep: String) -> [String] {
		return self.componentsSeparatedByString(sep)
	}
	
	public func trim() -> String {
		return self.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
	}
	
	/// Split the string at the first occurrence of separator, and return a 3-tuple containing the part before the separator, the separator itself, and the part after the separator. If the separator is not found, return a 3-tuple containing the string itself, followed by two empty strings.
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

