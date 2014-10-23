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

/**
This file contains operators and functions inspired by Functional Programming.
It can be used on its own.
*/

infix operator |> { precedence 50 associativity left }

public func |> <T,U>(lhs: T, rhs: T -> U) -> U {
	return rhs(lhs)
}

/** Lazily returns a sequence containing the elements of source, in order, that satisfy the predicate includeElement */
public func filter<S : SequenceType> 
	(includeElement: (S.Generator.Element) -> Bool)
	(source: S)
	-> LazySequence<FilterSequenceView<S>> {
		
	return lazy(source).filter(includeElement)
}

/**
Returns an `Array` containing the sorted elements of `source` according to 'isOrderedBefore'. 

Requires: `isOrderedBefore` is a `strict weak ordering 
<http://en.wikipedia.org/wiki/Strict_weak_order#Strict_weak_orderings>` over `elements`.
*/
public func sorted<S : SequenceType>
	(isOrderedBefore: (S.Generator.Element, S.Generator.Element) -> Bool)
	(source: S)
	-> [S.Generator.Element] {
		
	return sorted(source, isOrderedBefore)
}

/** Lazily returns a sequence containing the results of mapping transform over source. */
public func map<S: SequenceType, T>
	(transform: (S.Generator.Element) -> T)
	(source: S)
	-> LazySequence<MapSequenceView<S, T>> {
		
	return lazy(source).map(transform)
}

/** 
Returns the result of repeatedly calling combine with an accumulated value 
initialized to initial and each element of sequence, in turn.
*/
public func reduce<S : SequenceType, U>
	(initial: U, combine: (U, S.Generator.Element) -> U)
	(sequence: S)
	-> U {
		
	return reduce(sequence, initial, combine)
}

/** Splits text over delimiter, returning an array. */
public func split(_ delimiter: String = "\n")(text: String) -> [String] {
	return text.componentsSeparatedByString(delimiter)
}

/** Insert separator between each item in elements. */
public func join<C : ExtensibleCollectionType, S : SequenceType where S.Generator.Element == C>
	(separator: C)
	(elements: S) 
	-> C {
		
	return join(separator, elements)
}

/** Turn a sequence into an array. For use after the |> operator. */
public func toArray <S : SequenceType, T where S.Generator.Element == T>(sequence: S) -> [T] {
	return Array(sequence)
}
