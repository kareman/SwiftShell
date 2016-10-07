/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

extension Collection where Iterator.Element: Equatable {

	/**
	Return everything before the first occurrence of ‘separator’ as 'head', and everything after it as 'tail'.
	Including empty sequences if ‘separator’ is first or last.

	If ‘separator’ is not found then ‘head’ contains everything and 'tail' is nil.
	*/
	public func splitOnce (separator: Iterator.Element) -> (head: SubSequence, tail: SubSequence?) {
		guard let nextindex = index(of: separator) else { return (self[startIndex..<endIndex], nil) }
		return (self[startIndex..<nextindex], self[index(after: nextindex)..<endIndex])
	}
}


public struct LazySplitSequence <Base: Collection>: IteratorProtocol, LazySequenceProtocol where
	Base.Iterator.Element: Equatable,
	Base.SubSequence: Collection,
	Base.SubSequence.Iterator.Element==Base.Iterator.Element,
	Base.SubSequence==Base.SubSequence.SubSequence {

	fileprivate var remaining: Base.SubSequence?
	private let separator: Base.Generator.Element
	private let allowEmptySlices: Bool

	public init (_ base: Base, separator: Base.Iterator.Element, allowEmptySlices: Bool = false) {
		self.separator = separator
		self.remaining = base[base.startIndex..<base.endIndex]
		self.allowEmptySlices = allowEmptySlices
	}

	public mutating func next () -> Base.SubSequence? {
		guard let remaining = self.remaining else { return nil }
		let (head, tail) = remaining.splitOnce(separator: separator)
		self.remaining = tail
		return (!allowEmptySlices && head.isEmpty) ? next() : head
	}
}

extension LazyCollectionProtocol where Elements.Iterator.Element: Equatable,
	Elements.SubSequence: Collection,
	Elements.SubSequence.Iterator.Element==Elements.Iterator.Element,
	Elements.SubSequence==Elements.SubSequence.SubSequence {

	public func split (
		separator: Elements.Iterator.Element,	allowEmptySlices: Bool = false
		) -> LazySplitSequence<Elements> {

		return LazySplitSequence(self.elements, separator: separator, allowEmptySlices: allowEmptySlices)
	}
}


public struct PartialSourceLazySplitSequence <Base: Collection>: IteratorProtocol, LazySequenceProtocol where
	Base.Iterator.Element: Equatable,
	Base.SubSequence: RangeReplaceableCollection,
	Base.SubSequence.Iterator.Element==Base.Iterator.Element,
	Base.SubSequence==Base.SubSequence.SubSequence {

	private var gs: LazyMapIterator<AnyIterator<Base>, LazySplitSequence<Base>>
	private var g: LazySplitSequence<Base>?

	public init (_ bases: @escaping ()->Base?, separator: Base.Iterator.Element) {
		gs = AnyIterator(bases).lazy.map {
			LazySplitSequence($0, separator: separator, allowEmptySlices: true).makeIterator()
			}.makeIterator()
	}

	public mutating func next() -> Base.SubSequence? {
		// Requires g handling repeated calls to next() after it is empty.
		// When g.remaining becomes nil there is always one item left in g.
		guard let head = g?.next() else {
			self.g = self.gs.next()
			return self.g == nil ? nil : next()
		}
		if g?.remaining == nil, let next = next() {
			return head + next
		} else {
			return head
		}
	}
}
