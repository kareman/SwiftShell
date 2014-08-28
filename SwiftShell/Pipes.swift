//
// Pipes.swift
// SwiftShell
//
// Created by Kåre Morstøl on 17/08/14.
// Copyright (c) 2014 NotTooBad Software. All rights reserved.
//


infix operator |> { precedence 50 associativity left }

public func |> <T,U>(lhs: T, rhs: T -> U) -> U {
	return rhs(lhs)
}

/* crashes the compiler (beta 6)
/**
    Sequence |>  (sorted, {<})  

  leads to

    sorted( Sequence, {<})
*/
public func |> <T,U,V>(lhs: T, rhs:((T,V) -> U, V)) -> U {
	return rhs.0(lhs, rhs.1 )
}
*/

/* crashes the compiler (beta 6).
Should replace the function below as it is more general and will also work with strings.

public func |> (lhs: Streamable, inout rhs: OutputStreamType) {
	
	// specifically its these that crash the compiler, not the function definition.
	// lhs.writeTo(&rhs)
	// rhs.write(lhs.)
	// print(lhs, &rhs)
	
}
*/


/**
Prints one stream to another.

	readablestream |> writablestream
*/
public func |> (lhs: ReadableStreamType, rhs: WriteableStreamType) {
	 rhs.write(lhs.read())
}
