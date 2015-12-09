/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

public struct LazySplitGenerator <Base: CollectionType where Base.Generator.Element: Equatable, Base.SubSequence: CollectionType,
	Base.SubSequence.Generator.Element==Base.Generator.Element, Base.SubSequence==Base.SubSequence.SubSequence>: GeneratorType {

	private var remaining: Base.SubSequence?
	private let separator: Base.Generator.Element

	public init (base: Base, separator: Base.Generator.Element) {
		self.separator = separator
		self.remaining = base[base.startIndex..<base.endIndex]
	}

	public mutating func next() -> Base.SubSequence? {
		guard let remaining = self.remaining else { return nil }
		let (head,tail) = remaining.splitOnce(separator)
		self.remaining = tail
		return head
	}
}

extension CollectionType where Generator.Element: Equatable {

	public func splitOnce (separator: Generator.Element, allowEmptySlices: Bool = false) -> (head: SubSequence, tail: SubSequence?) {
		guard let nextindex = indexOf(separator) else { return (self[startIndex..<endIndex], nil) }
		return (self[startIndex..<nextindex], self[nextindex.successor()..<endIndex])
	}
}
