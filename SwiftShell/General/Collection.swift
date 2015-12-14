/*
* Released under the MIT License (MIT), http://opensource.org/licenses/MIT
*
* Copyright (c) 2015 Kåre Morstøl, NotTooBad Software (nottoobadsoftware.com)
*
*/

extension CollectionType where Generator.Element: Equatable {

	public func splitOnce (separator: Generator.Element) -> (head: SubSequence, tail: SubSequence?) {
		guard let nextindex = indexOf(separator) else { return (self[startIndex..<endIndex], nil) }
		return (self[startIndex..<nextindex], self[nextindex.successor()..<endIndex])
	}
}


public struct LazySplitSequence <Base: CollectionType where Base.Generator.Element: Equatable,
	Base.SubSequence: CollectionType, Base.SubSequence.Generator.Element==Base.Generator.Element,
	Base.SubSequence==Base.SubSequence.SubSequence>: GeneratorType, LazySequenceType {

	private var remaining: Base.SubSequence?
	private let separator: Base.Generator.Element
	private let allowEmptySlices: Bool

	public init (base: Base, separator: Base.Generator.Element, allowEmptySlices: Bool = false) {
		self.separator = separator
		self.remaining = base[base.startIndex..<base.endIndex]
		self.allowEmptySlices = allowEmptySlices
	}

	public mutating func next () -> Base.SubSequence? {
		guard let remaining = self.remaining else { return nil }
		let (head, tail) = remaining.splitOnce(separator)
		self.remaining = tail
		return (!allowEmptySlices && head.isEmpty) ? next() : head
	}
}

extension LazyCollectionType where Elements.Generator.Element: Equatable, Elements.SubSequence: CollectionType,
	Elements.SubSequence.Generator.Element==Elements.Generator.Element, Elements.SubSequence==Elements.SubSequence.SubSequence {

	public func split (separator: Self.Elements.Generator.Element, allowEmptySlices: Bool = false) -> LazySplitSequence<Self.Elements> {
		return LazySplitSequence(base: self.elements, separator: separator, allowEmptySlices: allowEmptySlices)
	}
}


public struct PartialSourceLazySplitSequence <Base: CollectionType where Base.Generator.Element: Equatable,
	Base.SubSequence: RangeReplaceableCollectionType, Base.SubSequence.Generator.Element==Base.Generator.Element,
	Base.SubSequence==Base.SubSequence.SubSequence>: GeneratorType, LazySequenceType {

	private var gs: LazyMapGenerator<AnyGenerator<Base>, LazySplitSequence<Base>>
	private var g: LazySplitSequence<Base>?

	public init (bases: ()->Base?, separator: Base.Generator.Element) {
		gs = anyGenerator(bases).lazy.map {LazySplitSequence(base: $0, separator: separator, allowEmptySlices: true).generate()} .generate()
	}

	public mutating func next() -> Base.SubSequence? {
		guard let head = g?.next() else {
			guard let nextg = self.gs.next() else { return nil }
			self.g = nextg
			return next()
		}
		if let _ = g?.remaining {
			return head
		} else {
			return head + (next() ?? head[head.startIndex..<head.startIndex])
		}
	}
}
