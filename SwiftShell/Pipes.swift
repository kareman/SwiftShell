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


infix operator |> { precedence 50 associativity left }

public func |> <T,U>(lhs: T, rhs: T -> U) -> U {
	return rhs(lhs)
}

/* crashes the compiler (beta 6)
/**
	Sequence |> (sorted, {<}) 

leads to

	sorted( Sequence, {<})
*/
public func |> <T,U,V>(lhs: T, rhs:((T,V) -> U, V)) -> U {
	return rhs.0(lhs, rhs.1 )
}
*/

/* crashes the compiler (6.1 beta).
Should replace other implementations of "|> (lhs: <whatever>, rhs: WriteableStreamType)" 
as it is more general and will also work with strings.
public func |> (lhs: Streamable, inout rhs: OutputStreamType) {
	
	// specifically it's these that crash the compiler, not the function definition.
	// lhs.writeTo(&rhs)
	// print(lhs, &rhs)
	
}
*/

/**
Writes one stream to another.

	readablestream |> writablestream
*/
public func |> (lhs: ReadableStreamType, rhs: WriteableStreamType) {
	while let some = lhs.readSome() {
		rhs.write(some)
	}
}

/**
Writes something Printable to a writable stream.
*/
public func |> (lhs: Printable, rhs: WriteableStreamType) {
	rhs.write(lhs.description)
}

/**
Writes a String to a writable stream.
*/
public func |> (lhs: String, rhs: WriteableStreamType) {
	rhs.write(lhs)
}
