//
// Released under the MIT License (MIT), http://opensource.org/licenses/MIT
//
// Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
//

extension Collection where Element: Equatable {

	/// Returns everything before the first occurrence of ‘separator’ as 'head', and everything after it as 'tail'.
	/// Including empty sequences if ‘separator’ is first or last.
	///
	/// If ‘separator’ is not found then ‘head’ contains everything and 'tail' is nil.
	func splitOnce(separator: Element) -> (head: SubSequence, tail: SubSequence?) {
		guard let nextindex = index(of: separator) else { return (self[...], nil) }
		return (self[..<nextindex], self[index(after: nextindex)...])
	}
}

/// A sequence from splitting a Collection lazily.
public struct LazySplitSequence <Base: Collection>: IteratorProtocol, LazySequenceProtocol where
	Base.Element: Equatable {
	public fileprivate(set) var remaining: Base.SubSequence?
	public let separator: Base.Element
	public let allowEmptySlices: Bool

	/// Creates a lazy sequence by splitting a Collection repeatedly.
	///
	/// - Parameters:
	///   - base: The Collection to split.
	///   - separator: The element of `base` to split over.
	///   - allowEmptySlices: If there are two or more separators in a row, or `base` begins or ends with 
	///     a separator, should empty slices be emitted? Defaults to false.
	public init(_ base: Base, separator: Base.Element, allowEmptySlices: Bool = false) {
		self.separator = separator
		self.remaining = base[...]
		self.allowEmptySlices = allowEmptySlices
	}

	/// The contents of ‘base’ up to the next occurrence of ‘separator’.
	public mutating func next() -> Base.SubSequence? {
		guard let remaining = self.remaining else { return nil }
		let (head, tail) = remaining.splitOnce(separator: separator)
		self.remaining = tail
		return (!allowEmptySlices && head.isEmpty) ? next() : head
	}
}

extension LazyCollectionProtocol where Elements.Element: Equatable {

	/// Creates a lazy sequence by splitting this Collection repeatedly.
	///
	/// - Parameters:
	///   - separator: The element of this collection to split over.
	///   - allowEmptySlices: If there are two or more separators in a row, or this Collection begins or ends with
	///     a separator, should empty slices be emitted? Defaults to false.
	public func split(
		separator: Elements.Element, allowEmptySlices: Bool = false
		) -> LazySplitSequence<Elements> {

		return LazySplitSequence(self.elements, separator: separator, allowEmptySlices: allowEmptySlices)
	}
}

/// A sequence from splitting a series of Collections lazily, as if they were one Collection.
public struct PartialSourceLazySplitSequence <Base: Collection>: IteratorProtocol, LazySequenceProtocol where
	Base.Element: Equatable,
	Base.SubSequence: RangeReplaceableCollection {

	private var gs: LazyMapIterator<AnyIterator<Base>, LazySplitSequence<Base>>
	private var g: LazySplitSequence<Base>?

	/// Creates a lazy sequence by splitting a series of collections repeatedly, as if they were one collection.
	///
	/// - Parameters:
	///   - bases: A function which returns the next collection in the series each time it is called, 
	///     or nil if there are no more collections.
	///   - separator: The element of ‘bases’ to split over.
	public init(_ bases: @escaping () -> Base?, separator: Base.Element) {
		gs = AnyIterator(bases).lazy.map {
			LazySplitSequence($0, separator: separator, allowEmptySlices: true).makeIterator()
			}.makeIterator()
	}

	/// The contents of ‘bases’ up to the next occurrence of ‘separator’.
	public mutating func next() -> Base.SubSequence? {
		// Requires g handling repeated calls to next() after it is empty.
		// When g.remaining becomes nil there is always one item left in g.
		guard let head = g?.next() else {
			self.g = self.gs.next()
			return self.g == nil ? nil : next()
		}
		if g?.remaining == nil, let next = next() {
			return head + next
		}
		return head
	}
}
